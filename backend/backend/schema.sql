-- LeoConnect D1 Schema
-- RULES:
--   - Never use DROP TABLE in this file (destroys production data)
--   - Always use CREATE TABLE IF NOT EXISTS
--   - New columns must use ALTER TABLE ... ADD COLUMN with a default or nullable
--   - Run locally:  bun run db:migrate
--   - Run remotely: bun run db:migrate:remote  (review carefully before running)

CREATE TABLE IF NOT EXISTS users (
  id          TEXT PRIMARY KEY,
  username    TEXT NOT NULL,
  email       TEXT NOT NULL UNIQUE,
  password    TEXT NOT NULL,
  leoId       TEXT,
  leoDistrict TEXT,
  clubName    TEXT,
  about       TEXT,
  avatarUrl   TEXT,
  createdAt   TEXT NOT NULL
);

-- Social graph: who follows whom
CREATE TABLE IF NOT EXISTS follows (
  id          TEXT PRIMARY KEY,
  followerId  TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  followingId TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  createdAt   TEXT NOT NULL,
  UNIQUE (followerId, followingId)
);

-- Posts (photos/text updates)
CREATE TABLE IF NOT EXISTS posts (
  id        TEXT PRIMARY KEY,
  authorId  TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  imageUrl  TEXT,
  caption   TEXT,
  createdAt TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS post_likes (
  id        TEXT PRIMARY KEY,
  postId    TEXT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  userId    TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  createdAt TEXT NOT NULL,
  UNIQUE (postId, userId)
);

CREATE TABLE IF NOT EXISTS post_comments (
  id        TEXT PRIMARY KEY,
  postId    TEXT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  authorId  TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  body      TEXT NOT NULL,
  createdAt TEXT NOT NULL
);

-- Clubs directory
CREATE TABLE IF NOT EXISTS clubs (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  district    TEXT,
  description TEXT,
  avatarUrl   TEXT,
  createdAt   TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS club_followers (
  id        TEXT PRIMARY KEY,
  clubId    TEXT NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
  userId    TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  createdAt TEXT NOT NULL,
  UNIQUE (clubId, userId)
);

-- Events
CREATE TABLE IF NOT EXISTS events (
  id          TEXT PRIMARY KEY,
  clubId      TEXT REFERENCES clubs(id) ON DELETE SET NULL,
  title       TEXT NOT NULL,
  description TEXT,
  location    TEXT,
  startAt     TEXT NOT NULL,
  endAt       TEXT,
  createdAt   TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS event_attendees (
  id        TEXT PRIMARY KEY,
  eventId   TEXT NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  userId    TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  createdAt TEXT NOT NULL,
  UNIQUE (eventId, userId)
);
