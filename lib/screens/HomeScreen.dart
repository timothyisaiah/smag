import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smag/screens/GraderScreen.dart';
import 'package:smag/screens/ReportsScreen.dart';
// import 'package:smag/screens/LearningScreen.dart';
import 'package:smag/screens/ShopScreen.dart';
import 'package:smag/screens/Website1.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final List<Widget> _cardsToDisplay = <Widget>[
    Card(
      key: UniqueKey(),
      child: Column(
        children: const <Widget>[
          Image(
            image: AssetImage('./assets/images/library.png'),
            height: 150,
            width: 150,
          ),
          Text('library'),
        ],
      ),
    ),
    Card(
      key: UniqueKey(),
      child: Column(
        children: const <Widget>[
          Image(
            image: AssetImage('./assets/images/grader.png'),
            height: 150,
            width: 150,
          ),
          Text('Grader'),
        ],
      ),
      // color: Colors.black45,
    ),
    Card(
      key: UniqueKey(),
      child: Column(
        children: const <Widget>[
          Image(
            image: AssetImage('./assets/images/records.png'),
            height: 150,
            width: 150,
          ),
          Text('Records'),
        ],
      ),
    ),
    Card(
      key: UniqueKey(),
      child: Column(
        children: const <Widget>[
          Image(
            image: AssetImage('./assets/images/website.png'),
            height: 150,
            width: 150,
          ),
          Text('Website'),
        ],
      ),
    ),
  ];
  final List<Widget> _classViews = <Widget>[
    ShopScreen(
      key: UniqueKey(),
    ),
    GraderScreen(
      key: UniqueKey(),
    ),
    ReportsScreen(
      key: UniqueKey(),
    ),
    Website1(
      key: UniqueKey(),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Column(
              children: <Widget>[
                const Image(
                  image: AssetImage('./assets/images/logo.png'),
                  height: 180,
                  width: 150,
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    ' Welcome, Select option ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.black45,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Expanded(
                SizedBox(
                  height: 600,
                  child: GridView.count(
                    shrinkWrap: true,
                    primary: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 8.0,
                    children: List.generate(_cardsToDisplay.length, (index) {
                      return InkWell(
                        child: _cardsToDisplay[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => _classViews[index]),
                          );
                        },
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
