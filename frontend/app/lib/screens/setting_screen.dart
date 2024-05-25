import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:luvreed/screens/changepw_screen.dart';
import 'package:luvreed/screens/main_screen.dart';
import 'package:luvreed/screens/redate_screen.dart';
import 'package:luvreed/screens/startpage1.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:luvreed/constants.dart';
import 'package:luvreed/screens/stomp_provider.dart';
import 'package:provider/provider.dart'; //아이피주소

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  String userName = ''; // 사용자 이름
  String userEmail = ''; // 사용자 이메일을 저장할 변수

  @override
  void initState() {
    super.initState();
    // loadUserEmail(); // 사용자 이메일을 불러오는 함수 호출
    _fetchUserInfo();
  }

  /////////////// 사용자 이름, 메일  GET요청//////////////////////////
  Future<void> _fetchUserInfo() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token'); // 저장된 토큰 읽기

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/userinfo'),
      headers: {
        'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
      },
    );

    if (response.statusCode == 200) {
      //한글 깨짐 현상 해결
      final decodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = json.decode(decodedBody);
      // final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        userName =
            data['name'] ?? '홍길동'; // 사용자 이름 저장 (name=null이면 'null'문자열 저장)
        userEmail = data['email']; // 사용자 이메일 저장
      });
    } else {
      throw Exception('Failed to load user info');
    }
  }

  /////////////// 탈퇴 버튼 함수//////////////////////////
  Future<void> deleteAccount() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/deleteaccount'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      await storage.delete(key: 'token');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StartPage1()),
      );
    } else {
      throw Exception('Failed to delete account');
    }
  }

  @override
  Widget build(BuildContext context) {
    const secureStorage = FlutterSecureStorage();

    // void logout() async {
    //   // SecureStorage에서 토큰 삭제
    //   await secureStorage.delete(key: 'token');
    //   await secureStorage.delete(key: 'userId'); //추가
    //   await secureStorage.delete(key: 'chatroomId'); //추가
    //   Builder(
    //     builder: (context) {
    //       final stompProvider =
    //           Provider.of<StompProvider>(context, listen: false);
    //       stompProvider.disconnectStomp();
    //       return Container();
    //     },
    //   );
    //   // StartPage1로 이동하여 로그인 화면으로 되돌아가기
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => const StartPage1()),
    //   );
    // }

    void logout() async {
      // 로그아웃 API 호출
      final token = await secureStorage.read(key: 'token');
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/logout'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // SecureStorage에서 토큰 삭제
        await secureStorage.delete(key: 'token');
        await secureStorage.delete(key: 'userId');
        await secureStorage.delete(key: 'chatroomId');

        // StompProvider를 통해 WebSocket 연결 종료 및 구독 해제
        final stompProvider =
            Provider.of<StompProvider>(context, listen: false);
        stompProvider.disconnectStomp();

        // StartPage1로 이동하여 로그인 화면으로 되돌아가기
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StartPage1()),
        );
      } else {
        // 로그아웃 실패 시 처리
        print('로그아웃 실패');
      }
    }

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
              // Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const MainScreen(),
                  transitionDuration: Duration.zero,
                ),
              );
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '이름',
                    style: TextStyle(
                      fontSize: 19,
                    ),
                  ),
                  Text(
                    userName, // 사용자 이름
                    style: TextStyle(
                      fontSize: 19,
                      color: Color(0xFF828282),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '이메일',
                    style: TextStyle(
                      fontSize: 19,
                    ),
                  ),
                  Text(
                    userEmail, //사용자 이메일
                    style: const TextStyle(
                      fontSize: 19,
                      color: Color(0xFF828282),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReDateScreen(),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '처음 만난 날 수정하기',
                      style: TextStyle(
                        fontSize: 19,
                      ),
                    ),
                    Image.asset('assets/images/emptyheart.png'),
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePwScreen(),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '비밀번호 변경',
                      style: TextStyle(
                        fontSize: 19,
                      ),
                    ),
                    Image.asset('assets/images/pwchange.png'),
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),

              GestureDetector(
                onTap: logout,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '로그아웃',
                      style: TextStyle(
                        fontSize: 19,
                      ),
                    ),
                    Image.asset('assets/images/logout.png'),
                  ],
                ),
              ),
              const Spacer(),
              // 탈퇴하기 버튼
              TextButton(
                onPressed: () {
                  // 탈퇴 다이얼로그 표시
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        backgroundColor: const Color(0xFFFFFFFF),
                        surfaceTintColor: const Color(0xFFFFFFFF),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: 200,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                height: 60,
                              ),
                              const Text(
                                '정말 탈퇴하겠습니까?',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF7F8FC),
                                      surfaceTintColor: const Color(0xFFF7F8FC),
                                      minimumSize: const Size(100, 40),
                                    ),
                                    onPressed: () async {
                                      await deleteAccount();
                                      Navigator.pop(context); // 다이얼로그 닫기
                                    },
                                    child: const Text(
                                      '탈퇴',
                                      style: TextStyle(
                                        color: Color(0xFFFF0000),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF7F8FC),
                                      surfaceTintColor: const Color(0xFFF7F8FC),
                                      minimumSize: const Size(100, 40),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context); // 다이얼로그 닫기
                                    },
                                    child: const Text(
                                      '계정유지',
                                      style: TextStyle(
                                        color: Color(0xFF007AFF),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: const Text(
                  '탈퇴하기',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFCE6E6E),
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
