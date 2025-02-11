import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'quiz_page.dart';

class UserInfoPage extends StatefulWidget {
  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _socialController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isChecking = false; // To show loading state during backend check
  String _errorMessage = ''; // To display error messages

  // Check if the social handle already exists in Firestore
  Future<bool> _isSocialHandleUnique(String socialHandle) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('social', isEqualTo: socialHandle)
          .limit(1)
          .get();

      return querySnapshot.docs.isEmpty; // True if no matching documents
    } catch (e) {
      print('Error checking social handle: $e');
      return false; // Assume not unique in case of error
    }
  }

  void _navigateToQuiz() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isChecking = true;
        _errorMessage = '';
      });

      final socialHandle = _socialController.text.trim();

      // Check if the social handle is unique
      final isUnique = await _isSocialHandleUnique(socialHandle);

      setState(() {
        _isChecking = false;
      });

      if (isUnique) {
        // Navigate to QuizPage if the social handle is unique
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizPage(
              userName: _nameController.text.trim(),
              socialHandle: socialHandle,
            ),
          ),
        );
      } else {
        // Show error message if the social handle already exists
        setState(() {
          _errorMessage = 'This social handle is already in use. Please try another one.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 20 : 40),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Let's Personalize Your Experience!",
                    style: GoogleFonts.dancingScript(
                      fontSize: isSmallScreen ? 28 : 34,
                      color: Colors.red[900],
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Your Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _socialController,
                    decoration: InputDecoration(
                      labelText: 'Social Media Handle (e.g., @loveexpert)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      prefixIcon: Icon(Icons.link),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your social handle';
                      }
                      return null;
                    },
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.red[800],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isChecking ? null : _navigateToQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isChecking
                        ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : Text(
                      'Continue to Quiz',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "We'll use this info to make your results more fun and show you potential matches!",
                    style: TextStyle(
                      color: Colors.red[800],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
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