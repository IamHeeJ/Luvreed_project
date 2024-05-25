import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:luvreed/constants.dart'; //아이피주소

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ko', ''),
        //Locale('en', ''),
      ],
      home: ReDateScreen(),
    ),
  );
}

class ReDateScreen extends StatefulWidget {
  const ReDateScreen({super.key});

  @override
  State<ReDateScreen> createState() => _ReDateScreenState();
}

class _ReDateScreenState extends State<ReDateScreen> {
  DateTime date = DateTime.now();

///////////// 디데이 수정 PUT 요청 /////////////////////////
  Future<void> _editDday(String dday) async {
    try {
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: 'token'); // 저장된 토큰 읽기

      final response = await http.put(
        Uri.parse('$apiBaseUrl/api/dday?dday=$dday'),
        headers: {
          'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
        },
      );

      if (response.statusCode == 200) {
        // 수정된 디데이에 대한 처리
        print('디데이 수정 성공');
      } else {
        // 요청이 실패한 경우 처리
        print('디데이 수정 실패');
        throw Exception('디데이 수정 실패');
      }
    } catch (e) {
      // 예외 처리
      print('오류 발생: $e');
    }
  }

////////////////////////////////////////////////////////////////
  ///  빌드 메서드
////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
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
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
            ),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 80,
            ),
            const Center(
              child: Text(
                '변경할 날짜를 선택하세요.',
                style: TextStyle(
                  // color: Color(0xFFFF8484),
                  color: Colors.black,
                  fontSize: 17,
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  showCupertinoDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext) {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          color: Colors.white,
                          height: 300,
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            onDateTimeChanged: (DateTime first) {
                              setState(() {
                                date = first;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  surfaceTintColor: const Color(0xFFFFFFFF),
                  backgroundColor: const Color(0xFFFFFFFF),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(100, 50),
                  shadowColor: Colors.grey.withOpacity(0),
                ),
                child: Text(
                  "${date.year.toString()}년 ${date.month.toString().padLeft(2, '0')}월 ${date.day.toString().padLeft(2, '0')}일",
                  style: const TextStyle(
                    color: Color(0xFF828282),
                    fontSize: 25,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            // onPressed 콜백 안에 수정된 날짜를 포맷하고 _editDday 메서드를 호출하는 코드를 넣어주세요
            ElevatedButton(
              onPressed: () {
                // 디데이 수정 요청 보내기
                String formattedDate =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                _editDday(formattedDate);
              },
              style: ElevatedButton.styleFrom(
                surfaceTintColor: const Color(0xFF000000),
                backgroundColor: const Color(0xFF000000),
                foregroundColor: Colors.white,
                minimumSize: const Size(180, 53),
                elevation: 3,
              ),
              child: Text(
                '변경하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:luvreed/constants.dart'; //아이피주소

// void main() {
//   runApp(
//     const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       localizationsDelegates: [
//         GlobalCupertinoLocalizations.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//       ],
//       supportedLocales: [
//         Locale('ko', ''),
//         //Locale('en', ''),
//       ],
//       home: ReDateScreen(),
//     ),
//   );
// }

// class ReDateScreen extends StatefulWidget {
//   const ReDateScreen({super.key});

//   @override
//   State<ReDateScreen> createState() => _ReDateScreenState();
// }

// class _ReDateScreenState extends State<ReDateScreen> {
//   DateTime date = DateTime.now();

// ///////////// 디데이 수정 PUT 요청 /////////////////////////
//   Future<void> _editDday(String dday) async {
//     try {
//       final storage = FlutterSecureStorage();
//       final token = await storage.read(key: 'token'); // 저장된 토큰 읽기

//       final response = await http.put(
//         Uri.parse('$apiBaseUrl/api/dday?dday=$dday'),
//         headers: {
//           'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
//         },
//       );

//       if (response.statusCode == 200) {
//         // 수정된 디데이에 대한 처리
//         print('디데이 수정 성공');
//       } else {
//         // 요청이 실패한 경우 처리
//         print('디데이 수정 실패');
//         throw Exception('디데이 수정 실패');
//       }
//     } catch (e) {
//       // 예외 처리
//       print('오류 발생: $e');
//     }
//   }

// ////////////////////////////////////////////////////////////////
//   ///  빌드 메서드
// ////////////////////////////////////////////////////////////////
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         backgroundColor: const Color(0xFFFFFFFF),
//         appBar: AppBar(
//           centerTitle: true,
//           backgroundColor: const Color(0xFFFFFFFF),
//           title: Hero(
//             tag: 'mainlogo',
//             child: Image.asset(
//               'assets/images/luvreed.png',
//               height: 28,
//               width: 270,
//             ),
//           ),
//           leading: IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: const Icon(
//               Icons.arrow_back_ios_new_rounded,
//             ),
//           ),
//         ),
//         body: Column(
//           children: [
//             const SizedBox(
//               height: 80,
//             ),
//             const Center(
//               child: Text(
//                 '변경할 날짜를 선택하세요.',
//                 style: TextStyle(
//                   // color: Color(0xFFFF8484),
//                   color: Colors.black,
//                   fontSize: 17,
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 50,
//             ),
//             Center(
//               child: TextButton(
//                 onPressed: () {
//                   showCupertinoDialog(
//                     context: context,
//                     barrierDismissible: true,
//                     builder: (BuildContext) {
//                       return Align(
//                         alignment: Alignment.bottomCenter,
//                         child: Container(
//                           color: Colors.white,
//                           height: 300,
//                           child: CupertinoDatePicker(
//                             mode: CupertinoDatePickerMode.date,
//                             onDateTimeChanged: (DateTime first) {
//                               setState(() {
//                                 date = first;
//                               });
//                             },
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   surfaceTintColor: const Color(0xFFFFFFFF),
//                   backgroundColor: const Color(0xFFFFFFFF),
//                   foregroundColor: Colors.black,
//                   minimumSize: const Size(100, 50),
//                   shadowColor: Colors.grey.withOpacity(0),
//                 ),
//                 child: Text(
//                   "${date.year.toString()}년 ${date.month.toString().padLeft(2, '0')}월 ${date.day.toString().padLeft(2, '0')}일",
//                   style: const TextStyle(
//                     color: Color(0xFF828282),
//                     fontSize: 25,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 50,
//             ),
//             // onPressed 콜백 안에 수정된 날짜를 포맷하고 _editDday 메서드를 호출하는 코드를 넣어주세요
//             ElevatedButton(
//               onPressed: () {
//                 // 디데이 수정 요청 보내기
//                 String formattedDate =
//                     '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//                 _editDday(formattedDate);
//               },
//               style: ElevatedButton.styleFrom(
//                 surfaceTintColor: const Color(0xFF000000),
//                 backgroundColor: const Color(0xFF000000),
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(180, 53),
//                 elevation: 3,
//               ),
//               child: Text(
//                 '변경하기',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
