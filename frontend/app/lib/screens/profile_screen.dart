// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:luvreed/constants.dart';
// import 'package:luvreed/screens/home_screen.dart';
// import 'package:luvreed/screens/main_screen.dart'; //아이피주소

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

//   @override
//   void initState() {
//     super.initState();
//     _fetchNickname();
//     _fetchLoverImage();
//   }

//   String loverNickname = ''; //상대방 닉네임
//   String newLoverNickname = ''; //변경할 닉네임
//   Image? loverImage;
//   // String name = '';
//   bool isEditing = false;

//   // void _navigateToHome(BuildContext context) {
//   //   //추가
//   //   Navigator.of(context).popUntil((route) => route.isFirst);
//   // }

//   void _navigateToHome(BuildContext context) {
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => const MainScreen()),
//       (route) => false,
//     );
//   }
  
// ///////////////// 닉네임 변경 put요청 ///////////////////////////
//   Future<void> _fetchChangeNickname(String nickname) async {
//     final String? token = await secureStorage.read(key: 'token'); // 토큰 읽기

//     try {
//       final response = await http.put(
//         Uri.parse('$apiBaseUrl/api/nickname?nickname=$nickname'),
//         headers: {
//           'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
//         },
//       );

//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//         final newNickname = jsonResponse['nickname']; // json응답에서 변경할 닉네임 추출

//         setState(() {
//           newLoverNickname = newNickname; //닉네임 변경
//         });
//       } else {
//         print('닉네임 변경 실패(api요청 실패): ${response.statusCode}');
//       }
//     } catch (e) {
//       print('닉네임 변경 실패(네트워크 오류 등): $e');
//     }
//   }

// ///////////////상대방 닉네임 GET요청////////////////////////
//   Future<void> _fetchNickname() async {
//     final token = await secureStorage.read(key: 'token'); // 저장된 토큰 읽기
//     print('Token: $token'); // 토큰 출력

//     final response = await http.get(
//       Uri.parse('$apiBaseUrl/api/getcoupleprofile'),
//       headers: {
//         'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
//       },
//     );

//     if (response.statusCode == 200) {
//       //한글깨짐 해결 (UTF-8로 디코딩)
//       final decodedBody = utf8.decode(response.bodyBytes);
//       final Map<String, dynamic> data = json.decode(decodedBody);

//       setState(() {
//         loverNickname = data['loverNickname']; // 상대방의 닉네임 설정
//       });
//       // 닉네임 정보를 가져온 후 로그 출력
//       print('상대방 닉네임 get 성공: $loverNickname');
//     } else {
//       loverNickname = '닉네임';
//     }
//   }

// ///////////////////이미지 method/////////////////
//   final ImagePicker picker = ImagePicker();
//   XFile? _image;

//   Future getImage(ImageSource imageSource) async {
//     final XFile? pickedFile = await picker.pickImage(source: imageSource);
//     if (pickedFile != null) {
//       setState(() {
//         _image = XFile(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _saveImage() async {
//     final token = await secureStorage.read(key: 'token');
//     final userId = await secureStorage.read(key: 'userId');
//     if (_image != null) {
//       final url = Uri.parse('$apiBaseUrl/api/saveimage');
//       final request = http.MultipartRequest('POST', url);
//       request.headers['Authorization'] = 'Bearer $token';
//       final file = await http.MultipartFile.fromPath('image', _image!.path);
//       request.files.add(file);

//       final response = await request.send();

//       if (response.statusCode == 200) {
//         print('이미지 저장 성공');
//       } else {
//         print('이미지 저장 실패');
//       }
//     }
//   }

//   Future<void> _fetchLoverImage() async {
//     final token = await secureStorage.read(key: 'token'); // 저장된 토큰 읽기

//     final response = await http.get(
//       Uri.parse('$apiBaseUrl/api/getloverprofile'),
//       headers: {
//         'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
//       },
//     );

//     if (response.statusCode == 200) {
//       //한글깨짐 해결 (UTF-8로 디코딩)
//       final decodedBody = utf8.decode(response.bodyBytes);
//       final Map<String, dynamic> data = json.decode(decodedBody);

//       // 이미지 파일 설정
//       final String? loverImageBase64 = data['loverImage'];

//       if (loverImageBase64 != null && loverImageBase64.isNotEmpty) {
//         // Base64 디코딩하여 Uint8List로 변환
//         final Uint8List loverImageBytes = base64Decode(loverImageBase64);
//         // 이미지 파일을 Image.memory로 설정
//         loverImage = Image.memory(loverImageBytes);
//       } else {
//         // loverImage가 null이거나 빈 문자열인 경우 기본 이미지로 설정
//         loverImage = Image.asset('assets/images/profile_default2.png');
//       }

//     } else {
      
//     }
//   }

//   ////////////////////////////////////////////////////////////////////////////
//   //           빌드 메서드
//   ///////////////////////////////////////////////////////////////////////////

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         if (isEditing) {
//           FocusManager.instance.primaryFocus?.unfocus();
//           setState(() {
//             isEditing = false;
//           });
//         }
//       },
//       child: Scaffold(
//         backgroundColor: const Color(0xFFFFFFFF),
//         appBar: AppBar(
//           centerTitle: false,
//           backgroundColor: const Color(0xFFFFFFFF),
//           title: Hero(
//             tag: 'mainlogo',
//             child: Image.asset(
//               'assets/images/luvreed.png',
//               height: 28,
//               width: 270,
//             ),
//           ),
//           leading: Hero(
//             tag: 'closebtn',
//             child: IconButton(
//               onPressed: () async {
//                 if (isEditing) {
//                   // 변경된 닉네임을 서버에 업데이트
//                   await _fetchChangeNickname(loverNickname);

//                   //프로필 화면으로 돌아감
//                   Navigator.pop(context);
//                 } else {
//                   // 변경 중이 아니라면 그냥 프로필 화면으로 돌아감
//                   Navigator.pop(context);
//                 }
//                 await _saveImage(); // 이미지 저장 메서드 호출
//                 //avigator.pop(context);
//                 Navigator.pushReplacement(
//                   context,
//                   PageRouteBuilder(
//                     pageBuilder: (_, __, ___) => const MainScreen(),
//                     transitionDuration: Duration.zero,
//                   ),
//                 );
//               },
//               icon: const Icon(Icons.arrow_back_ios_new_rounded),
//             ),
//           ),
//         ),
//         body: Column(
//           children: [
//             const SizedBox(
//               height: 105,
//             ),
//             _image != null
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(25),
//                     child: Image.file(
//                       File(_image!.path),
//                       width: 200,
//                       height: 200,
//                     ),
//                   )
//                 : loverImage != null
//                   ? ClipRRect(
//                       borderRadius: BorderRadius.circular(25),
//                       child: SizedBox(
//                         width: 200,
//                         height: 200,
//                         child: FittedBox(
//                           fit: BoxFit.cover,
//                           child: loverImage,
//                         ),
//                       ),
//                     )
//                   : ClipRRect(
//                       borderRadius: BorderRadius.circular(25),
//                       child: Image.asset(
//                         'assets/images/profile_default2.png',
//                         width: 200,
//                         height: 200,
//                       ),
//                     ),
                
//             const SizedBox(
//               height: 15,
//             ),
//             Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 160),
//                   child: isEditing
//                       ? TextField(
//                           decoration: const InputDecoration(
//                             isCollapsed: true,
//                             contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 5),
//                           ),
//                           style: const TextStyle(
//                             fontSize: 15,
//                           ),
//                           autofocus: true,
//                           onChanged: (value) {
//                             setState(() {
//                               loverNickname = value;
//                             });
//                           },
//                           onEditingComplete: () {
//                             // 수정이 완료되면 변경된 닉네임을 서버에 업데이트
//                             _fetchChangeNickname(loverNickname);
//                             // 수정 모드 종료
//                             setState(() {
//                               isEditing = false;
//                             });
//                           },
//                         )
                      
//                       : Text(
//                           loverNickname.isNotEmpty ? loverNickname : '기존 닉네임',
//                           style: const TextStyle(
//                             fontSize: 15,
//                           ),
//                         ),
//                 ),
//                 const SizedBox(
//                   height: 80,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         getImage(ImageSource.gallery);
//                       },
//                       child: const Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.camera_alt_outlined,
//                             size: 20,
//                           ),
//                           SizedBox(
//                             width: 5,
//                           ),
//                           Text(
//                             '사진 변경하기',
//                             style: TextStyle(
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 30,
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           isEditing = true;
//                         });
//                       },
//                       child: const Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.edit,
//                             size: 20,
//                           ),
//                           SizedBox(
//                             width: 5,
//                           ),
//                           Text(
//                             '이름 변경하기',
//                             style: TextStyle(
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:luvreed/constants.dart';
import 'package:luvreed/screens/home_screen.dart';
import 'package:luvreed/screens/main_screen.dart'; //아이피주소

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchNickname();
    _fetchLoverImage();
  }

  String loverNickname = ''; //상대방 닉네임
  String newLoverNickname = ''; //변경할 닉네임
  Image? loverImage;
  // String name = '';
  bool isEditing = false;

  // void _navigateToHome(BuildContext context) {
  //   //추가
  //   Navigator.of(context).popUntil((route) => route.isFirst);
  // }

  void _navigateToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (route) => false,
    );
  }

///////////////// 닉네임 변경 put요청 ///////////////////////////
  Future<void> _fetchChangeNickname(String nickname) async {
    final String? token = await secureStorage.read(key: 'token'); // 토큰 읽기

    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/api/nickname?nickname=$nickname'),
        headers: {
          'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final newNickname = jsonResponse['nickname']; // json응답에서 변경할 닉네임 추출

        setState(() {
          newLoverNickname = newNickname; //닉네임 변경
        });
      } else {
        print('닉네임 변경 실패(api요청 실패): ${response.statusCode}');
      }
    } catch (e) {
      print('닉네임 변경 실패(네트워크 오류 등): $e');
    }
  }

///////////////상대방 닉네임 GET요청////////////////////////
  Future<void> _fetchNickname() async {
    final token = await secureStorage.read(key: 'token'); // 저장된 토큰 읽기
    print('Token: $token'); // 토큰 출력

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/getcoupleprofile'),
      headers: {
        'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
      },
    );

    if (response.statusCode == 200) {
      //한글깨짐 해결 (UTF-8로 디코딩)
      final decodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = json.decode(decodedBody);

      setState(() {
        loverNickname = data['loverNickname']; // 상대방의 닉네임 설정
      });
      // 닉네임 정보를 가져온 후 로그 출력
      print('상대방 닉네임 get 성공: $loverNickname');
    } else {
      loverNickname = '닉네임';
    }
  }

///////////////////이미지 method/////////////////
  final ImagePicker picker = ImagePicker();
  XFile? _image;

  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
      });
    }
  }

  Future<void> _saveImage() async {
    final token = await secureStorage.read(key: 'token');
    final userId = await secureStorage.read(key: 'userId');
    if (_image != null) {
      final url = Uri.parse('$apiBaseUrl/api/saveimage');
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      final file = await http.MultipartFile.fromPath('image', _image!.path);
      request.files.add(file);

      final response = await request.send();

      if (response.statusCode == 200) {
        print('이미지 저장 성공');
      } else {
        print('이미지 저장 실패');
      }
    }
  }

  Future<void> _fetchLoverImage() async {
    final token = await secureStorage.read(key: 'token'); // 저장된 토큰 읽기

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/getloverprofile'),
      headers: {
        'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
      },
    );

    if (response.statusCode == 200) {
      //한글깨짐 해결 (UTF-8로 디코딩)
      final decodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = json.decode(decodedBody);

      // 이미지 파일 설정
      final String? loverImageBase64 = data['loverImage'];

      if (loverImageBase64 != null && loverImageBase64.isNotEmpty) {
        // Base64 디코딩하여 Uint8List로 변환
        final Uint8List loverImageBytes = base64Decode(loverImageBase64);
        // 이미지 파일을 Image.memory로 설정
        loverImage = Image.memory(loverImageBytes);
      } else {
        // loverImage가 null이거나 빈 문자열인 경우 기본 이미지로 설정
        loverImage = Image.asset('assets/images/profile_default2.png');
      }
    } else {}
  }

  ////////////////////////////////////////////////////////////////////////////
  //           빌드 메서드
  ///////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isEditing) {
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() {
            isEditing = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: const Color(0xFFFFFFFF),
          title: Hero(
            tag: 'mainlogo',
            child: Image.asset(
              'assets/images/luvreed.png',
              height: 28,
              width: 270,
            ),
          ),
          leading: Hero(
            tag: 'closebtn',
            child: IconButton(
              onPressed: () async {
                if (isEditing) {
                  // 변경된 닉네임을 서버에 업데이트
                  await _fetchChangeNickname(loverNickname);

                  //프로필 화면으로 돌아감
                  Navigator.pop(context);
                } else {
                  // 변경 중이 아니라면 그냥 프로필 화면으로 돌아감
                  Navigator.pop(context);
                }
                await _saveImage(); // 이미지 저장 메서드 호출
                //avigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const MainScreen(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 105,
            ),
            _image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.file(
                      File(_image!.path),
                      width: 200,
                      height: 200,
                      fit: BoxFit.fill,
                    ),
                  )
                : loverImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: loverImage,
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset(
                          'assets/images/profile_default2.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.fill,
                        ),
                      ),
            const SizedBox(
              height: 15,
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 160),
                  child: isEditing
                      ? TextField(
                          decoration: const InputDecoration(
                            isCollapsed: true,
                            contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                          autofocus: true,
                          onChanged: (value) {
                            setState(() {
                              loverNickname = value;
                            });
                          },
                          onEditingComplete: () {
                            // 수정이 완료되면 변경된 닉네임을 서버에 업데이트
                            _fetchChangeNickname(loverNickname);
                            // 수정 모드 종료
                            setState(() {
                              isEditing = false;
                            });
                          },
                        )
                      : Text(
                          loverNickname.isNotEmpty ? loverNickname : '기존 닉네임',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                ),
                const SizedBox(
                  height: 80,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        getImage(ImageSource.gallery);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 20,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            '사진 변경하기',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isEditing = true;
                        });
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit,
                            size: 20,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            '이름 변경하기',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}