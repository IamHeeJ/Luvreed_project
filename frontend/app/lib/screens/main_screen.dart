import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:luvreed/constants.dart';
import 'package:luvreed/screens/chart_screen.dart';
import 'package:luvreed/screens/chat_screen.dart';
import 'package:luvreed/screens/collection_screen.dart';
import 'package:luvreed/screens/home_screen.dart';
import 'package:luvreed/screens/stomp_provider.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
export 'main_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _index = 0;
  bool _hasNewMessages = false;
  final List<Widget> _pages = [
    const HomeScreen(),
    const ChatScreen(),
    const ChartScreen(),
    const CollectionScreen(),
  ];

  // items 상태 관리 변수
  List<BottomNavigationBarItem> _bottomNavItems = [];

  @override
  void initState() {
    super.initState();
    _bottomNavItems = _buildBottomNavItems();
  }

  void _handlePageChange(int index) {
    setState(() {
      _index = index;
      // 페이지를 변경할 때마다 데이터를 다시 가져옴
      print("Fetching data in HomeProvider");
      if (_index == 0) {
        Provider.of<HomeProvider>(context, listen: false).fetchData();
      }

      // 채팅 화면을 선택하면 새로운 메시지 알림 제거
      if (index == 1) {
        _hasNewMessages = false;
        updateBottomNavItems();
      }
    });
  }

  void updateBottomNavItems() {
    setState(() {
      _bottomNavItems = _buildBottomNavItems();
    });
  }

  void setNewMessageIndicator(bool hasNewMessages) {
    setState(() {
      _hasNewMessages = hasNewMessages;
      _bottomNavItems = _buildBottomNavItems();
    });
  }

  List<BottomNavigationBarItem> _buildBottomNavItems() {
    return [
      //////////////// 홈화면 아이콘 /////////////////
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined, size:35), // 아이콘 
        activeIcon: Icon(Icons.home, size:35),   // 활성화된 아이콘 
        label: 'home',
      ),

      //////////////// 채팅 아이콘 /////////////////
      BottomNavigationBarItem(
        icon: Stack(
          children: [
            const Icon(Icons.chat_outlined, size:35),
            if (_hasNewMessages)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 116, 106),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        activeIcon: const Icon(Icons.chat_rounded, size:35),
        label: 'chatting',
      ),
      //////////////// 통계 아이콘 /////////////////
      const BottomNavigationBarItem(
        icon: Icon(Icons.insert_chart_outlined_rounded, size:35),
        activeIcon: Icon(Icons.insert_chart_rounded, size:35),
        label: 'chart',
      ),
      //////////////// 도감화면 아이콘 /////////////////
      const BottomNavigationBarItem(
        icon: Icon(Icons.my_library_add_outlined, size:35),
        activeIcon: Icon(Icons.my_library_add, size:35),
        label: 'collection',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _index == 0,
      onPopInvoked: (bool didPop) {
        if (_index != 0) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const MainScreen(),
              transitionDuration: Duration.zero,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: IndexedStack(
          index: _index,
          children: _pages,
        ),
        bottomNavigationBar: _index == 1
            ? null
            : BottomNavigationBar(
                elevation: 100,
                currentIndex: _index,
                type: BottomNavigationBarType.fixed,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                selectedItemColor: const Color(0xFF545454),
                unselectedItemColor: const Color(0xFF545454),
                backgroundColor: const Color(0xFFFFFFFF),
                onTap: (value) => _handlePageChange(value),
                items: _bottomNavItems,
              ),
      ),
    );
  }
}


// class MainScreenState extends State<MainScreen> {
//   int _index = 0;
//   final List<Widget> _pages = [
//     const HomeScreen(),
//     const ChatScreen(),
//     const ChartScreen(),
//     const CollectionScreen(),
//   ];

//   // items 상태 관리 변수
//   List<BottomNavigationBarItem> _bottomNavItems = [];

//   @override
//   void initState() {
//     super.initState();
//     _bottomNavItems = _buildBottomNavItems();
//   }

//   void _handlePageChange(int index) {
//     setState(() {
//       _index = index;
//       // 페이지를 변경할 때마다 데이터를 다시 가져옴
//       print("Fetching data in HomeProvider");
//       if (_index == 0) {
//         Provider.of<HomeProvider>(context, listen: false).fetchData();
//       }
//     });
//   }
//   void updateBottomNavItems() {
//   setState(() {
//     _bottomNavItems = _buildBottomNavItems();
//   });
// }


//   List<BottomNavigationBarItem> _buildBottomNavItems() {
//     return [
//       const BottomNavigationBarItem(
//         icon: Icon(Icons.home_outlined),
//         activeIcon: Icon(Icons.home),
//         label: 'home',
//       ),
//       BottomNavigationBarItem(
//         icon: Stack(
//           children: [
//             const Icon(Icons.chat_outlined),
//             // 빨간 동그라미 표시 추가
//             Positioned(
//               top: 0,
//               right: 0,
//               child: Container(
//                 width: 10,
//                 height: 10,
//                 decoration: const BoxDecoration(
//                   color: Colors.red,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         activeIcon: const Icon(Icons.chat_rounded),
//         label: 'chatting',
//       ),
//       const BottomNavigationBarItem(
//         icon: Icon(Icons.insert_chart_outlined_rounded),
//         activeIcon: Icon(Icons.insert_chart_rounded),
//         label: 'chart',
//       ),
//       const BottomNavigationBarItem(
//         icon: Icon(Icons.my_library_add_outlined),
//         activeIcon: Icon(Icons.my_library_add),
//         label: 'collection',
//       ),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: _index == 0,
//       onPopInvoked: (bool didPop) {
//         if (_index != 0) {
//           Navigator.pushReplacement(
//             context,
//             PageRouteBuilder(
//               pageBuilder: (_, __, ___) => const MainScreen(),
//               transitionDuration: Duration.zero,
//             ),
//           );
//           //return false;
//         }
//         //return true;
//       },
//       child: Scaffold(
//         backgroundColor: const Color(0xFFFFFFFF),
//         body: IndexedStack(
//           index: _index,
//           children: _pages,
//         ),
//         bottomNavigationBar: _index == 1
//             ? null
//             : BottomNavigationBar(
//                 elevation: 100,
//                 currentIndex: _index,
//                 type: BottomNavigationBarType.fixed,
//                 showSelectedLabels: false,
//                 showUnselectedLabels: false,
//                 selectedItemColor: const Color(0xFF545454),
//                 unselectedItemColor: const Color(0xFF545454),
//                 backgroundColor: const Color(0xFFFFFFFF),
//                 onTap: (value) => _handlePageChange(value),
//                 items: _bottomNavItems, // 업데이트된 _bottomNavItems 사용
//                 // items: [
//                 //   BottomNavigationBarItem(
//                 //     icon: Icon(
//                 //       Icons.home_outlined,
//                 //       size: 35,
//                 //     ),
//                 //     label: 'home',
//                 //     activeIcon: Icon(
//                 //       Icons.home,
//                 //       size: 35,
//                 //     ),
//                 //   ),
//                 //   BottomNavigationBarItem(
//                 //     icon: Icon(
//                 //       Icons.chat_outlined,
//                 //       size: 35,
//                 //     ),
//                 //     label: 'chatting',
//                 //     activeIcon: Icon(
//                 //       Icons.chat_rounded,
//                 //       size: 35,
//                 //     ),
//                 //   ),
//                 //   BottomNavigationBarItem(
//                 //     icon: Icon(
//                 //       Icons.insert_chart_outlined_rounded,
//                 //       size: 35,
//                 //     ),
//                 //     label: 'chart',
//                 //     activeIcon: Icon(
//                 //       Icons.insert_chart_rounded,
//                 //       size: 35,
//                 //     ),
//                 //   ),
//                 //   BottomNavigationBarItem(
//                 //     icon: Icon(
//                 //       Icons.my_library_add_outlined,
//                 //       size: 35,
//                 //     ),
//                 //     label: 'collection',
//                 //     activeIcon: Icon(
//                 //       Icons.my_library_add,
//                 //       size: 35,
//                 //     ),
//                 //   ),
//                 // ],
//               ),
//       ),
//     );
//   }
// }