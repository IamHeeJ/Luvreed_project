import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:luvreed/screens/connect_screen.dart';
import 'package:luvreed/screens/findpw_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:luvreed/main.dart';
import 'package:luvreed/constants.dart';
import 'package:luvreed/screens/home_screen.dart';
import 'package:luvreed/screens/main_screen.dart'; //아이피주소

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final secureStorage = const FlutterSecureStorage();
  String email = '';
  String password = '';
  bool isWrongPassword = false; // 비밀번호가 틀렸는지 여부를 저장하는 변수

  //////////////////////////////////////////////////////////////////
  ///  로그인 요청(POST)
  //////////////////////////////////////////////////////////////////
  Future<void> login(
      BuildContext context, String email, String password) async {
    // 이메일 또는 비밀번호가 빈 문자열인지 확인
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        isWrongPassword = true;
      });
      return;
    }

    await _logoutPreviousSession(); //추가

    final Uri uri = Uri.parse('$apiBaseUrl/api/login');
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    final Map<String, String> body = {
      'email': email,
      'password': password,
    };

    final http.Response response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String token = data['token'];
      final String role = data['role'];
      final String userId = data['id'].toString();

      //final String chatroomId = data['chatroomId'].toString();

      // 토큰을 SecureStorage에 저장
      await secureStorage.write(key: 'token', value: token);
      await secureStorage.write(key: 'userId', value: userId);
      // await secureStorage.write(key: 'chatroomId', value: chatroomId);

      // role에 따라 화면 이동
      if (role == 'SOLO') {
        // solo 유저는 connect_screen.dart로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConnectScreen(),
          ),
        );
      } else if (role == 'COUPLE') {
        final String chatroomId = data['chatroomId'].toString();
        await secureStorage.write(key: 'chatroomId', value: chatroomId);
        // couple 유저는 home_screen.dart로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      } else {
        // 예상하지 못한 role 값
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('예상치 못한 문제가 발생했습니다.'),
          ),
        );
      }
    } else {
      // 로그인 실패 처리
      if (response.statusCode == 401) {
        // 인증 실패 (잘못된 이메일 또는 비밀번호)
        setState(() {
          isWrongPassword = true; // 로그인 실패 시 isWrongPassword를 true로 설정
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이메일 또는 비밀번호가 잘못되었습니다.'),
          ),
        );
      } else {
        // 기타 실패 (서버 오류 등)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인에 실패했습니다. 잠시 후 다시 시도해주세요.'),
          ),
        );
      }
    }
  }

  Future<void> _logoutPreviousSession() async {
    //추가.
    final token = await secureStorage.read(key: 'token');
    if (token != null) {
      final Uri uri = Uri.parse('$apiBaseUrl/api/logout');
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      await http.post(uri, headers: headers);
    }
  }

  //////////////////////////////////////////////////////////////////
  ///   빌드
  //////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFFFFFFFF),
          title: Hero(
            tag: 'StartLogo',
            child: Image.asset(
              'assets/images/luvreed.png',
              height: 28,
              width: 270,
            ),
          ),
          leading: Hero(
            tag: 'closebtn',
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                onChanged: (value) {
                  // 이메일 입력 값 업데이트
                  email = value;
                },
                decoration: const InputDecoration(
                  hintText: '이메일',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  // 비밀번호 입력 값 업데이트
                  password = value;
                },
                decoration: const InputDecoration(
                  hintText: '비밀번호',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                keyboardType: TextInputType.text,
                obscureText: true,
              ),
              if (isWrongPassword)
                Column(
                  children: [
                    if (email.isEmpty && password.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          '이메일과 비밀번호를 입력하세요.',
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    else if (email.isEmpty && password.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          '이메일을 입력하세요.',
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    else if (email.isNotEmpty && password.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          '비밀번호를 입력하세요.',
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    else
                      (const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          '이메일 또는 비밀번호가 올바르지 않습니다.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ))
                  ],
                ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () async {
                  // 로그인 버튼이 눌렸을 때마다 isWrongPassword 초기화
                  setState(() {
                    isWrongPassword = false;
                  });
                  await login(context, email, password);
                },
                style: ElevatedButton.styleFrom(
                  surfaceTintColor: const Color(0xFF000000),
                  backgroundColor: const Color(0xFF000000),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(180, 53),
                  elevation: 3,
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FindPwBtn extends StatelessWidget {
  const FindPwBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FindPwScreen(),
        ),
      ),
      child: const Text(
        '비밀번호 찾기',
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFFC5C5C5),
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:luvreed/screens/connect_screen.dart';
// import 'package:luvreed/screens/findpw_screen.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:luvreed/main.dart';
// import 'package:luvreed/constants.dart'; //아이피주소

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final secureStorage = const FlutterSecureStorage();
//   String email = '';
//   String password = '';
//   bool isWrongPassword = false; // 비밀번호가 틀렸는지 여부를 저장하는 변수

//   //////////////////////////////////////////////////////////////////
//   ///  로그인 요청(POST)
//   //////////////////////////////////////////////////////////////////
//   Future<void> login(
//       BuildContext context, String email, String password) async {
//     // 이메일 또는 비밀번호가 빈 문자열인지 확인
//     if (email.isEmpty || password.isEmpty) {
//       setState(() {
//         isWrongPassword = true;
//       });
//       return;
//     }

//     final Uri uri = Uri.parse('$apiBaseUrl/api/login');
//     final Map<String, String> headers = {'Content-Type': 'application/json'};
//     final Map<String, String> body = {
//       'email': email,
//       'password': password,
//     };

//     final http.Response response = await http.post(
//       uri,
//       headers: headers,
//       body: jsonEncode(body),
//     );

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = jsonDecode(response.body);
//       final String token = data['token'];
//       final String role = data['role'];
//       final String userId = data['id'].toString();

//       //final String chatroomId = data['chatroomId'].toString();

//       // 토큰을 SecureStorage에 저장
//       await secureStorage.write(key: 'token', value: token);
//       await secureStorage.write(key: 'userId', value: userId);
//       // await secureStorage.write(key: 'chatroomId', value: chatroomId);

//       // role에 따라 화면 이동
//       if (role == 'SOLO') {
//         // solo 유저는 connect_screen.dart로 이동
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ConnectScreen(),
//           ),
//         );
//       } else if (role == 'COUPLE') {
//         final String chatroomId = data['chatroomId'].toString();
//         await secureStorage.write(key: 'chatroomId', value: chatroomId);
//         // couple 유저는 MyApp.dart로 이동
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const MyApp(),
//           ),
//         );
//       } else {
//         // 예상하지 못한 role 값
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('예상치 못한 문제가 발생했습니다.'),
//           ),
//         );
//       }
//     } else {
//       // 로그인 실패 처리
//       if (response.statusCode == 401) {
//         // 인증 실패 (잘못된 이메일 또는 비밀번호)
//         setState(() {
//           isWrongPassword = true; // 로그인 실패 시 isWrongPassword를 true로 설정
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('이메일 또는 비밀번호가 잘못되었습니다.'),
//           ),
//         );
//       } else {
//         // 기타 실패 (서버 오류 등)
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('로그인에 실패했습니다. 잠시 후 다시 시도해주세요.'),
//           ),
//         );
//       }
//     }
//   }

//   //////////////////////////////////////////////////////////////////
//   ///   빌드
//   //////////////////////////////////////////////////////////////////
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         backgroundColor: const Color(0xFFFFFFFF),
//         appBar: AppBar(
//           centerTitle: true,
//           backgroundColor: const Color(0xFFFFFFFF),
//           title: Image.asset(
//             'assets/images/luvreed.png',
//             height: 28,
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
//         body: Padding(
//           padding: const EdgeInsets.all(40),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               TextField(
//                 onChanged: (value) {
//                   // 이메일 입력 값 업데이트
//                   email = value;
//                 },
//                 decoration: const InputDecoration(
//                   hintText: '이메일',
//                   prefixIcon: Icon(Icons.email_outlined),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 20),
//               TextField(
//                 onChanged: (value) {
//                   // 비밀번호 입력 값 업데이트
//                   password = value;
//                 },
//                 decoration: const InputDecoration(
//                   hintText: '비밀번호',
//                   prefixIcon: Icon(Icons.lock_outline),
//                 ),
//                 keyboardType: TextInputType.text,
//                 obscureText: true,
//               ),
//               if (isWrongPassword)
//                 Column(
//                   children: [
//                     if (email.isEmpty && password.isEmpty)
//                       const Padding(
//                         padding: EdgeInsets.only(top: 8),
//                         child: Text(
//                           '이메일과 비밀번호를 입력하세요.',
//                           style: TextStyle(color: Colors.red),
//                         ),
//                       )
//                     else if (email.isEmpty && password.isNotEmpty)
//                       const Padding(
//                         padding: EdgeInsets.only(top: 8),
//                         child: Text(
//                           '이메일을 입력하세요.',
//                           style: TextStyle(color: Colors.red),
//                         ),
//                       )
//                     else if (email.isNotEmpty && password.isEmpty)
//                       const Padding(
//                         padding: EdgeInsets.only(top: 8),
//                         child: Text(
//                           '비밀번호를 입력하세요.',
//                           style: TextStyle(color: Colors.red),
//                         ),
//                       )
//                     else
//                       (const Padding(
//                         padding: EdgeInsets.only(top: 8),
//                         child: Text(
//                           '이메일 또는 비밀번호가 올바르지 않습니다.',
//                           style: TextStyle(color: Colors.red),
//                         ),
//                       ))
//                   ],
//                 ),
//               const SizedBox(height: 50),
//               ElevatedButton(
//                 onPressed: () async {
//                   // 로그인 버튼이 눌렸을 때마다 isWrongPassword 초기화
//                   setState(() {
//                     isWrongPassword = false;
//                   });
//                   await login(context, email, password);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   surfaceTintColor: const Color(0xFF000000),
//                   backgroundColor: const Color(0xFF000000),
//                   foregroundColor: Colors.white,
//                   minimumSize: const Size(180, 53),
//                   elevation: 3,
//                 ),
//                 child: const Text(
//                   '로그인',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class FindPwBtn extends StatelessWidget {
//   const FindPwBtn({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextButton(
//       onPressed: () => Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const FindPwScreen(),
//         ),
//       ),
//       child: const Text(
//         '비밀번호 찾기',
//         style: TextStyle(
//           fontSize: 12,
//           color: Color(0xFFC5C5C5),
//         ),
//       ),
//     );
//   }
// }
