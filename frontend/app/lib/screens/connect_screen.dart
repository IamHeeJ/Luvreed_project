import 'dart:convert'; // json 라이브러리 추가
import 'package:flutter/material.dart';
import 'package:luvreed/screens/chat_screen.dart';
import 'package:luvreed/screens/startinfo_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:luvreed/constants.dart';
import 'package:luvreed/screens/home_screen.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ConnectScreen extends StatefulWidget {
  @override
  _ConnectScreenState createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State {
  final TextEditingController _controller = TextEditingController();
  late final WebSocketChannel channel;
  String? _chatroomId; // chatroomId 필드 추가
  String _myInviteCode = '';
  String _partnerInviteCode = '';
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  bool _isInviteCodeFetched = false;
  bool _showErrorMessage = false;

  @override
  void initState() {
    super.initState();
    _fetchInviteCode();
  }

  void _fetchInviteCode() async {
    if (_isInviteCodeFetched) return;

    String? jwtToken = await secureStorage.read(key: 'token');
    if (jwtToken != null) {
      final headers = {'Authorization': 'Bearer $jwtToken'};
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/invitecode'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        setState(() {
          _myInviteCode = response.body;
          _isInviteCodeFetched = true;
        });
      } else {
        // Handle error
      }
    }
  }

  Future<String?> _getChatroomId() async {
    String? jwtToken = await secureStorage.read(key: 'token');
    if (jwtToken != null) {
      final headers = {'Authorization': 'Bearer $jwtToken'};
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/connectandreturnchatroom'),
        headers: headers,
        body: {'invite_code': _partnerInviteCode},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.containsKey('chatroomId')) {
          // 수정된 부분: 'id'로 변경
          return jsonResponse['chatroomId'].toString(); // 수정된 부분: 'id'로 변경
        } else {
          // Handle error, chatroom field not found in response
          return null;
        }
      } else {
        // Handle error, response status code is not 200
        return null;
      }
    }
    return null;
  }

  Future<bool> _sendCoupleConnectRequest() async {
    final chatroomId = await _getChatroomId();

    if (chatroomId != null) {
      await secureStorage.write(key: 'chatroomId', value: chatroomId);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StartInfoScreen(chatroomId: chatroomId),
        ),
      );

      return true; // 연결에 성공했으므로 true 반환
    } else {
      // 연결 실패 시 에러 메시지 표시 등 추가 작업 수행 가능
      return false; // 연결에 실패했으므로 false 반환
    }
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
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Text(
                    '연결을 위해 상대방의 초대코드를\n입력해주세요.',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Form(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '내 초대코드: ',
                            style: TextStyle(fontSize: 14),
                          ),
                          Expanded(
                            child: Text(
                              _myInviteCode,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFB8B8BC),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Row(
                      //   children: [
                      //     Text(
                      //       '내 초대코드',
                      //       style: TextStyle(fontSize: 14),
                      //     ),
                      //     Text(
                      //       _myInviteCode,
                      //       style: TextStyle(
                      //         fontSize: 16,
                      //         color: Color(0xFFB8B8BC),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(
                        height: 30,
                      ),
                      TextField(
                        decoration: InputDecoration(
                          hintText: '상대방 코드 입력',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFB8B8BC),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          setState(() {
                            _partnerInviteCode = value; // 변수 할당
                            _showErrorMessage = false;
                          });
                        },
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      if (_showErrorMessage) // 에러 메시지 표시 조건 추가
                        Text(
                          '초대코드를 다시 입력해주세요',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                        height: 40,
                      ),
                      Center(
                        child: ConnectBtn(this, _partnerInviteCode, () {
                          setState(() {
                            _showErrorMessage = true; // 연결 실패 시 에러 메시지 표시
                          });
                        }),
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


class ConnectBtn extends StatelessWidget {
  final _ConnectScreenState _connectScreenState;
  final String _partnerInviteCode;
  final VoidCallback _onConnectionFailure;

   const ConnectBtn(
    this._connectScreenState,
    this._partnerInviteCode,
    this._onConnectionFailure, // 콜백 매개변수 추가
    {Key? key}
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final success = await _connectScreenState._sendCoupleConnectRequest();

        if (success) {
          // chatroomId를 secureStorage에서 읽어옴
          final chatroomId =
              await _connectScreenState.secureStorage.read(key: 'chatroomId');

          if (chatroomId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StartInfoScreen(chatroomId: chatroomId),
              ),
            );
          } else {
            // chatroomId가 null인 경우 처리
          }
        } else {
          _onConnectionFailure();
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
        '연결하기',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
