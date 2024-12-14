import 'package:flutter/material.dart';
import 'joke_service.dart';

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
  final JokeService _jokeService = JokeService();
  List<Map<String, String>> jokes = [];
  bool isLoading = false;

  /// Function to fetch jokes using JokeService
  Future<void> fetchJokes() async {
    setState(() {
      isLoading = true;
    });
    try {
      final jokesRaw = await _jokeService.fetchJokesRaw();
      setState(() {
        jokes = jokesRaw.map<Map<String, String>>((joke) {
          if (joke['type'] == 'single') {
            return {
              'title': '😂 Funny Joke',
              'joke': joke['joke'],
              'setup': '',
              'delivery': '',
            };
          } else {
            return {
              'title': '🤣 Twopart Joke',
              'joke': '',
              'setup': joke['setup'],
              'delivery': joke['delivery'],
            };
          }
        }).toList();
      });
    } catch (e) {
      setState(() {
        jokes = [
          {'title': '⚠️ Error', 'joke': 'Error fetching jokes: $e', 'setup': '', 'delivery': ''}
        ];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Joke App', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                children: [
                  Text(
                    "Laugh Out Loud!",
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    "Click below to fetch some jokes.",
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: isLoading ? null : fetchJokes,
              icon: Icon(Icons.refresh),
              label: Text(
                isLoading ? "Loading..." : "Get Jokes",
                style: TextStyle(fontSize: 18.0),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              ),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
                  : jokes.isEmpty
                  ? Center(
                child: Text(
                  "No jokes fetched yet.",
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: jokes.length,
                itemBuilder: (context, index) {
                  final joke = jokes[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 16.0),
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            joke['title']!,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          if (joke['setup']!.isNotEmpty)
                            Text(
                              'Q: ${joke['setup']}',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          if (joke['delivery']!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'A: ${joke['delivery']}',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          if (joke['joke']!.isNotEmpty)
                            Text(
                              joke['joke']!,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.left,
                            ),
                        ],
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
