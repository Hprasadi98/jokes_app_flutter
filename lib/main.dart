import 'package:flutter/material.dart';
import 'joke_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jokes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: JokeListPage(),
    );
  }
}

class JokeListPage extends StatefulWidget {
  const JokeListPage({Key? key}) : super(key: key);

  @override
  _JokeListPageState createState() => _JokeListPageState();
}

class _JokeListPageState extends State<JokeListPage> {
  final JokeService _jokeService = JokeService();
  List<Map<String, dynamic>> _jokesRaw = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCachedJokes();
  }

  Future<void> _fetchJokes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final jokes = await _jokeService.fetchJokesRaw();
      if (jokes.length > 5) {
        _jokesRaw = jokes.sublist(0, 5);
      } else {
        _jokesRaw = jokes;
      }

      await _cacheJokes(_jokesRaw);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch jokes: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCachedJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jokesJson = prefs.getString('cached_jokes');

    if (jokesJson != null) {
      setState(() {
        _jokesRaw = List<Map<String, dynamic>>.from(json.decode(jokesJson));
      });
    }
  }

  Future<void> _cacheJokes(List<Map<String, dynamic>> jokes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jokesJson = json.encode(jokes);
    await prefs.setString('cached_jokes', jokesJson);
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joke App'),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(16.0, 64.0, 16.0, 16.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(0.8, 1),
            colors: <Color>[
              Color(0xff050187),
              Color(0xff4859ca),
              Color(0xff5cb2e1),
              Color(0xff6bd8ff),
            ],
            tileMode: TileMode.mirror,
          ),
        ),
        child: Column(
          children: [
            Text(
              'Laugh Out Loud!',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Colors.orange[50],
                fontWeight: FontWeight.w900,
                fontFamily: 'ComicSans',
                fontSize: 40,
              ),
            ),
            const SizedBox(height: 16.0),
            const SizedBox(height: 16.0),
            Text(
              'Click below to fetch some jokes 👇',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Colors.white, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 28.0),
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchJokes,
              child: Text(
                _isLoading ? "Loading..." : "Get Jokes",
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.all(16.0),
                elevation: 10,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _jokesRaw.isEmpty
                  ? const Center(
                child: Text(
                  'No jokes fetched yet.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black45,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: _jokesRaw.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final joke = _jokesRaw[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          joke['type'] == 'single'
                              ? '😂 Single Joke'
                              : '🤣 ${joke['category']}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          joke['type'] == 'single'
                              ? joke['joke']
                              : '${joke['setup']}\n\n${joke['delivery']}',
                          style: const TextStyle(
                              fontSize: 16.0, color: Colors.black87),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

}


