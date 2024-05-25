import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:luvreed/screens/signup_complete.dart';
import 'package:luvreed/constants.dart'; //아이피주소
import 'dart:core';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isInvalidEmail = false; // 잘못된 이메일 형식 여부를 저장하는 변수
  bool isMissingInput = false; // 입력 누락 여부를 저장하는 변수
  String email = '';
  String password = '';
  final RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  Future<void> signUp(
      BuildContext context, String email, String password) async {
    //이메일 형식 확인
    if (!emailRegExp.hasMatch(email)) {
      setState(() {
        isInvalidEmail = true; // 이메일 형식이 잘못된 경우 true로 설정
      });
      return; // 이메일 형식이 잘못되면 함수 종료
    }

    // 이메일 또는 비밀번호 누락 여부 확인
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        isMissingInput = true; // 입력이 누락된 경우 true로 설정
      });
      return; // 입력이 누락되면 함수 종료
    }

    final url = Uri.parse('$apiBaseUrl/api/signup/submit');

    final response = await http.post(
      url,
      body: json.encode({
        'email': email,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SignupComplete(),
        ),
      );
    } else {
      print('회원가입 실패');
    }
  }

////////////////////////////////////////////////////////////////////
  ///  빌드 메서드
////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          centerTitle: false,
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
        body: Container(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    '반갑습니다!',
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
                    '가입을 위한 정보를 입력해주세요.',
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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        onChanged: (value) {
                          setState(() {
                            email = value;
                            isInvalidEmail = false; // 이메일이 바뀌면 다시 유효성을 검사하도록 설정
                            // isMissingInput = false; // 입력 값이 변경되면 누락 여부도 초기화
                          });
                        },
                        decoration: InputDecoration(
                          hintText: '이메일',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFB8B8BC),
                          ),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            size: 29,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      TextField(
                        controller: passwordController,
                        onChanged: (value) {
                          setState(() {
                            password = value;
                            // isMissingInput = false; // 입력 값이 변경되면 누락 여부 초기화
                          });
                        },
                        decoration: InputDecoration(
                          hintText: '비밀번호',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFB8B8BC),
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            size: 29,
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        obscureText: true,
                      ),
                      if (isMissingInput || isInvalidEmail) // 메시지 표시 조건 변경
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            isMissingInput
                                ? '이메일과 비밀번호를 입력하세요.'
                                : '올바른 이메일 형식이 아닙니다.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(
                        height: 50,
                      ),
                      Center(
                        child: RealSignupBtn(
                          onPressed: () {
                            setState(() {
                              if (email.isEmpty && password.isEmpty) {
                                isMissingInput = true;
                              } else {
                                isMissingInput = false;
                              }

                              if (!emailRegExp.hasMatch(email)) {
                                isInvalidEmail = true;
                              } else {
                                isInvalidEmail = false;
                              }
                            });

                            if (!isMissingInput && !isInvalidEmail) {
                              signUp(
                                context,
                                emailController.text,
                                passwordController.text,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RealSignupBtn extends StatelessWidget {
  final VoidCallback onPressed;

  const RealSignupBtn({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        surfaceTintColor: const Color(0xFF000000),
        backgroundColor: const Color(0xFF000000),
        foregroundColor: Colors.white,
        minimumSize: const Size(180, 53),
        elevation: 3,
      ),
      child: const Text(
        '회원가입',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:luvreed/screens/signup_complete.dart';
// import 'package:luvreed/constants.dart'; //아이피주소


// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({Key? key}) : super(key: key);

//   @override
//   _SignUpScreenState createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   Future<void> signUp(BuildContext context, String email, String password) async {
//     final url = Uri.parse('$apiBaseUrl/api/signup/submit');

//     final response = await http.post(
//       url,
//       body: json.encode({
//         'email': email,
//         'password': password,
//       }),
//       headers: {'Content-Type': 'application/json'},
//     );

//     if (response.statusCode == 200) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const SignupComplete(),
//         ),
//       );
//     } else {
//       print('Failed to sign up');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         backgroundColor: const Color(0xFFFFFFFF),
//         appBar: AppBar(
//           centerTitle: false,
//           backgroundColor: const Color(0xFFFFFFFF),
//           title: Hero(
//             tag: 'StartLogo',
//             child: Image.asset(
//               'assets/images/luvreed.png',
//               height: 28,
//               width: 270,
//             ),
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
//                     '반갑습니다!',
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
//                     '가입을 위한 정보를 입력해주세요.',
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
//                         controller: emailController,
//                         decoration: InputDecoration(
//                           hintText: '이메일',
//                           hintStyle: TextStyle(
//                             fontSize: 16,
//                             color: Color(0xFFB8B8BC),
//                           ),
//                           prefixIcon: Icon(
//                             Icons.email_outlined,
//                             size: 29,
//                           ),
//                         ),
//                         keyboardType: TextInputType.emailAddress,
//                       ),
//                       SizedBox(
//                         height: 30,
//                       ),
//                       TextField(
//                         controller: passwordController,
//                         decoration: InputDecoration(
//                           hintText: '비밀번호',
//                           hintStyle: TextStyle(
//                             fontSize: 16,
//                             color: Color(0xFFB8B8BC),
//                           ),
//                           prefixIcon: Icon(
//                             Icons.lock_outline,
//                             size: 29,
//                           ),
//                         ),
//                         keyboardType: TextInputType.text,
//                         obscureText: true,
//                       ),
//                       SizedBox(
//                         height: 50,
//                       ),
//                       Center(
//                         child: RealSignupBtn(
//                           onPressed: () {
//                             signUp(
//                               context,
//                               emailController.text,
//                               passwordController.text,
//                             );
//                           },
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
//   final VoidCallback onPressed;

//   const RealSignupBtn({Key? key, required this.onPressed}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         surfaceTintColor: const Color(0xFF000000),
//         backgroundColor: const Color(0xFF000000),
//         foregroundColor: Colors.white,
//         minimumSize: const Size(180, 53),
//         elevation: 3,
//       ),
//       child: const Text(
//         '회원가입',
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }
