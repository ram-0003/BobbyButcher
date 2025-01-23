import 'package:flutter/material.dart';
import 'dart:math';

import 'login.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'lib/assets/onboarding1.jpg', // Adjusted path
      'title': 'Welcome to the Butcher Shop',
      'content': 'Discover the craft of butchery, a tradition of quality, and our mission to bring the best meats to your table.'
    },
    {
      'image': 'lib/assets/onboarding2.jpg', // Adjusted path
      'title': 'Shop Culture and Values',
      'content': 'Learn about our dedication to quality, mastery, and the values that make our shop unique.'
    },
    {
      'image': 'lib/assets/onboarding3.jpg', // Adjusted path
      'title': 'Hygiene and Food Safety',
      'content': 'Explore our rigorous hygiene standards and our commitment to providing safe, fresh products.'
    },
  ];

  void _onNextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              double opacity = _currentPage == index ? 1.0 : 0.5;

              return Stack(
                children: [
                  Opacity(
                    opacity: opacity,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(_onboardingData[index]['image']!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.5,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFE8C00).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _onboardingData[index]['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            _onboardingData[index]['content']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _onboardingData.length,
                                  (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                height: 4,
                                width: _currentPage == index ? 25 : 15,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (_currentPage == 2)
                            GestureDetector(
                              onTap: _onNextPage,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    child: SizedBox(
                                      width: 80,
                                      height: 80,
                                      child: CustomPaint(
                                        painter: ThreeQuarterCirclePainter(),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: _onNextPage,
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Next',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class ThreeQuarterCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - 15,
    );
    canvas.drawArc(rect, -pi / 2, 3 * pi / 2, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
