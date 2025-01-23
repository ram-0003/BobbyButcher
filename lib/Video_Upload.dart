import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateRecipePage extends StatefulWidget {
  const CreateRecipePage({super.key});

  @override
  _CreateRecipePageState createState() => _CreateRecipePageState();
}

class _CreateRecipePageState extends State<CreateRecipePage> {
  final titleController = TextEditingController(); // Add this as a class member if necessary
  final descriptionController = TextEditingController();
  List<Map<String, dynamic>> ingredients = [];
  List<Map<String, dynamic>> instructions = [];

  File? _videoFile;
  VideoPlayerController? _videoController;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  Future<void> uploadRecipe() async {
    setState(() {
      isLoading = true;
    });
    String title = titleController.text;
    String description = descriptionController.text;
    if (_videoFile == null || title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields and upload a video.')),
      );
      setState(() {
        isLoading = false;
        print(isLoading);
      });
      return;
    }

    try {
      // Generate a unique file name for the video
      final String videoFileName = 'recipes/${DateTime.now().millisecondsSinceEpoch}.mp4';

      // Upload the video to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(videoFileName);
      final uploadTask = await storageRef.putFile(_videoFile!);

      // Get the download URL for the video
      final videoUrl = await uploadTask.ref.getDownloadURL();

      // Format ingredients and instructions
      List<Map<String, dynamic>> formattedIngredients = ingredients.map((ingredient) {
        return {
          'quantity': ingredient['amountController'].text,
          'detail': ingredient['nameController'].text,
        };
      }).toList();

      List formattedInstructions = instructions.map((instruction) {
        return instruction['controller'].text;
      }).toList();

      // Save the recipe to Firestore
      await FirebaseFirestore.instance.collection('recipes').add({
        'video_url': videoUrl,
        'title': title,
        'description': description,
        'ingredients': formattedIngredients,
        'instructions': formattedInstructions,
        'created_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe uploaded successfully!')),
      );

      // Clear form fields after successful upload
      setState(() {
        titleController.text = '';
        descriptionController.text = '';
        _videoFile = null;
        _videoController?.dispose();
        _videoController = null;
        ingredients.clear();
        instructions.clear();
      });
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload recipe: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    // Dispose video controller
    _videoController?.dispose();

    // Dispose all ingredient controllers
    for (var ingredient in ingredients) {
      ingredient['amountController'].dispose();
      ingredient['nameController'].dispose();
    }

    // Dispose all instruction controllers
    for (var instruction in instructions) {
      instruction['controller'].dispose();
    }

    super.dispose();
  }

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
        _videoController = VideoPlayerController.file(_videoFile!)
          ..initialize().then((_) {
            setState(() {}); // Refresh UI after video is loaded
            _videoController!.play(); // Start playing automatically
          });
      });
    }
  }

  void _addIngredient() {
    setState(() {
      ingredients.add({
        'amountController': TextEditingController(text: ''),
        'nameController': TextEditingController(text: ''),
      });
    });
  }

  void _deleteIngredient(int index) {
    setState(() {
      // Dispose controllers for the deleted ingredient
      ingredients[index]['amountController'].dispose();
      ingredients[index]['nameController'].dispose();
      ingredients.removeAt(index);
    });
  }

  void _addInstruction() {
    setState(() {
      instructions.add({'controller': TextEditingController(text: '')});
    });
  }

  void _deleteInstruction(int index) {
    setState(() {
      instructions[index]['controller'].dispose();
      instructions.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Recipe',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        leading: GestureDetector(
          onTap: () => {Navigator.pop(context)},
          child: const Icon(Icons.arrow_back, color: Colors.red),
        ),
      ),
      body:Stack(
        children: [
          Opacity(
            opacity: isLoading? 0.5 : 1,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: uploadRecipe,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                          ),
                          child: const Text('Publish'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickVideo, // Tap to pick video
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: _videoFile == null
                            ? const Center(
                          child: Text(
                            "Tap to upload video",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        )
                            : _videoController != null &&
                            _videoController!.value.isInitialized
                            ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        )
                            : const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Title',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.pink[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Description',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      maxLines: 2,
                      controller: descriptionController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.pink[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ingredients',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ingredients.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.drag_indicator, color: Colors.pink),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: ingredients[index]['amountController'],
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.pink[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 4,
                                child: TextField(
                                  controller: ingredients[index]['nameController'],
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.pink[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteIngredient(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addIngredient,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                      ),
                      child: const Text('+ Add Ingredient'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Instructions',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: instructions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: instructions[index]['controller'],
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.pink[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _deleteInstruction(index),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addInstruction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                      ),
                      child: const Text('+ Add Instruction'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.4), // Optional background color
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}