import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';

class QuizPage extends StatefulWidget {
  final String userName;
  final String socialHandle;

  QuizPage({required this.userName, required this.socialHandle});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _matches = [];
  int _currentQuestionIndex = 0;
  List<String> _answers = [];
  String _result = "";
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // API configuration
  static const String apiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}';
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
    {
      "question": "Your ideal date night involves:",
      "options": ["Stargazing 🌌", "Dancing 💃", "Cooking together 👩🍳", "Movie marathon 🍿"],
    },
    {
      "question": "What's your love song anthem?",
      "options": ["Perfect by Ed Sheeran 🎸", "Crazy in Love 🎺", "All of Me 🎹", "Shape of You 🥁"],
    },
    {
      "question": "How do you resolve conflicts?",
      "options": ["Deep talks 💬", "Love letters 💌", "Quality time 🌻", "Gifts 🎁"],
    },
    {
      "question": "Pick a couple emoji:",
      "options": ["👫", "👩❤️💋👨", "💑", "🥰"],
    },
    {
      "question": "Your relationship motto is:",
      "options": ["Through thick and thin 💪", "Always adventurous 🚀", "Love conquers all ❤️", "Laugh every day 😂"],
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
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

  void _generateResult() async {
    setState(() => _isLoading = true);

    // Run API call and Firestore operations concurrently
    final results = await Future.wait([
      _callGeminiAPI(),
      _firestore.collection('users').add({
        'name': widget.userName,
        'social': widget.socialHandle,
        'answers': _answers,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((_) => _findMatches()),
    ]);

    setState(() {
      _result = results[0] as String; // API result
      _matches = results[1] as List<Map<String, dynamic>>; // Matches from Firestore
      _isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> _findMatches() async {
    List<Map<String, dynamic>> matches = [];
    final currentAnswers = Set.from(_answers);

    final querySnapshot = await _firestore
        .collection('users')
        .where('name', isNotEqualTo: widget.userName)
        .get();

    for (var doc in querySnapshot.docs) {
      final userData = doc.data() as Map<String, dynamic>;
      final userAnswers = Set.from(userData['answers']);

      final intersection = currentAnswers.intersection(userAnswers);
      final matchPercent = (intersection.length / _answers.length) * 100;

      matches.add({
        'name': userData['name'],
        'social': userData['social'],
        'match': matchPercent.round()
      });
    }

    // Sort matches by descending percentage
    matches.sort((a, b) => b['match'].compareTo(a['match']));
    return matches;
  }

  Future<String> _callGeminiAPI() async {
  try {
      final response = await http.post(
        Uri.parse(ApiConfig.getApiEndpoint()),
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
                Lottie.asset(
                  'assets/loading_animation.json', // Add your Lottie file
                  width: 150,
                  height: 150,
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
                  FadeTransition(
                    opacity: _animation,
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
                        Text(
                          "Your Perfect Matches",
                          style: GoogleFonts.dancingScript(
                            fontSize: isSmallScreen ? 28 : 32,
                            color: Colors.red[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        if (_matches.isEmpty)
                          Column(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 60,
                                color: Colors.red[400],
                              ),
                              SizedBox(height: 20),
                              Text(
                                "You're One of a Kind!",
                                style: GoogleFonts.dancingScript(
                                  fontSize: 28,
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  "Your unique personality hasn't found its perfect match yet. Don't worry - your special someone is out there! 💫",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red[800],
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _currentQuestionIndex = 0;
                                    _answers.clear();
                                    _result = "";
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[400],
                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Try Again',
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              Text(
                                "Compatibility Results",
                                style: GoogleFonts.dancingScript(
                                  fontSize: isSmallScreen ? 28 : 32,
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20),
                              ..._matches.map((match) => _MatchCard(
                                name: match['name'],
                                social: match['social'],
                                matchPercent: match['match'],
                              )).toList(),
                            ],
                          ),

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

class _MatchCard extends StatelessWidget {
  final String name;
  final String social;
  final int matchPercent;

  const _MatchCard({required this.name, required this.social, required this.matchPercent});

  @override
  Widget build(BuildContext context) {
    final isHighMatch = matchPercent >= 80;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      color: isHighMatch ? Colors.red[50] : Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(
          isHighMatch ? Icons.favorite : Icons.people_outline,
          color: isHighMatch ? Colors.red : Colors.grey,
        ),
        title: Text(
          name,
          style: TextStyle(
            color: isHighMatch ? Colors.red[900] : Colors.grey[700],
            fontWeight: isHighMatch ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          social,
          style: TextStyle(
            color: isHighMatch ? Colors.red[800] : Colors.grey[600],
          ),
        ),
        trailing: Chip(
          label: Text("$matchPercent%"),
          backgroundColor: isHighMatch ? Colors.red[100] : Colors.grey[200],
          labelStyle: TextStyle(
            color: isHighMatch ? Colors.red[900] : Colors.grey[800],
          ),
        ),
      ),
    );
  }
}