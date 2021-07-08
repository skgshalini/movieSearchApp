import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tradexa_app/models/movie.dart';
import 'package:tradexa_app/widgets/moviesWidget.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _App createState() => _App();
}

class _App extends State<App> {
  List<Movie> _movies = new List<Movie>();
  String path = "barbie";
  bool b = true;
  @override
  void initState() {
    super.initState();
    _populateAllMovies();
  }

  void _populateAllMovies() async {
    final movies = await _fetchAllMovies();
    setState(() {
      _movies = movies;
    });
  }

  Future<List<Movie>> _fetchAllMovies() async {
    final url = "https://www.omdbapi.com/?s=${path}&page=2&apikey=491da562";
    final response = await http.get(Uri.parse(Uri.encodeFull(url)));

    if (response.statusCode == 200) {
      b = true;
      final result = jsonDecode(response.body);
      Iterable list = result["Search"];
      if (list == null) {
        setState(() {
          b = false;
        });
        throw Exception("Failed to load movies!");
      }
      return list.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception("Failed to load movies!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Movies App",
        home: Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Home',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    onChanged: (v) {
                      path = v;
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for movie',
                      border: OutlineInputBorder(),
                      suffixIcon: GestureDetector(
                        child: Icon(
                          Icons.search,
                        ),
                        onTap: () {
                          _populateAllMovies();
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: b
                        ? MoviesWidget(movies: _movies)
                        : Text('Nothing found related to the search')),
              ],
            ),
          ),
        ));
  }
}
