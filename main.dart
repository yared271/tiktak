import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

void main() => runApp(TikTokApp());

class TikTokApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TikTak',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    FeedScreen(),
    DiscoverScreen(),
    UploadScreen(),
    InboxScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.add, color: Colors.white),
            ),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// 1. HOME / FEED SCREEN
class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<dynamic> videos = [];
  bool isLoading = true;

  final List<Map<String, dynamic>> fallbackVideos = [
    {
      "videoUrl": "https://assets.mixkit.co/videos/preview/mixkit-girl-in-neon-sign-1232-large.mp4",
      "userId": {"username": "yared_official"},
      "caption": "እንኳን ወደ TikTak በደህና መጡ! 🚀 #ethiopia",
      "songName": "Original Sound - Yared",
      "likes": ["1", "2", "3"]
    },
    {
      "videoUrl": "https://assets.mixkit.co/videos/preview/mixkit-young-woman-skater-performing-a-trick-41142-large.mp4",
      "userId": {"username": "habesha_vibes"},
      "caption": "መልካም ቀን ለሁላችሁም! ✨ #tiktak",
      "songName": "Habesha Music",
      "likes": ["1", "2"]
    }
  ];

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    try {
      final response = await http.get(Uri.parse("https://tiktak-backend.onrender.com/api/videos/feed"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          videos = (data is List && data.isNotEmpty) ? data : fallbackVideos;
          isLoading = false;
        });
      } else {
        setState(() { videos = fallbackVideos; isLoading = false; });
      }
    } catch (e) {
      setState(() { videos = fallbackVideos; isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.redAccent));
    }
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: videos.length,
      itemBuilder: (context, index) => VideoCard(data: videos[index]),
    );
  }
}

class VideoCard extends StatefulWidget {
  final Map<String, dynamic> data;
  VideoCard({required this.data});

  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late VideoPlayerController _controller;
  bool isLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    likeCount = (widget.data['likes'] as List?)?.length ?? 0;
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.data['videoUrl'] ?? ''))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.data['userI
