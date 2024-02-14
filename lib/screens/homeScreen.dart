import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:movie_db/components/post.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_db/utils/api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  String searchTerms = "a";

  var myController = TextEditingController();

  Future<void> dialog(BuildContext context) async {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 43, 42, 42),
          title: const Text(
            'Search',
            style: TextStyle(color: Colors.red),
          ),
          content: TextField(
            style: TextStyle(color: Colors.white),
            controller: myController,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Search',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                setState(() {
                  searchTerms = myController.text;
                });
                Navigator.pop(context);
                print(searchTerms);
              },
            ),
          ],
        );
      },
    );

  }

  Future<dynamic> getPosts() async {
    var data = await Api().getMovies(searchTerms);
    var post = jsonDecode(data);

    return post;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //////////// AppBar //////////////////
      backgroundColor: const Color.fromARGB(255, 37, 36, 36),
      appBar: AppBar(
        title: Center(
          child: const Text(
            'NetWish',
            style: TextStyle(
                color: Color.fromARGB(255, 244, 3, 3),
                fontSize: 25,
                fontWeight: FontWeight.w800),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 37, 36, 36),
        elevation: 20,
      ),

      //////////// Body //////////////////
      body: FutureBuilder(
        future: Future.wait([getPosts()]),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            var posts = snapshot.data[0]["results"];
            // var genres = snapshot.data[1]["genres"];

            // List genreList = [];
            // for (var i = 0; i < posts.length; i++) {
            //   for (var j = 0; j < genres.length; j++) {
            //     if (posts[i]["genre_ids"][j] == genres[j]["id"]) {
            //       genreList.add(genres[j]["name"]);
            //     }
            //   }              
            // }
            
            // print(posts);
            return Column(
              children: [
                //////// Popular on NetWish /////////
                Container(
                  margin: EdgeInsets.only(top: 20, bottom: 10),
                  child: Text(
                    "Catalog",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                //////// posts /////////
                Expanded(
                  child: GridView.count(
                    primary: false,
                    padding: const EdgeInsets.all(15),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.5,
                    mainAxisSpacing: 10,
                    scrollDirection: Axis.vertical,
                    children: [
                      for (var i = 0; i < posts.length; i++)
                        GestureDetector(
                          onTap: () =>
                              {context.go('/movie?id=${posts[i]["id"]}')},
                              // {context.go('/movie',)},
                          child: Post(
                              note: posts[i]["vote_average"],
                              postImage: posts[i]["poster_path"],
                              genre : posts[i]["genre_ids"]
                              ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
      //////////////// footer //////////////////
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 37, 36, 36),
        unselectedItemColor: Color.fromARGB(255, 254, 254, 254),
        selectedItemColor: Colors.red,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                dialog(context);
              },
              child: Icon(Icons.search),
            ),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}