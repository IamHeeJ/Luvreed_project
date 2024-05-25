import 'package:flutter/material.dart';
import 'package:luvreed/screens/calender_screen.dart';
import 'package:luvreed/screens/main_screen.dart';
import 'package:luvreed/screens/setting_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:luvreed/constants.dart'; //아이피주소

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  _CollectionScreenState createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchPetInfo(); //펫 정보 list를 get하는 메서드
    print("_fetchPetInfo() 메서드가 initState 내에서 호출되었습니다."); // 이 부분을 추가하세요
  }

  int petId = 0;
  int collectionId = 0;
  int collectionLevel = 0;
  int collectionGoalExp = 0;
  String collectionExplain = '';
  int petExperience = 0;
  bool petSelection = false;

  int petId_1 = 0;
  int petId_2 = 0;
  int petId_3 = 0;
  int petId_4 = 0;
  int collectionId_1 = 0;
  int collectionId_2 = 0;
  int collectionId_3 = 0;
  int collectionId_4 = 0;
  int collectionLevel_1 = 0;
  int collectionLevel_2 = 0;
  int collectionLevel_3 = 0;
  int collectionLevel_4 = 0;
  String collectionExplain_1 = 'explain1';
  String collectionExplain_2 = 'explain2';
  String collectionExplain_3 = 'explain3';
  String collectionExplain_4 = 'explain4';
  int selectedPetId = 0; // 선택된 펫의 ID를 저장할 변수
  String selectedPetName = ''; // 선택된 펫의 이름을 저장할 변수

  List<Map<String, dynamic>> petList = []; // 펫 정보를 저장할 리스트

  ///////////////// 펫 정보 get ///////////////////////////
  Future<void> _fetchPetInfo() async {
    final String? token = await secureStorage.read(key: 'token'); // 토큰 읽기

    final http.Response response = await http.get(
      Uri.parse('$apiBaseUrl/api/petlist'),
      headers: {
        'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
      },
    );

    if (response.statusCode == 200) {
      //한글깨짐현상 해결
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = json.decode(decodedBody);

      setState(() {
        petList.clear(); // 기존 데이터 초기화

        for (var petData in data) {
          if (petData is Map<String, dynamic>) {
            petList.add({
              'id': petData['id'], // 커플이 소유한 pet_id
              'collection':
                  petData['collection'], // 4마리 각각 정보 (id,level,goalExp,explain)
              'experience': petData['experience'], // 커플의 소유한 펫의 경험치
              'selection': petData['selection'], // 펫 선택 여부(1,0)
            });

            // 선택된 펫의 정보 저장
            if (petData['selection'] == true) {
              selectedPetId = petData['id'];
              selectedPetName = getSelectedPetName(petData['collection']['id']);
            }
          }
        }

        //펫 고유 id
        petId_1 = petList[0]['id'];
        petId_2 = petList[1]['id'];
        petId_3 = petList[2]['id'];
        petId_4 = petList[3]['id'];
        // 리스트에서 n번째 펫의 collectionID 가져오기
        collectionId_1 = petList[0]['collection']['id']; //호섭 (11~15)
        collectionId_2 = petList[1]['collection']['id']; //폴리 (21~25)
        collectionId_3 = petList[2]['collection']['id']; //분이 (31~35)
        collectionId_4 = petList[3]['collection']['id']; //용용 (41~45)
        // 레벨 (1~5)
        collectionLevel_1 = petList[0]['collection']['level'];
        collectionLevel_2 = petList[1]['collection']['level'];
        collectionLevel_3 = petList[2]['collection']['level'];
        collectionLevel_4 = petList[3]['collection']['level'];
        // 펫 소개
        collectionExplain_1 = petList[0]['collection']['explain'];
        collectionExplain_2 = petList[1]['collection']['explain'];
        collectionExplain_3 = petList[2]['collection']['explain'];
        collectionExplain_4 = petList[3]['collection']['explain'];

        print('펫 아이디 : $petId_1, $petId_2, $petId_3, $petId_4');
      });
    } else {
      throw Exception('Failed to load pet info');
    }
  }

////////////// 펫 '선택하기' PUT 요청 ////////////////////
  Future<void> _fetchPetChange(int petId) async {
    final String? token = await secureStorage.read(key: 'token'); // 토큰 읽기

    final http.Response response = await http.put(
      Uri.parse('$apiBaseUrl/api/petchange?id=$petId'),
      headers: {
        'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
      },
    );

    if (response.statusCode == 200) {
      // 성공적으로 요청이 처리되었을 때의 동작

      print('펫 변경이 성공적으로 처리되었습니다. (변경된 petId=$petId)');
    } else {
      // 요청이 실패했을 때의 동작
      print('펫 변경에 실패했습니다. 상태 코드: ${response.statusCode}');
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  //           빌드 메서드
  ///////////////////////////////////////////////////////////////////////////
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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: 175,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.25),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/jelly.png',
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    Text(
                      selectedPetName.isNotEmpty
                          ? '현재 Pet : $selectedPetName'
                          : 'Pet Collection',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 122, 117, 116),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            // const Center(
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CollectionCard(
                    petname: '호섭',
                    petimage: getImagePathFromCollectionId(collectionId_1),
                    level: '$collectionLevel_1',
                    petIntroduce: collectionExplain_1,
                    petId: petId_1, // 생성자를 통해 펫의 ID를 전달
                    onPetSelected: (petId) {
                      _fetchPetChange(petId); // 선택한 펫의 ID를 전달하여 메서드 호출
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const MainScreen(),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  CollectionCard(
                    petname: '폴리',
                    // petimage: getImagePathFromCollectionId(petList[1]['collection']['id']),
                    petimage: getImagePathFromCollectionId(collectionId_2),
                    level: '$collectionLevel_2',
                    petIntroduce: collectionExplain_2,
                    petId: petId_2, // 생성자를 통해 펫의 ID를 전달
                    onPetSelected: (petId) {
                      _fetchPetChange(petId); // 선택한 펫의 ID를 전달하여 메서드 호출
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const MainScreen(),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CollectionCard(
                    petname: '분이',
                    petimage: getImagePathFromCollectionId(collectionId_3),
                    level: '$collectionLevel_3',
                    petIntroduce: collectionExplain_3,
                    petId: petId_3, // 생성자를 통해 펫의 ID를 전달
                    onPetSelected: (petId) {
                      _fetchPetChange(petId); // 선택한 펫의 ID를 전달하여 메서드 호출
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const MainScreen(),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  CollectionCard(
                    petname: '용용',
                    petimage: getImagePathFromCollectionId(collectionId_4),
                    level: '$collectionLevel_4',
                    petIntroduce: collectionExplain_4,
                    petId: petId_4, // 생성자를 통해 펫의 ID를 전달
                    onPetSelected: (petId) {
                      _fetchPetChange(petId); // 선택한 펫의 ID를 전달하여 메서드 호출
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const MainScreen(),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////
///  콜렉션 카드
/// ///////////////////////////////////////////////////////
class CollectionCard extends StatelessWidget {
  final String petname;
  final String petimage;
  final String level;
  final String petIntroduce;
  final int petId; // 펫의 ID 추가
  final Function(int) onPetSelected;

  const CollectionCard({
    super.key,
    required this.petname,
    required this.petimage,
    required this.level,
    required this.petIntroduce,
    required this.petId, // 펫의 ID 추가
    required this.onPetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showBottomSheet(context);
      },
      child: Container(
        width: 165,
        height: 240,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 25,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                petname,
                style: const TextStyle(
                  color: Color(0xFF767676),
                  fontSize: 15,
                ),
              ),
              Hero(
                tag: 'petimg_$petname',
                child: Image.asset(
                  petimage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.white.withOpacity(0),
      backgroundColor: Colors.white,
      enableDrag: true,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          width: double.infinity,
          child: Scaffold(
            backgroundColor: const Color(0xFFFFFFFF),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Hero(
                    tag: 'petimg_$petname',
                    child: Image.asset(
                      petimage,
                      width: 280,
                    ),
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                  Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 280,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FC),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 7,
                              offset: const Offset(2, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Lv.',
                                  style: TextStyle(
                                    color: Color(0xFF767676),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  level,
                                  style: const TextStyle(
                                    color: Color(0xFF767676),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              color: const Color(0xFFF7F8FC),
                              width: 250,
                              height: 69,
                              child: Center(
                                child: Text(
                                  petIntroduce,
                                  style: const TextStyle(
                                    color: Color(0xFF767676),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // 변경하기 버튼을 누르면 펫의 ID를 이용하여 put 요청 보내기
                                    onPetSelected(petId);
                                    Navigator.pop(context); // 모달 시트 닫기
                                  },
                                  style: ElevatedButton.styleFrom(
                                    surfaceTintColor: const Color(0xFFFFFFFF),
                                    backgroundColor: const Color(0xFFFFFFFF),
                                    foregroundColor: Colors.black,
                                    minimumSize: const Size(90, 50),
                                    shadowColor: Colors.grey.withOpacity(0.3),
                                    elevation: 10,
                                  ),
                                  child: const Text(
                                    '선택하기',
                                  ),
                                ),
                                const SizedBox(
                                  width: 40,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    surfaceTintColor: const Color(0xFFFFFFFF),
                                    backgroundColor: const Color(0xFFFFFFFF),
                                    foregroundColor: Colors.black,
                                    minimumSize: const Size(100, 50),
                                    shadowColor: Colors.grey.withOpacity(0.3),
                                    elevation: 10,
                                  ),
                                  child: const Text(
                                    '닫기',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        child: Transform.translate(
                          offset: const Offset(0, -23),
                          child: Center(
                            child: Container(
                              width: 90,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F8FC),
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(100),
                                    topRight: Radius.circular(100),
                                    bottomLeft: Radius.circular(30),
                                    bottomRight: Radius.circular(30)),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 7,
                                    offset: const Offset(2, 3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        child: Transform.translate(
                          offset: const Offset(0, 2),
                          child: Center(
                            child: Container(
                              width: 120,
                              height: 39,
                              color: const Color(0xFFF7F8FC),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        child: Transform.translate(
                          offset: const Offset(0, -9),
                          child: Center(
                            child: Text(
                              petname,
                              style: const TextStyle(
                                color: Color(0xFF767676),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

String getSelectedPetName(int collectionId) {
  if (collectionId >= 11 && collectionId <= 15) {
    return '호섭';
  } else if (collectionId >= 21 && collectionId <= 25) {
    return '폴리';
  } else if (collectionId >= 31 && collectionId <= 35) {
    return '분이';
  } else if (collectionId >= 41 && collectionId <= 45) {
    return '용용';
  } else {
    return '';
  }
}

//////////////////////////////////////////////////////////////
//              펫 레벨(1~5)에 따라 이미지 설정
///////////////////////////////////////////////////////////////
String getImagePathFromCollectionId(int collectionId) {
  switch (collectionId) {
    case 11:
      return 'assets/images/hosub1.png';
    case 12:
      return 'assets/images/hosub2.png';
    case 13:
      return 'assets/images/hosub3.png';
    case 14:
      return 'assets/images/hosub4.png';
    case 15:
      return 'assets/images/hosub5.png';
    case 21:
      return 'assets/images/poly1.png';
    case 22:
      return 'assets/images/poly2.png';
    case 23:
      return 'assets/images/poly3.png';
    case 24:
      return 'assets/images/poly4.png';
    case 25:
      return 'assets/images/poly5.png';
    case 31:
      return 'assets/images/boon1.png';
    case 32:
      return 'assets/images/boon2.png';
    case 33:
      return 'assets/images/boon3.png';
    case 34:
      return 'assets/images/boon4.png';
    case 35:
      return 'assets/images/boon5.png';
    case 41:
      return 'assets/images/yong1.png';
    case 42:
      return 'assets/images/yong2.png';
    case 43:
      return 'assets/images/yong3.png';
    case 44:
      return 'assets/images/yong4.png';
    case 45:
      return 'assets/images/yong5.png';
    default:
      return 'assets/images/profile_default2.png'; // 기본 이미지 경로
  }
}

void doNothing() {}

// import 'package:flutter/material.dart';
// import 'package:luvreed/screens/calender_screen.dart';
// import 'package:luvreed/screens/setting_screen.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:luvreed/constants.dart'; //아이피주소

// class CollectionScreen extends StatefulWidget {
//   const CollectionScreen({super.key});

//   @override
//   _CollectionScreenState createState() => _CollectionScreenState();
// }

// class _CollectionScreenState extends State<CollectionScreen> {
//   final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

//   @override
//   void initState() {
//     super.initState();
//     _fetchPetInfo(); //펫 정보 list를 get하는 메서드
//     print("_fetchPetInfo() 메서드가 initState 내에서 호출되었습니다."); // 이 부분을 추가하세요
//   }

//   int petId = 0;
//   int collectionId = 0;
//   int collectionLevel = 0;
//   int collectionGoalExp = 0;
//   String collectionExplain = '';
//   int petExperience = 0;
//   bool petSelection = false;

//   int petId_1 = 0;
//   int petId_2 = 0;
//   int petId_3 = 0;
//   int petId_4 = 0;
//   int collectionId_1 = 0;
//   int collectionId_2 = 0;
//   int collectionId_3 = 0;
//   int collectionId_4 = 0;
//   int collectionLevel_1 = 0;
//   int collectionLevel_2 = 0;
//   int collectionLevel_3 = 0;
//   int collectionLevel_4 = 0;
//   String collectionExplain_1 = 'explain1';
//   String collectionExplain_2 = 'explain2';
//   String collectionExplain_3 = 'explain3';
//   String collectionExplain_4 = 'explain4';
//   // int selectedPetId = 0; // 선택한 펫의 id 전달

//   List<Map<String, dynamic>> petList = []; // 펫 정보를 저장할 리스트

//   ///////////////// 펫 정보 get ///////////////////////////
//   Future<void> _fetchPetInfo() async {
//     final String? token = await secureStorage.read(key: 'token'); // 토큰 읽기

//     final http.Response response = await http.get(
//       Uri.parse('$apiBaseUrl/api/petlist'),
//       headers: {
//         'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
//       },
//     );

//     if (response.statusCode == 200) {
//       //한글깨짐현상 해결
//       final decodedBody = utf8.decode(response.bodyBytes);
//       final List<dynamic> data = json.decode(decodedBody);

//       setState(() {
//         petList.clear(); // 기존 데이터 초기화

//         for (var petData in data) {
//           if (petData is Map<String, dynamic>) {
//             petList.add({
//               'id': petData['id'], // 커플이 소유한 pet_id
//               'collection':
//                   petData['collection'], // 4마리 각각 정보 (id,level,goalExp,explain)
//               'experience': petData['experience'], // 커플의 소유한 펫의 경험치
//               'selection': petData['selection'], // 펫 선택 여부(1,0)
//             });
//           }
//         }

//         //펫 고유 id
//         petId_1 = petList[0]['id'];
//         petId_2 = petList[1]['id'];
//         petId_3 = petList[2]['id'];
//         petId_4 = petList[3]['id'];
//         // 리스트에서 n번째 펫의 collectionID 가져오기
//         collectionId_1 = petList[0]['collection']['id']; //호섭 (11~15)
//         collectionId_2 = petList[1]['collection']['id']; //폴리 (21~25)
//         collectionId_3 = petList[2]['collection']['id']; //분이 (31~35)
//         collectionId_4 = petList[3]['collection']['id']; //용용 (41~45)
//         // 레벨 (1~5)
//         collectionLevel_1 = petList[0]['collection']['level'];
//         collectionLevel_2 = petList[1]['collection']['level'];
//         collectionLevel_3 = petList[2]['collection']['level'];
//         collectionLevel_4 = petList[3]['collection']['level'];
//         // 펫 소개
//         collectionExplain_1 = petList[0]['collection']['explain'];
//         collectionExplain_2 = petList[1]['collection']['explain'];
//         collectionExplain_3 = petList[2]['collection']['explain'];
//         collectionExplain_4 = petList[3]['collection']['explain'];

//         print('펫 아이디 : $petId_1, $petId_2, $petId_3, $petId_4');
//       });
//     } else {
//       throw Exception('Failed to load pet info');
//     }
//   }

// ////////////// 펫 '선택하기' PUT 요청 ////////////////////
//   Future<void> _fetchPetChange(int petId) async {
//     final String? token = await secureStorage.read(key: 'token'); // 토큰 읽기

//     final http.Response response = await http.put(
//       Uri.parse('$apiBaseUrl/api/petchange?id=$petId'),
//       headers: {
//         'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
//       },
//     );

//     if (response.statusCode == 200) {
//       // 성공적으로 요청이 처리되었을 때의 동작

//       print('펫 변경이 성공적으로 처리되었습니다. (변경된 petId=$petId)');
//     } else {
//       // 요청이 실패했을 때의 동작
//       print('펫 변경에 실패했습니다. 상태 코드: ${response.statusCode}');
//     }
//   }

//   //////////////////////////////////////////////////////////////
//   //              펫 레벨(1~5)에 따라 이미지 설정
//   ///////////////////////////////////////////////////////////////
//   String getImagePathFromCollectionId(int collectionId) {
//     switch (collectionId) {
//       case 11:
//         return 'assets/images/hosub1.png';
//       case 12:
//         return 'assets/images/hosub2.png';
//       case 13:
//         return 'assets/images/hosub3.png';
//       case 14:
//         return 'assets/images/hosub4.png';
//       case 15:
//         return 'assets/images/hosub5.png';
//       case 21:
//         return 'assets/images/poly1.png';
//       case 22:
//         return 'assets/images/poly2.png';
//       case 23:
//         return 'assets/images/poly3.png';
//       case 24:
//         return 'assets/images/poly4.png';
//       case 25:
//         return 'assets/images/poly5.png';
//       case 31:
//         return 'assets/images/boon1.png';
//       case 32:
//         return 'assets/images/boon2.png';
//       case 33:
//         return 'assets/images/boon3.png';
//       case 34:
//         return 'assets/images/boon4.png';
//       case 35:
//         return 'assets/images/boon5.png';
//       case 41:
//         return 'assets/images/yong1.png';
//       case 42:
//         return 'assets/images/yong2.png';
//       case 43:
//         return 'assets/images/yong3.png';
//       case 44:
//         return 'assets/images/yong4.png';
//       case 45:
//         return 'assets/images/yong5.png';
//       default:
//         return 'assets/images/profile_default2.png'; // 기본 이미지 경로
//     }
//   }

//   ////////////////////////////////////////////////////////////////////////////
//   //           빌드 메서드
//   ///////////////////////////////////////////////////////////////////////////
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
//             width: 270,
//           ),
//           leading: IconButton(
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const CalenderScreen(),
//               ),
//             ),
//             icon: const Icon(
//               Icons.calendar_today_outlined,
//             ),
//           ),
//           actions: [
//             IconButton(
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const SettingScreen(),
//                 ),
//               ),
//               icon: const Icon(
//                 Icons.settings,
//                 size: 27,
//                 color: Color(0xFF545454),
//               ),
//             ),
//           ],
//         ),
//         body: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Center(
//               child: Container(
//                 width: 175,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.25),
//                       blurRadius: 10,
//                       spreadRadius: 2,
//                       offset: const Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Image.asset(
//                       'assets/images/jelly.png',
//                     ),
//                     const SizedBox(
//                       width: 7,
//                     ),
//                     const Text(
//                       'Pet Collection',
//                       style: TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 50,
//             ),
//             // const Center(
//             Center(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CollectionCard(
//                     petname: '호섭',
//                     petimage: getImagePathFromCollectionId(collectionId_1),
//                     level: '$collectionLevel_1',
//                     petIntroduce: collectionExplain_1,
//                     petId: petId_1, // 생성자를 통해 펫의 ID를 전달
//                     onPetSelected: (petId) {
//                       _fetchPetChange(petId); // 선택한 펫의 ID를 전달하여 메서드 호출
//                     },
//                   ),
//                   const SizedBox(
//                     width: 25,
//                   ),
//                   CollectionCard(
//                     petname: '폴리',
//                     // petimage: getImagePathFromCollectionId(petList[1]['collection']['id']),
//                     petimage: getImagePathFromCollectionId(collectionId_2),
//                     level: '$collectionLevel_2',
//                     petIntroduce: collectionExplain_2,
//                     petId: petId_2, // 생성자를 통해 펫의 ID를 전달
//                     onPetSelected: (petId) {
//                       _fetchPetChange(petId); // 선택한 펫의 ID를 전달하여 메서드 호출
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(
//               height: 50,
//             ),
//             Center(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CollectionCard(
//                     petname: '분이',
//                     petimage: getImagePathFromCollectionId(collectionId_3),
//                     level: '$collectionLevel_3',
//                     petIntroduce: collectionExplain_3,
//                     petId: petId_3, // 생성자를 통해 펫의 ID를 전달
//                     onPetSelected: (petId) {
//                       _fetchPetChange(petId); // 선택한 펫의 ID를 전달하여 메서드 호출
//                     },
//                   ),
//                   const SizedBox(
//                     width: 25,
//                   ),
//                   CollectionCard(
//                     petname: '용용',
//                     petimage: getImagePathFromCollectionId(collectionId_4),
//                     level: '$collectionLevel_4',
//                     petIntroduce: collectionExplain_4,
//                     petId: petId_4, // 생성자를 통해 펫의 ID를 전달
//                     onPetSelected: (petId) {
//                       _fetchPetChange(petId); // 선택한 펫의 ID를 전달하여 메서드 호출
//                     },
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(
//               height: 30,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// //////////////////////////////////////////////////////////
// ///  콜렉션 카드
// /// ///////////////////////////////////////////////////////
// class CollectionCard extends StatelessWidget {
//   final String petname;
//   final String petimage;
//   final String level;
//   final String petIntroduce;
//   final int petId; // 펫의 ID 추가
//   final Function(int) onPetSelected;

//   const CollectionCard({
//     super.key,
//     required this.petname,
//     required this.petimage,
//     required this.level,
//     required this.petIntroduce,
//     required this.petId, // 펫의 ID 추가
//     required this.onPetSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         _showBottomSheet(context);
//       },
//       child: Container(
//         width: 165,
//         height: 240,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.25),
//               blurRadius: 10,
//               spreadRadius: 2,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(
//             vertical: 25,
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 petname,
//                 style: const TextStyle(
//                   color: Color(0xFF767676),
//                   fontSize: 12,
//                 ),
//               ),
//               Hero(
//                 tag: 'petimg_$petname',
//                 child: Image.asset(
//                   petimage,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       barrierColor: Colors.white.withOpacity(0),
//       backgroundColor: Colors.white,
//       enableDrag: true,
//       isScrollControlled: true,
//       builder: (context) {
//         return SizedBox(
//           height: MediaQuery.of(context).size.height * 0.8,
//           width: double.infinity,
//           child: Scaffold(
//             backgroundColor: const Color(0xFFFFFFFF),
//             body: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Hero(
//                     tag: 'petimg_$petname',
//                     child: Image.asset(
//                       petimage,
//                       width: 280,
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 80,
//                   ),
//                   Stack(
//                     children: [
//                       Container(
//                         width: MediaQuery.of(context).size.width,
//                         height: 280,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF7F8FC),
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(30),
//                             topRight: Radius.circular(30),
//                           ),
//                           border: Border.all(
//                             color: Colors.white,
//                             width: 2,
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.2),
//                               blurRadius: 10,
//                               spreadRadius: 7,
//                               offset: const Offset(2, 3),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Text(
//                                   'Lv.',
//                                   style: TextStyle(
//                                     color: Color(0xFF767676),
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 18,
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   width: 2,
//                                 ),
//                                 Text(
//                                   level,
//                                   style: const TextStyle(
//                                     color: Color(0xFF767676),
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 18,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Container(
//                               color: const Color(0xFFF7F8FC),
//                               width: 250,
//                               height: 69,
//                               child: Center(
//                                 child: Text(
//                                   petIntroduce,
//                                   style: const TextStyle(
//                                     color: Color(0xFF767676),
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     // 변경하기 버튼을 누르면 펫의 ID를 이용하여 put 요청 보내기
//                                     onPetSelected(petId);
//                                     Navigator.pop(context); // 모달 시트 닫기
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     surfaceTintColor: const Color(0xFFFFFFFF),
//                                     backgroundColor: const Color(0xFFFFFFFF),
//                                     foregroundColor: Colors.black,
//                                     minimumSize: const Size(90, 50),
//                                     shadowColor: Colors.grey.withOpacity(0.3),
//                                     elevation: 10,
//                                   ),
//                                   child: const Text(
//                                     '선택하기',
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   width: 40,
//                                 ),
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     Navigator.pop(context);
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     surfaceTintColor: const Color(0xFFFFFFFF),
//                                     backgroundColor: const Color(0xFFFFFFFF),
//                                     foregroundColor: Colors.black,
//                                     minimumSize: const Size(100, 50),
//                                     shadowColor: Colors.grey.withOpacity(0.3),
//                                     elevation: 10,
//                                   ),
//                                   child: const Text(
//                                     '닫기',
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       Positioned(
//                         child: Transform.translate(
//                           offset: const Offset(0, -23),
//                           child: Center(
//                             child: Container(
//                               width: 90,
//                               height: 50,
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFF7F8FC),
//                                 borderRadius: const BorderRadius.only(
//                                     topLeft: Radius.circular(100),
//                                     topRight: Radius.circular(100),
//                                     bottomLeft: Radius.circular(30),
//                                     bottomRight: Radius.circular(30)),
//                                 border: Border.all(
//                                   color: Colors.white,
//                                   width: 2,
//                                 ),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.grey.withOpacity(0.1),
//                                     blurRadius: 10,
//                                     spreadRadius: 7,
//                                     offset: const Offset(2, 3),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         child: Transform.translate(
//                           offset: const Offset(0, 2),
//                           child: Center(
//                             child: Container(
//                               width: 120,
//                               height: 39,
//                               color: const Color(0xFFF7F8FC),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         child: Transform.translate(
//                           offset: const Offset(0, -9),
//                           child: Center(
//                             child: Text(
//                               petname,
//                               style: const TextStyle(
//                                 color: Color(0xFF767676),
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 15,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// void doNothing() {}
