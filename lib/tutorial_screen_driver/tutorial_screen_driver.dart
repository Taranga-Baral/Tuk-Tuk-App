import 'package:final_menu/homepage1.dart';
import 'package:final_menu/login_screen/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialPageDriver extends StatefulWidget {
  @override
  _TutorialPageDriverState createState() => _TutorialPageDriverState();
}

class _TutorialPageDriverState extends State<TutorialPageDriver> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // List of tutorial data
  final List<Map<String, String>> _tutorialData = [
    {
      'image': 'assets/logo.png',
      'title': 'चालक मोडमा स्वागत छ!',
      'subtitle': 'Driver Optimised Page',
    },
    {
      'image': 'assets/search_tutorial.png',
      'title': 'Search',
      'subtitle': 'Here you can search Places',
    },
    {
      'image': 'assets/book ride screenshot.png',
      'title': 'Book Your Ride',
      'subtitle': 'Options for your Ride',
    },
    {
      'image': 'assets/ride completed.png',
      'title': 'Get Going',
      'subtitle': 'Track your ride in real-time and reach safely.',
    },
  ];

  // Navigate to HomePage and save tutorial completion status
  Future<void> _navigateToHome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenTutorial', true); // Set tutorial as seen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()), // Navigate to HomePage1
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _tutorialData.length,
            onPageChanged: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    _tutorialData[index]['image']!,
                    height: MediaQuery.of(context).size.height *0.59,
                  ),
                  SizedBox(height: 20),
                  Text(
                    _tutorialData[index]['title']!,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _tutorialData[index]['subtitle']!,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height *0.02,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip Button
                if (_currentIndex < _tutorialData.length - 1)
                  TextButton(
                    onPressed: _navigateToHome,
                    child: Text('Skip', style: TextStyle(fontSize: 16)),
                  ),
                // Indicator
                Row(
                  children: List.generate(
                    _tutorialData.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
                // Next Button or Start Button
                if (_currentIndex == _tutorialData.length - 1)
                  ElevatedButton(
                    onPressed: _navigateToHome,
                    child: Text('Start'),
                  )
                else
                  ElevatedButton(
                    
                    onPressed: () {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text('Next'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

