import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';

import 'chickenbiriyani.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> filteredRecipes = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRecipe();
    searchController.addListener(onSearch); // Attach listener for search input
  }

  /// Fetch recipes from Firestore
  Future<void> fetchRecipe() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('recipes').get();
      List<Map<String, dynamic>> fetchedRecipes = [];

      for (var doc in snapshot.docs) {
        fetchedRecipes.add({
          'uid': doc.id,
          'title': doc['title'],
          'video_url': doc['video_url'],
        });
      }

      setState(() {
        recipes = fetchedRecipes;
        filteredRecipes = fetchedRecipes; // Initially show all recipes
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching recipes: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Filter recipes based on search input
  void onSearch() {
    String query = searchController.text.toLowerCase();
    setState(() {
      // If the search bar is empty, show all recipes
      if (query.isEmpty) {
        filteredRecipes = recipes;
      } else {
        // Otherwise, filter recipes based on the input
        filteredRecipes = recipes.where((recipe) {
          return recipe['title'].toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose(); // Dispose controller to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Recipe Categories',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Recipes',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),

          // Recipe Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: filteredRecipes.length,
                itemBuilder: (context, index) {
                  return RecipeCard(
                    title: filteredRecipes[index]['title'],
                    videoUrl: filteredRecipes[index]['video_url'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChickenBiriyaniScreen(
                            uid: filteredRecipes[index]['uid'],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class RecipeCard extends StatefulWidget {
  final String title;
  final String videoUrl;
  final VoidCallback onTap;

  const RecipeCard({
    super.key,
    required this.title,
    required this.videoUrl,
    required this.onTap,
  });

  @override
  _RecipeCardState createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.network(widget.videoUrl)
      ..initialize()
          .then((_) {
        setState(() {});
      });
  }

  

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            fit: FlexFit.loose, // Make the video widget take up only necessary space
            child: Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12), // Ensure the video corners are also rounded
                child: _videoController.value.isInitialized
                    ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: AspectRatio(
                        aspectRatio: _videoController.value.aspectRatio,
                        child: VideoPlayer(_videoController),
                      ),
                    ),
                    const Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 50,
                    ),
                  ],
                )
                    : const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

}
