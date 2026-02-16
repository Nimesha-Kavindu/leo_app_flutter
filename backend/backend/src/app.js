const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/authRoutes');

const createApp = (env) => {
      const app = express();

      // Middleware to inject env
      app.use((req, res, next) => {
            req.env = env;
            next();
      });

      // Middleware
      app.use(cors());
      app.use(express.json());

      // Routes
      app.use('/api/auth', authRoutes);

      // Basic route
      app.get('/', (req, res) => {
            res.send('Leo Connect Backend is running on Cloudflare Workers');
      });

      return app;
};

module.exports = createApp;
