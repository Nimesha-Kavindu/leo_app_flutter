const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');

const register = async (req, res) => {
      try {
            const { username, email, password, leoId, leoDistrict, clubName, about } = req.body;

            // Validate required fields
            if (!username || !email || !password || !leoDistrict || !clubName) {
                  return res.status(400).json({ message: 'Username, email, password, Leo District, and Club Name are required' });
            }

            const existingUser = await User.findByEmail(req.env, email);
            if (existingUser) {
                  return res.status(400).json({ message: 'User already exists' });
            }

            const hashedPassword = await bcrypt.hash(password, 10);
            const user = await User.create(req.env, {
                  username,
                  email,
                  password: hashedPassword,
                  leoId: leoId || null,
                  leoDistrict,
                  clubName,
                  about: about || null
            });

            res.status(201).json({ message: 'User created successfully', userId: user.id });
      } catch (error) {
            res.status(500).json({ message: 'Server error', error: error.message });
      }
};


const login = async (req, res) => {
      try {
            const { email, password } = req.body;

            if (!email || !password) {
                  return res.status(400).json({ message: 'All fields are required' });
            }

            const user = await User.findByEmail(req.env, email);
            if (!user) {
                  return res.status(400).json({ message: 'Invalid credentials' });
            }

            const isMatch = await bcrypt.compare(password, user.password);
            if (!isMatch) {
                  return res.status(400).json({ message: 'Invalid credentials' });
            }

            // Use a default secret if env variable is not set (for dev/demo purposes)
            // In production, ALWAYS set JWT_SECRET in wrangler.toml or dashboard
            const secret = req.env.JWT_SECRET || 'dev_secret_key_123';
            const token = jwt.sign({ id: user.id }, secret, { expiresIn: '1h' });

            res.json({ token, user: { id: user.id, username: user.username, email: user.email } });
      } catch (error) {
            console.error(error);
            res.status(500).json({ message: 'Server error', error: error.message });
      }
};

const getProfile = async (req, res) => {
      try {
            const user = await User.findById(req.env, req.user.id);
            if (!user) {
                  return res.status(404).json({ message: 'User not found' });
            }
            // Match the expected format from Flutter ApiService with all Leo fields
            res.json({
                  user: {
                        id: user.id,
                        username: user.username,
                        email: user.email,
                        leoId: user.leoId,
                        leoDistrict: user.leoDistrict,
                        clubName: user.clubName,
                        about: user.about
                  }
            });
      } catch (error) {
            res.status(500).json({ message: 'Server error', error: error.message });
      }
};

const updateProfile = async (req, res) => {
      try {
            const userId = req.userId; // from auth middleware
            const { username, about, avatarUrl } = req.body;

            if (!username) {
                  return res.status(400).json({ message: 'Username is required' });
            }

            const updatedUser = await User.updateProfile(req.env, userId, {
                  username,
                  about,
                  avatarUrl
            });

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
                        avatarUrl: updatedUser.avatarUrl
                  }
            });
      } catch (error) {
            res.status(500).json({ message: 'Server error', error: error.message });
      }
};

module.exports = { register, login, getProfile, updateProfile };
