
import { register, login, getProfile } from './controllers/authController';
import authenticateToken from './middleware/authMiddleware';

const createApp = (env) => {
      return async (req, res) => {
            // CORS
            res.setHeader('Access-Control-Allow-Origin', '*');
            res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
            res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

            if (req.method === 'OPTIONS') {
                  res.status(200).send('OK');
                  return;
            }

            const url = new URL(req.url, 'http://localhost'); // dummy base for relative URLs
            const path = url.pathname;

            console.log(`[Router] ${req.method} ${path}`);

            try {
                  if (path === '/api/auth/register' && req.method === 'POST') {
                        await register(req, res);
                  } else if (path === '/api/auth/login' && req.method === 'POST') {
                        await login(req, res);
                  } else if (path === '/api/auth/profile' && req.method === 'GET') {
                        // Middleware wrapper
                        let nextCalled = false;
                        await authenticateToken(req, res, () => { nextCalled = true; });
                        if (nextCalled) {
                              await getProfile(req, res);
                        }
                  } else if (path === '/') {
                        res.status(200).send('Leo App Backend (Lightweight) Works!');
                  } else {
                        res.status(404).json({ message: 'Not Found' });
                  }
            } catch (err) {
                  console.error(err);
                  res.status(500).json({ message: 'Internal Server Error', error: err.message });
            }
      };
};

export default createApp;
