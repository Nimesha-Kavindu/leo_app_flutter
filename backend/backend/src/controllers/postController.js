const CAPTION_MAX = 2200;
const IMAGE_URL_MAX = 2048;

// GET /api/posts/feed?cursor=<createdAt>&limit=20
const getFeed = async (req, res) => {
  try {
    const url = new URL(req.url, 'http://localhost');
    const limit = Math.min(parseInt(url.searchParams.get('limit') || '20', 10), 50);
    const cursor = url.searchParams.get('cursor') || null;

    let rows;
    if (cursor) {
      rows = await req.env.DB.prepare(
        `SELECT p.id, p.authorId, p.imageUrl, p.caption, p.createdAt,
                u.username, u.avatarUrl,
                (SELECT COUNT(*) FROM post_likes WHERE postId = p.id) AS likeCount,
                (SELECT COUNT(*) FROM post_comments WHERE postId = p.id) AS commentCount
         FROM posts p
         JOIN users u ON u.id = p.authorId
         WHERE p.createdAt < ?
         ORDER BY p.createdAt DESC
         LIMIT ?`
      ).bind(cursor, limit).all();
    } else {
      rows = await req.env.DB.prepare(
        `SELECT p.id, p.authorId, p.imageUrl, p.caption, p.createdAt,
                u.username, u.avatarUrl,
                (SELECT COUNT(*) FROM post_likes WHERE postId = p.id) AS likeCount,
                (SELECT COUNT(*) FROM post_comments WHERE postId = p.id) AS commentCount
         FROM posts p
         JOIN users u ON u.id = p.authorId
         ORDER BY p.createdAt DESC
         LIMIT ?`
      ).bind(limit).all();
    }

    const posts = rows.results;
    const nextCursor = posts.length === limit ? posts[posts.length - 1].createdAt : null;

    res.json({ posts, nextCursor });
  } catch (error) {
    console.error('[getFeed]', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// POST /api/posts
const createPost = async (req, res) => {
  try {
    const { imageUrl, caption } = req.body;

    if (!imageUrl && !caption) {
      return res.status(400).json({ message: 'A post must have an image or caption' });
    }

    if (imageUrl !== undefined && imageUrl !== null) {
      if (typeof imageUrl !== 'string') {
        return res.status(400).json({ message: 'Invalid imageUrl' });
      }
      if (imageUrl.startsWith('data:')) {
        return res.status(400).json({ message: 'Base64 images are not accepted. Use /api/media/upload.' });
      }
      if (!imageUrl.startsWith('https://')) {
        return res.status(400).json({ message: 'imageUrl must be a valid HTTPS URL' });
      }
      if (imageUrl.length > IMAGE_URL_MAX) {
        return res.status(400).json({ message: 'imageUrl too long' });
      }
    }

    if (caption !== undefined && caption !== null) {
      if (typeof caption !== 'string') {
        return res.status(400).json({ message: 'Invalid caption' });
      }
      if (caption.length > CAPTION_MAX) {
        return res.status(400).json({ message: `Caption must be ${CAPTION_MAX} characters or fewer` });
      }
    }

    const postId = globalThis.crypto.randomUUID();
    const now = new Date().toISOString();

    await req.env.DB.prepare(
      `INSERT INTO posts (id, authorId, imageUrl, caption, createdAt)
       VALUES (?, ?, ?, ?, ?)`
    ).bind(postId, req.user.id, imageUrl || null, caption ? caption.trim() : null, now).run();

    res.status(201).json({
      post: { id: postId, authorId: req.user.id, imageUrl: imageUrl || null, caption: caption || null, createdAt: now },
    });
  } catch (error) {
    console.error('[createPost]', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// POST /api/posts/:id/like
const likePost = async (req, res) => {
  try {
    const postId = req.params.id;
    const userId = req.user.id;

    const post = await req.env.DB.prepare('SELECT id FROM posts WHERE id = ?').bind(postId).first();
    if (!post) return res.status(404).json({ message: 'Post not found' });

    const existing = await req.env.DB.prepare(
      'SELECT id FROM post_likes WHERE postId = ? AND userId = ?'
    ).bind(postId, userId).first();

    if (existing) {
      return res.status(409).json({ message: 'Already liked' });
    }

    await req.env.DB.prepare(
      'INSERT INTO post_likes (id, postId, userId, createdAt) VALUES (?, ?, ?, ?)'
    ).bind(globalThis.crypto.randomUUID(), postId, userId, new Date().toISOString()).run();

    res.status(201).json({ message: 'Liked' });
  } catch (error) {
    console.error('[likePost]', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// DELETE /api/posts/:id/like
const unlikePost = async (req, res) => {
  try {
    const postId = req.params.id;
    const userId = req.user.id;

    await req.env.DB.prepare(
      'DELETE FROM post_likes WHERE postId = ? AND userId = ?'
    ).bind(postId, userId).run();

    res.json({ message: 'Unliked' });
  } catch (error) {
    console.error('[unlikePost]', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// GET /api/posts/:id/comments
const getComments = async (req, res) => {
  try {
    const postId = req.params.id;

    const post = await req.env.DB.prepare('SELECT id FROM posts WHERE id = ?').bind(postId).first();
    if (!post) return res.status(404).json({ message: 'Post not found' });

    const rows = await req.env.DB.prepare(
      `SELECT c.id, c.body, c.createdAt, u.username, u.avatarUrl
       FROM post_comments c
       JOIN users u ON u.id = c.authorId
       WHERE c.postId = ?
       ORDER BY c.createdAt ASC`
    ).bind(postId).all();

    res.json({ comments: rows.results });
  } catch (error) {
    console.error('[getComments]', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// POST /api/posts/:id/comments
const addComment = async (req, res) => {
  try {
    const postId = req.params.id;
    const { body } = req.body;

    if (!body || typeof body !== 'string' || body.trim().length === 0) {
      return res.status(400).json({ message: 'Comment body is required' });
    }
    if (body.length > 1000) {
      return res.status(400).json({ message: 'Comment must be 1000 characters or fewer' });
    }

    const post = await req.env.DB.prepare('SELECT id FROM posts WHERE id = ?').bind(postId).first();
    if (!post) return res.status(404).json({ message: 'Post not found' });

    const commentId = globalThis.crypto.randomUUID();
    const now = new Date().toISOString();

    await req.env.DB.prepare(
      'INSERT INTO post_comments (id, postId, authorId, body, createdAt) VALUES (?, ?, ?, ?, ?)'
    ).bind(commentId, postId, req.user.id, body.trim(), now).run();

    res.status(201).json({ comment: { id: commentId, postId, authorId: req.user.id, body: body.trim(), createdAt: now } });
  } catch (error) {
    console.error('[addComment]', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

module.exports = { getFeed, createPost, likePost, unlikePost, getComments, addComment };
