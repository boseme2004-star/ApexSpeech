import 'package:flutter/material.dart';

class PlaybackScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Playback"),
      ),

      body: Center(

        child: Padding(
          padding: EdgeInsets.all(20),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              Icon(
                Icons.play_circle_fill,
                size: 100,
                color: Colors.deepPurple,
              ),

              SizedBox(height: 30),

              Text(
                "Recorded Audio",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 40),

              ElevatedButton(

                onPressed: () {

                  // Audio playback later

                },

                child: Padding(
                  padding: EdgeInsets.all(15),

                  child: Text(
                    "Play Recording",
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