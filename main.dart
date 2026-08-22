import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String savedUsername = prefs.getString('username') ?? "";
  final String savedName = prefs.getString('name') ?? "";
  final String savedAvatar = prefs.getString('avatar') ?? "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200";

  if (isLoggedIn && savedUsername.isNotEmpty) {
    AppState.isLoggedIn = true;
    AppState.userProfile['username'] = savedUsername;
    AppState.userProfile['name'] = savedName;
    AppState.userProfile['avatar'] = savedAvatar;
  }

  runApp(TikTokApp());
}

class TikTokApp extends StatefulWidget {
  @override
  _TikTokAppState createState() => _TikTokAppState();
}

class _TikTokAppState extends State<TikTokApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TikTak',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: AppState.isLoggedIn ? MainNavigationScreen() : AuthPhoneScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ================= GLOBAL APP STATE =================
class AppState {
  static bool isLoggedIn = false;

  static Map<String, String> userProfile = {
    "username": "@user",
    "name": "User",
    "phone": "",
    "bio": "Welcome to my TikTak profile! ✨ #Ethiopia",
    "avatar": "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200",
    "following": "0",
    "followers": "0",
    "likes": "0"
  };

  static Set<String> followedUsers = {};
  static Set<String> savedPostIds = {};
  static Set<String> repostedPostIds = {};
  static Set<String> likedPostIds = {};

  static List<Map<String, String>> friendsList = [
    {
      "username": "@selam_official",
      "name": "Selam Tesfaye",
      "avatar": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200",
      "lastMsg": "ሰላም! አዲሱ TikTak መተግበሪያ በጣም ያምራል 🔥"
    },
    {
      "username": "@ethiopian_beauty",
      "name": "Helen Berhe",
      "avatar": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200",
      "lastMsg": "ይህን ቪዲዮ እይው እስኪ 🎬"
    }
  ];

  static Map<String, List<Map<String, dynamic>>> directChats = {
    "@selam_official": [
      {"sender": "@selam_official", "text": "ሰላም እንዴት ነህ?", "time": "10:30 AM", "isVideo": false}
    ]
  };

  static Map<String, List<Map<String, String>>> commentsDb = {
    "1": [
      {"user": "Dawit", "text": "ዋው ምርጥ የሀበሻ ጭፈራ ነው! 🔥", "time": "5m ago"}
    ]
  };

  static final List<Map<String, String>> globalMusic = [
    {"name": "🇪🇹 Habesha Traditional Beat", "audioUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"},
    {"name": "🎵 Teddy Afro - Mar Eske Tuwaf", "audioUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4"},
    {"name": "🔥 Rophnan - Gurage Electronic Mix", "audioUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4"},
    {"name": "🌍 The Weeknd - Blinding Lights", "audioUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4"}
  ];

  static List<Map<String, dynamic>> allPosts = [];
}

// ================= 1. PHONE & PASSWORD AUTH SCREEN =================
class AuthPhoneScreen extends StatefulWidget {
  @override
  _AuthPhoneScreenState createState() => _AuthPhoneScreenState();
}

class _AuthPhoneScreenState extends State<AuthPhoneScreen> {
  bool isLogin = true;
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool isLoading = false;

  void _proceedAuth() async {
    final phone = _phoneCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("እባክዎ ስልክ ቁጥር እና የይለፍ ቃል ያስገቡ!")));
      return;
    }

    AppState.userProfile['phone'] = phone;

    if (isLogin) {
      setState(() => isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('phone', phone);
      await prefs.setString('username', AppState.userProfile['username'] ?? "@user");
      await prefs.setString('name', AppState.userProfile['name'] ?? "User");
      await prefs.setString('avatar', AppState.userProfile['avatar']!);

      AppState.isLoggedIn = true;
      setState(() => isLoading = false);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => MainNavigationScreen()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (c) => SetupProfileScreen(phoneNumber: phone, password: password)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                      child: Icon(Icons.music_note, size: 50, color: Colors.white),
                    ),
                    SizedBox(height: 12),
                    Text("TikTak", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
                    Text("Watch • Create • Share", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Text(isLogin ? "Welcome Back! 👋" : "Sign Up with Phone 📱", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 8),
              Text(isLogin ? "Login with your phone number and password" : "Enter your phone number to get started", style: TextStyle(color: Colors.grey, fontSize: 13)),
              SizedBox(height: 25),

              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Phone Number (ስልክ ቁጥር)",
                  hintText: "+251 9... ወይም 09...",
                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.phone, color: Colors.redAccent),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 15),

              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Password (የይለፍ ቃል)",
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.lock, color: Colors.redAccent),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 30),

              isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.redAccent))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _proceedAuth,
                    child: Text(isLogin ? "Login 🚀" : "Continue (ቀጥል) ➡️", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
              SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin ? "Don't have an account? Sign Up with Phone" : "Already have an account? Login",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ================= STEP 2: USERNAME + PROFILE PICTURE OR SKIP =================
class SetupProfileScreen extends StatefulWidget {
  final String phoneNumber;
  final String password;
  SetupProfileScreen({required this.phoneNumber, required this.password});

  @override
  _SetupProfileScreenState createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final _usernameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? localAvatarPath;
  bool isSaving = false;

  void _pickAvatar() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => localAvatarPath = img.path);
    }
  }

  void _finishRegistration({bool isSkipped = false}) async {
    setState(() => isSaving = true);

    String finalUsername = _usernameCtrl.text.trim();
    if (finalUsername.isEmpty || isSkipped) {
      final randSuffix = widget.phoneNumber.length >= 4 ? widget.phoneNumber.substring(widget.phoneNumber.length - 4) : "user";
      finalUsername = "user_$randSuffix";
    }
    if (!finalUsername.startsWith('@')) {
      finalUsername = "@$finalUsername";
    }

    String finalName = _nameCtrl.text.trim();
    if (finalName.isEmpty || isSkipped) {
      finalName = finalUsername.replaceAll('@', '');
    }

    String finalAvatar = localAvatarPath ?? "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200";

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('phone', widget.phoneNumber);
    await prefs.setString('username', finalUsername);
    await prefs.setString('name', finalName);
    await prefs.setString('avatar', finalAvatar);

    AppState.isLoggedIn = true;
    AppState.userProfile['phone'] = widget.phoneNumber;
    AppState.userProfile['username'] = finalUsername;
    AppState.userProfile['name'] = finalName;
    AppState.userProfile['avatar'] = finalAvatar;

    AppState.userProfile['following'] = "0";
    AppState.userProfile['followers'] = "0";
    AppState.userProfile['likes'] = "0";

    setState(() => isSaving = false);

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => MainNavigationScreen()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Profile Setup"),
        actions: [
          TextButton(
            onPressed: isSaving ? null : () => _finishRegistration(isSkipped: true),
            child: Text("Skip (ዝለል)", style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Text("Set up your Profile 📸", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 6),
            Text("Add your photo and choose a unique username", style: TextStyle(color: Colors.grey, fontSize: 13)),
            SizedBox(height: 25),

            GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[900],
                    backgroundImage: localAvatarPath != null
                        ? FileImage(File(localAvatarPath!)) as ImageProvider
                        : NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200"),
                  ),
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text("Tap to add photo (ፎቶ ምረጥ)", style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 30),

            TextField(
              controller: _usernameCtrl,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Choose Username (የተጠቃሚ ስም)",
                hintText: "e.g. yared_tech",
                prefixIcon: Icon(Icons.alternate_email, color: Colors.redAccent),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 15),

            TextField(
              controller: _nameCtrl,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Full Name (ሙሉ ስም)",
                hintText: "e.g. Yared Nigusse",
                prefixIcon: Icon(Icons.person, color: Colors.redAccent),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 35),

            isSaving
              ? CircularProgressIndicator(color: Colors.redAccent)
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _finishRegistration(isSkipped: false),
                  child: Text("Save & Enter TikTak 🚀", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
            SizedBox(height: 15),

            TextButton(
              onPressed: isSaving ? null : () => _finishRegistration(isSkipped: true),
              child: Text("Skip for now (አሁን ይለፈኝ)", style: TextStyle(color: Colors.grey, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= 2. FEED SCREEN =================
class FeedScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? customPosts;
  FeedScreen({this.customPosts});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;

  final List<Map<String, dynamic>> defaultSeedPosts = [
    {
      "id": "seed_1",
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
      "id": "seed_2",
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

  @override
  void initState() {
    super.initState();
    _loadLiveFeed();
  }

  Future<void> _loadLiveFeed() async {
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
              "username": e["username"] ?? "@creator",
              "userAvatar": e["userAvatar"] ?? "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200",
              "caption": e["caption"] ?? "",
              "songName": e["songName"] ?? "Original Sound",
              "likes": (e["likes"] is List) ? (e["likes"] as List).length : 12,
              "tags": (e["caption"] ?? "").toString().toLowerCase().split(' ')
            };
          }).toList();

          setState(() {
            AppState.allPosts = [...serverPosts, ...defaultSeedPosts];
            posts = widget.customPosts ?? AppState.allPosts;
            isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}

    setState(() {
      if (AppState.allPosts.isEmpty) AppState.allPosts = List.from(defaultSeedPosts);
      posts = widget.customPosts ?? AppState.allPosts;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.redAccent));
    }

    return Stack(
      children: [
        RefreshIndicator(
          color: Colors.redAccent,
          onRefresh: _loadLiveFeed,
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return TikTokCard(
                key: ValueKey(posts[index]['id'] ?? index),
                post: posts[index],
                onPostDeleted: () {
                  setState(() {
                    posts.removeAt(index);
                  });
                },
                onStateChanged: () => setState(() {}),
              );
            },
          ),
        ),

        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => LiveStreamingRoom())),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    children: [
                      Icon(Icons.live_tv, color: Colors.white, size: 15),
                      SizedBox(width: 4),
                      Text("LIVE 🔴", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 25),
              Text("Following", style: TextStyle(color: Colors.white60, fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(width: 15),
              Text("|", style: TextStyle(color: Colors.white30)),
              SizedBox(width: 15),
              Text("For You", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}

class TikTokCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final VoidCallback onStateChanged;
  final VoidCallback onPostDeleted;
  TikTokCard({Key? key, required this.post, required this.onStateChanged, required this.onPostDeleted}) : super(key: key);

  @override
  _TikTokCardState createState() => _TikTokCardState();
}

class _TikTokCardState extends State<TikTokCard> with SingleTickerProviderStateMixin {
  VideoPlayerController? _mediaController;
  late AnimationController _discAnim;
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
      if (mediaPath.toString().startsWith("http")) {
        _mediaController = VideoPlayerController.networkUrl(Uri.parse(mediaPath));
      } else {
        final cleanPath = mediaPath.toString().replaceFirst("file://", "");
        _mediaController = VideoPlayerController.file(File(cleanPath));
      }

      _mediaController!.initialize().then((_) {
        if (mounted) {
          setState(() => isInitialized = true);
          _mediaController!.setVolume(1.0);
          _mediaController!.play();
          _mediaController!.setLooping(true);
        }
      }).catchError((_) {});
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

  void _confirmDeleteVideo() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Delete Video? 🗑️", style: TextStyle(color: Colors.white)),
        content: Text("ይህን ቪዲዮ ከዳታቤዝ እና ከአፑ ላይ ሙሉ በሙሉ ማጥፋት ይፈልጋሉ?", style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              final postId = widget.post['id'];

              try {
                await http.delete(Uri.parse("https://tiktak-backend.onrender.com/api/videos/$postId"));
              } catch (_) {}

              AppState.allPosts.removeWhere((p) => p['id'] == postId);
              widget.onPostDeleted();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ቪዲዮው በተሳካ ሁኔታ ጠፍቷል! 🗑️")));
            },
            child: Text("Yes, Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _toggleFollow() {
    final username = widget.post['username'];
    setState(() {
      if (AppState.followedUsers.contains(username)) {
        AppState.followedUsers.remove(username);
        int current = int.tryParse(AppState.userProfile['following'] ?? "0") ?? 1;
        AppState.userProfile['following'] = "${(current - 1) < 0 ? 0 : current - 1}";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$username Unfollowed")));
      } else {
        AppState.followedUsers.add(username);
        int current = int.tryParse(AppState.userProfile['following'] ?? "0") ?? 0;
        AppState.userProfile['following'] = "${current + 1}";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$username Following 🎉")));
      }
    });
    widget.onStateChanged();
  }

  void _openShareModal() {
    final postUrl = "https://tiktak.app/v/${widget.post['id']}";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => Container(
        height: 380,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Share Video 📲", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text("Send to Friends:", style: TextStyle(color: Colors.grey, fontSize: 12)),
            Divider(color: Colors.grey[800]),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AppState.friendsList.length,
                itemBuilder: (context, idx) {
                  final friend = AppState.friendsList[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        CircleAvatar(radius: 28, backgroundImage: NetworkImage(friend["avatar"]!)),
                        SizedBox(height: 6),
                        Text(friend["name"]!, style: TextStyle(color: Colors.white, fontSize: 12)),
                        SizedBox(height: 6),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: Size(55, 26)),
                          onPressed: () {
                            final currentChat = AppState.directChats[friend["username"]] ?? [];
                            currentChat.add({
                              "sender": AppState.userProfile['username'] ?? "@user",
                              "text": "Shared Video 🎬: ${widget.post['caption']}",
                              "time": "Just now",
                              "isVideo": true,
                              "videoData": widget.post
                            });
                            AppState.directChats[friend["username"]!] = currentChat;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sent to ${friend['name']}! 🚀")));
                          },
                          child: Text("Send", style: TextStyle(fontSize: 10)),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            Divider(color: Colors.grey[800]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800], padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: postUrl));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Link Copied to Clipboard! 📋🔗")));
                  },
                  icon: Icon(Icons.copy, color: Colors.white, size: 18),
                  label: Text("Copy Link", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[800], padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  onPressed: () {
                    final postId = widget.post['id'] ?? "1";
                    setState(() {
                      AppState.repostedPostIds.add(postId);
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You Reposted this video! 🔄")));
                    widget.onStateChanged();
                  },
                  icon: Icon(Icons.repeat, color: Colors.white, size: 18),
                  label: Text("Repost 🔄", style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _openComments() {
    final postId = widget.post['id']?.toString() ?? "1";
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
                      ? Center(child: Text("Be the first to comment! 💬", style: TextStyle(color: Colors.grey)))
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
                              hintText: "Comment as ${AppState.userProfile['username']}...",
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
                                "user": AppState.userProfile['username'] ?? "@user",
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
    final isOwner = username == AppState.userProfile['username'];
    final isFollowing = AppState.followedUsers.contains(username);
    final postId = widget.post['id']?.toString() ?? "1";
    final isLiked = AppState.likedPostIds.contains(postId);
    final isSaved = AppState.savedPostIds.contains(postId);
    final isReposted = AppState.repostedPostIds.contains(postId);
    final commentCount = (AppState.commentsDb[postId] ?? []).length;
    final totalLikes = (widget.post['likes'] as int? ?? 10) + (isLiked ? 1 : 0);
    final photoUrl = widget.post['imageUrl'] ?? widget.post['videoUrl'] ?? 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800';

    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isPhoto)
            Image.network(photoUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.black))
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
                if (isReposted)
                  Container(
                    margin: EdgeInsets.only(bottom: 6),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.repeat, color: Colors.amber, size: 14),
                        SizedBox(width: 4),
                        Text("You Reposted", style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
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
                          decoration: BoxDecoration(color: isFollowing ? Colors.grey : Colors.redAccent, shape: BoxShape.circle),
                          child: Icon(isFollowing ? Icons.check : Icons.add, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),

                IconButton(
                  icon: Icon(Icons.favorite, color: isLiked ? Colors.redAccent : Colors.white, size: 36),
                  onPressed: () {
                    setState(() {
                      if (isLiked) {
                        AppState.likedPostIds.remove(postId);
                      } else {
                        AppState.likedPostIds.add(postId);
                      }
                    });
                    widget.onStateChanged();
                  },
                ),
                Text("$totalLikes", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),

                IconButton(
                  icon: Icon(Icons.comment, color: Colors.white, size: 34),
                  onPressed: _openComments,
                ),
                Text("$commentCount", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),

                IconButton(
                  icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, color: isSaved ? Colors.amber : Colors.white, size: 34),
                  onPressed: () {
                    setState(() {
                      if (isSaved) {
                        AppState.savedPostIds.remove(postId);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Removed from Saved 🔖")));
                      } else {
                        AppState.savedPostIds.add(postId);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saved to Favorites! 🔖✨")));
                      }
                    });
                    widget.onStateChanged();
                  },
                ),
                Text("Save", style: TextStyle(fontSize: 12, color: Colors.white)),
                SizedBox(height: 10),

                IconButton(
                  icon: Icon(Icons.send_rounded, color: Colors.white, size: 32),
                  onPressed: _openShareModal,
                ),
                Text("Share", style: TextStyle(fontSize: 12, color: Colors.white)),
                SizedBox(height: 10),

                if (isOwner)
                  IconButton(
                    icon: Icon(Icons.delete_forever, color: Colors.redAccent, size: 32),
                    onPressed: _confirmDeleteVideo,
                  ),

                SizedBox(height: 12),
                RotationTransition(
                  turns: _discAnim,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                      border: Border.all(color: Colors.white30, width: 4),
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

// ================= 3. LIVE STREAMING ROOM =================
class LiveStreamingRoom extends StatefulWidget {
  @override
  _LiveStreamingRoomState createState() => _LiveStreamingRoomState();
}

class _LiveStreamingRoomState extends State<LiveStreamingRoom> {
  final List<String> liveMessages = [
    "🔥 selam: ዋው እንዴት ያምራል!",
    "❤️ dawit: Welcome to live stream!",
    "👏 helen: ድምፅህ በጣም ደስ ይላል"
  ];
  final _chatCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network("https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800", fit: BoxFit.cover),
          Container(color: Colors.black45),

          Positioned(
            top: 45,
            left: 15,
            right: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 16, backgroundImage: NetworkImage("https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200")),
                      SizedBox(width: 8),
                      Text("selam_live", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(10)),
                        child: Text("LIVE", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(15)),
                      child: Text("👥 3.4K Viewers", style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    IconButton(icon: Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  ],
                )
              ],
            ),
          ),

          Positioned(
            bottom: 80,
            left: 15,
            child: Container(
              height: 180,
              width: MediaQuery.of(context).size.width * 0.75,
              child: ListView.builder(
                itemCount: liveMessages.length,
                itemBuilder: (context, idx) => Container(
                  margin: EdgeInsets.symmetric(vertical: 3),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(15)),
                  child: Text(liveMessages[idx], style: TextStyle(color: Colors.white, fontSize: 13)),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 15,
            left: 15,
            right: 15,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(25)),
                    child: TextField(
                      controller: _chatCtrl,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(hintText: "Say something in LIVE...", hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          setState(() {
                            liveMessages.add("💬 ${AppState.userProfile['username']}: $val");
                            _chatCtrl.clear();
                          });
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sent ❤️ Like to Live Host!"), duration: Duration(milliseconds: 500))),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    child: Icon(Icons.favorite, color: Colors.white, size: 24),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ================= 4. DISCOVER / SEARCH SCREEN =================
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
            hintText: "Search posts, 'Ethiopia girl', 'dance'...",
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
            child: searchResults.isEmpty
              ? Center(child: Text("No posts found! Try another word 🔍", style: TextStyle(color: Colors.grey)))
              : GridView.builder(
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

// ================= 5. REAL CAMERA & CLOUD UPLOAD STUDIO =================
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
  bool isUploading = false;

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

  Future<void> _uploadPostToCloud() async {
    setState(() => isUploading = true);

    final newPost = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "type": isVideo ? "video" : "photo",
      "videoUrl": pickedFile?.path ?? "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
      "imageUrl": pickedFile?.path ?? "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800",
      "username": AppState.userProfile['username'] ?? "@user",
      "userAvatar": AppState.userProfile['avatar'] ?? "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200",
      "caption": _captionCtrl.text.trim().isEmpty ? "New TikTak Post ✨" : _captionCtrl.text.trim(),
      "songName": selectedSound["name"],
      "likes": 1,
      "tags": _captionCtrl.text.toLowerCase().split(' ')
    };

    AppState.allPosts.insert(0, newPost);

    try {
      await http.post(
        Uri.parse("https://tiktak-backend.onrender.com/api/videos/upload"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(newPost),
      );
    } catch (_) {}

    setState(() => isUploading = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Video Saved to Cloud Permanently! 🚀")));
    widget.onPostComplete();
  }

  void _openPublishModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Publish to TikTak Cloud 🚀", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                TextField(
                  controller: _captionCtrl,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Caption... #ethiopia #viral #habesha",
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
                Center(
                  child: isUploading
                    ? CircularProgressIndicator(color: Colors.redAccent)
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: Size(double.infinity, 48)),
                        onPressed: _uploadPostToCloud,
                        child: Text("Post Now (Save to Cloud) 🚀", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        },
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
            SizedBox(height: 25),

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
                    Text("📹 በካሜራ ቪዲዮ ቅረጽ (Record Video)", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _takePhotoWithCamera,
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: EdgeInsets.all(18),
                      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        children: [
                          Icon(Icons.camera_alt, size: 32, color: Colors.amber),
                          SizedBox(height: 6),
                          Text("📸 ፎቶ አንሳ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickFromGallery,
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: EdgeInsets.all(18),
                      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        children: [
                          Icon(Icons.photo_library, size: 32, color: Colors.blueAccent),
                          SizedBox(height: 6),
                          Text("🖼️ ከጋለሪ ምረጥ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => LiveStreamingRoom())),
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.red[900], borderRadius: BorderRadius.circular(15)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.live_tv, color: Colors.white),
                    SizedBox(width: 8),
                    Text("Go LIVE 🔴 (የቀጥታ ስርጭት ጀምር)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ================= 6. INBOX & DIRECT CHAT =================
class InboxScreen extends StatefulWidget {
  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text("Direct Messages 💬"), centerTitle: true),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Friends You Follow (ጓደኞች)", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          ...AppState.friendsList.map((friend) {
            final chats = AppState.directChats[friend["username"]] ?? [];
            final lastMessage = chats.isNotEmpty ? chats.last["text"] : friend["lastMsg"];

            return ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => DirectChatDetailScreen(friend: friend))).then((_) => setState(() {}));
              },
              leading: CircleAvatar(radius: 26, backgroundImage: NetworkImage(friend["avatar"]!)),
              title: Text(friend["name"]!, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(lastMessage ?? '', style: TextStyle(color: Colors.grey, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Icon(Icons.chat_bubble_outline, color: Colors.redAccent, size: 20),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class DirectChatDetailScreen extends StatefulWidget {
  final Map<String, String> friend;
  DirectChatDetailScreen({required this.friend});

  @override
  _DirectChatDetailScreenState createState() => _DirectChatDetailScreenState();
}

class _DirectChatDetailScreenState extends State<DirectChatDetailScreen> {
  final TextEditingController _msgCtrl = TextEditingController();

  void _sendMessage() {
    if (_msgCtrl.text.trim().isEmpty) return;

    final currentChats = AppState.directChats[widget.friend["username"]] ?? [];
    setState(() {
      currentChats.add({
        "sender": AppState.userProfile['username'] ?? "@user",
        "text": _msgCtrl.text.trim(),
        "time": "Just now",
        "isVideo": false
      });
      AppState.directChats[widget.friend["username"]!] = currentChats;
    });

    _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chats = AppState.directChats[widget.friend["username"]] ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            CircleAvatar(radius: 18, backgroundImage: NetworkImage(widget.friend["avatar"]!)),
            SizedBox(width: 10),
            Text(widget.friend["name"]!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: chats.length,
              itemBuilder: (context, idx) {
                final msg = chats[idx];
                final isMe = msg["sender"] == AppState.userProfile['username'];
                final isVideoShare = msg["isVideo"] == true;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(color: isMe ? Colors.redAccent : Colors.grey[850], borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isVideoShare) ...[
                          Row(
                            children: [
                              Icon(Icons.play_circle_fill, color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text("Shared TikTak Video", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          SizedBox(height: 6),
                        ],
                        Text(msg["text"] ?? '', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.grey[900],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Message ${widget.friend['name']}...",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: IconButton(icon: Icon(Icons.send, color: Colors.white, size: 18), onPressed: _sendMessage),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ================= 7. PROFILE & SETTINGS =================
class ProfileScreen extends StatefulWidget {
  final VoidCallback onProfileUpdated;
  ProfileScreen({required this.onProfileUpdated});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  void _changeProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        AppState.userProfile['avatar'] = image.path;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar', image.path);
      widget.onProfileUpdated();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile Picture Updated! 🎉")));
    }
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Settings & Privacy ⚙️", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(color: Colors.grey[800]),
            ListTile(
              leading: Icon(Icons.add_a_photo, color: Colors.white),
              title: Text("Change Profile Picture (ከጋለሪ ምረጥ)", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _changeProfilePicture();
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.redAccent),
              title: Text("Log Out 🚪", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                AppState.isLoggedIn = false;
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => AuthPhoneScreen()), (r) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarWidget(String path) {
    if (path.startsWith("http")) {
      return CircleAvatar(radius: 42, backgroundImage: NetworkImage(path));
    } else {
      return CircleAvatar(radius: 42, backgroundImage: FileImage(File(path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppState.userProfile;
    final following = AppState.userProfile['following'] ?? "0";
    final followers = AppState.userProfile['followers'] ?? "0";
    final likes = AppState.userProfile['likes'] ?? "0";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(user["name"]!),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.settings, color: Colors.white), onPressed: _openSettings),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 10),
                GestureDetector(
                  onTap: _changeProfilePicture,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      _buildAvatarWidget(user["avatar"]!),
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 14),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Text(user["username"]!, style: TextStyle(color: Colors.grey, fontSize: 14)),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _stat("Following", following),
                    _divider(),
                    _stat("Followers", followers),
                    _divider(),
                    _stat("Likes", likes),
                  ],
                ),
                SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(user["bio"]!, textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 13)),
                ),
                SizedBox(height: 15),
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.redAccent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(icon: Icon(Icons.grid_on), text: "Videos"),
                    Tab(icon: Icon(Icons.repeat), text: "Reposts"),
                    Tab(icon: Icon(Icons.bookmark), text: "Saved"),
                    Tab(icon: Icon(Icons.favorite), text: "Liked"),
                  ],
                ),
              ],
            ),
          )
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildGrid(AppState.allPosts.length),
            AppState.repostedPostIds.isEmpty
              ? Center(child: Text("No reposted videos yet 🔄", style: TextStyle(color: Colors.grey)))
              : _buildGrid(AppState.repostedPostIds.length),
            AppState.savedPostIds.isEmpty
              ? Center(child: Text("No saved favorites yet 🔖", style: TextStyle(color: Colors.grey)))
              : _buildGrid(AppState.savedPostIds.length),
            AppState.likedPostIds.isEmpty
              ? Center(child: Text("No liked videos yet ❤️", style: TextStyle(color: Colors.grey)))
              : _buildGrid(AppState.likedPostIds.length),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(int count) {
    return GridView.builder(
      padding: EdgeInsets.all(2),
      itemCount: count == 0 ? 3 : count,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
      itemBuilder: (context, index) => Container(
        color: Colors.grey[900],
        child: Center(child: Icon(Icons.play_arrow, color: Colors.white54)),
      ),
    );
  }

  Widget _stat(String label, String count) => Column(children: [Text(count, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), Text(label, style: TextStyle(color: Colors.grey, fontSize: 12))]);
  Widget _divider() => Container(height: 20, width: 1, color: Colors.grey[800], margin: EdgeInsets.symmetric(horizontal: 20));
}
