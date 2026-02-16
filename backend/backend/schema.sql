DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  username TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  leoId TEXT,
  leoDistrict TEXT,
  clubName TEXT,
  about TEXT,
  avatarUrl TEXT,
  createdAt TEXT NOT NULL
);
