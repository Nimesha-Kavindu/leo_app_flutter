
import { register, login, getProfile, updateProfile } from './controllers/authController';
import { getFeed, createPost, likePost, unlikePost, getComments, addComment } from './controllers/postController';
import { getClubs, followClub, unfollowClub } from './controllers/clubController';
import { getEvents, createEvent, rsvpEvent, cancelRsvp } from './controllers/eventController';
import authenticateToken from './middleware/authMiddleware';

// Extract a named segment from a path pattern.
// e.g. matchPath('/api/posts/:id/like', '/api/posts/abc123/like') => { id: 'abc123' }
function matchPath(pattern, actual) {
  const patternParts = pattern.split('/');
  const actualParts = actual.split('/');
  if (patternParts.length !== actualParts.length) return null;
  const params = {};
  for (let i = 0; i < patternParts.length; i++) {
    if (patternParts[i].startsWith(':')) {
      params[patternParts[i].slice(1)] = actualParts[i];
    } else if (patternParts[i] !== actualParts[i]) {
      return null;
    }
  }
  return params;
}

const createApp = (env) => {
  return async (req, res) => {
    // CORS — include all methods used by this API
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    const url = new URL(req.url, 'http://localhost');
    const path = url.pathname;
    const method = req.method;

    // Helper: run auth middleware then a handler
    const withAuth = async (handler) => {
      let nextCalled = false;
      await authenticateToken(req, res, () => { nextCalled = true; });
      if (nextCalled) await handler(req, res);
    };

    // Helper: attach path params to req and run handler
    const withParams = (params, handler) => {
      req.params = params;
      return handler;
    };

    try {
      // Health
      if (path === '/health' || path === '/') {
        res.status(200).send('OK');
        return;
      }

      // Auth routes
      if (path === '/api/auth/register' && method === 'POST') {
        await register(req, res); return;
      }
      if (path === '/api/auth/login' && method === 'POST') {
        await login(req, res); return;
      }
      if (path === '/api/auth/profile' && method === 'GET') {
        await withAuth(getProfile); return;
      }
      if (path === '/api/auth/profile' && method === 'PUT') {
        await withAuth(updateProfile); return;
      }

      // Post feed
      if (path === '/api/posts' && method === 'GET') {
        await withAuth(getFeed); return;
      }
      if (path === '/api/posts' && method === 'POST') {
        await withAuth(createPost); return;
      }

      // Post likes
      let params;
      params = matchPath('/api/posts/:id/like', path);
      if (params) {
        req.params = params;
        if (method === 'POST') { await withAuth(likePost); return; }
        if (method === 'DELETE') { await withAuth(unlikePost); return; }
      }

      // Post comments
      params = matchPath('/api/posts/:id/comments', path);
      if (params) {
        req.params = params;
        if (method === 'GET') { await withAuth(getComments); return; }
        if (method === 'POST') { await withAuth(addComment); return; }
      }

      // Clubs
      if (path === '/api/clubs' && method === 'GET') {
        await withAuth(getClubs); return;
      }

      params = matchPath('/api/clubs/:id/follow', path);
      if (params) {
        req.params = params;
        if (method === 'POST') { await withAuth(followClub); return; }
        if (method === 'DELETE') { await withAuth(unfollowClub); return; }
      }

      // Events
      if (path === '/api/events' && method === 'GET') {
        await withAuth(getEvents); return;
      }
      if (path === '/api/events' && method === 'POST') {
        await withAuth(createEvent); return;
      }

      params = matchPath('/api/events/:id/rsvp', path);
      if (params) {
        req.params = params;
        if (method === 'POST') { await withAuth(rsvpEvent); return; }
        if (method === 'DELETE') { await withAuth(cancelRsvp); return; }
      }

      res.status(404).json({ message: 'Not found' });
    } catch (err) {
      console.error('[router]', err);
      res.status(500).json({ message: 'Internal server error' });
    }
  };
};

export default createApp;
