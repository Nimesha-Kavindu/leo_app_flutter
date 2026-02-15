# Leo App Backend

Express.js backend server for the Leo App Flutter application. Provides RESTful APIs for user authentication, clubs, events, and posts management.

## Project Architecture

```
backend/
├── src/
│   ├── config/       # Database & Environment configuration
│   ├── controllers/  # Route logic and business logic
│   ├── middleware/   # Authentication, file uploads, error handling
│   ├── models/       # Mongoose schemas (matches Dart models)
│   ├── routes/       # API endpoint definitions
│   ├── app.js        # Express app setup & middleware
│   └── server.js     # Entry point & server startup
├── package.json      # Dependencies & scripts
├── .env              # Environment variables (secrets)
├── .gitignore        # Git ignore rules
└── README.md         # This file
```

## Tech Stack

- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** MongoDB with Mongoose
- **Authentication:** JWT (JSON Web Tokens)
- **File Storage:** (Configured in middleware)
- **Environment:** .env configuration

## Setup Instructions

### Prerequisites

- Node.js (v14 or higher)
- npm or yarn
- MongoDB (local or Atlas connection string)

### Installation

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure environment variables:**
   - Create/edit `.env` file in the backend root:
   ```env
   PORT=5000
   MONGODB_URI=mongodb://localhost:27017/leo_app
   NODE_ENV=development
   JWT_SECRET=your_secret_key_here
   ```

4. **Start the server:**
   ```bash
   npm start
   ```
   The server will run on `http://localhost:5000`

### Development

For development with auto-reload:
```bash
npm run dev
```

## Project Structure Details

### `/src/config`
Database connection settings, environment configuration, and constants.

### `/src/models`
Mongoose schemas for:
- User
- Club
- Event
- Post

### `/src/controllers`
Business logic for handling requests:
- User authentication & profile management
- Club CRUD operations
- Event management
- Post creation & interactions

### `/src/routes`
API endpoint definitions organized by resource:
- `/api/auth` - Authentication endpoints
- `/api/users` - User profile endpoints
- `/api/clubs` - Club management
- `/api/events` - Event management
- `/api/posts` - Post management

### `/src/middleware`
- JWT authentication verification
- File upload handlers
- Error handling
- Request validation

### Entry Points
- **server.js** - Starts the Express server and connects to MongoDB
- **app.js** - Configures Express app, middleware, and routes

## Environment Variables

Create a `.env` file with the following:

```env
PORT=5000
MONGODB_URI=<your_mongodb_connection_string>
NODE_ENV=development
JWT_SECRET=<your_jwt_secret_key>
JWT_EXPIRE=7d
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/logout` - Logout user

### Users
- `GET /api/users/:id` - Get user profile
- `PUT /api/users/:id` - Update user profile

### Clubs
- `GET /api/clubs` - List all clubs
- `POST /api/clubs` - Create new club
- `GET /api/clubs/:id` - Get club details
- `PUT /api/clubs/:id` - Update club
- `DELETE /api/clubs/:id` - Delete club

### Events
- `GET /api/events` - List events
- `POST /api/events` - Create event
- `GET /api/events/:id` - Get event details
- `PUT /api/events/:id` - Update event

### Posts
- `GET /api/posts` - Get posts feed
- `POST /api/posts` - Create post
- `GET /api/posts/:id` - Get post details
- `DELETE /api/posts/:id` - Delete post

## Common Scripts

```bash
npm start          # Start production server
npm run dev        # Start development server with nodemon
npm test           # Run tests
```

## Database Models

Mongoose models mirror the Dart data classes:
- User (email, password, profile info)
- Club (name, description, members)
- Event (title, date, location, club)
- Post (content, author, timestamp)

## Error Handling

Centralized error handling middleware catches and formats errors for consistent API responses.

## Security

- JWT-based authentication
- Password hashing
- CORS configuration
- Input validation

## Contributing

1. Create a feature branch
2. Make changes
3. Test thoroughly
4. Submit pull request

## License

Proprietary - Leo App
