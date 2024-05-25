import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:luvreed/screens/calender_screen.dart';
import 'package:luvreed/screens/profile_screen.dart';
import 'package:luvreed/screens/setting_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:luvreed/screens/chat_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:luvreed/constants.dart'; //아이피주소
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  // const HomeScreen({super.key});
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

///////////////////////////////////////////////////////////////////////
///  Provider로 홈화면 리로드
///////////////////////////////////////////////////////////////////////
class HomeProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _chatroomId;
  String _currentEmotion = 'neutral'; // 현재 감정 상태
  String get currentEmotion => _currentEmotion;

  // 마지막 감정 상태 업데이트 메서드
  void updateLastEmotion(String emotion) {
    _currentEmotion = emotion;
    print("homescreen's Last emotion: $_currentEmotion");
    notifyListeners();
  }

  // 실시간 감정 상태 업데이트 메서드
  void updateEmotion(String emotion) {
    _currentEmotion = emotion;
    print("homescreen's emotion: $_currentEmotion");
    notifyListeners();
  }

  String userNickname = '';
  String loverNickname = '';
  Image? userImage;
  Image? loverImage;
  String dday = '';
  int petLevel = 0;
  int petExperience = 0;
  int collectionId = 0;
  String petName = ''; //펫 이름

  Future<void> fetchData() async {
    // API 데이터 가져오기 메소드 호출
    await _fetchPetInfo();
    await _fetchProfile();
    await _fetchDday();
    await _fetchChatroomId();
    notifyListeners(); // UI 새로고침
  }

  ///////////////펫 레벨, 경험치 GET요청//////////////////////////
  Future<void> _fetchPetInfo() async {
    final token = await _secureStorage.read(key: 'token'); // 저장된 토큰 읽기

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/pet'),
      headers: {
        'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      petLevel = data['collection']['level']; // 펫 레벨
      petExperience = data['experience']; // 펫 경험치
      collectionId = data['collection']['id']; // 펫 아이디

      //collectionId에 따라 펫 닉네임 결정
      if (collectionId >= 11 && collectionId <= 15) {
        petName = '호섭';
      } else if (collectionId >= 21 && collectionId <= 25) {
        petName = '폴리';
      } else if (collectionId >= 31 && collectionId <= 35) {
        petName = '분이';
      } else if (collectionId >= 41 && collectionId <= 45) {
        petName = '용용';
      } else {
        petName = 'Unknown'; // 이외의 경우에는 Unknown으로 설정할 수 있습니다.
      }

      /// 펫 정보를 가져온 후 로그 출력
      print(
          '펫 정보 가져오기 성공: 이름:$petName, 레벨:$petLevel, 경험치: $petExperience, 펫아이디: $collectionId');
    } else {
      throw Exception('펫 정보 가져오기 실패(홈화면)');
    }
  }

  ///////////////사용자&상대방 닉네임,이미지 GET요청////////////////////////
  Future<void> _fetchProfile() async {
    final token = await _secureStorage.read(key: 'token'); // 저장된 토큰 읽기

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

      loverNickname = data['loverNickname']; // 사용자의 닉네임 설정
      userNickname = data['userNickName']; // 상대방의 닉네임 설정

      // 이미지 파일 설정
      final String? userImageBase64 = data['userImage'];
      final String? loverImageBase64 = data['loverImage'];

      if (userImageBase64 != null && userImageBase64.isNotEmpty) {
        // Base64 디코딩하여 Uint8List로 변환
        final Uint8List userImageBytes = base64Decode(userImageBase64);
        // 이미지 파일을 Image.memory로 설정
        userImage = Image.memory(userImageBytes);
      } else {
        // userImage가 null이거나 빈 문자열인 경우 기본 이미지로 설정
        userImage = Image.asset('assets/images/profile_default2.png');
      }

      if (loverImageBase64 != null && loverImageBase64.isNotEmpty) {
        // Base64 디코딩하여 Uint8List로 변환
        final Uint8List loverImageBytes = base64Decode(loverImageBase64);
        // 이미지 파일을 Image.memory로 설정
        loverImage = Image.memory(loverImageBytes);
      } else {
        // loverImage가 null이거나 빈 문자열인 경우 기본 이미지로 설정
        loverImage = Image.asset('assets/images/profile_default2.png');
      }

      // 닉네임 정보를 가져온 후 로그 출력
      // print(
      //     '닉네임 get 성공: User - $userNickname, Lover - $loverNickname');
    } else {}
  }

  ////////////////// 커플 디데이 GET요청 //////////////////////////
  Future<void> _fetchDday() async {
    // final storage = FlutterSecureStorage();
    final token = await _secureStorage.read(key: 'token'); // 저장된 토큰 읽기

    print('Token: $token'); // 토큰 출력

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/dday'),
      headers: {
        'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String ddayFromAPI = data['dday']; // API에서 받아온 디데이
      final DateTime ddayDate =
          DateFormat('yyyy-MM-dd').parse(ddayFromAPI); // 디데이를 날짜로 변환

      final DateTime currentDate = DateTime.now(); // 현재 날짜

      final int daysPassed =
          currentDate.difference(ddayDate).inDays + 1; // 현재 날짜로부터 디데이까지의 일 수 +1

      dday = 'D+$daysPassed'; // 수정된 부분: 디데이 정보를 현재 날짜로부터 며칠이 지났는지 일 수로 표시

      // 디데이 정보를 가져온 후 로그 출력
      // print('디데이 get 성공: $dday');
    } else {
      throw Exception('디데이 로드 실패(홈화면)');
    }
  }

  ////////////// 채팅방 id GET //////////////////////
  Future<void> _fetchChatroomId() async {
    final chatroomId = await _secureStorage.read(key: 'chatroomId');

    _chatroomId = chatroomId;
  }

  void updateData({
    String? userNickname,
    String? loverNickname,
    String? dday,
    int? petLevel,
    int? petExperience,
    int? collectionId,
  }) {
    if (userNickname != null) this.userNickname = userNickname;
    if (loverNickname != null) this.loverNickname = loverNickname;
    if (dday != null) this.dday = dday;
    if (petLevel != null) this.petLevel = petLevel;
    if (petExperience != null) this.petExperience = petExperience;
    if (collectionId != null) this.collectionId = collectionId;
    notifyListeners(); // UI 새로고침
  }
}

//////////////////////////////////////////////////////
////                 홈스크린 CLass
////////////////////////////////////////////////////
class _HomeScreenState extends State<HomeScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String _loverNickname = ''; // 닉네임 상태를 홈 화면으로 이동

  @override
  void initState() {
    super.initState();
    Provider.of<HomeProvider>(context, listen: false).fetchData();
    // 이니셜 상태에서 닉네임 가져오기
    _fetchNickname();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 프로필 화면에서 닉네임이 변경되었을 때 닉네임 다시 가져오기
    _fetchNickname();
  }

  Future<void> _fetchNickname() async {
    // 닉네임 가져오는 비동기 작업
    final newNickname = await _secureStorage.read(key: 'nickname');
    setState(() {
      _loverNickname = newNickname ?? ''; // 새로운 닉네임으로 상태 업데이트
    });
  }

  ////////////////////////////////////////////////////////////////////////////
  //           빌드 메서드
  ///////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    //provider 확인용 로그
    // int hc = homeProvider.collectionId;
    // String he = homeProvider.currentEmotion;
    // print('collectionId(홈화면) : $hc');
    // print('_currentEmotion(홈화면) : $he');

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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CalenderScreen(),
              ),
            ),
            icon: const Icon(
              Icons.calendar_today_outlined,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingScreen(),
                ),
              ),
              icon: const Icon(
                Icons.settings,
                size: 27,
                color: Color(0xFF545454),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // FadeInImage(
                  //   placeholder: AssetImage('assets/images/jelly.png'),
                  //   image: AssetImage(
                  //     getImagePathFromCollectionId(
                  //       homeProvider.collectionId,
                  //       homeProvider.currentEmotion,
                  //     ),
                  //   ),
                  // ),
                  FadeInImage(
                    placeholder: AssetImage('assets/images/jelly.png'),
                    image: AssetImage(getImagePathFromCollectionId(
                        homeProvider.collectionId,
                        homeProvider.currentEmotion)),
                    fit: BoxFit.cover,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        '${homeProvider.petName}', // API에서 가져온 펫의 레벨
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8), // 여백 추가
                      Text(
                        'Lv.${homeProvider.petLevel}', // API에서 가져온 펫의 레벨
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'EXP ${homeProvider.petExperience}', //  API에서 가져온 펫의 경험치
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 46,
              ),
              Container(
                height: 1,
                width: 340,
                color: const Color(0xFFE8E9EA),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    homeProvider.dday, // API에서 가져온 dday 일수
                    style: const TextStyle(
                      color: Color(0xFF545454),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 2,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: FadeInImage(
                            placeholder: AssetImage(
                                'assets/images/profile_default2.png'),
                            image: homeProvider.loverImage?.image ??
                                AssetImage(
                                    'assets/images/profile_default2.png'),
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          homeProvider.userNickname, // API에서 가져온 사용자 닉네임
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 15, // 간격을 줄이기 위해 10에서 5로 변경
                  ),
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/heart.png',
                      ),
                      const SizedBox(
                        height: 23,
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 15, // 간격을 줄이기 위해 10에서 5로 변경
                  ),
                  Flexible(
                    flex: 2,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: FadeInImage(
                              placeholder:
                                  AssetImage('assets/images/jelly.png'),
                              image: homeProvider.userImage?.image ??
                                  AssetImage(
                                      'assets/images/profile_default2.png'),
                              width: 45,
                              height: 45,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          homeProvider.loverNickname, // API에서 가져온 상대방 닉네임
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
//    현재 감정상태(_currentEmotion), 펫 레벨(collectionId)에 따라 이미지 설정
///////////////////////////////////////////////////////////////
String getImagePathFromCollectionId(int collectionId, String currentEmotion) {
  switch (collectionId) {
    case 11:
      if (currentEmotion == 'happy') {
        return 'assets/images/hosub1_good.png';
      } else if (currentEmotion == 'angry' ||
          currentEmotion == 'sad' ||
          currentEmotion == 'anxious' ||
          currentEmotion == 'annoyed') {
        return 'assets/images/hosub1_bad.png';
      } else {
        return 'assets/images/hosub1.png';
      }
    case 12:
      if (currentEmotion == 'happy') {
        return 'assets/images/hosub2_good.png';
      } else if (currentEmotion == 'angry' ||
          currentEmotion == 'sad' ||
          currentEmotion == 'anxious' ||
          currentEmotion == 'annoyed') {
        return 'assets/images/hosub2_bad.png';
      } else {
        return 'assets/images/hosub2.png';
      }
    case 13:
      if (currentEmotion == 'happy') {
        return 'assets/images/hosub3_good.png';
      } else if (currentEmotion == 'angry' ||
          currentEmotion == 'sad' ||
          currentEmotion == 'anxious' ||
          currentEmotion == 'annoyed') {
        return 'assets/images/hosub3_bad.png';
      } else {
        return 'assets/images/hosub3.png';
      }
    case 14:
      if (currentEmotion == 'happy') {
        return 'assets/images/hosub4_good.png';
      } else if (currentEmotion == 'angry' ||
          currentEmotion == 'sad' ||
          currentEmotion == 'anxious' ||
          currentEmotion == 'annoyed') {
        return 'assets/images/hosub4_bad.png';
      } else {
        return 'assets/images/hosub4.png';
      }
    case 15:
      if (currentEmotion == 'happy') {
        return 'assets/images/hosub5_good.png';
      } else if (currentEmotion == 'angry' ||
          currentEmotion == 'sad' ||
          currentEmotion == 'anxious' ||
          currentEmotion == 'annoyed') {
        return 'assets/images/hosub5_bad.png';
      } else {
        return 'assets/images/hosub5.png';
      }
    case 21:
      if (currentEmotion == 'happy') {
        return 'assets/images/poly1_good.png';
      } else if (currentEmotion == 'angry' ||
          currentEmotion == 'sad' ||
          currentEmotion == 'anxious' ||
          currentEmotion == 'annoyed') {
        return 'assets/images/poly1_bad.png';
      } else {
        return 'assets/images/poly1.png';
      }
    case 22:
      if (currentEmotion == 'happy') {
        return 'assets/images/poly2_good.png';
      } else if (currentEmotion == 'angry' ||
          currentEmotion == 'sad' ||
          currentEmotion == 'anxious' ||
          currentEmotion == 'annoyed') {
        return 'assets/images/poly2_bad.png';
      } else {
        return 'assets/images/poly2.png';
      }
    case 23:
      if (currentEmotion == 'happy') {
        return 'assets/images/poly3_good.png';
      } else if (currentEmotion == 'angry' ||
          currentEmotion == 'sad' ||
          currentEmotion == 'anxious' ||
          currentEmotion == 'annoyed') {
        return 'assets/images/poly3_bad.png';
      } else {
        return 'assets/images/poly3.png';
      }
    case 24:
      if (currentEmotion == 'happy') {
        return 'assets/images/poly4_good.png';
      } else if (currentEmotion == 'angry' ||
          currentEmotion == 'sad' ||
          currentEmotion == 'anxious' ||
          currentEmotion == 'annoyed') {
        return 'assets/images/poly4_bad.png';
      } else {
        return 'assets/images/poly4.png';
      }
    case 25:
      if (currentEmotion == 'happy') {
        return 'assets/images/poly5_good.png';
      } else if (currentEmotion == 'angry' ||
          currentEmotion == 'sad' ||
          currentEmotion == 'anxious' ||
          currentEmotion == 'annoyed') {
        return 'assets/images/poly5_bad.png';
      } else {
        return 'assets/images/poly5.png';
      }
    case 31:
      if (currentEmotion == 'happy') {
        return 'assets/images/boon1_good.png';
      } else if (currentEmotion == 'angry' ||
          currentEmotion == 'sad' ||
          currentEmotion == 'anxious' ||
          currentEmotion == 'annoyed') {
        return 'assets/images/boon1_bad.png';
      } else {
        return 'assets/images/boon1.png';
      }
    case 32:
      if (currentEmotion == 'happy') {
        return 'assets/images/boon2_good.png';
      } else if (currentEmotion == 'angry' ||
          currentEmotion == 'sad' ||
          currentEmotion == 'anxious' ||
          currentEmotion == 'annoyed') {
        return 'assets/images/boon2_bad.png';
      } else {
        return 'assets/images/boon2.png';
      }
    case 33:
      if (currentEmotion == 'happy') {
        return 'assets/images/boon3_good.png';
      } else if (currentEmotion == 'angry' ||
          currentEmotion == 'sad' ||
          currentEmotion == 'anxious' ||
          currentEmotion == 'annoyed') {
        return 'assets/images/boon3_bad.png';
      } else {
        return 'assets/images/boon3.png';
      }
    case 34:
      if (currentEmotion == 'happy') {
        return 'assets/images/boon4_good.png';
      } else if (currentEmotion == 'angry' ||
          currentEmotion == 'sad' ||
          currentEmotion == 'anxious' ||
          currentEmotion == 'annoyed') {
        return 'assets/images/boon4_bad.png';
      } else {
        return 'assets/images/boon4.png';
      }
    case 35:
      if (currentEmotion == 'happy') {
        return 'assets/images/boon5_good.png';
      } else if (currentEmotion == 'angry' ||
          currentEmotion == 'sad' ||
          currentEmotion == 'anxious' ||
          currentEmotion == 'annoyed') {
        return 'assets/images/boon5_bad.png';
      } else {
        return 'assets/images/boon5.png';
      }
    case 41:
      if (currentEmotion == 'happy') {
        return 'assets/images/yong1_good.png';
      } else if (currentEmotion == 'angry' ||
          currentEmotion == 'sad' ||
          currentEmotion == 'anxious' ||
          currentEmotion == 'annoyed') {
        return 'assets/images/yong1_bad.png';
      } else {
        return 'assets/images/yong1.png';
      }
    case 42:
      if (currentEmotion == 'happy') {
        return 'assets/images/yong2_good.png';
      } else if (currentEmotion == 'angry' ||
          currentEmotion == 'sad' ||
          currentEmotion == 'anxious' ||
          currentEmotion == 'annoyed') {
        return 'assets/images/yong2_bad.png';
      } else {
        return 'assets/images/yong2.png';
      }
    case 43:
      if (currentEmotion == 'happy') {
        return 'assets/images/yong3_good.png';
      } else if (currentEmotion == 'angry' ||
          currentEmotion == 'sad' ||
          currentEmotion == 'anxious' ||
          currentEmotion == 'annoyed') {
        return 'assets/images/yong3_bad.png';
      } else {
        return 'assets/images/yong3.png';
      }
    case 44:
      if (currentEmotion == 'happy') {
        return 'assets/images/yong4_good.png';
      } else if (currentEmotion == 'angry' ||
          currentEmotion == 'sad' ||
          currentEmotion == 'anxious' ||
          currentEmotion == 'annoyed') {
        return 'assets/images/yong4_bad.png';
      } else {
        return 'assets/images/yong4.png';
      }
    case 45:
      if (currentEmotion == 'happy') {
        return 'assets/images/yong5_good.png';
      } else if (currentEmotion == 'angry' ||
          currentEmotion == 'sad' ||
          currentEmotion == 'anxious' ||
          currentEmotion == 'annoyed') {
        return 'assets/images/yong5_bad.png';
      } else {
        return 'assets/images/yong5.png';
      }
    default:
      return 'assets/images/profile_default.png'; // 기본 이미지 경로
  }
}

// String getImagePathFromCollectionId(int collectionId, String currentEmotion) {
//   switch (collectionId) {
//     case 11:
//       if (currentEmotion == 'happy') {
//         return 'assets/images/hosub1_good.png';
//       } else if (currentEmotion == 'angry' ||
//           currentEmotion == 'sad' ||
//           currentEmotion == 'anxious' ||
//           currentEmotion == 'surprised' ||
//           currentEmotion == 'annoyed') {
//         return 'assets/images/hosub1_bad.png';
//       } else {
//         return 'assets/images/hosub1.png';
//       }
//     case 12:
//       if (currentEmotion == 'happy') {
//         return 'assets/images/hosub2_good.png';
//       } else if (currentEmotion == 'angry' ||
//           currentEmotion == 'sad' ||
//           currentEmotion == 'anxious' ||
//           currentEmotion == 'surprised' ||
//           currentEmotion == 'annoyed') {
//         return 'assets/images/hosub2_bad.png';
//       } else {
//         return 'assets/images/hosub2.png';
//       }
//     case 13:
//       if (currentEmotion == 'happy') {
//         return 'assets/images/hosub3_good.png';
//       } else if (currentEmotion == 'angry' ||
//           currentEmotion == 'sad' ||
//           currentEmotion == 'anxious' ||
//           currentEmotion == 'surprised' ||
//           currentEmotion == 'annoyed') {
//         return 'assets/images/hosub3_bad.png';
//       } else {
//         return 'assets/images/hosub3.png';
//       }
//     case 14:
//       if (currentEmotion == 'happy') {
//         return 'assets/images/hosub4_good.png';
//       } else if (currentEmotion == 'angry' ||
//           currentEmotion == 'sad' ||
//           currentEmotion == 'anxious' ||
//           currentEmotion == 'surprised' ||
//           currentEmotion == 'annoyed') {
//         return 'assets/images/hosub4_bad.png';
//       } else {
//         return 'assets/images/hosub4.png';
//       }
//     case 15:
//       if (currentEmotion == 'happy') {
//         return 'assets/images/hosub5_good.png';
//       } else if (currentEmotion == 'angry' ||
//           currentEmotion == 'sad' ||
//           currentEmotion == 'anxious' ||
//           currentEmotion == 'surprised' ||
//           currentEmotion == 'annoyed') {
//         return 'assets/images/hosub5_bad.png';
//       } else {
//         return 'assets/images/hosub5.png';
//       }
//     case 21:
//       if (currentEmotion == 'happy') {
//         return 'assets/images/poly1_good.png';
//       } else if (currentEmotion == 'angry' ||
//           currentEmotion == 'sad' ||
//           currentEmotion == 'anxious' ||
//           currentEmotion == 'surprised' ||
//           currentEmotion == 'annoyed') {
//         return 'assets/images/poly1_bad.png';
//       } else {
//         return 'assets/images/poly1.png';
//       }
//     case 22:
//       if (currentEmotion == 'happy') {
//         return 'assets/images/poly2_good.png';
//       } else if (currentEmotion == 'angry' ||
//           currentEmotion == 'sad' ||
//           currentEmotion == 'anxious' ||
//           currentEmotion == 'surprised' ||
//           currentEmotion == 'annoyed') {
//         return 'assets/images/poly2_bad.png';
//       } else {
//         return 'assets/images/poly2.png';
//       }
//     case 23:
//       if (currentEmotion == 'happy') {
//         return 'assets/images/poly3_good.png';
//       } else if (currentEmotion == 'angry' ||
//           currentEmotion == 'sad' ||
//           currentEmotion == 'anxious' ||
//           currentEmotion == 'surprised' ||
//           currentEmotion == 'annoyed') {
//         return 'assets/images/poly3_bad.png';
//       } else {
//         return 'assets/images/poly3.png';
//       }
//     case 24:
//       if (currentEmotion == 'happy') {
//         return 'assets/images/poly4_good.png';
//       } else if (currentEmotion == 'angry' ||
//           currentEmotion == 'sad' ||
//           currentEmotion == 'anxious' ||
//           currentEmotion == 'surprised' ||
//           currentEmotion == 'annoyed') {
//         return 'assets/images/poly4_bad.png';
//       } else {
//         return 'assets/images/poly4.png';
//       }
//     case 25:
//       if (currentEmotion == 'happy') {
//         return 'assets/images/poly5_good.png';
//       } else if (currentEmotion == 'angry' ||
//           currentEmotion == 'sad' ||
//           currentEmotion == 'anxious' ||
//           currentEmotion == 'surprised' ||
//           currentEmotion == 'annoyed') {
//         return 'assets/images/poly5_bad.png';
//       } else {
//         return 'assets/images/poly5.png';
//       }
//     case 31:
//       if (currentEmotion == 'happy') {
//         return 'assets/images/boon1_good.png';
//       } else if (currentEmotion == 'angry' ||
//           currentEmotion == 'sad' ||
//           currentEmotion == 'anxious' ||
//           currentEmotion == 'surprised' ||
//           currentEmotion == 'annoyed') {
//         return 'assets/images/boon1_bad.png';
//       } else {
//         return 'assets/images/boon1.png';
//       }
//     case 32:
//       if (currentEmotion == 'happy') {
//         return 'assets/images/boon2_good.png';
//       } else if (currentEmotion == 'angry' ||
//           currentEmotion == 'sad' ||
//           currentEmotion == 'anxious' ||
//           currentEmotion == 'surprised' ||
//           currentEmotion == 'annoyed') {
//         return 'assets/images/boon2_bad.png';
//       } else {
//         return 'assets/images/boon2.png';
//       }
//     case 33:
//       if (currentEmotion == 'happy') {
//         return 'assets/images/boon3_good.png';
//       } else if (currentEmotion == 'angry' ||
//           currentEmotion == 'sad' ||
//           currentEmotion == 'anxious' ||
//           currentEmotion == 'surprised' ||
//           currentEmotion == 'annoyed') {
//         return 'assets/images/boon3_bad.png';
//       } else {
//         return 'assets/images/boon3.png';
//       }
//     case 34:
//       if (currentEmotion == 'happy') {
//         return 'assets/images/boon4_good.png';
//       } else if (currentEmotion == 'angry' ||
//           currentEmotion == 'sad' ||
//           currentEmotion == 'anxious' ||
//           currentEmotion == 'surprised' ||
//           currentEmotion == 'annoyed') {
//         return 'assets/images/boon4_bad.png';
//       } else {
//         return 'assets/images/boon4.png';
//       }
//     case 35:
//       if (currentEmotion == 'happy') {
//         return 'assets/images/boon5_good.png';
//       } else if (currentEmotion == 'angry' ||
//           currentEmotion == 'sad' ||
//           currentEmotion == 'anxious' ||
//           currentEmotion == 'surprised' ||
//           currentEmotion == 'annoyed') {
//         return 'assets/images/boon5_bad.png';
//       } else {
//         return 'assets/images/boon5.png';
//       }
//     case 41:
//       if (currentEmotion == 'happy') {
//         return 'assets/images/yong1_good.png';
//       } else if (currentEmotion == 'angry' ||
//           currentEmotion == 'sad' ||
//           currentEmotion == 'anxious' ||
//           currentEmotion == 'surprised' ||
//           currentEmotion == 'annoyed') {
//         return 'assets/images/yong1_bad.png';
//       } else {
//         return 'assets/images/yong1.png';
//       }
//     case 42:
//       if (currentEmotion == 'happy') {
//         return 'assets/images/yong2_good.png';
//       } else if (currentEmotion == 'angry' ||
//           currentEmotion == 'sad' ||
//           currentEmotion == 'anxious' ||
//           currentEmotion == 'surprised' ||
//           currentEmotion == 'annoyed') {
//         return 'assets/images/yong2_bad.png';
//       } else {
//         return 'assets/images/yong2.png';
//       }
//     case 43:
//       if (currentEmotion == 'happy') {
//         return 'assets/images/yong3_good.png';
//       } else if (currentEmotion == 'angry' ||
//           currentEmotion == 'sad' ||
//           currentEmotion == 'anxious' ||
//           currentEmotion == 'surprised' ||
//           currentEmotion == 'annoyed') {
//         return 'assets/images/yong3_bad.png';
//       } else {
//         return 'assets/images/yong3.png';
//       }
//     case 44:
//       if (currentEmotion == 'happy') {
//         return 'assets/images/yong4_good.png';
//       } else if (currentEmotion == 'angry' ||
//           currentEmotion == 'sad' ||
//           currentEmotion == 'anxious' ||
//           currentEmotion == 'surprised' ||
//           currentEmotion == 'annoyed') {
//         return 'assets/images/yong4_bad.png';
//       } else {
//         return 'assets/images/yong4.png';
//       }
//     case 45:
//       if (currentEmotion == 'happy') {
//         return 'assets/images/yong5_good.png';
//       } else if (currentEmotion == 'angry' ||
//           currentEmotion == 'sad' ||
//           currentEmotion == 'anxious' ||
//           currentEmotion == 'surprised' ||
//           currentEmotion == 'annoyed') {
//         return 'assets/images/yong5_bad.png';
//       } else {
//         return 'assets/images/yong5.png';
//       }
//     default:
//       return 'assets/images/profile_default.png'; // 기본 이미지 경로
//   }
// }
