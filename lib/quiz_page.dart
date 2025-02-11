import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  List<String> _answers = [];
  String _result = "";
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // API configuration
  static const String apiKey = 'AIzaSyBju6Fn9yW21zymWGatVjsmyXQDpRF0Ek4';
  static const String apiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyDzlQfkt8I7n8JvWYnqTUzrXP0g8dJGmDc';
  final String websiteUrl = "https://ajnabee.in";

  final List<Map<String, dynamic>> _questions = [
    {
      "question": "If your love story was a movie genre, what would it be?",
      "options": ["Rom-Com 😊", "Epic Adventure 🌟", "Dramatic Romance 🎭", "Fairy Tale ✨"],
    },
    {
      "question": "Pick your ideal romantic superpower:",
      "options": ["Mind Reading 🧠", "Time Freezing ⌛", "Teleportation 🌎", "Love Potion Making 💝"],
    },
    {
      "question": "Your partner turns into an animal for a day. What's the cutest outcome?",
      "options": ["Playful Puppy 🐕", "Cuddly Cat 😺", "Majestic Eagle 🦅", "Sweet Penguin 🐧"],
    },
    {
      "question": "Choose your romantic time travel destination:",
      "options": ["Paris 1920s 🗼", "Ancient Rome 🏛️", "Victorian Era 👒", "Future 3000 🚀"],
    },
    {
      "question": "Your love language in emoji form is:",
      "options": ["🎁 Gifts", "🤗 Hugs", "🗣️ Words", "👩‍🍳 Acts"],
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _answerQuestion(String answer) {
    setState(() {
      _answers.add(answer);
      if (_currentQuestionIndex < _questions.length - 1) {
        _animationController.reset();
        _currentQuestionIndex++;
        _animationController.forward();
      } else {
        _generateResult();
      }
    });
  }

  Future<void> _generateResult() async {
    setState(() {
      _isLoading = true;
    });

    final String result = await _callGeminiAPI();

    setState(() {
      _result = result;
      _isLoading = false;
    });
  }

  Future<String> _callGeminiAPI() async {
    try {
      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "contents": [{
            "parts": [{
              "text": "You are a romantic personality analyzer. Based on these quiz answers: ${_answers.join(", ")}, generate a fun, creative, and specific 3-sentence personality analysis with emojis. Include a romantic tip and a beauty suggestion. Make it playful and engaging."
            }]
          }]
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ??
            "Your romantic soul sparkles with uniqueness! ✨ Your perfect match will appreciate your special way of showing love. 💖 Time to treat yourself to a luxurious spa day and let your inner beauty shine through! 💫";
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return "Your romantic soul sparkles with uniqueness! ✨ Your perfect match will appreciate your special way of showing love. 💖 Time to treat yourself to a luxurious spa day and let your inner beauty shine through! 💫";
      }
    } catch (e) {
      print('API Error: $e');
      return "Your romantic soul sparkles with uniqueness! ✨ Your perfect match will appreciate your special way of showing love. 💖 Time to treat yourself to a luxurious spa day and let your inner beauty shine through! 💫";
    }
  }

  void _launchWebsite() async {
    if (await canLaunch(websiteUrl)) {
      await launch(websiteUrl);
    } else {
      throw 'Could not launch $websiteUrl';
    }
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.red[100],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red[400]!),
          ),
          SizedBox(height: 10),
          Text(
            "Question ${_currentQuestionIndex + 1} of ${_questions.length}",
            style: TextStyle(
              color: Colors.red[900],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Love Calculator",
          style: GoogleFonts.dancingScript(fontSize: isSmallScreen ? 22 : 24),
        ),
        backgroundColor: Colors.red[400],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink[50]!, Colors.red[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red[400]!),
                ),
                SizedBox(height: 20),
                Text(
                  "Analyzing your romantic personality...",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    color: Colors.red[900],
                  ),
                ),
              ],
            ),
          )
              : _result.isEmpty
              ? SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 15 : size.width * 0.1,
                vertical: isSmallScreen ? 15 : 30,
              ),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  _buildProgressIndicator(),
                  SizedBox(height: 30),
                  FadeTransition(
                    opacity: _animation,
                    child: Container(
                      padding: EdgeInsets.all(20),
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
                        _questions[_currentQuestionIndex]["question"],
                        style: GoogleFonts.quicksand(
                          fontSize: isSmallScreen ? 20 : 24,
                          color: Colors.red[900],
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  ..._questions[_currentQuestionIndex]["options"]
                      .map<Widget>((option) => Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: isSmallScreen ? 0 : 50),
                    child: FadeTransition(
                      opacity: _animation,
                      child: ElevatedButton(
                        onPressed: () => _answerQuestion(option),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red[900],
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: isSmallScreen ? 12 : 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(15),
                          ),
                          elevation: 3,
                        ),
                        child: Container(
                          width: double.infinity,
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ))
                      .toList(),
                ],
              ),
            ),
          )
              : SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 15 : size.width * 0.1,
                vertical: isSmallScreen ? 15 : 30,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.favorite,
                    size: isSmallScreen ? 50 : 60,
                    color: Colors.red[400],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Your Love Analysis",
                    style: GoogleFonts.dancingScript(
                      fontSize: isSmallScreen ? 32 : 36,
                      color: Colors.red[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  StyledResultCard(resultText: _result),
                  SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _launchWebsite,
                    icon: Icon(Icons.spa),
                    label: Text(
                      "Get Special Offers",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 20,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 25 : 30,
                        vertical: isSmallScreen ? 12 : 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StyledResultCard extends StatelessWidget {
  final String resultText;

  const StyledResultCard({Key? key, required this.resultText}) : super(key: key);

  Widget _buildStyledSection(String title, String content, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.red[400], size: 24),
            SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[900],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 18,
            color: Colors.red[800],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Split the result into sections
    final sections = resultText.split('**');
    final mainAnalysis = sections[0].trim();
    String romanticTip = '';
    String beautySuggestion = '';

    // Extract tip and suggestion if they exist
    for (var section in sections) {
      if (section.startsWith('Romantic Tip:')) {
        romanticTip = section.replaceAll('Romantic Tip:', '').trim();
      } else if (section.startsWith('Beauty Suggestion:')) {
        beautySuggestion = section.replaceAll('Beauty Suggestion:', '').trim();
      }
    }

    return Container(
      padding: EdgeInsets.all(25),
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
      child: Column(
        children: [
          Text(
            mainAnalysis,
            style: GoogleFonts.quicksand(
              fontSize: 20,
              color: Colors.red[900],
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          if (romanticTip.isNotEmpty)
            _buildStyledSection('Romantic Tip', romanticTip, Icons.favorite),
          if (beautySuggestion.isNotEmpty)
            _buildStyledSection('Beauty Suggestion', beautySuggestion, Icons.spa),
        ],
      ),
    );
  }
}