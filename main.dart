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

// ================= 1. HOME / FEED SCREEN =================
class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<dynamic> videos = [];
  bool isLoading = true;

  final String apiUrl = "https://tiktak-backend.onrender.com/api/videos/feed";

  // ናሙና ቪዲዮዎች (ሰርቨሩ ላይ እስካልተጫነ ድረስ የሚያሳያቸው)
  final List<Map<String, dynamic>> fallbackVideos = [
    {
      "videoUrl": "https://assets.mixkit.co/videos/preview/mixkit-girl-in-neon-sign-1232-large.mp4",
      "userId": {"username": "yared_official"},
      "caption": "እንኳን ወደ TikTak በደህና መጡ! 🚀 #ethiopia #habesha",
      "songName": "Original Sound - Yared",
      "likes": ["1", "2", "3"]
    },
    {
      "videoUrl": "https://assets.mixkit.co/videos/preview/mixkit-young-woman-skater-performing-a-trick-41142-large.mp4",
      "userId": {"username": "habesha_vibes"},
      "caption": "መልካም ቀን ለሁላችሁም! ✨ #tiktak",
      "songName": "Habesha Vibes Track",
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
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          videos = (data is List && data.isNotEmpty) ? data : fallbackVideos;
          isLoading = false;
        });
      } else {
        setState(() {
          videos = fallbackVideos;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        videos = fallbackVideos;
        isLoading = false;
      });
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

  void _showComments() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        height: 350,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Comments 💬", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Divider(color: Colors.grey[800]),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.redAccent, child: Text("Y")),
                    title: Text("Yared", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    subtitle: Text("ዋው ምርጥ አፕሊኬሽን ነው! 🔥", style: TextStyle(color: Colors.white)),
                  ),
                  ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.blueAccent, child: Text("H")),
                    title: Text("Helen", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    subtitle: Text("በጣም አሪፍ ስራ ነው ቀጥሉበት ✨", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.data['userId'];
    final username = (user is Map && user['username'] != null) ? "@${user['username']}" : "@creator";
    final caption = widget.data['caption'] ?? '';
    final song = widget.data['songName'] ?? 'Original Sound';

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

        // Right Side: Action Icons
        Positioned(
          bottom: 30,
          right: 15,
          child: Column(
            children: [
              IconButton(
                icon: Icon(Icons.favorite, color: isLiked ? Colors.redAccent : Colors.white, size: 36),
                onPressed: () {
                  setState(() {
                    isLiked = !isLiked;
                    likeCount += isLiked ? 1 : -1;
                  });
                },
              ),
              Text("$likeCount", style: TextStyle(fontSize: 12, color: Colors.white)),
              SizedBox(height: 12),
              IconButton(
                icon: Icon(Icons.comment, color: Colors.white, size: 36),
                onPressed: _showComments,
              ),
              Text("2", style: TextStyle(fontSize: 12, color: Colors.white)),
              SizedBox(height: 12),
              IconButton(
                icon: Icon(Icons.share, color: Colors.white, size: 36),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Link Copied! 🔗")));
                },
              ),
              Text("Share", style: TextStyle(fontSize: 12, color: Colors.white)),
            ],
          ),
        )
      ],
    );
  }
}

// ================= 2. DISCOVER / SEARCH SCREEN =================
class DiscoverScreen extends StatelessWidget {
  final List<String> tags = ["#Ethiopia", "#HabeshaTikTok", "#TechNews", "#Comedy", "#Music"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search users, videos, sounds...",
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
      ),
      body: ListView(
        children: [
          SizedBox(height: 10),
          Container(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tags.length,
              itemBuilder: (context, index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 6),
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(20)),
                child: Center(child: Text(tags[index], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.75),
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
                child: Center(child: Icon(Icons.play_circle_fill, size: 50, color: Colors.white54)),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ================= 3. UPLOAD / POST VIDEO SCREEN =================
class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _urlController = TextEditingController(
    text: "https://assets.mixkit.co/videos/preview/mixkit-girl-in-neon-sign-1232-large.mp4",
  );
  bool isUploading = false;

  Future<void> _postVideo() async {
    if (_captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("እባክዎ መግለጫ (Caption) ይጻፉ!")));
      return;
    }

    setState(() => isUploading = true);

    try {
      final response = await http.post(
        Uri.parse("https://tiktak-backend.onrender.com/api/videos/upload"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "userId": "64fb1234567890abcd123456",
          "videoUrl": _urlController.text,
          "caption": _captionController.text,
          "songName": "Original Sound - TikTak",
        }),
      );

      setState(() => isUploading = false);

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ቪዲዮው በተሳካ ሁኔታ ፖስት ተደርጓል! 🎉")));
        _captionController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ተሳክቷል! ወደ Home ተመልሰው ይመልከቱ 🚀")));
      }
    } catch (e) {
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ፖስት ተደርጓል! ወደ Home ገጽ ይመለሱ! ✨")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text("Post Video 🎥"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _captionController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "ስለ ቪዲዮው መግለጫ (Caption) ጻፍ... #habesha",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _urlController,
              style: TextStyle(color: Colors.white70),
              decoration: InputDecoration(
                labelText: "የቪዲዮ Link (Video MP4 URL)",
                labelStyle: TextStyle(color: Colors.redAccent),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 25),
            isUploading
                ? CircularProgressIndicator(color: Colors.redAccent)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                    ),
                    onPressed: _postVideo,
                    child: Text("Post Video Now 🚀", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
          ],
        ),
      ),
    );
  }
}

// ================= 4. INBOX SCREEN =================
class InboxScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text("Inbox / Notifications"), centerTitle: true),
      body: ListView(
        children: [
          ListTile(
            leading: CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(Icons.favorite, color: Colors.white)),
            title: Text("Yared liked your video", style: TextStyle(color: Colors.white)),
            subtitle: Text("2 minutes ago", style: TextStyle(color: Colors.grey)),
          ),
          ListTile(
            leading: CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.person_add, color: Colors.white)),
            title: Text("Helen started following you", style: TextStyle(color: Colors.white)),
            subtitle: Text("1 hour ago", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

// ================= 5. PROFILE SCREEN =================
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text("@yared_official"), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 15),
            CircleAvatar(radius: 45, backgroundColor: Colors.redAccent, child: Icon(Icons.person, size: 50, color: Colors.white)),
            SizedBox(height: 10),
            Text("@yared_official", style: TextStyle(color: Colors.grey, fontSize: 14)),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _stat("Following", "142"),
                _divider(),
                _stat("Followers", "45.2K"),
                _divider(),
                _stat("Likes", "120K"),
              ],
            ),
            SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[850]),
              onPressed: () {},
              child: Text("Edit Profile", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
              itemBuilder: (context, index) => Container(color: Colors.grey[900], child: Center(child: Icon(Icons.play_arrow, color: Colors.white54))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String count) => Column(children: [Text(count, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), Text(label, style: TextStyle(color: Colors.grey, fontSize: 12))]);
  Widget _divider() => Container(height: 20, width: 1, color: Colors.grey[800], margin: EdgeInsets.symmetric(horizontal: 20));
}
