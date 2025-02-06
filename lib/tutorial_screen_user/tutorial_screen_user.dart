import 'package:final_menu/login_screen/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialPageUser extends StatefulWidget {
  const TutorialPageUser({super.key});

  @override
  _TutorialPageUserState createState() => _TutorialPageUserState();
}

class _TutorialPageUserState extends State<TutorialPageUser> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // List of tutorial data
  final List<Map<String, String>> _tutorialData = [
    {
      'image': 'assets/logo.png',
      'title': 'Welcome to Tuk Tuk!',
      'subtitle': 'Platform for your Ride',
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
      MaterialPageRoute(
          builder: (context) => SignInPage()), // Navigate to HomePage1
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
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
                      height: MediaQuery.of(context).size.height * 0.59,
                    ),
                    SizedBox(height: 20),
                    Text(
                      _tutorialData[index]['title']!,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    MediaQuery.of(context).size.height >= 600
                        ? Text(
                            _tutorialData[index]['subtitle']!,
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          )
                        : SizedBox(),
                  ],
                );
              },
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(50)),
                child: Container(
                  color: Colors.blueAccent,
                  height: MediaQuery.of(context).size.height * 0.12,
                  width: MediaQuery.of(context).size.width * 0.26,
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.02,
              left: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Indicator

                  // Skip Button
                  if (_currentIndex < _tutorialData.length - 1)
                    TextButton(
                      onPressed: _navigateToHome,
                      child: Text('Skip',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w400)),
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.02,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip Button
                  if (_currentIndex < _tutorialData.length - 1)
                    TextButton(
                      onPressed: _navigateToHome,
                      child: Text('Skip', style: TextStyle(fontSize: 0)),
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
                              ? Colors.blueAccent
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  // Next Button or Start Button
                  if (_currentIndex == _tutorialData.length - 1)
                    // ElevatedButton(
                    //   onPressed: _navigateToHome,
                    //   child: Text('Start'),
                    // )
                    GestureDetector(
                      onTap: _navigateToHome,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Container(
                          // color: Colors.deepPurpleAccent.shade200.withOpacity(0.8),
                          color: Colors.transparent,
                          height: 50,
                          width: 60,
                          child: Center(
                              child: Icon(
                            Icons.home,
                            color: Colors.white,
                          )),
                        ),
                        // child: SizedBox(
                        //   height: 90,
                        //   width: 80,
                        //   child: Image(
                        //       image:
                        //           AssetImage('assets/onboarding last go.gif')),
                        // ),
                      ),
                    )
                  else
                    // ElevatedButton(
                    //   onPressed: () {
                    //     _pageController.nextPage(
                    //       duration: Duration(milliseconds: 300),
                    //       curve: Curves.easeInOut,
                    //     );
                    //   },
                    //   child: Text('Next'),
                    // ),

                    GestureDetector(
                      onTap: () {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Icon(
                        Icons.arrow_right,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
