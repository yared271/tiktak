import 'package:flutter/material.dart';
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
class FeedScreen extends StatelessWidget {
  final List<Map<String, String>> sampleVideos = [
    {
      "url": "https://assets.mixkit.co/videos/preview/mixkit-girl-in-neon-sign-1232-large.mp4",
      "user": "@solomon_dev",
      "caption": "TikTak MVP Launch! 🚀 #flutter #coding #ethiopia",
      "song": "Original Sound - Solomon",
      "likes": "45.2K",
      "comments": "1.1K"
    },
    {
      "url": "https://assets.mixkit.co/videos/preview/mixkit-young-woman-skater-performing-a-trick-41142-large.mp4",
      "user": "@habesha_vibes",
      "caption": "መልካም ቀን ለሁላችሁም! ✨ #tiktak",
      "song": "Habesha Vibes Track",
      "likes": "18.4K",
      "comments": "530"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: sampleVideos.length,
      itemBuilder: (context, index) {
        return VideoCard(data: sampleVideos[index]);
      },
    );
  }
}

class VideoCard extends StatefulWidget {
  final Map<String, String> data;
  VideoCard({required this.data});

  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.data['url']!))
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
            crossContent: CrossAxisAlignment.start,
            children: [
              Text(widget.data['user']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              SizedBox(height: 6),
              Text(widget.data['caption']!, style: TextStyle(color: Colors.white)),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.music_note, size: 15, color: Colors.white),
                  SizedBox(width: 5),
                  Text(widget.data['song']!, style: TextStyle(fontSize: 12, color: Colors.white)),
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
              Text(widget.data['likes']!, style: TextStyle(fontSize: 12, color: Colors.white)),
              SizedBox(height: 18),
              Icon(Icons.comment, color: Colors.white, size: 36),
              Text(widget.data['comments']!, style: TextStyle(fontSize: 12, color: Colors.white)),
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
