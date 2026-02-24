const jwt = require('jsonwebtoken');

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer <token>

  if (!token) {
    return res.status(401).json({ message: 'Authentication required' });
  }

  // Fail hard if JWT_SECRET is missing — never use a fallback
  const secret = req.env.JWT_SECRET;
  if (!secret) {
    console.error('[authMiddleware] JWT_SECRET is not set in environment');
    return res.status(500).json({ message: 'Internal server error' });
  }

  try {
    const decoded = jwt.verify(token, secret, { issuer: 'leoconnect' });
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
};

module.exports = authenticateToken;
