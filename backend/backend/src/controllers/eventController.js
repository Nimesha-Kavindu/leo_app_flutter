const TITLE_MAX = 200;
const DESC_MAX = 2000;
const LOCATION_MAX = 200;

// GET /api/events?clubId=<id>&cursor=<startAt>&limit=20
const getEvents = async (req, res) => {
  try {
    const url = new URL(req.url, 'http://localhost');
    const clubId = url.searchParams.get('clubId') || null;
    const cursor = url.searchParams.get('cursor') || null;
    const limit = Math.min(parseInt(url.searchParams.get('limit') || '20', 10), 50);
    const userId = req.user.id;

    const conditions = [];
    const bindings = [];

    if (clubId) {
      conditions.push('e.clubId = ?');
      bindings.push(clubId);
    }
    if (cursor) {
      conditions.push('e.startAt > ?');
      bindings.push(cursor);
    }

    const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

    bindings.push(userId, limit);

    const rows = await req.env.DB.prepare(
      `SELECT e.id, e.clubId, e.title, e.description, e.location, e.startAt, e.endAt, e.createdAt,
              c.name AS clubName,
              (SELECT COUNT(*) FROM event_attendees WHERE eventId = e.id) AS attendeeCount,
              EXISTS(SELECT 1 FROM event_attendees WHERE eventId = e.id AND userId = ?) AS isAttending
       FROM events e
       LEFT JOIN clubs c ON c.id = e.clubId
       ${whereClause}
       ORDER BY e.startAt ASC
       LIMIT ?`
    ).bind(...bindings).all();

    const events = rows.results.map((r) => ({ ...r, isAttending: r.isAttending === 1 }));
    const nextCursor = events.length === limit ? events[events.length - 1].startAt : null;

    res.json({ events, nextCursor });
  } catch (error) {
    console.error('[getEvents]', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// POST /api/events (club admin only — for now any authenticated user can create)
const createEvent = async (req, res) => {
  try {
    const { clubId, title, description, location, startAt, endAt } = req.body;

    if (!title || typeof title !== 'string' || title.trim().length === 0) {
      return res.status(400).json({ message: 'title is required' });
    }
    if (title.length > TITLE_MAX) {
      return res.status(400).json({ message: `title must be ${TITLE_MAX} characters or fewer` });
    }
    if (!startAt || typeof startAt !== 'string') {
      return res.status(400).json({ message: 'startAt (ISO 8601 date string) is required' });
    }
    if (isNaN(Date.parse(startAt))) {
      return res.status(400).json({ message: 'startAt must be a valid ISO 8601 date string' });
    }
    if (endAt !== undefined && endAt !== null) {
      if (typeof endAt !== 'string' || isNaN(Date.parse(endAt))) {
        return res.status(400).json({ message: 'endAt must be a valid ISO 8601 date string' });
      }
    }
    if (description !== undefined && description !== null) {
      if (typeof description !== 'string') {
        return res.status(400).json({ message: 'Invalid description' });
      }
      if (description.length > DESC_MAX) {
        return res.status(400).json({ message: `description must be ${DESC_MAX} characters or fewer` });
      }
    }
    if (location !== undefined && location !== null) {
      if (typeof location !== 'string' || location.length > LOCATION_MAX) {
        return res.status(400).json({ message: `location must be a string of ${LOCATION_MAX} characters or fewer` });
      }
    }

    if (clubId) {
      const club = await req.env.DB.prepare('SELECT id FROM clubs WHERE id = ?').bind(clubId).first();
      if (!club) return res.status(404).json({ message: 'Club not found' });
    }

    const eventId = globalThis.crypto.randomUUID();
    const now = new Date().toISOString();

    await req.env.DB.prepare(
      `INSERT INTO events (id, clubId, title, description, location, startAt, endAt, createdAt)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`
    ).bind(
      eventId,
      clubId || null,
      title.trim(),
      description ? description.trim() : null,
      location ? location.trim() : null,
      startAt,
      endAt || null,
      now,
    ).run();

    res.status(201).json({
      event: { id: eventId, clubId: clubId || null, title: title.trim(), description: description || null, location: location || null, startAt, endAt: endAt || null, createdAt: now },
    });
  } catch (error) {
    console.error('[createEvent]', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// POST /api/events/:id/rsvp
const rsvpEvent = async (req, res) => {
  try {
    const eventId = req.params.id;
    const userId = req.user.id;

    const event = await req.env.DB.prepare('SELECT id FROM events WHERE id = ?').bind(eventId).first();
    if (!event) return res.status(404).json({ message: 'Event not found' });

    const existing = await req.env.DB.prepare(
      'SELECT id FROM event_attendees WHERE eventId = ? AND userId = ?'
    ).bind(eventId, userId).first();

    if (existing) {
      return res.status(409).json({ message: 'Already attending' });
    }

    await req.env.DB.prepare(
      'INSERT INTO event_attendees (id, eventId, userId, createdAt) VALUES (?, ?, ?, ?)'
    ).bind(globalThis.crypto.randomUUID(), eventId, userId, new Date().toISOString()).run();

    res.status(201).json({ message: 'RSVP confirmed' });
  } catch (error) {
    console.error('[rsvpEvent]', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// DELETE /api/events/:id/rsvp
const cancelRsvp = async (req, res) => {
  try {
    const eventId = req.params.id;
    const userId = req.user.id;

    await req.env.DB.prepare(
      'DELETE FROM event_attendees WHERE eventId = ? AND userId = ?'
    ).bind(eventId, userId).run();

    res.json({ message: 'RSVP cancelled' });
  } catch (error) {
    console.error('[cancelRsvp]', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

module.exports = { getEvents, createEvent, rsvpEvent, cancelRsvp };
