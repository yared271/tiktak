import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
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

// Global App State
class AppState {
  static Map<String, String> userProfile = {
    "username": "@yared_official",
    "name": "Yared Nigusse",
    "bio": "🇪🇹 Content Creator | TikTak Star ✨ #Ethiopia",
    "avatar": "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200"
  };

  static List<Map<String, String>> friendsList = [
    {
      "username": "@selam_official",
      "name": "Selam Tesfaye",
      "avatar": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200",
      "lastMsg": "ሰላም ያሬድ! አዲሱ ቪዲዮህ በጣም ያምራል 🔥"
    },
    {
      "username": "@ethiopian_beauty",
      "name": "Helen Berhe",
      "avatar": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200",
      "lastMsg": "ይህን ቪዲዮ እይው እስኪ 🎬"
    }
  ];

  static Set<String> followedUsers = {"@selam_official", "@ethiopian_beauty"};
  
  static Map<String, List<Map<String, dynamic>>> directChats = {
    "@selam_official": [
      {"sender": "@selam_official", "text": "ሰላም ያሬድ! እንዴት ነህ?", "time": "10:30 AM", "isVideo": false},
      {"sender": "@yared_official", "text": "ደህና ነኝ ሰላም! አዲሱን TikTak መተግበሪያ እየሞከርኩት ነው 🚀", "time": "10:32 AM", "isVideo": false}
    ]
  };

  static Map<String, List<Map<String, String>>> commentsDb = {
    "1": [
      {"user": "Dawit", "text": "ዋው ምርጥ የሀበሻ ጭፈራ ነው! 🔥", "time": "5m ago"},
      {"user": "Helen", "text": "አልባሳቱ በጣም ያምራል ✨", "time": "12m ago"}
    ]
  };

  static final List<Map<String, String>> globalMusic = [
    {"name": "🇪🇹 Habesha Traditional Beat", "audioUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"},
    {"name": "🎵 Teddy Afro - Mar Eske Tuwaf", "audioUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4"},
    {"name": "🔥 Rophnan - Gurage Electronic Mix", "audioUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4"},
    {"name": "🌍 The Weeknd - Blinding Lights", "audioUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4"}
  ];

  static List<Map<String, dynamic>> defaultPosts = [
    {
      "id": "1",
      "type": "video",
      "videoUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
      "username": "@ethiopian_beauty",
      "userAvatar": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200",
      "caption": "Ethiopian traditional dance & beauty ✨🇪🇹 #EthiopiaGirl #habesha",
      "songName": "🇪🇹 Tilahun Gessesse - Traditional Beat",
      "likes": 4250,
      "tags": ["ethiopia girl", "ethiopia", "habesha", "dance"]
    },
    {
      "id": "2",
      "type": "video",
      "videoUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
      "username": "@selam_official",
      "userAvatar": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200",
      "caption": "መልካም ቀን ከውቧ አዲስ አበባ 🌸✨ #EthiopiaGirl #HabeshaStyle",
      "songName": "🎵 Teddy Afro - Mar Eske Tuwaf",
      "likes": 8920,
      "tags": ["ethiopia girl", "habesha", "photo", "addis ababa"]
    }
  ];

  static List<Map<String, dynamic>> allPosts = List.from(defaultPosts);
}

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      FeedScreen(),
      DiscoverScreen(),
      RealCameraStudio(onPostComplete: () => setState(() => _currentIndex = 0)),
      InboxScreen(),
      ProfileScreen(onProfileUpdated: () => setState(() {})),
    ];

    return Scaffold(
      body: screens[_currentIndex],
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
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.add, color: Colors.white, size: 20),
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

// ================= 1. FAST FULLSCREEN FEED PLAYER =================
class FeedScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? customPosts;
  FeedScreen({this.customPosts});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    try {
      final response = await http.get(Uri.parse("https://tiktak-backend.onrender.com/api/videos/feed"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final serverPosts = data.map<Map<String, dynamic>>((e) {
            return {
              "id": e["_id"] ?? DateTime.now().millisecondsSinceEpoch.toString(),
              "type": e["type"] ?? "video",
              "videoUrl": e["videoUrl"] ?? "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
              "imageUrl": e["imageUrl"] ?? e["videoUrl"],
              "username": e["userId"] is Map ? "@${e["userId"]["username"]}" : "@yared_creator",
              "userAvatar": "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200",
              "caption": e["caption"] ?? "",
              "songName": e["songName"] ?? "Original Sound",
              "likes": (e["likes"] as List?)?.length ?? 10,
              "tags": (e["caption"] ?? "").toString().toLowerCase().split(' ')
            };
          }).toList();

          setState(() {
            AppState.allPosts = [...serverPosts, ...AppState.defaultPosts];
            posts = widget.customPosts ?? AppState.allPosts;
            isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}

    setState(() {
      posts = widget.customPosts ?? AppState.allPosts;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.redAccent));
    }

    return RefreshIndicator(
      color: Colors.redAccent,
      onRefresh: _loadFeed,
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return TikTokCard(
            key: ValueKey(posts[index]['id'] ?? index),
            post: posts[index],
            onStateChanged: () => setState(() {}),
          );
        },
      ),
    );
  }
}

class TikTokCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final VoidCallback onStateChanged;
  TikTokCard({Key? key, required this.post, required this.onStateChanged}) : super(key: key);

  @override
  _TikTokCardState createState() => _TikTokCardState();
}

class _TikTokCardState extends State<TikTokCard> with SingleTickerProviderStateMixin {
  VideoPlayerController? _mediaController;
  late AnimationController _discAnim;
  bool isLiked = false;
  bool isPlaying = true;
  bool isPhoto = false;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    isPhoto = widget.post['type'] == 'photo' || (widget.post['imageUrl'] != null && widget.post['videoUrl'] == null);

    _discAnim = AnimationController(vsync: this, duration: Duration(seconds: 4))..repeat();

    _initPlayer();
  }

  void _initPlayer() {
    if (isPhoto) return;

    final mediaPath = widget.post['videoUrl'] ?? widget.post['imageUrl'] ?? "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4";

    try {
      if (mediaPath.toString().startsWith("http://") || mediaPath.toString().startsWith("https://")) {
        // የኢንተርኔት ቪዲዮ ከሆነ
        _mediaController = VideoPlayerController.networkUrl(Uri.parse(mediaPath));
      } else {
        // በስልክ ካሜራ/ጋለሪ የተነሳ ፋይል ከሆነ (Local File - ቀዩን ስህተት የሚያጠፋው)
        final cleanPath = mediaPath.toString().replaceFirst("file://", "");
        _mediaController = VideoPlayerController.file(File(cleanPath));
      }

      _mediaController!.initialize().then((_) {
        if (mounted) {
          setState(() {
            isInitialized = true;
          });
          _mediaController!.setVolume(1.0);
          _mediaController!.play();
          _mediaController!.setLooping(true);
        }
      }).catchError((_) {
        if (mounted) {
          _mediaController = VideoPlayerController.networkUrl(
            Uri.parse("https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"),
          )..initialize().then((_) {
              if (mounted) {
                setState(() { isInitialized = true; });
                _mediaController!.setVolume(1.0);
                _mediaController!.play();
                _mediaController!.setLooping(true);
              }
            });
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _mediaController?.dispose();
    _discAnim.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_mediaController == null || !isInitialized) return;
    setState(() {
      if (_mediaController!.value.isPlaying) {
        _mediaController!.pause();
        _discAnim.stop();
        isPlaying = false;
      } else {
        _mediaController!.play();
        _discAnim.repeat();
        isPlaying = true;
      }
    });
  }

  void _toggleFollow() {
    final username = widget.post['username'];
    setState(() {
      if (AppState.followedUsers.contains(username)) {
        AppState.followedUsers.remove(username);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$username Unfollowed")));
      } else {
        AppState.followedUsers.add(username);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$username Following 🎉")));
      }
    });
    widget.onStateChanged();
  }

  Widget _buildPhotoWidget(String path) {
    if (path.startsWith("http://") || path.startsWith("https://")) {
      return Image.network(path, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.black));
    } else {
      final clean = path.replaceFirst("file://", "");
      return Image.file(File(clean), fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.black));
    }
  }

  void _openComments() {
    final postId = widget.post['id'] ?? "1";
    final comments = AppState.commentsDb[postId] ?? [];
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: 420,
              padding: EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${comments.length} Comments", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(icon: Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  Divider(color: Colors.grey[800]),
                  Expanded(
                    child: comments.isEmpty
                      ? Center(child: Text("የመጀመሪያው አስተያየት ሰጪ ይሁኑ! 💬", style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (context, idx) {
                            final c = comments[idx];
                            return ListTile(
                              leading: CircleAvatar(backgroundColor: Colors.redAccent, child: Text(c["user"]![0].toUpperCase())),
                              title: Text(c["user"]!, style: TextStyle(color: Colors.grey, fontSize: 13)),
                              subtitle: Text(c["text"]!, style: TextStyle(color: Colors.white, fontSize: 15)),
                              trailing: Text(c["time"] ?? "now", style: TextStyle(color: Colors.grey, fontSize: 11)),
                            );
                          },
                        ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(25)),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: textController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Add a comment as ${AppState.userProfile['username']}...",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.redAccent),
                          onPressed: () {
                            if (textController.text.trim().isEmpty) return;
                            setModalState(() {
                              comments.insert(0, {
                                "user": AppState.userProfile['username'] ?? "@yared",
                                "text": textController.text.trim(),
                                "time": "Just now"
                              });
                              AppState.commentsDb[postId] = comments;
                            });
                            setState(() {});
                            textController.clear();
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.post['username'] ?? "@creator";
    final isFollowing = AppState.followedUsers.contains(username);
    final postId = widget.post['id'] ?? "1";
    final commentCount = (AppState.commentsDb[postId] ?? []).length;
    final totalLikes = (widget.post['likes'] as int? ?? 10) + (isLiked ? 1 : 0);
    final photoUrl = widget.post['imageUrl'] ?? widget.post['videoUrl'] ?? 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800';

    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isPhoto)
            _buildPhotoWidget(photoUrl)
          else if (isInitialized && _mediaController != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _mediaController!.value.size.width > 0 ? _mediaController!.value.size.width : 400,
                  height: _mediaController!.value.size.height > 0 ? _mediaController!.value.size.height : 800,
                  child: VideoPlayer(_mediaController!),
                ),
              ),
            )
          else
            Center(child: CircularProgressIndicator(color: Colors.redAccent)),

          if (!isPlaying && !isPhoto)
            Center(child: Icon(Icons.play_circle_outline, size: 80, color: Colors.white70)),

          Positioned(
            bottom: 25,
            left: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                SizedBox(height: 6),
                Container(
                  width: MediaQuery.of(context).size.width * 0.72,
                  child: Text(widget.post['caption'] ?? '', style: TextStyle(color: Colors.white, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.music_note, size: 16, color: Colors.white),
                    SizedBox(width: 5),
                    Text(widget.post['songName'] ?? 'Original Sound', style: TextStyle(fontSize: 13, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 25,
            right: 12,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(widget.post['userAvatar'] ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200'),
                    ),
                    Positioned(
                      bottom: -2,
                      child: GestureDetector(
                        onTap: _toggleFollow,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isFollowing ? Colors.grey : Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(isFollowing ? Icons.check : Icons.add, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18),
                IconButton(
                  icon: Icon(Icons.favorite, color: isLiked ? Colors.redAccent : Colors.white, size: 38),
                  onPressed: () => setState(() => isLiked = !isLiked),
                ),
                Text("$totalLikes", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 14),
                IconButton(
                  icon: Icon(Icons.comment, color: Colors.white, size: 36),
                  onPressed: _openComments,
                ),
                Text("$commentCount", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 14),
                IconButton(
                  icon: Icon(Icons.share, color: Colors.white, size: 36),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Link Copied! 🔗"))),
                ),
                Text("Share", style: TextStyle(fontSize: 12, color: Colors.white)),
                SizedBox(height: 18),
                RotationTransition(
                  turns: _discAnim,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                      border: Border.all(color: Colors.white30, width: 6),
                      image: DecorationImage(image: NetworkImage("https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=100"), fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ================= 2. REAL PHONE CAMERA & GALLERY STUDIO =================
class RealCameraStudio extends StatefulWidget {
  final VoidCallback onPostComplete;
  RealCameraStudio({required this.onPostComplete});

  @override
  _RealCameraStudioState createState() => _RealCameraStudioState();
}

class _RealCameraStudioState extends State<RealCameraStudio> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionCtrl = TextEditingController();
  
  Map<String, String> selectedSound = AppState.globalMusic[0];
  XFile? pickedFile;
  bool isVideo = true;

  Future<void> _recordVideoWithCamera() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera, maxDuration: Duration(seconds: 60));
    if (video != null) {
      setState(() { pickedFile = video; isVideo = true; });
      _openPublishModal();
    }
  }

  Future<void> _takePhotoWithCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() { pickedFile = photo; isVideo = false; });
      _openPublishModal();
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      setState(() { pickedFile = file; isVideo = true; });
      _openPublishModal();
    } else {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() { pickedFile = image; isVideo = false; });
        _openPublishModal();
      }
    }
  }

  void _openPublishModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Publish to TikTak 🚀", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            TextField(
              controller: _captionCtrl,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Write caption... #ethiopia #viral #habesha",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.music_note, color: Colors.redAccent, size: 18),
                SizedBox(width: 6),
                Expanded(child: Text(selectedSound["name"]!, style: TextStyle(color: Colors.white70, fontSize: 13), overflow: TextOverflow.ellipsis)),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: Size(double.infinity, 48)),
              onPressed: () async {
                final newPost = {
                  "id": DateTime.now().millisecondsSinceEpoch.toString(),
                  "type": isVideo ? "video" : "photo",
                  "videoUrl": pickedFile?.path ?? "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
                  "imageUrl": pickedFile?.path ?? "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800",
                  "username": AppState.userProfile['username'] ?? "@yared_official",
                  "userAvatar": AppState.userProfile['avatar'] ?? "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200",
                  "caption": _captionCtrl.text.trim().isEmpty ? "My TikTak Post ✨" : _captionCtrl.text.trim(),
                  "songName": selectedSound["name"],
                  "likes": 1,
                  "tags": ["ethiopia", "viral", "habesha"]
                };

                AppState.allPosts.insert(0, newPost);
                
                try {
                  await http.post(
                    Uri.parse("https://tiktak-backend.onrender.com/api/videos/upload"),
                    headers: {"Content-Type": "application/json"},
                    body: json.encode(newPost),
                  );
                } catch (_) {}

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ተጭኗል! ወደ Home ገጽ ተመልሰህ እይ 🎉")));
                widget.onPostComplete();
              },
              child: Text("Post Now 🚀", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text("TikTak Studio 🎬"), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.grey[900],
                  builder: (c) => Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Select Sound 🎵", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Divider(),
                        ...AppState.globalMusic.map((m) => ListTile(
                          leading: Icon(Icons.music_note, color: Colors.redAccent),
                          title: Text(m["name"]!, style: TextStyle(color: Colors.white)),
                          trailing: selectedSound["name"] == m["name"] ? Icon(Icons.check, color: Colors.redAccent) : null,
                          onTap: () {
                            setState(() => selectedSound = m);
                            Navigator.pop(context);
                          },
                        )).toList(),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    Icon(Icons.music_note, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Expanded(child: Text(selectedSound["name"]!, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),

            InkWell(
              onTap: _recordVideoWithCamera,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.redAccent, Colors.deepOrange]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(Icons.videocam_rounded, size: 60, color: Colors.white),
                    SizedBox(height: 10),
                    Text("📹 በካሜራ ቪዲዮ ቅረጽ", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                    Text("የስልክህን ካሜራ ከፍቶ ቪዲዮ ይቀርጻል", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _takePhotoWithCamera,
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        children: [
                          Icon(Icons.camera_alt, size: 36, color: Colors.amber),
                          SizedBox(height: 8),
                          Text("📸 ፎቶ አንሳ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: InkWell(
                    onTap: _pickFromGallery,
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        children: [
                          Icon(Icons.photo_library, size: 36, color: Colors.blueAccent),
                          SizedBox(height: 8),
                          Text("🖼️ ከጋለሪ ምረጥ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ================= 3. DISCOVER SCREEN =================
class DiscoverScreen extends StatefulWidget {
  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> searchResults = AppState.allPosts;
  String selectedTag = "All";

  final List<String> trendingTags = ["All", "Ethiopia Girl", "Habesha", "Dance", "Comedy", "Music", "Fashion"];

  void _filterSearch(String query) {
    setState(() {
      if (query.trim().isEmpty && selectedTag == "All") {
        searchResults = AppState.allPosts;
      } else {
        final q = query.toLowerCase();
        searchResults = AppState.allPosts.where((post) {
          final caption = (post['caption'] ?? '').toString().toLowerCase();
          final username = (post['username'] ?? '').toString().toLowerCase();
          final tags = (post['tags'] as List<dynamic>? ?? []).map((e) => e.toString().toLowerCase()).toList();
          return caption.contains(q) || username.contains(q) || tags.any((t) => t.contains(q));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextField(
          controller: _searchCtrl,
          onChanged: _filterSearch,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search 'Ethiopia girl', 'dance', 'comedy'...",
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.redAccent),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 45,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: trendingTags.length,
              itemBuilder: (context, idx) {
                final tag = trendingTags[idx];
                final isSel = (selectedTag == tag);
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: ChoiceChip(
                    label: Text(tag, style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
                    selected: isSel,
                    selectedColor: Colors.redAccent,
                    backgroundColor: Colors.grey[900],
                    onSelected: (val) {
                      setState(() {
                        selectedTag = tag;
                        _filterSearch(tag == "All" ? "" : tag);
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8),
              itemCount: searchResults.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.72),
              itemBuilder: (context, index) {
                final item = searchResults[index];
                final isPhoto = item['type'] == 'photo';
                final previewUrl = isPhoto ? item['imageUrl'] : 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=500';

                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => Scaffold(body: FeedScreen(customPosts: [item])))),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(previewUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey[900])),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Text(item['caption'] ?? '', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 2),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
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
      appBar: AppBar(backgroundColor: Colors.black, title: Text("Notifications 💬"), centerTitle: true),
      body: ListView(
        children: [
          ListTile(
            leading: CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(Icons.favorite, color: Colors.white)),
            title: Text("@selam_official liked your post", style: TextStyle(color: Colors.white)),
            subtitle: Text("1 minute ago", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

// ================= 5. PROFILE SCREEN =================
class ProfileScreen extends StatefulWidget {
  final VoidCallback onProfileUpdated;
  ProfileScreen({required this.onProfileUpdated});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final followingCount = AppState.followedUsers.length;
    final user = AppState.userProfile;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text(user["name"]!), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 15),
            CircleAvatar(radius: 45, backgroundImage: NetworkImage(user["avatar"]!)),
            SizedBox(height: 10),
            Text(user["username"]!, style: TextStyle(color: Colors.grey, fontSize: 14)),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _stat("Following", "$followingCount"),
                _divider(),
                _stat("Followers", "45.2K"),
                _divider(),
                _stat("Likes", "120K"),
              ],
            ),
            SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(user["bio"]!, textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 13)),
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
