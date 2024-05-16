import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Import for Timer
import 'package:carousel_slider/carousel_slider.dart';
import 'about.dart';
import 'fixtures/fixture.dart';
import 'pointstable.dart';
import 'Teams/teams.dart';
import 'Players/topplayers.dart';

class PCDashBoardScreen extends StatefulWidget {
  static String tag = '/CricketDashBoard';

  @override
  _PCDashBoardScreenState createState() => _PCDashBoardScreenState();
}

class _PCDashBoardScreenState extends State<PCDashBoardScreen> {
  List<dynamic> fixtures = [];
  Map<String, dynamic> liveMatchData = {};
  Map<String, dynamic> firstInningScore = {};
  Map<String, dynamic> secondInningScore = {};
  List<dynamic> strikerNonstrikerbowler = [];
  late double screenWidth;
  late Timer _timer; // Timer variable for blinking effect
  late Timer _scoreTimer; // Timer variable for fetching score periodically
  bool _isLiveVisible = true; // Initial visibility of "Live" text

   @override
  void initState() {
    super.initState();
    fetchFixtures();
    fetchLiveMatchData();
    fetchFirstInningScore();
    _startTimer();
    _startScoreTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _scoreTimer.cancel();
    super.dispose();
  }

  

  Future<void> fetchFixtures() async {
    final response = await http.get(
        Uri.parse('https://radshahmat.tech/rest_apis/upcoming_matches.php'));
    if (response.statusCode == 200) {
      setState(() {
        fixtures = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load fixtures');
    }
  }

  Future<void> fetchLiveMatchData() async {
    final liveMatchResponse = await http.get(
        Uri.parse('https://radshahmat.tech/rest_apis/toss_n_live_team.php'));
    if (liveMatchResponse.statusCode == 200) {
      setState(() {
        liveMatchData = json.decode(liveMatchResponse.body)[0];
      });
    } else {
      throw Exception('Failed to load live match data');
    }
  }

  Future<void> fetchFirstInningScore() async {
    final scoreResponse = await http.get(Uri.parse(
        'https://radshahmat.tech/rest_apis/first_inn_score.php?match_id=${liveMatchData['fix_id']}'));
    if (scoreResponse.statusCode == 200) {
      setState(() {
        firstInningScore = json.decode(scoreResponse.body)[0];
      });
    } else {
      throw Exception('Failed to load first inning score');
    }
  }

  Future<void> fetchSecondInningScore() async {
    if (liveMatchData.isNotEmpty) {
      final scoreResponse = await http.get(Uri.parse(
          'https://radshahmat.tech/rest_apis/second_inn_score.php?match_id=${liveMatchData['fix_id']}'));
      if (scoreResponse.statusCode == 200) {
        setState(() {
          secondInningScore = json.decode(scoreResponse.body)[0];
        });
      } else {
        throw Exception('Failed to load second inning score');
      }
    }
  }

  Future<void> fetchStrikerNonstrikerBowler() async {
    if (liveMatchData.isNotEmpty) {
      final scoreResponse = await http.get(Uri.parse(
          'https://radshahmat.tech/rest_apis/get_striker_nonstriker_bowler.php?match_id=${liveMatchData['fix_id']}'));
      if (scoreResponse.statusCode == 200) {
        setState(() {
          strikerNonstrikerbowler = json.decode(scoreResponse.body);
          print('$strikerNonstrikerbowler');
        });
      } else {
        throw Exception('Failed to load Striker Non Striker and Bowler');
      }
    }
  }
  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        _isLiveVisible =
            !_isLiveVisible; // Toggle the visibility of "Live" text
      });
    });
  }

  void _startScoreTimer() {
    _scoreTimer = Timer.periodic(Duration(seconds: 5), (timer) {

      fetchFirstInningScore();
      fetchSecondInningScore();
      fetchStrikerNonstrikerBowler();
    });
  }

  String convertBallsToOvers(String balls) {
    int totalBalls = int.parse(balls);

    int overs = totalBalls ~/ 6; // Get the integer part for complete overs
    int ballsRemaining = totalBalls % 6; // Get the remaining balls

    return '$overs.$ballsRemaining'; // Combine overs and balls
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      //backgroundColor: Colors.indigo.withOpacity(.20),
      backgroundColor: Color.fromARGB(0xFF, 0x2B, 0x2D, 0x33),
      appBar: AppBar(
        backgroundColor: Colors.indigo.withOpacity(.03),
        title: Text(
          'PSTU Cricket Fever',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        backgroundColor: Color.fromRGBO(201, 215, 225, 1.0),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 200.0,
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 200.0,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: MediaQuery.of(context).size.width / 200,
                  viewportFraction: 1,
                ),
                items: _buildSliderItems(),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text(
                'Home',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text(
                'Calendar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AboutDeveloperPage(), // Define AboutDeveloperPage
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text(
                'Gallery',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AboutDeveloperPage(), // Define AboutDeveloperPage
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text(
                'About',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AboutDeveloperPage(), // Define AboutDeveloperPage
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Match',
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            ),
            Container(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: fixtures.length + (liveMatchData.isNotEmpty ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (liveMatchData.isNotEmpty && index == 0) {
                    return _buildLiveMatchCard();
                  } else {
                    var fixture =
                        fixtures[index - (liveMatchData.isNotEmpty ? 1 : 0)];
                    return _buildFixtureCard(fixture);
                  }
                },
              ),
            ),
            SizedBox(height: 16),
            _buildDashboardButton(
              context,
              title: 'Fixture',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Fixture()), // Define Fixture
                );
              },
            ),
            _buildDashboardButton(
              context,
              title: 'Teams',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TeamsPage()), // Define TeamsPage
                );
              },
            ),
            _buildDashboardButton(
              context,
              title: 'Point Table',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CricketPointsTablePage()), // Define CricketPointsTablePage
                );
              },
            ),
            _buildDashboardButton(
              context,
              title: 'Leaderboard',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TopPlayers()), // Define TopPlayers
                );
              },
            ),
            _buildDashboardButton(
              context,
              title: 'History',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSliderItems() {
    List<Widget> items = [
      'assets/images/slider1.jpg',
      'assets/images/slider2.jpg',
      'assets/images/slider3.jpg',
    ].map((item) {
      return Container(
        width: double.infinity,
        child: Image.asset(
          item,
          fit: BoxFit.cover,
        ),
      );
    }).toList();

    return items;
  }

  Widget _buildLiveMatchCard() {
    String tossWinner = liveMatchData['toss_team_name'];
    String selectedAction = liveMatchData['selected'];
    String formattedDate = liveMatchData['match_formatted_date'];
    String formattedTime = liveMatchData['match_formatted_time'];

    // Check if score data is null for either first or second innings
    bool isFirstInningScoreNull = firstInningScore.isEmpty;
    bool isSecondInningScoreNull = secondInningScore.isEmpty;

    // first innings running or not
    bool isFirstInningCompleted = firstInningScore['status'] == '1';

    // striker , non striker ,bowler info
    String strikerName = '';
    String strikerRuns = '';
    String strikerBallsplayed = '';
    String nonStrikerName = '';
    String nonStrikerRuns = '';
    String nonstrikerBallsplayed = '';
    String bowlerName = '';
    String bowlerOversbowled = '';
    String bowlerRunsgiven = '';
    String bowlerWicket = '';
    
    // Loop through strikerNonstrikerbowler list to find striker and non-striker data
    for (var playerData in strikerNonstrikerbowler) {
      if (playerData['status'] == '1') {
        strikerName = playerData['name'];
        strikerRuns = playerData['runs'];
        strikerBallsplayed = playerData['balls_played'];
      } else if (playerData['status'] == '2') {
        nonStrikerName = playerData['name'];
        nonStrikerRuns = playerData['runs'];
        nonstrikerBallsplayed = playerData['balls_played'];
      } else if (playerData['status'] == '3') {
        bowlerName = playerData['name'];
        bowlerOversbowled = playerData['overs_bowled'];
        bowlerRunsgiven = playerData['runs_given'];
        bowlerWicket = playerData['wickets'];
      }
    }

    return Container(
      margin: EdgeInsets.all(16),
      width: screenWidth - 30,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color.fromARGB(255, 66, 140, 67),
            Color.fromARGB(255, 31, 66, 39)
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            child: Text(
              '$formattedDate  $formattedTime',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Positioned(
            top: 7,
            right: 10,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: _isLiveVisible ? 1.0 : 0.0, // Toggle opacity
              child: Container(
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: Colors.red, // Set background color to red
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'Live',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 22),
                isFirstInningScoreNull || isSecondInningScoreNull
                    ? CircularProgressIndicator()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '${firstInningScore['batting_team_name']}',
                                  style: TextStyle(color: Colors.white,
                                    fontWeight: FontWeight.bold,),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      '${firstInningScore['batting_team_logo']}',
                                      height: 50,
                                      width: 50,
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${firstInningScore['runs']}/${firstInningScore['wickets']}',
                                          style: TextStyle(color: Colors.white,
                                            fontWeight: FontWeight.bold,),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          '(${convertBallsToOvers(firstInningScore['bowls'])})',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  isFirstInningCompleted
                                      ? '$strikerName $strikerRuns ($strikerBallsplayed)*\n$nonStrikerName $nonStrikerRuns ($nonstrikerBallsplayed)'
                                      : (() {
                                    try {
                                      return '$bowlerName $bowlerWicket - $bowlerRunsgiven (${convertBallsToOvers(bowlerOversbowled)})';
                                    } catch (e) {
                                      return '-';
                                    }
                                  })(),
                                  style: TextStyle(color: Color.fromRGBO(252, 250, 250, 1.0)),
                                )

                              ],
                            ),
                          ),
                          Text(
                            'VS',
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 20.0,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                            '${secondInningScore['batting_team_name']}',
                                  style: TextStyle(color: Colors.white,
                                    fontWeight: FontWeight.bold,),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          isFirstInningCompleted
                                              ? 'Yet to'
                                              : '${secondInningScore['runs']}/${secondInningScore['wickets']}',
                                          style: TextStyle(color: Colors.white,
                                            fontWeight: FontWeight.bold,),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          isFirstInningCompleted
                                              ? 'Bat'
                                              : '(${convertBallsToOvers(secondInningScore['bowls'])})',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 10),
                                    Image.network(
                                      '${secondInningScore['batting_team_logo']}',
                                      height: 50,
                                      width: 50,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  isFirstInningCompleted
                                      ? '$bowlerName $bowlerWicket - $bowlerRunsgiven (${convertBallsToOvers(bowlerOversbowled)})'
                                      : '$strikerName $strikerRuns ($strikerBallsplayed)*\n$nonStrikerName $nonStrikerRuns ($nonstrikerBallsplayed)',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                SizedBox(height: 10),
                Text(
                  '$tossWinner won the toss and elected to $selectedAction first',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixtureCard(dynamic fixture) {
    return Container(
      margin: EdgeInsets.all(16),
      width: screenWidth - 30,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color.fromARGB(255, 234, 57, 104),
            Color.fromARGB(255, 200, 5, 207)
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${fixture['teamA_name']} vs ${fixture['teamB_name']}',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              '${fixture['match_formatted_date']} at ${fixture['match_formatted_time']}',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  fixture['teamA_logo'],
                  height: 50,
                  width: 50,
                ),
                SizedBox(width: 20),
                Text(
                  'VS',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(width: 20),
                Image.network(
                  fixture['teamB_logo'],
                  height: 50,
                  width: 50,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context,
      {required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.indigo.withOpacity(0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.sports_cricket, color: Colors.white),
                SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
