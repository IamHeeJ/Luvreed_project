// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/painting.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/widgets.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:luvreed/constants.dart'; //아이피주소

// class CalenderScreen extends StatefulWidget {
//   const CalenderScreen({super.key});

//   @override
//   State<CalenderScreen> createState() => _CalenderScreenState();
// }

// class Emotion {
//   String title;

//   Emotion(this.title);
// }

// class _CalenderScreenState extends State<CalenderScreen> {
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

//   DateTime selectedDate = DateTime.utc(
//     DateTime.now().year,
//     DateTime.now().month,
//     DateTime.now().day,
//   );

//   List<Map<String, dynamic>> selectedSchedules = []; // 선택된 날짜에 해당하는 일정을 저장할 리스트

//   @override
//   void initState() {
//     super.initState();
//     fetchAllSchedule().then((schedules) {
//       setState(() {
//         selectedSchedules = schedules;
//       });
//     });
//   }
//   void _refreshSchedules() async {
//     final schedules = await fetchAllSchedule();
//     setState(() {
//       selectedSchedules = schedules;
//     });
//   }

// ////////////////////////////////////////////////////////////////////
//   ///  전체  일정을 가져오는 메서드 (GET)
//   ////////////////////////////////////////////////////////////////////
//   Future<List<Map<String, dynamic>>> fetchAllSchedule() async {
//     final token = await _secureStorage.read(key: 'token'); // 저장된 토큰 읽기

//     final response = await http.get(
//       Uri.parse('$apiBaseUrl/api/schedule'),
//       headers: {
//         'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
//       },
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
//       // 전체 일정 데이터 반환
//       final List<Map<String, dynamic>> allSchedules =
//           data.map((schedule) => schedule as Map<String, dynamic>).toList();
//       return allSchedules;
//     } else {
//       throw Exception('전체 일정 가져오기 실패');
//     }
//   }

//   ////////////////////////////////////////////////////////////////////
//   ///   클릭한 일정을 가져오는 메서드 (GET)
//   ////////////////////////////////////////////////////////////////////
//   Future<List<Map<String, dynamic>>> _fetchSchedule(DateTime date) async {
//     final token = await _secureStorage.read(key: 'token'); // 저장된 토큰 읽기

//     final response = await http.get(
//       Uri.parse('$apiBaseUrl/api/schedule'),
//       headers: {
//         'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
//       },
//     );
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
//       // 해당 날짜의 일정만 필터링하여 반환
//       final List<Map<String, dynamic>> filteredSchedules = data
//           .where((schedule) {
//             final memoDate = DateTime.parse(schedule['memoDate']);
//             return memoDate.year == date.year &&
//                 memoDate.month == date.month &&
//                 memoDate.day == date.day;
//           })
//           .map((schedule) => schedule as Map<String, dynamic>)
//           .toList();
//       print('스케줄 GET 성공: $filteredSchedules'); // 가져온 일정 데이터 출력
//       return filteredSchedules;
//     } else {
//       throw Exception('스케줄 GET 실패 ');
//     }
//   }

//   //////////////////////////////////////////////////////////////////////
//   ///   일일 대표 감정 (GET)
//   //////////////////////////////////////////////////////////////////////
//   Future<Map<String, dynamic>> _fetchDailyEmotion(DateTime date) async {
//     final token = await _secureStorage.read(key: 'token');

//     final response = await http.get(
//       Uri.parse(
//           '$apiBaseUrl/api/emotionofschedule?date=${date.toIso8601String().split('T')[0]}'),
//       headers: {
//         'Authorization': 'Bearer $token', // 헤더에 토큰을 추가합니다.
//       },
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

//       final Map<String, int> emotionCounts = {
//         'happy': 0,
//         'surprised': 0,
//         'anxious': 0,
//         'sad': 0,
//         'angry': 0,
//         'annoyed': 0,
//       };

//       final filteredData = data.where((emotionData) =>
//           emotionData['date'] == date.toIso8601String().split('T')[0]);
//       // 각 감정의 발생 횟수를 세어봅니다.
//       for (var emotionData in filteredData) {
//         emotionCounts.forEach((key, value) {
//           if (emotionData.containsKey(key)) {
//             emotionCounts[key] = value + (emotionData[key] as int);
//           }
//         });
//       }

//       // 가장 큰 값을 가진 감정을 찾음
//       String dominantEmotion = '';
//       int maxCount = 0;
//       emotionCounts.forEach((key, value) {
//         if (value > maxCount) {
//           dominantEmotion = key;
//           maxCount = value;
//         }
//       });

//       // 감정이 하나도 없는 경우 처리
//       if (dominantEmotion.isEmpty) {
//         dominantEmotion = 'NoData';
//       }

//       print('대표 감정 : $dominantEmotion, 개수 : $maxCount');
//       return {'emotion': dominantEmotion, 'count': maxCount};
//     } else {
//       throw Exception('일일 감정 데이터를 가져오는 데 실패했습니다');
//     }
//   }

//   ////////////////////////////////////////////////////////////////////////////
//   //           빌드 메서드
//   ///////////////////////////////////////////////////////////////////////////
//   @override
//   Widget build(BuildContext context) {
//     final GlobalKey<_CalenderScreenState> calenderScreenStateKey =
//         GlobalKey<_CalenderScreenState>();

//     return MaterialApp(
//       home: Scaffold(
//         resizeToAvoidBottomInset: false,
//         backgroundColor: const Color(0xFFFFFFFF),
//         appBar: PreferredSize(
//           preferredSize: const Size.fromHeight(70),
//           child: AppBar(
//             shape: const Border(
//               bottom: BorderSide(
//                 color: Color(0xFFECECEC),
//                 width: 0.8,
//               ),
//             ),
//             centerTitle: true,
//             backgroundColor: const Color(0xFFFFFFFF),
//             title: Hero(
//               tag: 'mainlogo',
//               child: Image.asset(
//                 'assets/images/luvreed.png',
//                 height: 28,
//                 width: 270,
//               ),
//             ),
//             leading: IconButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               icon: const Icon(
//                 Icons.arrow_back_ios_new_rounded,
//               ),
//             ),
//           ),
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               MainCalendar(
//                 selectedDate: selectedDate,
//                 selectedSchedules: selectedSchedules,
//                 onDaySelected: (selectedDate, focusedDate) async {
//                   setState(() {
//                     this.selectedDate = selectedDate;
//                   });

//                   final emotionData = await _fetchDailyEmotion(selectedDate);
//                   print('선택된 날짜 감정 데이터: $emotionData');
//                   _refreshSchedules(); // 날짜 선택 시 일정을 새로고침
//                 },
//               ),
//               ScheduleCard(
//                 key: UniqueKey(),
//                 selectedDate: selectedDate,
//                 selectedSchedules: selectedSchedules,
//                 calenderScreenStateKey: calenderScreenStateKey,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// ///////////////////////////////////////////////////////////
// ///   캘린더를 구현
// ///////////////////////////////////////////////////////////
// class MainCalendar extends StatefulWidget {
//   final DateTime selectedDate;
//   final List<dynamic> selectedSchedules;
//   final Function(DateTime, DateTime) onDaySelected;

//   MainCalendar({
//     required this.selectedDate,
//     required this.selectedSchedules,
//     required this.onDaySelected,
//   });

//   @override
//   _MainCalendarState createState() => _MainCalendarState();
// }

// class _MainCalendarState extends State<MainCalendar> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(12),
//       child: TableCalendar(
//         rowHeight: 65,
//         onDaySelected: (selectedDate, focusedDate) {
//           widget.onDaySelected(selectedDate, focusedDate);
//         },
//         selectedDayPredicate: (date) =>
//             date.year == widget.selectedDate.year &&
//             date.month == widget.selectedDate.month &&
//             date.day == widget.selectedDate.day,
//         firstDay: DateTime(2000),
//         lastDay: DateTime(2100),
//         focusedDay: widget.selectedDate,
//         locale: 'ko-KR',
//         daysOfWeekHeight: 40,
//         calendarBuilders: CalendarBuilders(
//           dowBuilder: ((context, day) {
//             switch (day.weekday) {
//               case 1:
//                 return const Center(
//                   child: Text(
//                     '월',
//                     style: TextStyle(color: Color(0xff34485E)),
//                   ),
//                 );
//               case 2:
//                 return const Center(
//                   child: Text(
//                     '화',
//                     style: TextStyle(color: Color(0xff34485E)),
//                   ),
//                 );
//               case 3:
//                 return const Center(
//                   child: Text(
//                     '수',
//                     style: TextStyle(color: Color(0xff34485E)),
//                   ),
//                 );
//               case 4:
//                 return const Center(
//                   child: Text(
//                     '목',
//                     style: TextStyle(color: Color(0xff34485E)),
//                   ),
//                 );
//               case 5:
//                 return const Center(
//                   child: Text(
//                     '금',
//                     style: TextStyle(color: Color(0xff34485E)),
//                   ),
//                 );
//               case 6:
//                 return const Center(
//                   child: Text(
//                     '토',
//                     style: TextStyle(color: Colors.blue),
//                   ),
//                 );
//               case 7:
//                 return const Center(
//                   child: Text(
//                     '일',
//                     style: TextStyle(color: Colors.red),
//                   ),
//                 );
//             }
//             return null;
//           }),

//           //////////////////////////////////////////////////////
//           ///    색깔 점 표시
//           //////////////////////////////////////////////////////
//           markerBuilder: (context, date, events) {
//             // 해당 날짜에 데이터가 있는지 확인
//             final hasData = _hasDataForDay(date);

//             // 데이터가 있는 경우에만 마커 표시
//             if (hasData) {
//               return Positioned(
//                 bottom: 18,
//                 child: Container(
//                   width: 10,
//                   height: 10,
//                   decoration: BoxDecoration(
//                     color: Colors.grey, // 마커 색상
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               );
//             } else {
//               // 데이터가 없는 경우 빈 위젯 반환
//               return SizedBox.shrink();
//             }
//           },
//           // markerBuilder: (context, date, events) {
//           //   return _getMarkerWidget(date);
//           // },
//         ),
//         headerStyle: const HeaderStyle(
//           titleCentered: true,
//           formatButtonVisible: false,
//           titleTextStyle: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//         calendarStyle: const CalendarStyle(
//           cellAlignment: Alignment(0, -0.5), //추가
//           isTodayHighlighted: true, //수정
//           defaultTextStyle:
//               TextStyle(color: Color(0xFF7C86A2), fontWeight: FontWeight.bold),
//           weekendTextStyle:
//               TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
//           selectedDecoration: BoxDecoration(
//             shape: BoxShape.rectangle,
//             color: Color.fromARGB(255, 231, 231, 231), //색 수정
//           ),
//           selectedTextStyle: TextStyle(
//             color: Colors.black,
//           ),
//           todayDecoration: BoxDecoration(
//             color: Color(0xFFF5F5F5),
//             shape: BoxShape.rectangle,
//           ),
//           todayTextStyle: TextStyle(
//             color: Colors.black,
//           ),
//         ),
//         eventLoader: (day) {
//           return _getEventsForDay(day);
//         },
//       ),
//     );
//   }

//   List<Emotion> _getEventsForDay(DateTime day) {
//     return []; // 모든 날짜에는 감정 데이터가 없으므로 빈 리스트 반환
//   }

//   Widget _getMarkerWidget(DateTime date) {
//     // 해당 날짜에 데이터가 있는지 확인
//     final hasData = _hasDataForDay(date);

//     // 데이터가 있는 경우에만 마커 표시
//     if (hasData) {
//       return Positioned(
//         bottom: 18,
//         child: Container(
//           width: 10,
//           height: 10,
//           decoration: BoxDecoration(
//             color: Colors.grey, // 마커 색상
//             shape: BoxShape.circle,
//           ),
//         ),
//       );
//     } else {
//       // 데이터가 없는 경우 빈 위젯 반환
//       return SizedBox.shrink();
//     }
//   }

// // 해당 날짜에 데이터가 있는지 확인하는 메서드
//   bool _hasDataForDay(DateTime date) {
//     final hasData = widget.selectedSchedules.any((schedule) {
//       final memoDate = DateTime.parse(schedule['memoDate']);
//       return memoDate.year == date.year &&
//           memoDate.month == date.month &&
//           memoDate.day == date.day;
//     });
//     return hasData;
//   }
// }

// ///////////////////////////////////////////////////////////
// ///   클릭한 날짜의 일정 목록을 보여줌
// ///////////////////////////////////////////////////////////
// class ScheduleCard extends StatefulWidget {
//   final DateTime selectedDate;
//   final List<Map<String, dynamic>> selectedSchedules;
//   final GlobalKey<_CalenderScreenState> calenderScreenStateKey;

//   const ScheduleCard({
//     super.key,
//     required this.selectedDate,
//     required this.selectedSchedules,
//     required this.calenderScreenStateKey,
//   });

//   @override
//   State<ScheduleCard> createState() => _ScheduleCardState();
// }

// class _ScheduleCardState extends State<ScheduleCard>
//     with TickerProviderStateMixin {
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
//   late final controller = SlidableController(this);
//   List<Map<String, dynamic>> schedules = [];
//   List<String> memos = [];
//   List<bool> isDismissed = [];
//   late List<Map<String, dynamic>> selectedSchedules;

//   @override
//   void initState() {
//     super.initState();
//     selectedSchedules = []; // 초기화
//     fetchSelectedSchedules(); // 선택된 날짜에 해당하는 일정을 가져오는 메서드를 호출합니다.
//   }

//   Future<void> fetchSelectedSchedules() async {
//     try {
//       final schedules = await _fetchSchedule(widget.selectedDate);
//       setState(() {
//         selectedSchedules = schedules;
//       });
//     } catch (e) {
//       // 에러 처리
//     }
//   }

// ////////////////////////////////////////////////////////////////////
//   ///   서버에서 일정을 가져오는 메서드 (GET)
//   ////////////////////////////////////////////////////////////////////
//   Future<List<Map<String, dynamic>>> _fetchSchedule(DateTime date) async {
//     final token = await _secureStorage.read(key: 'token'); // 저장된 토큰 읽기

//     final response = await http.get(
//       Uri.parse('$apiBaseUrl/api/schedule'),
//       headers: {
//         'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
//       },
//     );
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
//       // 해당 날짜의 일정만 필터링하여 반환
//       final List<Map<String, dynamic>> filteredSchedules = data
//           .where((schedule) {
//             final memoDate = DateTime.parse(schedule['memoDate']);
//             return memoDate.year == date.year &&
//                 memoDate.month == date.month &&
//                 memoDate.day == date.day;
//           })
//           .map((schedule) => schedule as Map<String, dynamic>)
//           .toList();
//       print('스케줄 GET 성공: $filteredSchedules'); // 가져온 일정 데이터 출력
//       return filteredSchedules;
//     } else {
//       throw Exception('스케줄 GET 실패 ');
//     }
//   }

// ///////////////////////////////////////////////////////////////////////////
//   ///   일정 추가 (POST)
//   //////////////////////////////////////////////////////////////////////////
//   Future<void> _updateSchedule(DateTime selectedDate, String memo) async {
//     print('일정 추가 POST 요청 호출 (_updateSchedule)');
//     try {
//       final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
//       final token = await _secureStorage.read(key: 'token');

//       final uri = Uri.parse(
//           '$apiBaseUrl/api/schedule?memo=$memo&memo_date=${selectedDate.toIso8601String().split('T')[0]}');

//       final response = await http.post(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 201 || response.statusCode == 200) {
//         // 일정 추가 성공
//         final Map<String, dynamic> responseData = json.decode(response.body);
//         final String addedMemo = responseData['memo'];
//         final String addedMemoDate = responseData['memoDate'];

//         print('일정 추가 성공: 메모 - $addedMemo, 날짜 - $addedMemoDate');
//       } else {
//         // 일정 추가 실패
//         print('일정 추가 실패: ${response.statusCode}');
//       }
//     } catch (e) {
//       // 에러 처리
//       print('일정 추가 에러: $e');
//     }
//   }

//   //////////////////////////////////////////////////////////////////////
//   ///   일정 삭제 (DELETE)
//   //////////////////////////////////////////////////////////////////////
//   Future<void> _deleteSchedule(int scheduleId) async {
//     try {
//       final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
//       final token = await _secureStorage.read(key: 'token');

//       final response = await http.delete(
//         Uri.parse('$apiBaseUrl/api/schedule?schedule_id=$scheduleId'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         print('일정 삭제 성공: schedule_id - $scheduleId');
//       } else {
//         print('일정 삭제 실패: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('일정 삭제 에러: $e');
//     }
//   }

// //////////////////////////////////////////////////////////////////////
//   ///   일일 대표 감정 (GET)
//   //////////////////////////////////////////////////////////////////////
//   Future<Map<String, dynamic>> _fetchDailyEmotion(DateTime date) async {
//     final token = await _secureStorage.read(key: 'token');

//     final response = await http.get(
//       Uri.parse(
//           '$apiBaseUrl/api/emotionofschedule?date=${date.toIso8601String().split('T')[0]}'),
//       headers: {
//         'Authorization': 'Bearer $token', // 헤더에 토큰을 추가합니다.
//       },
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

//       final Map<String, int> emotionCounts = {
//         'happy': 0,
//         'surprised': 0,
//         'anxious': 0,
//         'sad': 0,
//         'angry': 0,
//         'annoyed': 0,
//       };

//       final filteredData = data.where((emotionData) =>
//           emotionData['date'] == date.toIso8601String().split('T')[0]);
//       // 각 감정의 발생 횟수를 세어봅니다.
//       for (var emotionData in filteredData) {
//         emotionCounts.forEach((key, value) {
//           if (emotionData.containsKey(key)) {
//             emotionCounts[key] = value + (emotionData[key] as int);
//           }
//         });
//       }

//       // 가장 큰 값을 가진 감정을 찾음
//       String dominantEmotion = '';
//       int maxCount = 0;
//       emotionCounts.forEach((key, value) {
//         if (value > maxCount) {
//           dominantEmotion = key;
//           maxCount = value;
//         }
//       });

//       // 감정이 하나도 없는 경우 처리
//       if (dominantEmotion.isEmpty) {
//         dominantEmotion = 'NoData';
//       }

//       print('대표 감정 : $dominantEmotion, 개수 : $maxCount');
//       return {'emotion': dominantEmotion, 'count': maxCount};
//     } else {
//       throw Exception('일일 감정 데이터를 가져오는 데 실패했습니다');
//     }
//   }

// /////////////////////////////////////////////////////////////////
//   /// +버튼누르면 입력창 띄움
// /////////////////////////////////////////////////////////////////
//   void _showAddScheduleDialog(BuildContext context) {
//     final TextEditingController _controller = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white, // 다이얼로그의 배경색 설정
//           title: const Text(
//             '일정 추가',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: TextField(
//             controller: _controller, // 컨트롤러 전달
//             decoration: const InputDecoration(
//               hintText: '일정을 입력하세요',
//               hintStyle: TextStyle(fontSize: 14), // 힌트 텍스트의 크기 조절
//             ),
//           ),

//           actions: <Widget>[
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(); // 다이얼로그 닫기
//                   },
//                   style: ElevatedButton.styleFrom(
//                     surfaceTintColor: Color.fromARGB(255, 155, 155, 155),
//                     backgroundColor: Color.fromARGB(255, 155, 155, 155),
//                     foregroundColor: Colors.white,
//                     minimumSize: const Size(80, 40),
//                     elevation: 3,
//                   ),
//                   child: const Text('취소'),
//                 ),
//                 SizedBox(width: 30), // 버튼 사이 간격 조절
//                 TextButton(
//                   onPressed: () {
//                     _addSchedule(context, _controller.text,
//                         widget.selectedDate); // widget.selectedDate를 전달
//                     _controller.clear();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     surfaceTintColor: const Color(0xFF000000),
//                     backgroundColor: const Color(0xFF000000),
//                     foregroundColor: Colors.white,
//                     minimumSize: const Size(80, 40),
//                     elevation: 3,
//                   ),
//                   child: const Text('추가'),
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _addSchedule(
//       BuildContext context, String memo, DateTime selectedDate) async {
//     try {
//       await _updateSchedule(selectedDate, memo); // 전달받은 selectedDate를 사용
//       setState(() {});
//       Navigator.of(context).pop();
//     } catch (e) {
//       print('일정 추가 에러: $e');
//     }
//   }

// /////////////////////////////////////////////////////////////////////
//   ///    빌드 메서드
// /////////////////////////////////////////////////////////////////
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Map<String, dynamic>>>(
//       future: _fetchSchedule(widget.selectedDate),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('에러: ${snapshot.error}'));
//         } else {
//           schedules = snapshot.data ?? [];
//           return SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.only(
//                   left: 25, top: 25, right: 25, bottom: 15),
//               child: Container(
//                 decoration: const BoxDecoration(
//                   border: Border(
//                     top: BorderSide(
//                         color: Color.fromARGB(255, 223, 223, 223), width: 1),
//                   ),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.only(
//                       left: 20, top: 30, right: 10, bottom: 0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Text(
//                                 '${widget.selectedDate.year}/${widget.selectedDate.month.toString().padLeft(2, '0')}/${widget.selectedDate.day.toString().padLeft(2, '0')} 일정',
//                                 style: const TextStyle(
//                                   color: Color(0xFF545454),
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               FutureBuilder<Map<String, dynamic>>(
//                                 future: _fetchDailyEmotion(widget.selectedDate),
//                                 builder: (context, snapshot) {
//                                   if (snapshot.connectionState ==
//                                       ConnectionState.waiting) {
//                                     return SizedBox(
//                                       width: 12,
//                                       height: 12,
//                                       child: CircularProgressIndicator(),
//                                     );
//                                   } else if (snapshot.hasError) {
//                                     return const Text(
//                                       '없음',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Color(0xFF828282),
//                                       ),
//                                     );
//                                   } else {
//                                     final emotionData = snapshot.data!;
//                                     final emotion =
//                                         emotionData['emotion'] as String;
//                                     final translatedEmotion =
//                                         translateEmotionLabel(emotion);
//                                     final color =
//                                         chooseColorByEmotion(translatedEmotion);
//                                     return Icon(
//                                       Icons.circle,
//                                       size: 12,
//                                       color: color,
//                                     );
//                                   }
//                                 },
//                               ),

//                               const SizedBox(width: 2),
//                               // 위젯에서 감정 데이터를 표시하는 부분 수정
//                               FutureBuilder<Map<String, dynamic>>(
//                                 future: _fetchDailyEmotion(widget.selectedDate),
//                                 builder: (context, snapshot) {
//                                   if (snapshot.connectionState ==
//                                       ConnectionState.waiting) {
//                                     return SizedBox(
//                                       width: 12,
//                                       height: 12,
//                                       child: CircularProgressIndicator(),
//                                     );
//                                   } else if (snapshot.hasError) {
//                                     return const Text(
//                                       '없음',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Color(0xFF828282),
//                                       ),
//                                     );
//                                   } else {
//                                     final emotionData = snapshot.data!;
//                                     final emotion =
//                                         emotionData['emotion'] as String;
//                                     final translatedEmotion =
//                                         translateEmotionLabel(emotion);
//                                     return Text(
//                                       emotion.isNotEmpty
//                                           ? translatedEmotion
//                                           : '없음',
//                                       style: const TextStyle(
//                                         fontSize: 12,
//                                         color: Color(0xFF828282),
//                                       ),
//                                     );
//                                   }
//                                 },
//                               ),
//                             ],
//                           ),
//                           IconButton(
//                             onPressed: () {
//                               _showAddScheduleDialog(context);
//                               //widget.calenderScreenStateKey.currentState?._showAddScheduleDialog(context);
//                             },
//                             icon: const Icon(Icons.add),
//                           ),
//                         ],
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(
//                             left: 2, top: 0, right: 2, bottom: 2),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: List.generate(schedules.length, (index) {
//                             final memo = schedules[index]['memo'] ?? '';
//                             final scheduleId = schedules[index]['id'];
//                             // 밀어서 일정 삭제
//                             return Slidable(
//                               endActionPane: ActionPane(
//                                 motion: const ScrollMotion(),
//                                 extentRatio: 0.2,
//                                 children: [
//                                   SlidableAction(
//                                     onPressed: (context) {
//                                       _deleteSchedule(scheduleId);
//                                       setState(() {
//                                         schedules.removeAt(index);
//                                       });
//                                     },
//                                     backgroundColor:
//                                         Color.fromARGB(255, 255, 126, 117),
//                                     foregroundColor: Colors.white,
//                                     icon: Icons.delete,
//                                     // label: '삭제',
//                                   ),
//                                 ],
//                               ),
//                               child: SizedBox(
//                                 width: MediaQuery.of(context).size.width *
//                                     0.8, // 화면 가로 너비의 80%로 설정
//                                 child: Padding(
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 8.0),
//                                   child: Text(
//                                     memo,
//                                     style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 16,
//                                     ),
//                                     overflow: TextOverflow
//                                         .ellipsis, // 텍스트가 너무 길면 ...으로 표시
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }
//       },
//     );
//   }
// }

// // 감정 레이블을 한글로 변환하는 함수
// String translateEmotionLabel(String emotion) {
//   switch (emotion) {
//     case 'happy':
//       return '행복';
//     case 'surprised':
//       return '놀람';
//     case 'anxious':
//       return '불안';
//     case 'sad':
//       return '슬픔';
//     case 'angry':
//       return '분노';
//     case 'annoyed':
//       return '짜증';
//     default:
//       return '감정없음';
//   }
// }

// // 감정에 따라 색상 선택
// Color chooseColorByEmotion(String emotion) {
//   switch (emotion) {
//     case '행복':
//       return Color.fromARGB(255, 255, 189, 200);
//     case '놀람':
//       return Color.fromARGB(255, 255, 226, 132);
//     case '불안':
//       return Color.fromARGB(255, 121, 209, 155);
//     case '슬픔':
//       return Color.fromARGB(255, 168, 216, 255);
//     case '분노':
//       return Color.fromARGB(255, 255, 152, 112);
//     case '짜증':
//       return Color.fromARGB(255, 172, 169, 247);
//     default:
//       return Color.fromARGB(255, 211, 211, 211);
//   }
// }

// void doNothing(BuildContext context) {}


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:luvreed/constants.dart'; //아이피주소

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({super.key});

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class Emotion {
  String title;

  Emotion(this.title);
}

class _CalenderScreenState extends State<CalenderScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  List<Map<String, dynamic>> selectedSchedules = []; // 선택된 날짜에 해당하는 일정을 저장할 리스트

  @override
  void initState() {
    super.initState();
    fetchAllSchedule().then((schedules) {
      setState(() {
        selectedSchedules = schedules;
      });
    });
  }
  void _refreshSchedules() async {
    final schedules = await fetchAllSchedule();
    setState(() {
      selectedSchedules = schedules;
    });
  }

////////////////////////////////////////////////////////////////////
  ///  전체  일정을 가져오는 메서드 (GET)
  ////////////////////////////////////////////////////////////////////
  Future<List<Map<String, dynamic>>> fetchAllSchedule() async {
    final token = await _secureStorage.read(key: 'token'); // 저장된 토큰 읽기

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/schedule'),
      headers: {
        'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      // 전체 일정 데이터 반환
      final List<Map<String, dynamic>> allSchedules =
          data.map((schedule) => schedule as Map<String, dynamic>).toList();
      return allSchedules;
    } else {
      throw Exception('전체 일정 가져오기 실패');
    }
  }

  ////////////////////////////////////////////////////////////////////
  ///   클릭한 일정을 가져오는 메서드 (GET)
  ////////////////////////////////////////////////////////////////////
  Future<List<Map<String, dynamic>>> _fetchSchedule(DateTime date) async {
    final token = await _secureStorage.read(key: 'token'); // 저장된 토큰 읽기

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/schedule'),
      headers: {
        'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      // 해당 날짜의 일정만 필터링하여 반환
      final List<Map<String, dynamic>> filteredSchedules = data
          .where((schedule) {
            final memoDate = DateTime.parse(schedule['memoDate']);
            return memoDate.year == date.year &&
                memoDate.month == date.month &&
                memoDate.day == date.day;
          })
          .map((schedule) => schedule as Map<String, dynamic>)
          .toList();
      print('스케줄 GET 성공: $filteredSchedules'); // 가져온 일정 데이터 출력
      return filteredSchedules;
    } else {
      throw Exception('스케줄 GET 실패 ');
    }
  }

  //////////////////////////////////////////////////////////////////////
  ///   일일 대표 감정 (GET)
  //////////////////////////////////////////////////////////////////////
  Future<Map<String, dynamic>> _fetchDailyEmotion(DateTime date) async {
    final token = await _secureStorage.read(key: 'token');

    final response = await http.get(
      Uri.parse(
          '$apiBaseUrl/api/emotionofschedule?date=${date.toIso8601String().split('T')[0]}'),
      headers: {
        'Authorization': 'Bearer $token', // 헤더에 토큰을 추가합니다.
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

      final Map<String, int> emotionCounts = {
        'happy': 0,
        'surprised': 0,
        'anxious': 0,
        'sad': 0,
        'angry': 0,
        'annoyed': 0,
      };

      final filteredData = data.where((emotionData) =>
          emotionData['date'] == date.toIso8601String().split('T')[0]);
      // 각 감정의 발생 횟수를 세어봅니다.
      for (var emotionData in filteredData) {
        emotionCounts.forEach((key, value) {
          if (emotionData.containsKey(key)) {
            emotionCounts[key] = value + (emotionData[key] as int);
          }
        });
      }

      // 가장 큰 값을 가진 감정을 찾음
      String dominantEmotion = '';
      int maxCount = 0;
      emotionCounts.forEach((key, value) {
        if (value > maxCount) {
          dominantEmotion = key;
          maxCount = value;
        }
      });

      // 감정이 하나도 없는 경우 처리
      if (dominantEmotion.isEmpty) {
        dominantEmotion = 'NoData';
      }

      print('대표 감정 : $dominantEmotion, 개수 : $maxCount');
      return {'emotion': dominantEmotion, 'count': maxCount};
    } else {
      throw Exception('일일 감정 데이터를 가져오는 데 실패했습니다');
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  //           빌드 메서드
  ///////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    final GlobalKey<_CalenderScreenState> calenderScreenStateKey =
        GlobalKey<_CalenderScreenState>();

    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            shape: const Border(
              bottom: BorderSide(
                color: Color(0xFFECECEC),
                width: 0.8,
              ),
            ),
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
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              MainCalendar(
                selectedDate: selectedDate,
                selectedSchedules: selectedSchedules,
                onDaySelected: (selectedDate, focusedDate) async {
                  setState(() {
                    this.selectedDate = selectedDate;
                  });

                  final emotionData = await _fetchDailyEmotion(selectedDate);
                  print('선택된 날짜 감정 데이터: $emotionData');
                  _refreshSchedules(); // 날짜 선택 시 일정을 새로고침
                },
              ),
              ScheduleCard(
                key: UniqueKey(),
                selectedDate: selectedDate,
                selectedSchedules: selectedSchedules,
                calenderScreenStateKey: calenderScreenStateKey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////
///   캘린더를 구현
///////////////////////////////////////////////////////////
class MainCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final List<dynamic> selectedSchedules;
  final Function(DateTime, DateTime) onDaySelected;

  MainCalendar({
    required this.selectedDate,
    required this.selectedSchedules,
    required this.onDaySelected,
  });

  @override
  _MainCalendarState createState() => _MainCalendarState();
}

class _MainCalendarState extends State<MainCalendar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TableCalendar(
        rowHeight: 65,
        onDaySelected: (selectedDate, focusedDate) {
          widget.onDaySelected(selectedDate, focusedDate);
        },
        selectedDayPredicate: (date) =>
            date.year == widget.selectedDate.year &&
            date.month == widget.selectedDate.month &&
            date.day == widget.selectedDate.day,
        firstDay: DateTime(2000),
        lastDay: DateTime(2100),
        focusedDay: widget.selectedDate,
        locale: 'ko-KR',
        daysOfWeekHeight: 40,
        calendarBuilders: CalendarBuilders(
          dowBuilder: ((context, day) {
            switch (day.weekday) {
              case 1:
                return const Center(
                  child: Text(
                    '월',
                    style: TextStyle(color: Color(0xff34485E)),
                  ),
                );
              case 2:
                return const Center(
                  child: Text(
                    '화',
                    style: TextStyle(color: Color(0xff34485E)),
                  ),
                );
              case 3:
                return const Center(
                  child: Text(
                    '수',
                    style: TextStyle(color: Color(0xff34485E)),
                  ),
                );
              case 4:
                return const Center(
                  child: Text(
                    '목',
                    style: TextStyle(color: Color(0xff34485E)),
                  ),
                );
              case 5:
                return const Center(
                  child: Text(
                    '금',
                    style: TextStyle(color: Color(0xff34485E)),
                  ),
                );
              case 6:
                return const Center(
                  child: Text(
                    '토',
                    style: TextStyle(color: Colors.blue),
                  ),
                );
              case 7:
                return const Center(
                  child: Text(
                    '일',
                    style: TextStyle(color: Colors.red),
                  ),
                );
            }
            return null;
          }),

          //////////////////////////////////////////////////////
          ///    색깔 점 표시
          //////////////////////////////////////////////////////
          markerBuilder: (context, date, events) {
            // 해당 날짜에 데이터가 있는지 확인
            final hasData = _hasDataForDay(date);

            // 데이터가 있는 경우에만 마커 표시
            if (hasData) {
              return Positioned(
                bottom: 18,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey, // 마커 색상
                    shape: BoxShape.circle,
                  ),
                ),
              );
            } else {
              // 데이터가 없는 경우 빈 위젯 반환
              return SizedBox.shrink();
            }
          },
          // markerBuilder: (context, date, events) {
          //   return _getMarkerWidget(date);
          // },
        ),
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        calendarStyle: const CalendarStyle(
          cellAlignment: Alignment(0, -0.5), //추가
          isTodayHighlighted: true, //수정
          defaultTextStyle:
              TextStyle(color: Color(0xFF7C86A2), fontWeight: FontWeight.bold),
          weekendTextStyle:
              TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          selectedDecoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Color.fromARGB(255, 231, 231, 231), //색 수정
          ),
          selectedTextStyle: TextStyle(
            color: Colors.black,
          ),
          todayDecoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            shape: BoxShape.rectangle,
          ),
          todayTextStyle: TextStyle(
            color: Colors.black,
          ),
        ),
        eventLoader: (day) {
          return _getEventsForDay(day);
        },
      ),
    );
  }

  List<Emotion> _getEventsForDay(DateTime day) {
    return []; // 모든 날짜에는 감정 데이터가 없으므로 빈 리스트 반환
  }

  Widget _getMarkerWidget(DateTime date) {
    // 해당 날짜에 데이터가 있는지 확인
    final hasData = _hasDataForDay(date);

    // 데이터가 있는 경우에만 마커 표시
    if (hasData) {
      return Positioned(
        bottom: 18,
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.grey, // 마커 색상
            shape: BoxShape.circle,
          ),
        ),
      );
    } else {
      // 데이터가 없는 경우 빈 위젯 반환
      return SizedBox.shrink();
    }
  }

// 해당 날짜에 데이터가 있는지 확인하는 메서드
  bool _hasDataForDay(DateTime date) {
    final hasData = widget.selectedSchedules.any((schedule) {
      final memoDate = DateTime.parse(schedule['memoDate']);
      return memoDate.year == date.year &&
          memoDate.month == date.month &&
          memoDate.day == date.day;
    });
    return hasData;
  }
}

///////////////////////////////////////////////////////////
///   클릭한 날짜의 일정 목록을 보여줌
///////////////////////////////////////////////////////////
class ScheduleCard extends StatefulWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> selectedSchedules;
  final GlobalKey<_CalenderScreenState> calenderScreenStateKey;

  const ScheduleCard({
    super.key,
    required this.selectedDate,
    required this.selectedSchedules,
    required this.calenderScreenStateKey,
  });

  @override
  State<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard>
    with TickerProviderStateMixin {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late final controller = SlidableController(this);
  List<Map<String, dynamic>> schedules = [];
  List<String> memos = [];
  List<bool> isDismissed = [];
  late List<Map<String, dynamic>> selectedSchedules;

  @override
  void initState() {
    super.initState();
    selectedSchedules = []; // 초기화
    fetchSelectedSchedules(); // 선택된 날짜에 해당하는 일정을 가져오는 메서드를 호출합니다.
  }

  Future<void> fetchSelectedSchedules() async {
    try {
      final schedules = await _fetchSchedule(widget.selectedDate);
      setState(() {
        selectedSchedules = schedules;
      });
    } catch (e) {
      // 에러 처리
    }
  }

////////////////////////////////////////////////////////////////////
  ///   서버에서 일정을 가져오는 메서드 (GET)
  ////////////////////////////////////////////////////////////////////
  Future<List<Map<String, dynamic>>> _fetchSchedule(DateTime date) async {
    final token = await _secureStorage.read(key: 'token'); // 저장된 토큰 읽기

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/schedule'),
      headers: {
        'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      // 해당 날짜의 일정만 필터링하여 반환
      final List<Map<String, dynamic>> filteredSchedules = data
          .where((schedule) {
            final memoDate = DateTime.parse(schedule['memoDate']);
            return memoDate.year == date.year &&
                memoDate.month == date.month &&
                memoDate.day == date.day;
          })
          .map((schedule) => schedule as Map<String, dynamic>)
          .toList();
      print('스케줄 GET 성공: $filteredSchedules'); // 가져온 일정 데이터 출력
      return filteredSchedules;
    } else {
      throw Exception('스케줄 GET 실패 ');
    }
  }

///////////////////////////////////////////////////////////////////////////
  ///   일정 추가 (POST)
  //////////////////////////////////////////////////////////////////////////
  Future<void> _updateSchedule(DateTime selectedDate, String memo) async {
    print('일정 추가 POST 요청 호출 (_updateSchedule)');
    try {
      final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
      final token = await _secureStorage.read(key: 'token');

      final uri = Uri.parse(
          '$apiBaseUrl/api/schedule?memo=$memo&memo_date=${selectedDate.toIso8601String().split('T')[0]}');

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // 일정 추가 성공
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String addedMemo = responseData['memo'];
        final String addedMemoDate = responseData['memoDate'];

        print('일정 추가 성공: 메모 - $addedMemo, 날짜 - $addedMemoDate');
      } else {
        // 일정 추가 실패
        print('일정 추가 실패: ${response.statusCode}');
      }
    } catch (e) {
      // 에러 처리
      print('일정 추가 에러: $e');
    }
  }

  //////////////////////////////////////////////////////////////////////
  ///   일정 삭제 (DELETE)
  //////////////////////////////////////////////////////////////////////
  Future<void> _deleteSchedule(int scheduleId) async {
    try {
      final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
      final token = await _secureStorage.read(key: 'token');

      final response = await http.delete(
        Uri.parse('$apiBaseUrl/api/schedule?schedule_id=$scheduleId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('일정 삭제 성공: schedule_id - $scheduleId');
      } else {
        print('일정 삭제 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('일정 삭제 에러: $e');
    }
  }

//////////////////////////////////////////////////////////////////////
  ///   일일 대표 감정 (GET)
  //////////////////////////////////////////////////////////////////////
  Future<Map<String, dynamic>> _fetchDailyEmotion(DateTime date) async {
    final token = await _secureStorage.read(key: 'token');

    final response = await http.get(
      Uri.parse(
          '$apiBaseUrl/api/emotionofschedule?date=${date.toIso8601String().split('T')[0]}'),
      headers: {
        'Authorization': 'Bearer $token', // 헤더에 토큰을 추가합니다.
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

      final Map<String, int> emotionCounts = {
        'happy': 0,
        'surprised': 0,
        'anxious': 0,
        'sad': 0,
        'angry': 0,
        'annoyed': 0,
      };

      final filteredData = data.where((emotionData) =>
          emotionData['date'] == date.toIso8601String().split('T')[0]);
      // 각 감정의 발생 횟수를 세어봅니다.
      for (var emotionData in filteredData) {
        emotionCounts.forEach((key, value) {
          if (emotionData.containsKey(key)) {
            emotionCounts[key] = value + (emotionData[key] as int);
          }
        });
      }

      // 가장 큰 값을 가진 감정을 찾음
      String dominantEmotion = '';
      int maxCount = 0;
      emotionCounts.forEach((key, value) {
        if (value > maxCount) {
          dominantEmotion = key;
          maxCount = value;
        }
      });

      // 감정이 하나도 없는 경우 처리
      if (dominantEmotion.isEmpty) {
        dominantEmotion = 'NoData';
      }

      print('대표 감정 : $dominantEmotion, 개수 : $maxCount');
      return {'emotion': dominantEmotion, 'count': maxCount};
    } else {
      throw Exception('일일 감정 데이터를 가져오는 데 실패했습니다');
    }
  }

/////////////////////////////////////////////////////////////////
  /// +버튼누르면 입력창 띄움
/////////////////////////////////////////////////////////////////
  void _showAddScheduleDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // 다이얼로그의 배경색 설정
          title: const Text(
            '일정 추가',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: _controller, // 컨트롤러 전달
            decoration: const InputDecoration(
              hintText: '일정을 입력하세요',
              hintStyle: TextStyle(fontSize: 14), // 힌트 텍스트의 크기 조절
            ),
          ),

          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  },
                  style: ElevatedButton.styleFrom(
                    surfaceTintColor: Color.fromARGB(255, 155, 155, 155),
                    backgroundColor: Color.fromARGB(255, 155, 155, 155),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(80, 40),
                    elevation: 3,
                  ),
                  child: const Text('취소'),
                ),
                SizedBox(width: 30), // 버튼 사이 간격 조절
                TextButton(
                  onPressed: () {
                    _addSchedule(context, _controller.text,
                        widget.selectedDate); // widget.selectedDate를 전달
                    _controller.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    surfaceTintColor: const Color(0xFF000000),
                    backgroundColor: const Color(0xFF000000),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(80, 40),
                    elevation: 3,
                  ),
                  child: const Text('추가'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _addSchedule(
      BuildContext context, String memo, DateTime selectedDate) async {
    try {
      await _updateSchedule(selectedDate, memo); // 전달받은 selectedDate를 사용
      setState(() {});
      Navigator.of(context).pop();
    } catch (e) {
      print('일정 추가 에러: $e');
    }
  }

/////////////////////////////////////////////////////////////////////
  ///    빌드 메서드
/////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchSchedule(widget.selectedDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('에러: ${snapshot.error}'));
        } else {
          schedules = snapshot.data ?? [];
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 25, top: 25, right: 25, bottom: 15),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: Color.fromARGB(255, 223, 223, 223), width: 1),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 20, top: 30, right: 10, bottom: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${widget.selectedDate.year}/${widget.selectedDate.month.toString().padLeft(2, '0')}/${widget.selectedDate.day.toString().padLeft(2, '0')} 일정',
                                style: const TextStyle(
                                  color: Color(0xFF545454),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              FutureBuilder<Map<String, dynamic>>(
                                future: _fetchDailyEmotion(widget.selectedDate),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return const Text(
                                      '없음',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF828282),
                                      ),
                                    );
                                  } else {
                                    final emotionData = snapshot.data!;
                                    final emotion =
                                        emotionData['emotion'] as String;
                                    final translatedEmotion =
                                        translateEmotionLabel(emotion);
                                    final color =
                                        chooseColorByEmotion(translatedEmotion);
                                    return Icon(
                                      Icons.circle,
                                      size: 12,
                                      color: color,
                                    );
                                  }
                                },
                              ),

                              const SizedBox(width: 2),
                              // 위젯에서 감정 데이터를 표시하는 부분 수정
                              FutureBuilder<Map<String, dynamic>>(
                                future: _fetchDailyEmotion(widget.selectedDate),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return const Text(
                                      '없음',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF828282),
                                      ),
                                    );
                                  } else {
                                    final emotionData = snapshot.data!;
                                    final emotion =
                                        emotionData['emotion'] as String;
                                    final translatedEmotion =
                                        translateEmotionLabel(emotion);
                                    return Text(
                                      emotion.isNotEmpty
                                          ? translatedEmotion
                                          : '없음',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF828282),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              _showAddScheduleDialog(context);
                              //widget.calenderScreenStateKey.currentState?._showAddScheduleDialog(context);
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 2, top: 0, right: 2, bottom: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(schedules.length, (index) {
                            final memo = schedules[index]['memo'] ?? '';
                            final scheduleId = schedules[index]['id'];
                            // 밀어서 일정 삭제
                            return Slidable(
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                extentRatio: 0.2,
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      _deleteSchedule(scheduleId);
                                      setState(() {
                                        schedules.removeAt(index);
                                      });
                                    },
                                    backgroundColor:
                                        Color.fromARGB(255, 255, 126, 117),
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    // label: '삭제',
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    0.8, // 화면 가로 너비의 80%로 설정
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    memo,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow
                                        .ellipsis, // 텍스트가 너무 길면 ...으로 표시
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

// 감정 레이블을 한글로 변환하는 함수
String translateEmotionLabel(String emotion) {
  switch (emotion) {
    case 'happy':
      return '행복';
    case 'surprised':
      return '놀람';
    case 'anxious':
      return '불안';
    case 'sad':
      return '슬픔';
    case 'angry':
      return '분노';
    case 'annoyed':
      return '짜증';
    default:
      return '감정없음';
  }
}

// 감정에 따라 색상 선택
Color chooseColorByEmotion(String emotion) {
  switch (emotion) {
    case '행복':
      return Color.fromARGB(255, 255, 189, 200);
    case '놀람':
      return Color.fromARGB(255, 255, 226, 132);
    case '불안':
      return Color.fromARGB(255, 121, 209, 155);
    case '슬픔':
      return Color.fromARGB(255, 168, 216, 255);
    case '분노':
      return Color.fromARGB(255, 255, 152, 112);
    case '짜증':
      return Color.fromARGB(255, 172, 169, 247);
    default:
      return Color.fromARGB(255, 211, 211, 211);
  }
}

void doNothing(BuildContext context) {}