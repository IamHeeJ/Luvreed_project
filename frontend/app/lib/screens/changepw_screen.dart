import 'package:flutter/material.dart';
import 'package:luvreed/main.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:luvreed/constants.dart'; //아이피주소

class ChangePwScreen extends StatefulWidget {
  const ChangePwScreen({super.key});

  @override
  _ChangePwScreenState createState() => _ChangePwScreenState();
}

class _ChangePwScreenState extends State<ChangePwScreen> {
  final TextEditingController _currentPwController = TextEditingController();
  final TextEditingController _newPwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isLoading = false;
  bool _isCurrentPasswordValid = true;
  bool _isNewPasswordEmpty = false;

  ////////////////////////////////////////////////////////////////////
  ///    현재 비밀번호 맞는지 확인
  ////////////////////////////////////////////////////////////////////
  Future<bool> checkCurrentPassword(String password) async {
    final token = await _secureStorage.read(key: 'token');
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/passwordmatching?requestPassword=$password'),
      headers: {
        'Authorization': 'Bearer $token', // 토큰을 헤더에 추가 (필요시)
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'requestPassword': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception('Failed to verify password');
    }
  }

////////////////////////////////////////////////////////////////////
  ///    비밀번호 변경 로직
  ////////////////////////////////////////////////////////////////////
  void _handleChangePassword() async {
    // 현재 비밀번호를 확인합니다.
    bool isValid = await checkCurrentPassword(_currentPwController.text);

    setState(() {
      _isCurrentPasswordValid = isValid;
    });

    if (!isValid) {
      // 현재 비밀번호가 틀린 경우 메시지를 띄우고 반환합니다.
      return;
    }

    if (_newPwController.text.isEmpty) {
      setState(() {
        _isNewPasswordEmpty = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isCurrentPasswordValid = true; // 기본값으로 true로 설정
    });

    // 새 비밀번호와 새 비밀번호 확인이 일치하는지 확인합니다.
    String newPassword = _newPwController.text;
    String confirmedPassword = _confirmPwController.text;

    if (newPassword == confirmedPassword) {
      // 새 비밀번호와 확인된 비밀번호가 일치하면 변경을 시도합니다.
      bool isSuccess = await changePassword(newPassword);

      setState(() {
        _isLoading = false;
      });

      if (isSuccess) {
        // 변경이 성공하면 각 컨트롤러를 비웁니다.
      _currentPwController.clear();
      _newPwController.clear();
      _confirmPwController.clear();
      
        // 변경이 성공하면 필요한 작업을 수행합니다.
        // 예를 들어 사용자에게 성공 메시지를 보여줄 수 있습니다.
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('비밀번호 변경 성공'),
            content: Text('비밀번호가 성공적으로 변경되었습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // 변경 완료 후 추가 작업을 수행할 수 있습니다.
                },
                child: Text('확인'),
              ),
            ],
          ),
        );
      } else {
        // 변경이 실패한 경우에 대한 처리
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('비밀번호 변경 실패'),
            content: Text('입력하신 비밀번호가 기존의 비밀번호와 동일합니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
              ),
            ],
          ),
        );
      }
    } else {
      // 새 비밀번호와 확인된 비밀번호가 일치하지 않는 경우에 대한 처리
      setState(() {
        _isCurrentPasswordValid = false; // 불일치 시 false로 설정
      });
    }
  }

  ////////////////////////////////////////////////////////////////////
  ///    새 비밀번호 변경
  ////////////////////////////////////////////////////////////////////
  Future<bool> changePassword(String newPassword) async {
    try {
      final token = await _secureStorage.read(key: 'token');
      final response = await http.post(
        Uri.parse(
            '$apiBaseUrl/api/change/password?requestPassword=$newPassword'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // 서버로부터 받은 응답에 따라 true 또는 false를 반환합니다.
        return response.body.trim() == 'true';
      } else {
        // 서버 요청이 실패한 경우에 대한 처리
        throw Exception('Failed to change password');
      }
    } catch (e) {
      // 예외가 발생한 경우에 대한 처리
      throw Exception('Error while changing password: $e');
    }
  }

// 새 비밀번호가 변경될 때마다 호출되는 함수
  void _onNewPasswordChanged() {
    setState(() {
      _isNewPasswordEmpty = _newPwController.text.isEmpty;
    });
  }

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
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Form(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text(
                              '현재 비밀번호',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        TextField(
                          controller: _currentPwController,
                          onChanged: (_) {
                            setState(() {
                              _isCurrentPasswordValid = true;
                            });
                          },
                          decoration: InputDecoration(
                              // errorText: _isCurrentPasswordValid
                              //     ? null
                              //     : '비밀번호가 올바르지 않습니다.',
                              ),
                          keyboardType: TextInputType.text,
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 10, // 경고 메시지와 입력 필드 사이의 간격 조정
                        ),
                        if (!_isCurrentPasswordValid)
                          Text(
                            '비밀번호가 올바르지 않습니다.',
                            style: TextStyle(
                              color: Colors.red, // 빨간색으로 텍스트 스타일 지정
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: [
                            const Text(
                              '새 비밀번호',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        TextField(
                          controller: _newPwController,
                          onChanged: (_) => _onNewPasswordChanged(),
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFB8B8BC),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 10, // 경고 메시지와 입력 필드 사이의 간격 조정
                        ),
                        if (_isNewPasswordEmpty) // 새 비밀번호가 비어 있는 경우에만 메시지 표시
                          Text(
                            '새 비밀번호를 입력하세요.',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: [
                            const Text(
                              '새 비밀번호 확인',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        TextField(
                          controller: _confirmPwController,
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFB8B8BC),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 10, // 경고 메시지와 입력 필드 사이의 간격 조정
                        ),
                        if (_isCurrentPasswordValid == false &&
                            _newPwController.text.isNotEmpty &&
                            _newPwController.text != _confirmPwController.text)
                          Text(
                            '새 비밀번호가 일치하지 않습니다.',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        // if (_newPwController.text.isNotEmpty &&
                        //     _newPwController.text != _confirmPwController.text)
                        //   Text(
                        //     '새 비밀번호가 일치하지 않습니다.',
                        //     style: TextStyle(
                        //       color: Colors.red,
                        //       fontSize: 12,
                        //     ),
                        //   ),
                        const SizedBox(
                          height: 50,
                        ),
                        Center(
                          child: ChangePwBtn(
                            onPressed: _handleChangePassword,
                            isLoading: _isLoading,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChangePwBtn extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const ChangePwBtn({
    super.key,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        surfaceTintColor: const Color(0xFF000000),
        backgroundColor: const Color(0xFF000000),
        foregroundColor: Colors.white,
        minimumSize: const Size(180, 53),
        elevation: 3,
      ),
      child: isLoading
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : const Text(
              '변경하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:luvreed/main.dart';

// class ChangePwScreen extends StatelessWidget {
//   const ChangePwScreen({super.key});

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
//           child: const SingleChildScrollView(
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 50,
//                 ),
//                 Form(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             Text(
//                               '현재 비밀번호',
//                               style: TextStyle(fontSize: 14),
//                             ),
//                           ],
//                         ),
//                         TextField(
//                           decoration: InputDecoration(),
//                           keyboardType: TextInputType.text,
//                           obscureText: true,
//                         ),
//                         SizedBox(
//                           height: 30,
//                         ),
//                         Row(
//                           children: [
//                             Text(
//                               '새 비밀번호',
//                               style: TextStyle(fontSize: 14),
//                             ),
//                           ],
//                         ),
//                         TextField(
//                           decoration: InputDecoration(
//                             hintStyle: TextStyle(
//                               fontSize: 16,
//                               color: Color(0xFFB8B8BC),
//                             ),
//                           ),
//                           keyboardType: TextInputType.text,
//                           obscureText: true,
//                         ),
//                         SizedBox(
//                           height: 30,
//                         ),
//                         Row(
//                           children: [
//                             Text(
//                               '새 비밀번호 확인',
//                               style: TextStyle(fontSize: 14),
//                             ),
//                           ],
//                         ),
//                         TextField(
//                           decoration: InputDecoration(
//                             hintStyle: TextStyle(
//                               fontSize: 16,
//                               color: Color(0xFFB8B8BC),
//                             ),
//                           ),
//                           keyboardType: TextInputType.text,
//                           obscureText: true,
//                         ),
//                         SizedBox(
//                           height: 50,
//                         ),
//                         Center(
//                           child: ChangePwBtn(),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ChangePwBtn extends StatelessWidget {
//   const ChangePwBtn({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () => Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const MyApp(),
//         ),
//       ),
//       style: ElevatedButton.styleFrom(
//         surfaceTintColor: const Color(0xFF000000),
//         backgroundColor: const Color(0xFF000000),
//         foregroundColor: Colors.white,
//         minimumSize: const Size(180, 53),
//         elevation: 3,
//       ),
//       child: const Text(
//         '변경하기',
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }
