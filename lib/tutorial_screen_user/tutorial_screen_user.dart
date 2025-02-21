// import 'package:final_menu/login_screen/sign_in_page.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class TutorialPageUser extends StatefulWidget {
//   const TutorialPageUser({super.key});

//   @override
//   _TutorialPageUserState createState() => _TutorialPageUserState();
// }

// class _TutorialPageUserState extends State<TutorialPageUser> {
//   final PageController _pageController = PageController();
//   int _currentIndex = 0;

//   // List of tutorial data
//   final List<Map<String, String>> _tutorialData = [
//     {
//       'image': 'assets/logo.png',
//       'title': 'Welcome to Tuk Tuk!',
//       'subtitle': 'Platform for your Ride',
//     },
//     {
//       'image': 'assets/search_tutorial.png',
//       'title': 'Search',
//       'subtitle': 'Here you can search Places',
//     },
//     {
//       'image': 'assets/book ride screenshot.png',
//       'title': 'Book Your Ride',
//       'subtitle': 'Options for your Ride',
//     },
//     {
//       'image': 'assets/ride completed.png',
//       'title': 'Get Going',
//       'subtitle': 'Track your ride in real-time and reach safely.',
//     },
//   ];

//   // Navigate to HomePage and save tutorial completion status
//   Future<void> _navigateToHome() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('hasSeenTutorial', true); // Set tutorial as seen
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//           builder: (context) => SignInPage()), // Navigate to HomePage1
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           children: [
//             PageView.builder(
//               controller: _pageController,
//               itemCount: _tutorialData.length,
//               onPageChanged: (int index) {
//                 setState(() {
//                   _currentIndex = index;
//                 });
//               },
//               itemBuilder: (context, index) {
//                 return Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Image.asset(
//                       _tutorialData[index]['image']!,
//                       height: MediaQuery.of(context).size.height * 0.59,
//                     ),
//                     SizedBox(height: 20),
//                     Text(
//                       _tutorialData[index]['title']!,
//                       style:
//                           TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 10),
//                     MediaQuery.of(context).size.height >= 600
//                         ? Text(
//                             _tutorialData[index]['subtitle']!,
//                             style: TextStyle(fontSize: 16),
//                             textAlign: TextAlign.center,
//                           )
//                         : SizedBox(),
//                   ],
//                 );
//               },
//             ),
//             Positioned(
//               bottom: 0,
//               right: 0,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.only(topLeft: Radius.circular(50)),
//                 child: Container(
//                   color: Colors.blueAccent,
//                   height: MediaQuery.of(context).size.height * 0.12,
//                   width: MediaQuery.of(context).size.width * 0.26,
//                 ),
//               ),
//             ),
//             Positioned(
//               top: MediaQuery.of(context).size.height * 0.02,
//               left: 10,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   // Indicator

//                   // Skip Button
//                   if (_currentIndex < _tutorialData.length - 1)
//                     TextButton(
//                       onPressed: _navigateToHome,
//                       child: Text('Skip',
//                           style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.white,
//                               fontWeight: FontWeight.w400)),
//                     ),
//                 ],
//               ),
//             ),
//             Positioned(
//               bottom: MediaQuery.of(context).size.height * 0.02,
//               left: 20,
//               right: 20,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Skip Button
//                   if (_currentIndex < _tutorialData.length - 1)
//                     TextButton(
//                       onPressed: _navigateToHome,
//                       child: Text('Skip', style: TextStyle(fontSize: 0)),
//                     ),
//                   // Indicator
//                   Row(
//                     children: List.generate(
//                       _tutorialData.length,
//                       (index) => Container(
//                         margin: EdgeInsets.symmetric(horizontal: 5),
//                         width: 10,
//                         height: 10,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: _currentIndex == index
//                               ? Colors.blueAccent
//                               : Colors.grey,
//                         ),
//                       ),
//                     ),
//                   ),
//                   // Next Button or Start Button
//                   if (_currentIndex == _tutorialData.length - 1)
//                     // ElevatedButton(
//                     //   onPressed: _navigateToHome,
//                     //   child: Text('Start'),
//                     // )
//                     GestureDetector(
//                       onTap: _navigateToHome,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(40),
//                         child: Container(
//                           // color: Colors.deepPurpleAccent.shade200.withOpacity(0.8),
//                           color: Colors.transparent,
//                           height: 50,
//                           width: 60,
//                           child: Center(
//                               child: Icon(
//                             Icons.home,
//                             color: Colors.white,
//                           )),
//                         ),
//                         // child: SizedBox(
//                         //   height: 90,
//                         //   width: 80,
//                         //   child: Image(
//                         //       image:
//                         //           AssetImage('assets/onboarding last go.gif')),
//                         // ),
//                       ),
//                     )
//                   else
//                     // ElevatedButton(
//                     //   onPressed: () {
//                     //     _pageController.nextPage(
//                     //       duration: Duration(milliseconds: 300),
//                     //       curve: Curves.easeInOut,
//                     //     );
//                     //   },
//                     //   child: Text('Next'),
//                     // ),

//                     GestureDetector(
//                       onTap: () {
//                         _pageController.nextPage(
//                           duration: Duration(milliseconds: 500),
//                           curve: Curves.easeInOut,
//                         );
//                       },
//                       child: Icon(
//                         Icons.arrow_right,
//                         size: 50,
//                         color: Colors.white,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:final_menu/login_screen/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialPageUser extends StatefulWidget {
  const TutorialPageUser({super.key});

  @override
  _TutorialPageUserState createState() => _TutorialPageUserState();
}

class _TutorialPageUserState extends State<TutorialPageUser> {
  final LiquidController _liquidController = LiquidController();
  int _currentIndex = 0;

  // List of tutorial data
  final List<Map<String, String>> _tutorialData = [
    {
      'image': 'assets/logo.gif',
      'title': 'Welcome to Tuk Tuk!',
      'subtitle':
          'Platform for your Ride at Reasonable Rate with 3 Vehicle Types',
      'color': '#7975FF', //bluish
      // 'color': '#FFFFFF',
    },
    {
      'image': 'assets/search_tutorial.png',
      'title': 'Search',
      'subtitle': 'Here you can search Places',
      'color': '#FF5252', //red
    },
    {
      'image': 'assets/book ride screenshot.png',
      'title': 'Book Your Ride',
      'subtitle': 'Options for your Ride',
      'color': '#49dd7e',
    },
    {
      'image': 'assets/ride completed.png',
      'title': 'Get Going',
      'subtitle': 'Track your ride in real-time and reach safely.',
      'color': '#38B6FF',
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
            LiquidSwipe(
              enableLoop: false,
              ignoreUserGestureWhileAnimating: true,
              liquidController: _liquidController,
              onPageChangeCallback: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              enableSideReveal: false,
              fullTransitionValue:
                  300, // Full transition value to cover the screen
              waveType: WaveType.liquidReveal, // Smooth liquid reveal effect
              pages: _tutorialData.map((data) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  color:
                      Color(int.parse(data['color']!.replaceAll('#', '0xFF'))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        data['image']!,
                        height: MediaQuery.of(context).size.height * 0.5,
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 0, left: 30, right: 30),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            height: 100,
                            width: double.infinity,
                            color: const Color.fromARGB(38, 0, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12, right: 12),
                                  child: Text(
                                    data['title']!,
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                                SizedBox(height: 10),
                                MediaQuery.of(context).size.height >= 600
                                    ? Text(
                                        data['subtitle']!,
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                        textAlign: TextAlign.center,
                                      )
                                    : SizedBox(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
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
                      child: Text(
                        'Skip',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  // Indicator
                  Row(
                    children: List.generate(
                      _tutorialData.length,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  // Next Button or Start Button
                  if (_currentIndex == _tutorialData.length - 1)
                    GestureDetector(
                      onTap: _navigateToHome,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.home,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        _liquidController.animateToPage(
                          page: _currentIndex + 1,
                          duration: 500,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: Colors.white,
                        ),
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
