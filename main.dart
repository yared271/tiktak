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

// Global App State
class AppState {
  static Set<String> followedUsers = {"@selam_official"};
  
  static Map<String, List<Map<String, String>>> commentsDb = {
    "1": [
      {"user": "Dawit", "text": "ዋው ምርጥ የሀበሻ ጭፈራ ነው! 🔥", "time": "5m ago"},
      {"user": "Helen", "text": "አልባሳቱ በጣም ያምራል ✨", "time": "12m ago"}
    ],
    "2": [
      {"user": "Amanuel", "text": "የኢትዮጵያ ውበት ድንቅ ነው 🇪🇹❤️", "time": "2m ago"}
    ]
  };

  static List<Map<String, dynamic>> defaultPosts = [
    {
      "id": "1",
      "type": "video",
      "videoUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
      "username": "@ethiopian_beauty",
      "userAvatar": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200",
      "caption": "Ethiopian traditional dance & beauty ✨🇪🇹 #EthiopiaGirl #habesha #culture",
      "songName": "🇪🇹 Tilahun Gessesse - Traditional Beat",
      "likes": 4250,
      "tags": ["ethiopia girl", "ethiopia", "habesha", "dance", "culture", "beauty"]
    },
    {
      "id": "2",
      "type": "photo",
      "imageUrl": "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800",
      "username": "@selam_official",
      "userAvatar": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200",
      "caption": "መልካም ቀን ከውቧ አዲስ አበባ 🌸✨ #EthiopiaGirl #HabeshaStyle #AddisAbaba",
      "songName": "🎵 Teddy Afro - Mar Eske Tuwaf",
      "likes": 8920,
      "tags": ["ethiopia girl", "ethiopia", "habesha", "photo", "addis ababa", "fashion"]
    },
    {
      "id": "3",
      "type": "video",
      "videoUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
      "username": "@ethio_comedy",
      "userAvatar": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
      "caption": "የዘመኑ ቲክቶከሮች ሲቀወጥ 😂🤣 #comedy #funny #ethiopia",
      "songName": "🎧 Funny Laugh Viral Sound Effect",
      "likes": 12400,
      "tags": ["comedy", "funny", "ethiopia", "viral", "joke"]
    },
    {
      "id": "4",
      "type": "photo",
      "imageUrl": "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800",
      "username": "@habesha_fashion",
      "userAvatar": "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200",
      "caption": "Habesha kemis modern vibes 👗🇪🇹 #EthiopiaGirl #habeshakemis #style",
      "songName": "✨ Aster Aweke - Classic Vibes",
      "likes": 6310,
      "tags": ["ethiopia girl", "fashion", "habeshakemis", "ethiopia", "model"]
    },
    {
      "id": "5",
      "type": "video",
      "videoUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
      "username": "@addis_music",
      "userAvatar": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200",
      "caption": "New Ethiopian Music Challenge 🔥🎶 #music #tiktokchallenge #dance",
      "songName": "🔥 Rophnan - Electronic Gurage Mix",
      "likes": 15800,
      "tags": ["music", "dance", "ethiopia", "rophnan", "challenge"]
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
      UploadScreen(onPostSuccess: () => setState(() => _currentIndex = 0)),
      InboxScreen(),
      ProfileScreen(),
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
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(8),
              ),
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

// ================= 1. HOME FEED SCREEN =================
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
              "type": e["type"] ?? (e["videoUrl"] != null && e["videoUrl"].toString().contains("unsplash") ? "photo" : "video"),
              "videoUrl": e["videoUrl"],
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
  VideoPlayerController? _videoController;
  late AnimationController _discAnim;
  bool isLiked = false;
  bool isPlaying = true;
  bool isPhoto = false;

  @override
  void initState() {
    super.initState();
    isPhoto = widget.post['type'] == 'photo' || widget.post['imageUrl'] != null;

    _discAnim = AnimationController(vsync: this, duration: Duration(seconds: 4))..repeat();

    if (!isPhoto) {
      final url = widget.post['videoUrl'] ?? "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4";
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoController!.play();
            _videoController!.setLooping(true);
          }
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _discAnim.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (isPhoto || _videoController == null) return;
    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
        _discAnim.stop();
        isPlaying = false;
      } else {
        _videoController!.play();
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
                            decoration: InputDecoration(hintText: "Add a comment as @yared...", hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.redAccent),
                          onPressed: () {
                            if (textController.text.trim().isEmpty) return;
                            setModalState(() {
                              comments.insert(0, {
                                "user": "@yared_official",
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
            Image.network(photoUrl, fit: BoxFit.cover)
          else if (_videoController != null && _videoController!.value.isInitialized)
            Center(child: AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!)))
          else
            Center(child: CircularProgressIndicator(color: Colors.redAccent)),

          if (!isPlaying && !isPhoto)
            Center(child: Icon(Icons.play_circle_outline, size: 80, color: Colors.white70)),

          // Bottom Left: User Info & Caption
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

          // Right Side: Follow Avatar, Like, Comment, Share, Sound Disc
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

// ================= 2. REAL SEARCH & DISCOVER SCREEN =================
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
            suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(icon: Icon(Icons.clear, color: Colors.grey), onPressed: () { _searchCtrl.clear(); _filterSearch(""); })
              : null,
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
            child: searchResults.isEmpty
              ? Center(child: Text("ምንም ውጤት አልተገኘም! ሌላ ቃል ይፈልጉ 🔍", style: TextStyle(color: Colors.grey)))
              : GridView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: searchResults.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.72),
                  itemBuilder: (context, index) {
                    final item = searchResults[index];
                    final isPhoto = item['type'] == 'photo';
                    final previewUrl = isPhoto ? item['imageUrl'] : 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=500';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (c) => Scaffold(body: FeedScreen(customPosts: [item]))));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(previewUrl, fit: BoxFit.cover),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black87]),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                                child: Text(isPhoto ? "📸 Photo" : "📹 Video", style: TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              right: 8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['caption'] ?? '', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  SizedBox(height: 4),
                                  Text(item['username'] ?? '', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              ),
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

// ================= 3. UPLOAD / POST SCREEN (ፎቶ/ቪዲዮ + ሙዚቃ መራጭ) =================
class UploadScreen extends StatefulWidget {
  final VoidCallback onPostSuccess;
  UploadScreen({required this.onPostSuccess});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final TextEditingController _captionController = TextEditingController();
  String selectedType = "video";
  String selectedMediaUrl = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4";
  String selectedMusic = "🇪🇹 Habesha Traditional Beat";
  bool isPosting = false;

  final List<Map<String, String>> presets = [
    {"name": "📹 Video 1 (Dance)", "type": "video", "url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"},
    {"name": "📸 Photo (Habesha Girl)", "type": "photo", "url": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800"},
    {"name": "📹 Video 2 (Addis Vibe)", "type": "video", "url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4"},
    {"name": "📸 Photo (Modern Dress)", "type": "photo", "url": "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800"},
  ];

  final List<String> musicLibrary = [
    "🇪🇹 Habesha Traditional Beat",
    "🎵 Teddy Afro - Mar Eske Tuwaf",
    "🔥 Rophnan - Gurage Electronic Mix",
    "🎧 Tilahun Gessesse Classics",
    "✨ Aster Aweke - Vibe Mix",
  ];

  Future<void> _publishPost() async {
    if (_captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("እባክዎ መግለጫ (Caption) ይጻፉ!")));
      return;
    }

    setState(() => isPosting = true);

    final newPost = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "type": selectedType,
      "videoUrl": selectedType == "video" ? selectedMediaUrl : null,
      "imageUrl": selectedType == "photo" ? selectedMediaUrl : null,
      "username": "@yared_official",
      "userAvatar": "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200",
      "caption": _captionController.text.trim(),
      "songName": selectedMusic,
      "likes": 1,
      "tags": _captionController.text.toLowerCase().split(' ')
    };

    AppState.allPosts.insert(0, newPost);

    try {
      await http.post(
        Uri.parse("https://tiktak-backend.onrender.com/api/videos/upload"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(newPost),
      );
    } catch (_) {}

    setState(() => isPosting = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("በተሳካ ሁኔታ ፖስት ተደርጓል! 🎉")));
    _captionController.clear();
    widget.onPostSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text("Create Post 🎨"), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("1. መግለጫ (Caption) ጻፍ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _captionController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "ስለ ፖስቱ ጻፍ... #EthiopiaGirl #habesha #viral",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 18),

            Text("2. የበስተጀርባ ሙዚቃ ምረጥ 🎵", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
              child: DropdownButton<String>(
                value: selectedMusic,
                isExpanded: true,
                dropdownColor: Colors.grey[900],
                underline: SizedBox(),
                items: musicLibrary.map((m) => DropdownMenuItem(value: m, child: Text(m, style: TextStyle(color: Colors.white)))).toList(),
                onChanged: (val) => setState(() => selectedMusic = val!),
              ),
            ),
            SizedBox(height: 18),

            Text("3. የሚጫን ሚዲያ ምረጥ (Video ወይም Photo)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presets.map((p) {
                final isSel = selectedMediaUrl == p["url"];
                return ChoiceChip(
                  label: Text(p["name"]!),
                  selected: isSel,
                  selectedColor: Colors.redAccent,
                  backgroundColor: Colors.grey[900],
                  labelStyle: TextStyle(color: isSel ? Colors.white : Colors.grey),
                  onSelected: (sel) {
                    if (sel) {
                      setState(() {
                        selectedMediaUrl = p["url"]!;
                        selectedType = p["type"]!;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 30),

            Center(
              child: isPosting
                ? CircularProgressIndicator(color: Colors.redAccent)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15)),
                    onPressed: _publishPost,
                    child: Text("Post Now 🚀", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
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
      appBar: AppBar(backgroundColor: Colors.black, title: Text("Notifications 💬"), centerTitle: true),
      body: ListView(
        children: [
          ListTile(
            leading: CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(Icons.favorite, color: Colors.white)),
            title: Text("@selam_official liked your post", style: TextStyle(color: Colors.white)),
            subtitle: Text("1 minute ago", style: TextStyle(color: Colors.grey)),
          ),
          ListTile(
            leading: CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.person_add, color: Colors.white)),
            title: Text("@ethiopian_beauty started following you", style: TextStyle(color: Colors.white)),
            subtitle: Text("10 minutes ago", style: TextStyle(color: Colors.grey)),
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
    final followingCount = AppState.followedUsers.length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text("@yared_official"), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 15),
            CircleAvatar(radius: 45, backgroundColor: Colors.redAccent, child: Icon(Icons.person, size: 50, color: Colors.white)),
            SizedBox(height: 10),
            Text("@yared_official", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
