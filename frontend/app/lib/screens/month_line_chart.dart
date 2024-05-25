import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:luvreed/screens/my_month_line_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:luvreed/constants.dart'; //아이피주소

class MonthLineChart extends StatefulWidget {
  const MonthLineChart({super.key});

  @override
  _MonthLineChartState createState() => _MonthLineChartState();
}

class _MonthLineChartState extends State<MonthLineChart> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  List<Map<String, dynamic>>? happyData;

  @override
  void initState() {
    super.initState();
    _fetchHappyData();
  }

  //////////아래 api에서 가져온 데이터로 행복 통계 상태 업데이트 /////////////
  Future<void> _fetchHappyData() async {
    try {
      final data = await _fetchHappyOfMonth();
      setState(() {
        happyData = data;
      });
    } catch (e) {
      // Handle error
    }
  }

/////////// 한달  행복 데이터  get ////////////////////////
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
      print('한달 행복 데이터 get 성공');
      print('가져온 데이터: $data'); // 데이터 로그로 출력
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('한달 행복 데이터 get 실패');
    }
  }

  //////////// 그래프 점 //////////////////////
  List<FlSpot> _getSpotsForUser(List<Map<String, dynamic>> data,
      {required int userId}) {
    final spots = <FlSpot>[];
    for (final entry in data) {
      if (entry['userId'] == userId) {
        final x =
            (31 - entry['daysAgo'].toDouble()).toDouble(); // 명시적으로 double로 변환
        // final x = entry['daysAgo'].toDouble(); // Adjust x value according to your API response
        spots.add(FlSpot(x, entry['happy'].toDouble()));
      }
    }
    return spots;
  }

  ///////////////////////////////////////////////////////////////////
  ///   빌드 메서드
  ///////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    if (happyData == null || happyData!.length < 2) {
      return const CircularProgressIndicator();
    }

    final userIds = happyData!.map((data) => data['userId']).toSet().toList();
    if (userIds.length != 2) {
      return const Text('두 개의 고유한 사용자 ID가 필요합니다.');
    }

    final user1Id = userIds[0];
    final user2Id = userIds[1];

    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: SizedBox(
        width: 320,
        height: 220,
        child: Stack(
          children: [
            MyMonthLineChart(
              lineColor: const Color(0xFFD41104),
              spots: _getSpotsForUser(happyData!, userId: user1Id),
            ),
            Positioned.fill(
              child: MyMonthLineChart(
                lineColor: const Color(0xFF165BAA),
                spots: _getSpotsForUser(happyData!, userId: user2Id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:luvreed/screens/my_month_line_chart.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:luvreed/constants.dart'; //아이피주소


// class MonthLineChart extends StatefulWidget {
//   const MonthLineChart({Key? key}) : super(key: key);

//   @override
//   _MonthLineChartState createState() => _MonthLineChartState();
// }

// class _MonthLineChartState extends State<MonthLineChart> {
//   final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

//   List<Map<String, dynamic>>? happyData;

//   @override
//   void initState() {
//     super.initState();
//     _fetchHappyData();
//   }

//   //////////아래 api에서 가져온 데이터로 행복 통계 상태 업데이트 /////////////
//   Future<void> _fetchHappyData() async {
//     try {
//       final data = await _fetchHappyOfMonth();
//       setState(() {
//         happyData = data;
//       });
//     } catch (e) {
//       // Handle error
//     }
//   }

// /////////// 한달  행복 데이터  get ////////////////////////
//   Future<List<Map<String, dynamic>>> _fetchHappyOfMonth() async {
//     final storage = FlutterSecureStorage();
//     final token = await storage.read(key: 'token'); // 저장된 토큰 읽기

//     final response = await http.get(
//       Uri.parse('$apiBaseUrl/api/happyoflastmonth'),
//       headers: {
//         'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
//       },
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = jsonDecode(response.body);
//       print('한달 행복 데이터 get 성공');
//       print('가져온 데이터: $data'); // 데이터 로그로 출력
//       return data.cast<Map<String, dynamic>>();
//     } else {
//       throw Exception('한달 행복 데이터 get 실패');
//     }
//   }

//   //////////// 그래프 점 //////////////////////
//   List<FlSpot> _getSpotsForUser(List<Map<String, dynamic>> data, {required int userId}) {
//     final spots = <FlSpot>[];
//     for (final entry in data) {
//       if (entry['userId'] == userId) {
//         final x =
//             (31 - entry['daysAgo'].toDouble()).toDouble(); // 명시적으로 double로 변환
//         // final x = entry['daysAgo'].toDouble(); // Adjust x value according to your API response
//         spots.add(FlSpot(x, entry['happy'].toDouble()));
//       }
//     }
//     return spots;
//   }


//   ///////////////////////////////////////////////////////////////////
//   ///   빌드 메서드 
//   ///////////////////////////////////////////////////////////////////
  
//   @override
// Widget build(BuildContext context) {
//   if (happyData == null || happyData!.length < 2) {
//     return const CircularProgressIndicator();
//   }

//   final userIds = happyData!.map((data) => data['userId']).toSet().toList();
//   if (userIds.length != 2) {
//     return const Text('두 개의 고유한 사용자 ID가 필요합니다.');
//   }

//   final user1Id = userIds[0];
//   final user2Id = userIds[1];

//   return Center(
//     child: Expanded(
//       child: SizedBox(
//         width: 320,
//         height: 220,
//         child: Stack(
//           children: [
//             MyMonthLineChart(
//               lineColor: Color(0xFFD41104),
//               spots: _getSpotsForUser(happyData!, userId: user1Id),
//             ),
//             Positioned.fill(
//               child: MyMonthLineChart(
//                 lineColor: Color(0xFF165BAA),
//                 spots: _getSpotsForUser(happyData!, userId: user2Id),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
// }
