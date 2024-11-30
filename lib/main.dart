import 'package:flutter/material.dart';
import 'joke_service.dart'; // Import JokeService

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: JokeApp(),
    );
  }
}

class JokeApp extends StatefulWidget {
  @override
  _JokeAppState createState() => _JokeAppState();
}

class _JokeAppState extends State<JokeApp> {
  final JokeService _jokeService = JokeService(); // Initialize JokeService
  String jokeText = "No jokes fetched yet.";
  bool isLoading = false; // To handle loading state

  /// Function to fetch jokes using JokeService
  Future<void> fetchJokes() async {
    setState(() {
      isLoading = true; // Show loading state
    });
    try {
      final jokes = await _jokeService.fetchJokesRaw(); // Fetch jokes
      setState(() {
        jokeText = jokes.map((joke) {
          if (joke['type'] == 'single') {
            return joke['joke']; // Single joke
          } else {
            return '${joke['setup']} - ${joke['delivery']}'; // Two-part joke
          }
        }).join('\n\n'); // Combine jokes into one string
      });
    } catch (e) {
      setState(() {
        jokeText = 'Error fetching jokes: $e';
      });
    } finally {
      setState(() {
        isLoading = false; // Hide loading state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Joke App'),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Text(
              "Welcome to the Joke App!",
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.0),
            Text(
              "Click the button to fetch random jokes!",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.purple.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: isLoading ? null : fetchJokes, // Disable button when loading
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              ),
              child: Text(
                isLoading ? "Fetching..." : "Fetch Jokes",
                style: TextStyle(color: Colors.white),
              ),
            ),
            Text(
              jokeText,
              style: TextStyle(fontSize: 18.0, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
