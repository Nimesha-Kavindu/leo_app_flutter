const fs = require('fs');
const path = require('path');
const bcrypt = require('bcryptjs');

const usersFilePath = path.join(__dirname, '../../data', 'users.json');

// Helper to read users from file
const getUsers = () => {
      if (!fs.existsSync(usersFilePath)) {
            return [];
      }
      const data = fs.readFileSync(usersFilePath);
      return JSON.parse(data);
};

// Helper to save users to file
const saveUsers = (users) => {
      fs.writeFileSync(usersFilePath, JSON.stringify(users, null, 2));
};

const User = {
      findAll: () => getUsers(),

      findByEmail: (email) => {
            const users = getUsers();
            return users.find(user => user.email === email);
      },

      findById: (id) => {
            const users = getUsers();
            return users.find(user => user.id === id);
      },

      create: async (userData) => {
            const users = getUsers();
            const newUser = {
                  id: Date.now().toString(),
                  username: userData.username,
                  email: userData.email,
                  password: userData.password, // Already hashed in controller
                  createdAt: new Date()
            };
            users.push(newUser);
            saveUsers(users);
            return newUser;
      }
};

module.exports = User;
