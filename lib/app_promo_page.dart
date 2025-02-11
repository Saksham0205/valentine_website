import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AppPromoPage extends StatelessWidget {
  final String playStoreUrl =
      "https://play.google.com/store/apps/details?id=com.ajnabee.app";

  void _launchPlayStore() async {
    if (await canLaunch(playStoreUrl)) {
      await launch(playStoreUrl);
    } else {
      throw 'Could not launch $playStoreUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Special Offers",
            style: GoogleFonts.dancingScript(fontSize: 24)),
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 40),
                Icon(
                  Icons.spa,
                  size: 60,
                  color: Colors.red[400],
                ),
                SizedBox(height: 20),
                Text(
                  "Valentine's Special",
                  style: GoogleFonts.dancingScript(
                    fontSize: 36,
                    color: Colors.red[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.all(25),
                  margin: EdgeInsets.symmetric(horizontal: 20),
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
                        "🌹 Limited Time Offers 🌹",
                        style: GoogleFonts.quicksand(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[900],
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildOfferTile("Couple Spa Package", "50% OFF", "💑"),
                      _buildOfferTile("Beauty Makeover", "30% OFF", "💄"),
                      _buildOfferTile("Hair Styling", "25% OFF", "💇‍♀️"),
                      SizedBox(height: 20),
                      Text(
                        "Download Ajnabee App Now!",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.red[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _launchPlayStore,
                  icon: Icon(Icons.download),
                  label: Text(
                    "Download Now",
                    style: TextStyle(fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 20),
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
                        "Why Choose Ajnabee?",
                        style: GoogleFonts.quicksand(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[900],
                        ),
                      ),
                      SizedBox(height: 15),
                      _buildFeatureTile("Professional Services",
                          "Expert beauticians at your service", Icons.star),
                      _buildFeatureTile(
                          "Best Prices",
                          "Competitive rates with great offers",
                          Icons.currency_rupee),
                      _buildFeatureTile("Sanitized Tools",
                          "Hygiene is our top priority", Icons.clean_hands),
                      _buildFeatureTile("Home Service",
                          "Convenience at your doorstep", Icons.home),
                    ],
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfferTile(String title, String discount, String emoji) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: Colors.red[900],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red[400],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              discount,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Colors.red[400],
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.red[900],
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.red[700],
        ),
      ),
    );
  }
}
