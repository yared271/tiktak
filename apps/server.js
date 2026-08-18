const express = require('express');
const http = require('http');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('cloudinary').v2;
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: '*' } });

app.use(express.json());
app.use(cors());

// --- 1. ዳታቤዝ ግንኙነት (MongoDB Connection) ---
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/tiktok_clone';
mongoose.connect(MONGO_URI)
  .then(() => console.log('✅ MongoDB ተገናኝቷል!'))
  .catch((err) => console.error('MongoDB Error:', err));

// --- 2. የዳታቤዝ ሞዴሎች (Schemas) ---
const UserSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  profilePic: { type: String, default: 'https://via.placeholder.com/150' },
  bio: { type: String, default: 'Welcome to my TikTok profile!' },
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

const CommentSchema = new mongoose.Schema({
  videoId: { type: mongoose.Schema.Types.ObjectId, ref: 'Video', required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  text: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});
const Comment = mongoose.model('Comment', CommentSchema);

// --- 3. Cloudinary የቪዲዮ ማስቀመጫ ማዋቀሪያ ---
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME || 'sample_cloud',
  api_key: process.env.CLOUDINARY_API_KEY || '123456789',
  api_secret: process.env.CLOUDINARY_API_SECRET || 'abcdefgh',
});

const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: { folder: 'tiktok_clone', resource_type: 'video', format: async () => 'mp4' },
});
const upload = multer({ storage });

// --- 4. API Endpoints ---

// መለያ መክፈቻ
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

// ቪዲዮ መጫኛ
app.post('/api/videos/upload', upload.single('video'), async (req, res) => {
  try {
    const { userId, caption, songName } = req.body;
    const video = new Video({
      userId,
      videoUrl: req.file ? req.file.path : req.body.videoUrl,
      caption,
      songName: songName || 'Original Sound',
    });
    await video.save();
    res.status(201).json({ message: 'Video uploaded!', video });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// For You Feed
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

// Following Feed
app.get('/api/videos/following-feed/:userId', async (req, res) => {
  try {
    const user = await User.findById(req.params.userId);
    if (!user) return res.status(404).json({ error: 'User not found' });
    const videos = await Video.find({ userId: { $in: user.following } })
      .populate('userId', 'username profilePic')
      .sort({ createdAt: -1 });
    res.json(videos);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Like / Unlike
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

// Follow / Unfollow
app.put('/api/users/:id/follow', async (req, res) => {
  try {
    const targetUserId = req.params.id;
    const { currentUserId } = req.body;
    const targetUser = await User.findById(targetUserId);
    const currentUser = await User.findById(currentUserId);

    if (!targetUser.followers.includes(currentUserId)) {
      targetUser.followers.push(currentUserId);
      currentUser.following.push(targetUserId);
      await targetUser.save();
      await currentUser.save();
      res.json({ message: 'Followed' });
    } else {
      targetUser.followers.pull(currentUserId);
      currentUser.following.pull(targetUserId);
      await targetUser.save();
      await currentUser.save();
      res.json({ message: 'Unfollowed' });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Search API
app.get('/api/search', async (req, res) => {
  try {
    const query = req.query.q || '';
    const users = await User.find({ username: { $regex: query, $options: 'i' } }).select('username profilePic');
    const videos = await Video.find({ caption: { $regex: query, $options: 'i' } }).populate('userId', 'username');
    res.json({ users, videos });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- 5. የቀጥታ Socket.io ማሳወቂያዎች እና ኮሜንት ---
io.on('connection', (socket) => {
  socket.on('join_user_channel', (userId) => socket.join(`user_${userId}`));

  socket.on('send_comment', async (data) => {
    const { videoId, userId, text, username } = data;
    const comment = new Comment({ videoId, userId, text });
    await comment.save();
    io.emit(`comments_${videoId}`, { text, username, createdAt: comment.createdAt });
  });

  socket.on('creator_live', ({ creatorId, creatorName }) => {
    socket.broadcast.emit('live_notification', { message: `🔴 ${creatorName} አሁን Live ገብቷል!` });
  });
});

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => console.log(`🚀 TikTok Server running on port ${PORT}`));