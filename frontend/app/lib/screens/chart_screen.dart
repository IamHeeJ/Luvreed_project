import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:intl/intl.dart';
import 'package:luvreed/screens/calender_screen.dart';
import 'package:luvreed/screens/month_line_chart.dart';
import 'package:luvreed/screens/setting_screen.dart';
import 'package:luvreed/screens/week_line_chart.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:luvreed/constants.dart'; //아이피주소

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  late PageController _controller;
  int _currentPage = 0;

  final List<String> pageTexts = ['어제', '일주일', '한 달'];

  // 사용자의 감정 데이터
  List<List<int>> userData = [];

  double happyLabelRatio = 0; // 행복 레이블 비율
  String feedbackMessage = ''; // 피드백 메시지1(일일)
  String feedbackMessage2 = ''; //피드백메시지2(일일)
  String feedbackMessage3 = ''; //피드백메시지3(일주일)
  String feedbackMessage4 = ''; //피드백메시지4(일주일)
  String feedbackMessage5 = ''; //피드백메시지5(한달)
  String feedbackMessage6 = ''; //피드백메시지6(한달)
  // 빌드에러 때문에 이미지 디폴트값 넣어놈
  String imagePathYesterday = 'assets/images/emotion.png';
  String imagePathLastweek = 'assets/images/emotion.png';
  String imagePathLastmonth = 'assets/images/emotion.png';
  // 두 개의 ID를 저장할 변수
  int userId1 = 0;
  int userId2 = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _currentPage);
    _fetchEmotionYesterday(); // 감정 데이터 가져오기
    _fetchHappyOfWeek();
    _fetchHappyOfMonth();
  }

////////////////////////////////////////////////////////////
// 어제의 감정 데이터를 가져오는 메서드 (GET)
////////////////////////////////////////////////////////////
  Future<void> _fetchEmotionYesterday() async {
    final token = await _secureStorage.read(key: 'token');

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/emotionofyesterday'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      userData ??= [];
      userData.clear();
      List<int> ids = [];
      for (final data in responseData) {
        ids.add(data['id']);
        final List<int> emotions = [
          data['happy'] ?? 0,
          data['surprised'] ?? 0,
          data['anxious'] ?? 0,
          data['sad'] ?? 0,
          data['annoyed'] ?? 0,
          data['angry'] ?? 0
        ];
        userData.add(emotions);
        print('어제 감정 정보 가져오기 성공 ');
        print('emotions : $emotions');
      }
      if (ids.length >= 2) {
        ids.sort();
        userId1 = ids[0];
        userId2 = ids[1];
        print('userId1: $userId1, userId2: $userId2');
      }
      int totalLabels = getTotalLabels(userData);
      // print('전체레이블개수 : $totalLabels');
      normalizeUserData();
      happyLabelRatio = calculateHappyLabelRatio(userData);
      feedbackMessage = generateFeedbackMessage(happyLabelRatio, totalLabels);
      feedbackMessage2 = generateFeedbackMessage2(happyLabelRatio, totalLabels);
      imagePathYesterday = yesterdayImage(happyLabelRatio, totalLabels);
      setState(() {});
    } else {
      final List<int> emotions = [0, 0, 0, 0, 0, 0];
      userData.add(emotions);
      print('어제 데이터가 없습니다.');
    }
  }

  ///////////////////////////////////////////////////////////////
  ///  일주일 행복 데이터 (GET)
  ///////////////////////////////////////////////////////////////
  Future<List<Map<String, dynamic>>> _fetchHappyOfWeek() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token'); // 저장된 토큰 읽기

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/happyoflastweek'),
      headers: {
        'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // print('일주일 행복 데이터 get 성공');
      print('가져온 데이터: $data'); // 데이터 로그로 출력

      // 첫날과 마지막 날의 행복 값 찾기
      int firstDayHappy = 0;
      int lastDayHappy = 0;
      for (var d in data) {
        if (d['daysAgo'] == 7) {
          firstDayHappy = d['happy'];
        } else if (d['daysAgo'] == 1) {
          lastDayHappy = d['happy'];
        }
      }

      // 행복 값 변화량 계산
      int happyChange = lastDayHappy - firstDayHappy;

      // 평균 변화율 계산
      double averageChangeRate = happyChange / 7.0;

      // 전체 레이블 개수 계산
      int totalLabels = getTotalLabels(userData);

      // 피드백 메시지 생성
      feedbackMessage3 =
          generateFeedbackMessage3(happyLabelRatio, totalLabels, [
        ...data,
        {'averageChangeRate': averageChangeRate}
      ]);
      feedbackMessage4 =
          generateFeedbackMessage4(happyLabelRatio, totalLabels, [
        ...data,
        {'averageChangeRate': averageChangeRate}
      ]);
      imagePathLastweek = weekMonthImage(happyLabelRatio, totalLabels, [
        ...data,
        {'averageChangeRate': averageChangeRate}
      ]);

      // 디버깅 로그
      // print('첫날 행복 값: $firstDayHappy');
      // print('마지막 날 행복 값: $lastDayHappy');
      // print('평균 변화율: $averageChangeRate');
      // print('피드백메세지3 : $feedbackMessage3');

      return [
        ...data,
        {'averageChangeRate': averageChangeRate}
      ].cast<Map<String, dynamic>>();
    } else {
      throw Exception('일주일 행복 데이터 get 실패');
    }
  }

//////////////////////////////////////////////////////////////
//   한달  행복 데이터 (GET)
//////////////////////////////////////////////////////////////
  Future<List<Map<String, dynamic>>> _fetchHappyOfMonth() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token'); // 저장된 토큰 읽기

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/happyoflastmonth'),
      headers: {
        'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // print('한달 행복 데이터 get 성공');
      print('가져온 데이터: $data'); // 데이터 로그로 출력

      // 첫 날과 마지막 날의 행복 값 찾기
      int firstDayHappy = 0;
      int lastDayHappy = 0;
      for (var d in data) {
        if (d['daysAgo'] == 30) {
          firstDayHappy = d['happy'];
        } else if (d['daysAgo'] == 1) {
          lastDayHappy = d['happy'];
        }
      }

      // 행복 값 변화량 계산
      int happyChange = lastDayHappy - firstDayHappy;

      // 평균 변화율 계산
      double averageChangeRate = happyChange / 30;

      // 전체 레이블 개수 계산
      int totalLabels = getTotalLabels(userData);

      // 피드백 메시지 생성
      feedbackMessage5 = generateFeedbackMessage3(
        happyLabelRatio,
        totalLabels,
        [
          ...data,
          {'averageChangeRate': averageChangeRate}
        ],
      );
      feedbackMessage6 = generateFeedbackMessage4(
        happyLabelRatio,
        totalLabels,
        [
          ...data,
          {'averageChangeRate': averageChangeRate}
        ],
      );
      imagePathLastmonth = weekMonthImage(
        happyLabelRatio,
        totalLabels,
        [
          ...data,
          {'averageChangeRate': averageChangeRate}
        ],
      );
      // print('피드백메세지5 : $feedbackMessage5');

      return [
        ...data,
        {'averageChangeRate': averageChangeRate},
      ].cast<Map<String, dynamic>>();
    } else {
      throw Exception('한달 행복 데이터 get 실패');
    }
  }

  //////////////////////////////////////////////////////////////
  // 사용자의 감정 데이터를 정규화하는 메서드
  ////////////////////////////////////////////////////////////////
  void normalizeUserData() {
    for (int i = 0; i < userData.length; i++) {
      userData[i] = normalizeData(userData[i], 50);
    }
  }

  List<int> normalizeData(List<int> data, int max) {
    List<int> normalizedData =
        data.map((value) => (value * 50 ~/ max)).toList();
    return normalizedData;
  }

  //////////////////////////////////////////////////////////////
  // 일일 '행복' 레이블의 비율을 계산하는 함수 (일일피드백)
  //////////////////////////////////////////////////////////////
  double calculateHappyLabelRatio(List<List<int>> data) {
    int totalHappyLabels = 0;
    int totalLabels = 0;
    for (List<int> userData in data) {
      totalHappyLabels += userData[0];
      totalLabels += userData.reduce((a, b) => a + b);
    }
    double ratio = totalHappyLabels / totalLabels;
    return ratio;
  }

/////////////////////////////////////////////////////////////////////
// 일일 행복 레이블 비율에 따른 피드백 메시지 생성하는 함수
///////////////////////////////////////////////////////////////////////
  String generateFeedbackMessage(double happyLabelRatio, int totalLabels) {
    // print(
    //     '일일감정피드백 : totalLabels:$totalLabels, happyLabelRatio:$happyLabelRatio');

    if (totalLabels < 20) {
      return '대화가 필요해';
    } else if (happyLabelRatio >= 0.5) {
      return '행복이 넘쳐나요!';
    } else if (happyLabelRatio >= 0.25 && happyLabelRatio < 0.5) {
      return '잘하고 있어요!';
    } else {
      return '분발합시다...';
    }
  }

  String generateFeedbackMessage2(double happyLabelRatio, int totalLabels) {
    if (totalLabels < 20) {
      return '두 분의 대화가 충분하지 않은 것 같아요.\n서로 더 많은 주제에 대해 이야기를 나누고\n공감해주는 모습을 보여주면 좋을 것 같아요.';
    } else if (happyLabelRatio >= 0.5) {
      return '서로를 존중하고 배려하는 마음이 멋있어요.\n지금처럼 바람직한 대화 습관을 유지해봅시다!';
    } else if (happyLabelRatio >= 0.25 && happyLabelRatio < 0.5) {
      return '다양한 감정이 나타나고 있어요.\n지금도 잘하고 있지만 따뜻한 대화를 더 많이\n나눌 수 있도록 조금만 더 노력해봅시다!';
    } else {
      return '서로에게 따뜻하고 행복한 대화가 필요해보여요.\n앞으로 더 나은 대화 습관을 위해 노력해봅시다!';
    }
  }

  String yesterdayImage(double happyLabelRatio, int totalLabels) {
    if (totalLabels < 20) {
      return 'assets/images/emotion_thinking.png';
    } else if (happyLabelRatio >= 0.5) {
      return 'assets/images/emotion_lovely.png';
    } else if (happyLabelRatio >= 0.25 && happyLabelRatio < 0.5) {
      return 'assets/images/emotion_smile.png';
    } else {
      return 'assets/images/emotion_sad.png';
    }
  }

/////////////////////////////////////////////////////////////////////
// 일주일, 한달 행복 레이블 비율에 따른 피드백 메시지 생성하는 함수
///////////////////////////////////////////////////////////////////////
  String generateFeedbackMessage3(double happyLabelRatio, int totalLabels,
      List<Map<String, dynamic>> happyData) {
    double averageChangeRate = happyData.last['averageChangeRate'];
    // print('생성된 피드백메세지3: averageChangeRate = $averageChangeRate');

    if (averageChangeRate > 0) {
      return '행복이 증가하는 추세예요.';
    } else if (averageChangeRate < 0) {
      return '행복이 하락하는 추세예요.';
    } else {
      return '행복 수준이 불안정해요.';
    }
  }

  String generateFeedbackMessage4(double happyLabelRatio, int totalLabels,
      List<Map<String, dynamic>> happyData) {
    double averageChangeRate = happyData.last['averageChangeRate'];
    // print('생성된 피드백메세지4: averageChangeRate = $averageChangeRate');

    if (averageChangeRate > 0) {
      return '계속해서 함께 행복을 키워나가봐요!';
    } else if (averageChangeRate < 0) {
      return '서로를 더 이해하고 배려하는 자세가\n필요해 보여요.';
    } else {
      return '행복한 대화를 안정적으로 늘려갈 수 있도록\n노력해보아요!';
    }
  }

  String weekMonthImage(double happyLabelRatio, int totalLabels,
      List<Map<String, dynamic>> happyData) {
    double averageChangeRate = happyData.last['averageChangeRate'];
    // print('선택된 이미지 경로: averageChangeRate = $averageChangeRate');

    if (averageChangeRate > 0) {
      return 'assets/images/emotion_lovely.png';
    } else if (averageChangeRate < 0) {
      return 'assets/images/emotion_sad.png';
    } else {
      return 'assets/images/emotion_wow.png';
    }
  }

  // 전체 레이블 개수 계산하는 함수
  int getTotalLabels(List<List<int>> data) {
    int totalLabels = 0;
    for (List<int> userData in data) {
      totalLabels += userData.reduce((a, b) => a + b);
    }
    return totalLabels;
  }

  // 빨강 파랑 메세지
Widget _buildIconTextMessage() {
    return const Row(
      children: [
        Icon(
          // Icons.crop_square_outlined,
          Icons.circle,
          size: 10,
          color: Color.fromARGB(255, 255, 156, 149),
        ),
        Text(
          ' Me      ',
          style: TextStyle(
            color: Color.fromARGB(255, 138, 138, 138),
            fontSize: 14,
            // fontWeight: FontWeight.bold,
          ),
        ),
        Icon(
          // Icons.crop_square_outlined,
          Icons.circle,
          size: 10,
          color: Color.fromARGB(255, 119, 194, 255),
        ),
        Text(
          ' Lover',
          style: TextStyle(
            color: Color.fromARGB(255, 138, 138, 138),
            fontSize: 14,
            // fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  /////////////////////////////////////////////////////////////////////
  ///       빌드 메서드
  /////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime eightDaysAgo = now.subtract(const Duration(days: 8));
    DateTime yesterday = now.subtract(const Duration(days: 1));
    DateTime startDate = DateTime(now.year, now.month - 1, now.day - 1);
    DateTime endDate = now.subtract(const Duration(days: 1));

    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFFFFFFFF),
          title: Hero(
            tag: 'mainlogo',
            child: Image.asset(
              'assets/images/luvreed.png',
              height: 28,
              width: 270,
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CalenderScreen(),
              ),
            ),
            icon: const Icon(
              Icons.calendar_today_outlined,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingScreen(),
                ),
              ),
              icon: const Icon(
                Icons.settings,
                size: 27,
                color: Color(0xFF545454),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              //////////////////////////////////////////////////////////
              //             통계 화면 3가지
              //////////////////////////////////////////////////////////
              child: PageView(
                controller: _controller,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      Center(
                        child: SizedBox(
                          width: 290,
                          height: 290,
                          //////////////////////////////////////////////////////////
                          //           1. 일일 차트(레이더 차트)
                          //////////////////////////////////////////////////////////
                          child: RadarChart(
                            graphColors: [
                              const Color(0xFFFF5454).withOpacity(0.49),
                              const Color(0xFF5599FF).withOpacity(0.47),
                            ],
                            axisColor: Colors.black.withOpacity(0),
                            outlineColor: Color.fromARGB(255, 209, 209, 209),
                            featuresTextStyle: const TextStyle(
                              color: Color.fromARGB(255, 148, 148, 148),
                              fontSize: 14,
                            ),
                            
                            sides: 6,
                            ticks: const [40], // 일일 육각형 그래프 최대값
                            features: const [
                              "행복",
                              "놀람",
                              "불안",
                              "분노",
                              "슬픔",
                              "짜증",
                            ],
                            data: userData,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIconTextMessage(),
                      ],
                    ),
                      Container(
                        height: 30,
                        width: 260,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color.fromARGB(255, 223, 223, 223),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            // 'assets/images/emotion.png',
                            imagePathYesterday,
                            width: 30,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 피드백 메시지 표시 //
                              Text(
                                feedbackMessage,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF767676),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2), // 간격 추가
                              Text(
                                feedbackMessage2,
                                style: const TextStyle(
                                  color: Color(0xFF767676),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 65,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DateRangeDisplay(
                        eightDaysAgo: eightDaysAgo,
                        yesterday: yesterday,
                      ),
                      const SizedBox(
                        height: 48,
                      ),
                      //////////////////////////////////////////////
                      ///       2.   1주일  차트
                      /// //////////////////////////////////////////
                      const WeekLineChart(),
                       const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIconTextMessage(),
                      ],
                    ),
                      Container(
                        height: 30,
                        width: 260,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color.fromARGB(255, 223, 223, 223),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            // 'assets/images/emotion.png',
                            imagePathLastweek,
                            width: 30,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feedbackMessage3,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF767676),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                feedbackMessage4,
                                style: const TextStyle(
                                  color: Color(0xFF767676),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${startDate.month}월 ${startDate.day}일 - ${endDate.month}월 ${endDate.day}일',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E30),
                        ),
                      ),
                      const SizedBox(
                        height: 48,
                      ),
                      //////////////////////////////////////////////////////////
                      ///           3. 1달 차트
                      //////////////////////////////////////////////////////////
                      const MonthLineChart(),
                       const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIconTextMessage(),
                      ],
                    ),
                      Container(
                        height: 30,
                        width: 260,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color.fromARGB(255, 223, 223, 223),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            // 'assets/images/emotion.png',
                            imagePathLastmonth,
                            width: 30,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feedbackMessage5,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF767676),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                feedbackMessage6,
                                style: const TextStyle(
                                  color: Color(0xFF767676),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                    ],
                  )
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_currentPage > 0) {
                          _controller.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        }
                      },
                      icon: const Icon(Icons.arrow_left_rounded),
                      iconSize: 40,
                    ),
                    Text(
                      pageTexts[_currentPage],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF2E2E30),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (_currentPage < 2) {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        }
                      },
                      icon: const Icon(Icons.arrow_right_rounded),
                      iconSize: 40,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 60,
                ),
              ],
            ),
          ],
        ),
      ),
    );
    
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class DateRangeDisplay extends StatelessWidget {
  final DateTime eightDaysAgo;
  final DateTime yesterday;

  const DateRangeDisplay(
      {super.key, required this.eightDaysAgo, required this.yesterday});

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('M월 d일');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${dateFormat.format(eightDaysAgo)} - ${dateFormat.format(yesterday)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2E30),
          ),
        ),
      ],
    );
  }
}
