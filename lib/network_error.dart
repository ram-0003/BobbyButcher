import 'package:flutter/material.dart';

class Network_error extends StatelessWidget {
  final VoidCallback onRetry;

  const Network_error({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 100,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 220,
                  color: Colors.grey[400],
                ),
                const SizedBox(
                  height: 25,
                ),
                const Text(
                  "No internet Connection",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Your internet connection is currently not available please check or try again",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(
              height: 170,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: onRetry,
              child: const Text(
                'Start  Ordering',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
