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
  List<String> jokes = []; // Store jokes as a list of strings
  bool isLoading = false; // To handle loading state

  /// Function to fetch jokes using JokeService
  Future<void> fetchJokes() async {
    setState(() {
      isLoading = true; // Show loading state
    });
    try {
      final jokesRaw = await _jokeService.fetchJokesRaw(); // Fetch jokes
      setState(() {
        jokes = jokesRaw.map<String>((joke) {
          if (joke['type'] == 'single') {
            return joke['joke']; // Single joke
          } else {
            return '${joke['setup']} - ${joke['delivery']}'; // Two-part joke
          }
        }).toList();
      });
    } catch (e) {
      setState(() {
        jokes = ['Error fetching jokes: $e'];
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
        backgroundColor: Colors.green,
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Welcome and instruction section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                children: [
                  Text(
                    "Welcome to the Joke App!",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    "Click the button to fetch random jokes!",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.green.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Fetch jokes button
            ElevatedButton(
              onPressed: isLoading ? null : fetchJokes, // Disable button when loading
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              ),
              child: Text(
                isLoading ? "Fetching..." : "Fetch Jokes",
                style: TextStyle(color: Colors.white),
              ),
            ),
            // Jokes or loading/error state
            Expanded(
              child: isLoading
                  ? Center(
                child: CircularProgressIndicator(), // Show loader while fetching
              )
                  : jokes.isEmpty
                  ? Center(
                child: Text(
                  "No jokes fetched yet.",
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.green.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemCount: jokes.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    elevation: 5.0,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        jokes[index],
                        style: TextStyle(fontSize: 16.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
