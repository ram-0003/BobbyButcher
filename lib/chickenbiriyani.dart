import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class ChickenBiriyaniScreen extends StatefulWidget {
  final String uid; // Pass the document ID (uid) of the recipe

  const ChickenBiriyaniScreen({super.key, required this.uid});

  @override
  _ChickenBiriyaniScreenState createState() => _ChickenBiriyaniScreenState();
}

class _ChickenBiriyaniScreenState extends State<ChickenBiriyaniScreen> {
  late VideoPlayerController _videoPlayerController;
  Map<String, dynamic>? recipeData;
  bool isLoading = true;
  bool isVideoInitialized = false;
  bool isMuted = false; // Track mute state
  double videoProgress = 0; // Video progress for the seek bar
  bool isVideoPlaying = false; // Track video playing state
  bool isFullScreen = false; // Track full-screen state

  @override
  void initState() {
    super.initState();
    fetchRecipeData(); // Fetch data when the screen loads
  }

  // Fetch recipe data from Firebase
  Future<void> fetchRecipeData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.uid)
          .get();

      if (doc.exists) {
        setState(() {
          recipeData = doc.data() as Map<String, dynamic>;

          // Initialize the VideoPlayerController with the updated method
          _videoPlayerController = VideoPlayerController.networkUrl(
            Uri.parse(recipeData?['video_url'] ?? ''),
          )..initialize().then((_) {
            setState(() {
              isVideoInitialized = true;
            });
            _videoPlayerController.play();
            isVideoPlaying = true;
            _videoPlayerController.addListener(() {
              // Update the progress bar as the video plays
              setState(() {
                videoProgress = _videoPlayerController.value.position.inMilliseconds /
                    _videoPlayerController.value.duration.inMilliseconds;
              });
            });
          });
          isLoading = false;
        });
      } else {
        throw Exception("Recipe not found");
      }
    } catch (e) {
      print("Error fetching recipe: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Toggle mute/unmute
  void toggleMute() {
    setState(() {
      isMuted = !isMuted;
      _videoPlayerController.setVolume(isMuted ? 0.0 : 1.0);
    });
  }

  // Play/Pause Video
  void togglePlayPause() {
    setState(() {
      if (_videoPlayerController.value.isPlaying) {
        _videoPlayerController.pause();
        isVideoPlaying = false;
      } else {
        _videoPlayerController.play();
        isVideoPlaying = true;
      }
    });
  }

  // Skip Forward by 10 seconds
  void skipForward() {
    final currentPosition = _videoPlayerController.value.position;
    final newPosition = currentPosition + const Duration(seconds: 10);
    _videoPlayerController.seekTo(newPosition);
  }

  // Skip Backward by 10 seconds
  void skipBackward() {
    final currentPosition = _videoPlayerController.value.position;
    final newPosition = currentPosition - const Duration(seconds: 10);
    _videoPlayerController.seekTo(newPosition);
  }

  // Toggle Full-Screen Mode
  void toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
      if (isFullScreen) {
        // Lock screen orientation to landscape
        SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
      } else {
        // Reset screen orientation to portrait
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      }
    });
  }

  @override
  void dispose() {
    if (isVideoInitialized) {
      _videoPlayerController.dispose(); // Dispose the video controller
      if (isFullScreen) {
        // Reset screen orientation when exiting full screen
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (recipeData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Recipe data not found.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          recipeData?['title'] ?? 'Recipe',
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.red),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Add share functionality here
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video Player Section
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black,
                ),
                child: isVideoInitialized
                    ? AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController),
                )
                    : const Center(
                  child: CircularProgressIndicator(),
                ),
              ),

              // Control Buttons (Play/Pause, Skip Forward/Backward, Full-Screen)
              if (isVideoInitialized)
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //   children: [
                //     IconButton(
                //       icon: Icon(
                //         isVideoPlaying ? Icons.pause : Icons.play_arrow,
                //         size: 30,
                //         color: Colors.red,
                //       ),
                //       onPressed: togglePlayPause,
                //     ),
                //     IconButton(
                //       icon: const Icon(
                //         Icons.fast_rewind,
                //         size: 30,
                //         color: Colors.red,
                //       ),
                //       onPressed: skipBackward,
                //     ),
                //     IconButton(
                //       icon: const Icon(
                //         Icons.fast_forward,
                //         size: 30,
                //         color: Colors.red,
                //       ),
                //       onPressed: skipForward,
                //     ),
                //     IconButton(
                //       icon: Icon(
                //         isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                //         size: 30,
                //         color: Colors.red,
                //       ),
                //       onPressed: toggleFullScreen,
                //     ),
                //   ],
                // ),
              const SizedBox(height: 16),

              // Recipe Title Section
              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.red,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        recipeData?['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(recipeData?['rating']?.toString() ?? '5'),
                          const SizedBox(width: 16),
                          const Icon(Icons.comment, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(recipeData?['comments']?.length.toString() ?? '0'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Recipe Details Section
              const Row(
                children: [
                  Text(
                    'Details',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.timer, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('30 min'),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                recipeData?['description'] ?? '',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Ingredients Section
              const Text(
                'Ingredients',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'For marination:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  (recipeData?['ingredients'] as List<dynamic>?)?.length ?? 0,
                      (index) => Text(
                    '• ${recipeData?['ingredients'][index]['quantity']} : ${recipeData?['ingredients'][index]['detail']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Ingredients Section
              const Text(
                'Instructions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'For Preparation:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  (recipeData?['instructions'] as List<dynamic>?)?.length ?? 0,
                      (index) => Text(
                    '• ${recipeData?['instructions'][index]}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}