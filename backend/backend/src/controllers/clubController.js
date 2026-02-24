// GET /api/clubs?district=<district>
const getClubs = async (req, res) => {
  try {
    const url = new URL(req.url, 'http://localhost');
    const district = url.searchParams.get('district') || null;

    let rows;
    if (district) {
      rows = await req.env.DB.prepare(
        `SELECT c.id, c.name, c.district, c.description, c.avatarUrl,
                (SELECT COUNT(*) FROM club_followers WHERE clubId = c.id) AS followerCount
         FROM clubs c
         WHERE c.district = ?
         ORDER BY c.name ASC`
      ).bind(district).all();
    } else {
      rows = await req.env.DB.prepare(
        `SELECT c.id, c.name, c.district, c.description, c.avatarUrl,
                (SELECT COUNT(*) FROM club_followers WHERE clubId = c.id) AS followerCount
         FROM clubs c
         ORDER BY c.name ASC`
      ).all();
    }

    res.json({ clubs: rows.results });
  } catch (error) {
    console.error('[getClubs]', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// POST /api/clubs/:id/follow
const followClub = async (req, res) => {
  try {
    const clubId = req.params.id;
    const userId = req.user.id;

    const club = await req.env.DB.prepare('SELECT id FROM clubs WHERE id = ?').bind(clubId).first();
    if (!club) return res.status(404).json({ message: 'Club not found' });

    const existing = await req.env.DB.prepare(
      'SELECT id FROM club_followers WHERE clubId = ? AND userId = ?'
    ).bind(clubId, userId).first();

    if (existing) {
      return res.status(409).json({ message: 'Already following' });
    }

    await req.env.DB.prepare(
      'INSERT INTO club_followers (id, clubId, userId, createdAt) VALUES (?, ?, ?, ?)'
    ).bind(globalThis.crypto.randomUUID(), clubId, userId, new Date().toISOString()).run();

    res.status(201).json({ message: 'Following' });
  } catch (error) {
    console.error('[followClub]', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// DELETE /api/clubs/:id/follow
const unfollowClub = async (req, res) => {
  try {
    const clubId = req.params.id;
    const userId = req.user.id;

    await req.env.DB.prepare(
      'DELETE FROM club_followers WHERE clubId = ? AND userId = ?'
    ).bind(clubId, userId).run();

    res.json({ message: 'Unfollowed' });
  } catch (error) {
    console.error('[unfollowClub]', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

module.exports = { getClubs, followClub, unfollowClub };
