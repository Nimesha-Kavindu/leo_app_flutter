const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');

const register = async (req, res) => {
      try {
            const { username, email, password } = req.body;

            if (!username || !email || !password) {
                  return res.status(400).json({ message: 'All fields are required' });
            }

            const existingUser = User.findByEmail(email);
            if (existingUser) {
                  return res.status(400).json({ message: 'User already exists' });
            }

            const salt = await bcrypt.genSalt(10);
            const hashedPassword = await bcrypt.hash(password, salt);

            const newUser = await User.create({
                  username,
                  email,
                  password: hashedPassword
            });

            res.status(201).json({ message: 'User registered successfully', userId: newUser.id });
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

            const user = User.findByEmail(email);
            if (!user) {
                  return res.status(400).json({ message: 'Invalid credentials' });
            }

            const isMatch = await bcrypt.compare(password, user.password);
            if (!isMatch) {
                  return res.status(400).json({ message: 'Invalid credentials' });
            }

            const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });

            res.json({ token, user: { id: user.id, username: user.username, email: user.email } });
      } catch (error) {
            res.status(500).json({ message: 'Server error', error: error.message });
      }
};

const getProfile = async (req, res) => {
      try {
            const user = User.findById(req.user.id);
            if (!user) {
                  return res.status(404).json({ message: 'User not found' });
            }
            res.json({ id: user.id, username: user.username, email: user.email });
      } catch (error) {
            res.status(500).json({ message: 'Server error', error: error.message });
      }
};

module.exports = { register, login, getProfile };
