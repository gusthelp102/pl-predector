import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo.png",
              width: 190,
              height: 190,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                primary:
                    Colors.lightGreen, // Set light green color for the button
                minimumSize: Size(200, 50), // Set fixed width and height
              ),
              child: Text('Log In'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              style: ElevatedButton.styleFrom(
                primary:
                    Colors.lightGreen, // Set light green color for the button
                minimumSize: Size(200, 50), // Set fixed width and height
              ),
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
