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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
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
    Center(child: Text("🔍 Discover / Search Screen", style: TextStyle(color: Colors.white, fontSize: 16))),
    Center(child: Text("🎥 Record Video Screen", style: TextStyle(color: Colors.white, fontSize: 16))),
    Center(child: Text("💬 Inbox / Notifications", style: TextStyle(color: Colors.white, fontSize: 16))),
    Center(child: Text("👤 User Profile & Videos Grid", style: TextStyle(color: Colors.white, fontSize: 16))),
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
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(8),
              ),
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

// 1. TikTok Vertical Video Feed
class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<dynamic> videos = [];
  bool isLoading = true;

  final String apiUrl = "https://tiktak-backend.onrender.com/api/videos/feed";

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          videos = data;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.redAccent));
    }

    if (videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text("እስካሁን የተጫነ ቪዲዮ የለም!", style: TextStyle(color: Colors.white, fontSize: 16)),
            SizedBox(height: 8),
            Text("የመጀመሪያውን ቪዲዮ ፖስት አድርግ 🚀", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return VideoCard(data: videos[index]);
      },
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

  @override
  void initState() {
    super.initState();
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
    final user = widget.data['userId'];
    final username = (user is Map && user['username'] != null) ? "@${user['username']}" : "@creator";
    final caption = widget.data['caption'] ?? '';
    final song = widget.data['songName'] ?? 'Original Sound';
    final likesCount = (widget.data['likes'] as List?)?.length ?? 0;

    return Stack(
      children: [
        _controller.value.isInitialized
            ? Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            : Center(child: CircularProgressIndicator(color: Colors.redAccent)),

        // Bottom Left: Username & Caption
        Positioned(
          bottom: 25,
          left: 15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(username, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              SizedBox(height: 6),
              Text(caption, style: TextStyle(color: Colors.white)),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.music_note, size: 15, color: Colors.white),
                  SizedBox(width: 5),
                  Text(song, style: TextStyle(fontSize: 12, color: Colors.white)),
                ],
              ),
            ],
          ),
        ),

        // Right Side: Action Icons (Like, Comment, Share)
        Positioned(
          bottom: 30,
          right: 15,
          child: Column(
            children: [
              Icon(Icons.favorite, color: Colors.redAccent, size: 36),
              Text("$likesCount", style: TextStyle(fontSize: 12, color: Colors.white)),
              SizedBox(height: 18),
              Icon(Icons.comment, color: Colors.white, size: 36),
              Text("0", style: TextStyle(fontSize: 12, color: Colors.white)),
              SizedBox(height: 18),
              Icon(Icons.share, color: Colors.white, size: 36),
              Text("Share", style: TextStyle(fontSize: 12, color: Colors.white)),
            ],
          ),
        )
      ],
    );
  }
}
