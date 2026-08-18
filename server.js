const express = require('express');
const http = require('http');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: '*' } });

app.use(express.json());
app.use(cors());

// MongoDB Connection
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/tiktok_clone';
mongoose.connect(MONGO_URI)
  .then(() => console.log('✅ MongoDB Connected!'))
  .catch((err) => console.error('MongoDB Error:', err));

// Database Schemas
const UserSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  profilePic: { type: String, default: 'https://via.placeholder.com/150' },
  followers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  following: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  createdAt: { type: Date, default: Date.now }
});
const User = mongoose.model('User', UserSchema);

const VideoSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  videoUrl: { type: String, required: true },
  caption: { type: String, default: '' },
  songName: { type: String, default: 'Original Sound' },
  likes: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  createdAt: { type: Date, default: Date.now }
});
const Video = mongoose.model('Video', VideoSchema);

// APIs
app.post('/api/auth/register', async (req, res) => {
  try {
    const { username, email, password } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({ username, email, password: hashedPassword });
    await user.save();
    res.status(201).json({ message: 'User created successfully', userId: user._id });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/videos/feed', async (req, res) => {
  try {
    const videos = await Video.find()
      .populate('userId', 'username profilePic')
      .sort({ createdAt: -1 })
      .limit(20);
    res.json(videos);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/videos/:id/like', async (req, res) => {
  try {
    const { userId } = req.body;
    const video = await Video.findById(req.params.id);
    if (video.likes.includes(userId)) {
      video.likes.pull(userId);
    } else {
      video.likes.push(userId);
    }
    await video.save();
    res.json({ likesCount: video.likes.length });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Socket.io Realtime Events
io.on('connection', (socket) => {
  socket.on('join_user_channel', (userId) => socket.join(`user_${userId}`));
  socket.on('creator_live', ({ creatorId, creatorName }) => {
    socket.broadcast.emit('live_notification', { message: `🔴 ${creatorName} is Live now!` });
  });
});

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => console.log(`🚀 TikTok Server running on port ${PORT}`));
