const jwt = require('jsonwebtoken');

const authenticateToken = (req, res, next) => {
      const authHeader = req.headers['authorization'];
      const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

      if (!token) {
            return res.status(401).json({ message: 'Access denied. No token provided.' });
      }

      try {
            // Use req.env for Cloudflare Workers, with fallback for dev
            const secret = req.env.JWT_SECRET || 'dev_secret_key_123';
            const decoded = jwt.verify(token, secret);
            req.user = decoded;
            next();
      } catch (error) {
            res.status(403).json({ message: 'Invalid token' });
      }
};

module.exports = authenticateToken;
