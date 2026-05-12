import 'package:flutter/material.dart';
import 'package:record/record.dart'; 

class HomeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Vocal Coach"),
      ),

      body: Center(

        child: Padding(
          padding: EdgeInsets.all(20),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              // Title
              Text(
                "Speech Recording",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 40),

              // Start Recording Button
              ElevatedButton(

                onPressed: () {

                  // Recording logic later

                },

                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    "Start Recording",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Playback button
              ElevatedButton(

                onPressed: () {

                  Navigator.pushNamed(
                    context,
                    '/playback',
                  );

                },

                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    "Playback",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Feedback button
              ElevatedButton(

                onPressed: () {

                  Navigator.pushNamed(
                    context,
                    '/feedback',
                  );

                },

                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    "Feedback",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}