import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:valentine_website/user_info_page.dart';
import 'quiz_page.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomePage extends StatelessWidget {
  final String websiteUrl = "https://ajnabee.in";

  void _launchWebsite() async {
    if (await canLaunch(websiteUrl)) {
      await launch(websiteUrl);
    } else {
      throw 'Could not launch $websiteUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink[50]!, Colors.red[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20 : size.width * 0.1,
                  vertical: isSmallScreen ? 20 : 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      size: isSmallScreen ? 60 : 80,
                      color: Colors.red[400],
                    ),
                    SizedBox(height: isSmallScreen ? 15 : 20),
                    AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          '❤️ Love Calculator 2025 ❤️',
                          textStyle: GoogleFonts.dancingScript(
                            fontSize: isSmallScreen ? 32 : 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[900],
                          ),
                          speed: Duration(milliseconds: 100),
                        ),
                      ],
                      totalRepeatCount: 1,
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 30),
                    Container(
                      width: isSmallScreen ? double.infinity : size.width * 0.6,
                      padding: EdgeInsets.all(isSmallScreen ? 15 : 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        "Discover your romantic personality and get personalized advice for the perfect Valentine's Day! 🌹",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          color: Colors.red[900],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 30 : 40),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserInfoPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 30 : 40,
                          vertical: isSmallScreen ? 15 : 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Start Quiz",
                            style: TextStyle(fontSize: isSmallScreen ? 18 : 22),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 30),
                    TextButton.icon(
                      onPressed: _launchWebsite,
                      icon: Icon(Icons.spa, color: Colors.red[900]),
                      label: Text(
                        "Get Valentine's Special Offers",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Colors.red[900],
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}