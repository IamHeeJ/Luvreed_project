import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:luvreed/main.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:luvreed/constants.dart'; //아이피주소

class StartInfoScreen extends StatefulWidget {
  final String chatroomId; // chatroomId 필드 추가

  StartInfoScreen({Key? key, required this.chatroomId}); // 생성자 수정

  @override
  _StartInfoScreenState createState() => _StartInfoScreenState();
}

class _StartInfoScreenState extends State<StartInfoScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ddayController = TextEditingController();
  bool isNameError = false;
  bool isDdayError = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFFFFFFFF),
          title: Image.asset(
            'assets/images/luvreed.png',
            height: 28,
            width: 270,
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Text(
                      '연결 성공!',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Text(
                      '프로필을 입력해주세요.',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: '이름',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFB8B8BC),
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline_rounded,
                            size: 29,
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        controller: nameController,
                        onChanged: (value) {
                          setState(() {
                            isNameError = false;
                          });
                        },
                      ),
                      if (isNameError)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '이름에는 특수문자와 숫자는 입력할 수 없습니다.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(
                        height: 30,
                      ),
                      TextField(
                        decoration: InputDecoration(
                          hintText: '처음 만난 날 (yyyy-MM-dd)',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFB8B8BC),
                          ),
                          prefixIcon: Icon(
                            Icons.date_range_outlined,
                            size: 29,
                          ),
                        ),
                        keyboardType: TextInputType.datetime,
                        controller: ddayController,
                        onChanged: (value) {
                          setState(() {
                            isDdayError = false;
                          });
                        },
                      ),
                      if (isDdayError)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '숫자와 - 만 입력할 수 있습니다.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(
                        height: 50,
                      ),
                      Center(
                        child: RealSignupBtn(
                          nameController: nameController,
                          ddayController: ddayController,
                          chatroomId: widget.chatroomId,
                          onNameError: () {
                            setState(() {
                              isNameError = true;
                            });
                          },
                          onDdayError: () {
                            setState(() {
                              isDdayError = true;
                            });
                          },
                          onBothError: () {
                            setState(() {
                              isNameError = true;
                              isDdayError = true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RealSignupBtn extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController ddayController;
  final String chatroomId; // chatroomId 필드 추가
  final VoidCallback onNameError;
  final VoidCallback onDdayError;
  final VoidCallback onBothError;

  const RealSignupBtn({
    Key? key,
    required this.nameController,
    required this.ddayController,
    required this.chatroomId,
    required this.onNameError,
    required this.onDdayError,
    required this.onBothError,
  }) : super(key: key);

//   bool isValidName(String name) {
//     // 이름 유효성 검사 로직 추가
//     final RegExp nameRegex = RegExp(r'^[가-힣a-zA-Z]+$');
//     return nameRegex.hasMatch(name);
//   }

//   bool isValidDday(String dday) {
//   // 현재 연도 가져오기
//   final currentYear = DateTime.now().year;

//   // 정규식 패턴 수정
//   final RegExp ddayRegex = RegExp(r'^(19[0-9]{2}|20[0-$currentYear]|$currentYear)-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$');

//   return ddayRegex.hasMatch(dday);
// }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        String name = nameController.text; // 이름 입력값
        String ddayString = ddayController.text; // dday 입력 문자열

        print('입력된 이름: $name'); // 이름 로그 출력
        print('입력된 dday: $ddayString'); // dday 로그 출력

        //bool isNameValid = isValidName(name);
        //bool isDdayValid = isValidDday(ddayString);

        // if (!isNameValid && !isDdayValid) {
        //   onBothError();
        //   return;
        // } else if (!isNameValid) {
        //   onNameError();
        //   return;
        // } else if (!isDdayValid) {
        //   onDdayError();
        //   return;
        // }

        // 문자열을 DateTime 객체로 변환
        final dateFormat = DateFormat("yyyy-MM-dd");
        DateTime dday = dateFormat.parse(ddayString);

        try {
          dday = dateFormat.parse(ddayString);
          print('파싱된 dday: $dday'); // 파싱된 dday 로그 출력
        } catch (e) {
          print('dday 형식이 잘못되었습니다: $e'); // 에러 로그 출력
          return; // 함수 종료
        }

        final storage = FlutterSecureStorage();
        final token = await storage.read(key: 'token'); // 저장된 토큰 읽기

        print('Token: $token'); // 토큰 출력

        final response = await http.post(
          Uri.parse('$apiBaseUrl/api/firstprofile'),
          headers: {
            'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
            'Content-Type': 'application/json', // 컨텐츠 타입을 application/json으로 설정
          },
          body: jsonEncode({
            'name': name,
            'dday': dday.toIso8601String(), // DateTime 객체를 ISO 8601 형식 문자열로 변환
            'chatroomId': chatroomId,
          }),
        );

        if (response.statusCode == 200) {
          // API 호출 성공
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyApp(),
            ),
          );
        } else {
          // API 호출 실패
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('API 호출 실패')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        surfaceTintColor: const Color(0xFF000000),
        backgroundColor: const Color(0xFF000000),
        foregroundColor: Colors.white,
        minimumSize: const Size(180, 53),
        elevation: 3,
      ),
      child: const Text(
        '시작하기',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// import 'dart:convert'; //제약조건 없음
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:luvreed/main.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:luvreed/constants.dart'; //아이피주소

// class StartInfoScreen extends StatelessWidget {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController ddayController = TextEditingController();
//   final String chatroomId; // chatroomId 필드 추가

//   StartInfoScreen({Key? key, required this.chatroomId}); // 생성자 수정

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         backgroundColor: const Color(0xFFFFFFFF),
//         appBar: AppBar(
//           centerTitle: false,
//           backgroundColor: const Color(0xFFFFFFFF),
//           title: Image.asset(
//             'assets/images/luvreed.png',
//               height: 28,
//               width: 270,
//           ),
//           leading: Hero(
//             tag: 'closebtn',
//             child: IconButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               icon: const Icon(Icons.close),
//             ),
//           ),
//         ),
//         body: Container(
//           padding: const EdgeInsets.all(40),
//           child: Column(
//             children: [
//               SizedBox(
//                 height: 20,
//               ),
//               Row(
//                 children: [
//                   Text(
//                     '연결 성공!',
//                     style: TextStyle(
//                       fontSize: 21,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 5,
//               ),
//               Row(
//                 children: [
//                   Text(
//                     '프로필을 입력해주세요.',
//                     style: TextStyle(
//                       fontSize: 21,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 40,
//               ),
//               Form(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       TextField(
//                         decoration: InputDecoration(
//                           hintText: '이름',
//                           hintStyle: TextStyle(
//                             fontSize: 16,
//                             color: Color(0xFFB8B8BC),
//                           ),
//                           prefixIcon: Icon(
//                             Icons.person_outline_rounded,
//                             size: 29,
//                           ),
//                         ),
//                         keyboardType: TextInputType.emailAddress,
//                         controller: nameController,
//                         onChanged: (value) {},
//                       ),
//                       SizedBox(
//                         height: 30,
//                       ),
//                       TextField(
//                         decoration: InputDecoration(
//                           hintText: '처음 만난 날 (yyyy-MM-dd)',
//                           hintStyle: TextStyle(
//                             fontSize: 16,
//                             color: Color(0xFFB8B8BC),
//                           ),
//                           prefixIcon: Icon(
//                             Icons.date_range_outlined,
//                             size: 29,
//                           ),
//                         ),
//                         keyboardType: TextInputType.datetime,
//                         controller: ddayController,
//                         onChanged: (value) {},
//                       ),
//                       SizedBox(
//                         height: 50,
//                       ),
//                       Center(
//                         child: RealSignupBtn(
//                           nameController: nameController,
//                           ddayController: ddayController,
//                           chatroomId: chatroomId,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class RealSignupBtn extends StatelessWidget {
//   final TextEditingController nameController;
//   final TextEditingController ddayController;
//   final String chatroomId; // chatroomId 필드 추가

//   const RealSignupBtn({
//     Key? key,
//     required this.nameController,
//     required this.ddayController,
//     required this.chatroomId,
//   }) : super(key: key);

//   // const RealSignupBtn({
//   //   Key? key,
//   // });

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () async {
//         String name = nameController.text; // 이름 입력값
//         String ddayString = ddayController.text; // dday 입력 문자열

//         print('입력된 이름: $name'); // 이름 로그 출력
//         print('입력된 dday: $ddayString'); // dday 로그 출력

//         // 문자열을 DateTime 객체로 변환
//         final dateFormat = DateFormat("yyyy-MM-dd");
//         DateTime dday = dateFormat.parse(ddayString);

//         try {
//           dday = dateFormat.parse(ddayString);
//           print('파싱된 dday: $dday'); // 파싱된 dday 로그 출력
//         } catch (e) {
//           print('dday 형식이 잘못되었습니다: $e'); // 에러 로그 출력
//           return; // 함수 종료
//         }

//         final storage = FlutterSecureStorage();
//         final token = await storage.read(key: 'token'); // 저장된 토큰 읽기

//         print('Token: $token'); // 토큰 출력

//         final response = await http.post(
//           Uri.parse('$apiBaseUrl/api/firstprofile'),
//           headers: {
//             'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
//             'Content-Type': 'application/json', // 컨텐츠 타입을 application/json으로 설정
//           },
//           body: jsonEncode({
//             'name': name,
//             'dday': dday.toIso8601String(), // DateTime 객체를 ISO 8601 형식 문자열로 변환
//             'chatroomId': chatroomId,
//           }),
//         );

//         if (response.statusCode == 200) {
//           // API 호출 성공
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const MyApp(),
//             ),
//           );
//         } else {
//           // API 호출 실패
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('API 호출 실패')),
//           );
//         }
//       },
//       style: ElevatedButton.styleFrom(
//         surfaceTintColor: const Color(0xFF000000),
//         backgroundColor: const Color(0xFF000000),
//         foregroundColor: Colors.white,
//         minimumSize: const Size(180, 53),
//         elevation: 3,
//       ),
//       child: const Text(
//         '시작하기',
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }
