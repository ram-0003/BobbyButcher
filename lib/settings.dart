import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SectionHeader(title: "PROFILE"),
          ListTile(
            title: const Text("Push Notification"),
            trailing: Switch(
              value: false,
              onChanged: (bool value) {
              },
            ),
          ),
          ListTile(
            title: const Text("Location"),
            trailing: Switch(
              value: true,
              onChanged: (bool value) {
              },
              activeColor: Colors.orange,
            ),
          ),
          ListTile(
            title: const Text("Language"),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("English"),
                Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              _showLanguagePicker(context);
            },
          ),
          const SizedBox(height: 16.0),

          const SectionHeader(title: "OTHER"),
          ListTile(
            title: const Text("About Ticketis"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
            },
          ),
          ListTile(
            title: const Text("Privacy Policy"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
            },
          ),
          ListTile(
            title: const Text("Terms and Conditions"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
            },
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final languages = [
      "Afrikaans", "Albanian", "Amharic", "Arabic", "Armenian", "Azerbaijani", 
      "Basque", "Belarusian", "Bengali", "Bosnian", "Bulgarian", "Catalan",
      "Cebuano", "Chichewa", "Chinese (Simplified)", "Chinese (Traditional)",
      "Corsican", "Croatian", "Czech", "Danish", "Dutch", "English", "Esperanto",
      "Estonian", "Filipino", "Finnish", "French", "Frisian", "Galician",
      "Georgian", "German", "Greek", "Gujarati", "Haitian Creole", "Hausa",
      "Hawaiian", "Hebrew", "Hindi", "Hmong", "Hungarian", "Icelandic",
      "Igbo", "Indonesian", "Irish", "Italian", "Japanese", "Javanese", "Kannada",
      "Kazakh", "Khmer", "Kinyarwanda", "Korean", "Kurdish", "Kyrgyz", "Lao",
      "Latin", "Latvian", "Lithuanian", "Luxembourgish", "Macedonian", "Malagasy",
      "Malay", "Malayalam", "Maltese", "Maori", "Marathi", "Mongolian", "Myanmar",
      "Nepali", "Norwegian", "Odia", "Pashto", "Persian", "Polish", "Portuguese",
      "Punjabi", "Romanian", "Russian", "Samoan", "Scots Gaelic", "Serbian",
      "Sesotho", "Shona", "Sindhi", "Sinhala", "Slovak", "Slovenian", "Somali",
      "Spanish", "Sundanese", "Swahili", "Swedish", "Tajik", "Tamil", "Tatar",
      "Telugu", "Thai", "Turkish", "Turkmen", "Ukrainian", "Urdu", "Uyghur",
      "Uzbek", "Vietnamese", "Welsh", "Xhosa", "Yiddish", "Yoruba", "Zulu"
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                "Select Language",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(languages[index]),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Selected: ${languages[index]}")),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
