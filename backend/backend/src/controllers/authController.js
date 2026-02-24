const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');

// Field length limits — enforced before any DB access
const LIMITS = {
  username: 30,
  email: 254,
  password: 128,
  leoId: 20,
  leoDistrict: 50,
  clubName: 100,
  about: 500,
};

function validateLength(value, field) {
  if (typeof value === 'string' && value.length > LIMITS[field]) {
    return `${field} must be ${LIMITS[field]} characters or fewer`;
  }
  return null;
}

// Basic email format — must contain @ and a dot after it
function isValidEmail(email) {
  return typeof email === 'string' && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

const register = async (req, res) => {
  try {
    const { username, email, password, leoId, leoDistrict, clubName, about } = req.body;

    // Required field presence
    if (!username || !email || !password || !leoDistrict || !clubName) {
      return res.status(400).json({ message: 'Username, email, password, Leo District, and Club Name are required' });
    }

    // Type checks
    if (typeof username !== 'string' || typeof email !== 'string' || typeof password !== 'string') {
      return res.status(400).json({ message: 'Invalid field types' });
    }

    // Email format
    if (!isValidEmail(email)) {
      return res.status(400).json({ message: 'Invalid email address' });
    }

    // Password minimum length (backend-enforced, not just Flutter)
    if (password.length < 8) {
      return res.status(400).json({ message: 'Password must be at least 8 characters' });
    }

    // Length limits
    for (const [field, value] of Object.entries({ username, email, password, leoId, leoDistrict, clubName, about })) {
      if (value === undefined || value === null) continue;
      const err = validateLength(String(value), field);
      if (err) return res.status(400).json({ message: err });
    }

    const existingUser = await User.findByEmail(req.env, email.toLowerCase().trim());
    if (existingUser) {
      return res.status(409).json({ message: 'An account with that email already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await User.create(req.env, {
      username: username.trim(),
      email: email.toLowerCase().trim(),
      password: hashedPassword,
      leoId: leoId ? leoId.trim() : null,
      leoDistrict: leoDistrict.trim(),
      clubName: clubName.trim(),
      about: about ? about.trim() : null,
    });

    res.status(201).json({ message: 'User created successfully', userId: user.id });
  } catch (error) {
    console.error('[register]', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    if (typeof email !== 'string' || typeof password !== 'string') {
      return res.status(400).json({ message: 'Invalid field types' });
    }

    // Fail fast if JWT_SECRET is not configured — do not silently use a fallback
    const secret = req.env.JWT_SECRET;
    if (!secret) {
      console.error('[login] JWT_SECRET is not set in environment');
      return res.status(500).json({ message: 'Internal server error' });
    }

    const user = await User.findByEmail(req.env, email.toLowerCase().trim());
    if (!user) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const token = jwt.sign(
      { id: user.id, type: 'access' },
      secret,
      { expiresIn: '24h', issuer: 'leoconnect' }
    );

    res.json({
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        leoId: user.leoId,
        leoDistrict: user.leoDistrict,
        clubName: user.clubName,
        about: user.about,
      },
    });
  } catch (error) {
    console.error('[login]', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

const getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.env, req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json({
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        leoId: user.leoId,
        leoDistrict: user.leoDistrict,
        clubName: user.clubName,
        about: user.about,
        avatarUrl: user.avatarUrl || null,
      },
    });
  } catch (error) {
    console.error('[getProfile]', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

const updateProfile = async (req, res) => {
  try {
    // CRIT-02 fix: auth middleware sets req.user, not req.userId
    const userId = req.user.id;
    const { username, about, avatarUrl } = req.body;

    if (!username) {
      return res.status(400).json({ message: 'Username is required' });
    }

    if (typeof username !== 'string') {
      return res.status(400).json({ message: 'Invalid field types' });
    }

    const usernameErr = validateLength(username, 'username');
    if (usernameErr) return res.status(400).json({ message: usernameErr });

    if (about !== undefined && about !== null) {
      const aboutErr = validateLength(String(about), 'about');
      if (aboutErr) return res.status(400).json({ message: aboutErr });
    }

    // CRIT-03: block base64 images — avatarUrl must be a proper URL or null
    if (avatarUrl !== undefined && avatarUrl !== null) {
      if (typeof avatarUrl !== 'string') {
        return res.status(400).json({ message: 'Invalid avatarUrl' });
      }
      if (avatarUrl.startsWith('data:')) {
        return res.status(400).json({ message: 'Base64 images are not accepted. Upload via /api/media/upload and provide the returned URL.' });
      }
      if (!avatarUrl.startsWith('https://')) {
        return res.status(400).json({ message: 'avatarUrl must be a valid HTTPS URL' });
      }
    }

    const updatedUser = await User.updateProfile(req.env, userId, {
      username: username.trim(),
      about: about ? String(about).trim() : null,
      avatarUrl: avatarUrl || null,
    });

    if (!updatedUser) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({
      message: 'Profile updated successfully',
      user: {
        id: updatedUser.id,
        username: updatedUser.username,
        email: updatedUser.email,
        leoId: updatedUser.leoId,
        leoDistrict: updatedUser.leoDistrict,
        clubName: updatedUser.clubName,
        about: updatedUser.about,
        avatarUrl: updatedUser.avatarUrl || null,
      },
    });
  } catch (error) {
    console.error('[updateProfile]', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

module.exports = { register, login, getProfile, updateProfile };
