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

// ================= GLOBAL APP STATE =================
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
    },
    {
      "username": "@ethio_comedy",
      "name": "Dawit Comedy",
      "avatar": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
      "lastMsg": "😂😂 በጣም ያስቃል!"
    }
  ];

  static Set<String> followedUsers = {"@selam_official", "@ethiopian_beauty", "@ethio_comedy"};
  
  static Map<String, List<Map<String, dynamic>>> directChats = {
    "@selam_official": [
      {"sender": "@selam_official", "text": "ሰላም ያሬድ! እንዴት ነህ?", "time": "10:30 AM", "isVideo": false},
      {"sender": "@yared_official", "text": "ደህና ነኝ ሰላም! አዲሱን TikTak መተግበሪያ እየሞከርኩት ነው 🚀", "time": "10:32 AM", "isVideo": false}
    ],
    "@ethiopian_beauty": [
      {"sender": "@ethiopian_beauty", "text": "መልካም ቀን ለሁላችንም 🇪🇹", "time": "Yesterday", "isVideo": false}
    ],
    "@ethio_comedy": [
      {"sender": "@ethio_comedy", "text": "አዲሱን ኮሜዲ ቪዲዮ አይተኸዋል?", "time": "Yesterday", "isVideo": false}
    ]
  };

  static Map<String, List<Map<String, String>>> commentsDb = {
    "1": [
      {"user": "Dawit", "text": "ዋው ምርጥ የሀበሻ ጭፈራ ነው! 🔥", "time": "5m ago"},
      {"user": "Helen", "text": "አልባሳቱ በጣም ያምራል ✨", "time": "12m ago"}
    ],
    "2": [
      {"user": "Amanuel", "text": "የኢትዮጵያ ውበት ድንቅ ነው 🇪🇹❤️", "time": "2m ago"}
    ]
  };

  static final List<Map<String, String>> globalMusic = [
    {"name": "🇪🇹 Habesha Traditional Beat", "audioUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"},
    {"name": "🎵 Teddy Afro - Mar Eske Tuwaf", "audioUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4"},
    {"name": "🔥 Rophnan - Gurage Electronic Mix", "audioUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4"},
    {"name": "🌍 The Weeknd - Blinding Lights", "audioUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4"},
    {"name": "🥁 Tyla - Water (TikTok Dance)", "audioUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"}
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
      "type": "photo",
      "imageUrl": "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800",
      "audioUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
      "username": "@selam_official",
      "userAvatar": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200",
      "caption": "መልካም ቀን ከውቧ አዲስ አበባ 🌸✨ #EthiopiaGirl #HabeshaStyle",
      "songName": "🎵 Teddy Afro - Mar Eske Tuwaf",
      "likes": 8920,
      "tags": ["ethiopia girl", "habesha", "photo", "addis ababa"]
    },
    {
      "id": "3",
      "type": "video",
      "videoUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
      "username": "@ethio_comedy",
      "userAvatar": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
      "caption": "የዘመኑ ቲክቶከሮች ሲቀወጥ 😂🤣 #comedy #funny #ethiopia",
      "songName": "🎧 Funny Laugh Viral Sound Effect",
      "likes": 12400,
      "tags": ["comedy", "funny", "ethiopia", "viral"]
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

// ================= 1. HOME FEED SCREEN WITH FULL AUDIO & LIVE SYNC =================
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
              "videoUrl": e["videoUrl"],
              "imageUrl": e["imageUrl"] ?? e["videoUrl"],
              "audioUrl": e["audioUrl"] ?? "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
              "localFile": e["loca
