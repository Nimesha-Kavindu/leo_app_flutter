const crypto = require('crypto');

const User = {
      findAll: async (env) => {
            const { results } = await env.DB.prepare('SELECT * FROM users').all();
            return results;
      },

      findByEmail: async (env, email) => {
            return await env.DB.prepare('SELECT * FROM users WHERE email = ?').bind(email).first();
      },

      findById: async (env, id) => {
            return await env.DB.prepare('SELECT * FROM users WHERE id = ?').bind(id).first();
      },

      create: async (env, userData) => {
            const id = globalThis.crypto.randomUUID();
            const now = new Date().toISOString();

            // Password hashing should be done in controller, here we just insert
            await env.DB.prepare(
                  'INSERT INTO users (id, username, email, password, leoId, leoDistrict, clubName, about, createdAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)'
            ).bind(
                  id,
                  userData.username,
                  userData.email,
                  userData.password,
                  userData.leoId || null,
                  userData.leoDistrict || null,
                  userData.clubName || null,
                  userData.about || null,
                  now
            ).run();

            return {
                  id,
                  username: userData.username,
                  email: userData.email,
                  leoId: userData.leoId,
                  leoDistrict: userData.leoDistrict,
                  clubName: userData.clubName,
                  about: userData.about,
                  createdAt: now
            };
      }
};

module.exports = User;
