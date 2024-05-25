import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:luvreed/constants.dart';
import 'package:luvreed/screens/collection_screen.dart';
import 'package:luvreed/screens/home_screen.dart';
import 'package:luvreed/screens/chat_screen.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';

class StompProvider extends ChangeNotifier {
  StompClient? _stompClient;

  StompClient? get stompClient => _stompClient;

  final StreamController<ChatHistory> _chatResponseController =
      StreamController<ChatHistory>.broadcast();

  Stream<ChatHistory> get chatResponseStream => _chatResponseController.stream;

  final StreamController<ChatHistory> _imageStreamController =
      StreamController<ChatHistory>.broadcast();

  Stream<ChatHistory> get imageStream => _imageStreamController.stream;

  void setStompClient(StompClient? client) {
    _stompClient = client;
    notifyListeners();
  }

  void disconnectStomp() {
    if (_stompClient != null && _stompClient!.isActive) {
      _stompClient!.deactivate();
      _stompClient = null;
      notifyListeners();
    }
  }

  Future<void> connect(BuildContext chatScreenContext) async {
    //백엔드 하나보냄, 클라이언트 수신 로그 두개 나옴 문제 해결 전.
    print('start WebSocket connect');
    if (_stompClient != null && _stompClient!.isActive) {
      //주석
      print('WebSocket is already connected');
      return;
    }

    final secureStorage = const FlutterSecureStorage();
    final token = await secureStorage.read(key: 'token');
    final chatroomId = await secureStorage.read(key: 'chatroomId');
    final userId = await secureStorage.read(key: 'userId');

    if (chatroomId != null && token != null && userId != null) {
      final uriWithHeaders = Uri.parse('ws://$websocketBaseUrl/ws').replace(
        queryParameters: {
          'Authorization': 'Bearer $token',
        },
      ).toString();

      _stompClient = StompClient(
        config: StompConfig(
          url: uriWithHeaders,
          onWebSocketDone: () {
            print('WebSocket connection closed');
          },
          onConnect: (frame) {
            print('WebSocket connection established');

            _stompClient?.subscribe(
              destination: '/sub/chat/$chatroomId',
              callback: (frame) async {
                final message = frame.body;
                if (message != null) {
                  print("connectWebSocket message: $message");
                  print("connectWebSocket message userId: $userId");
                  var chatResponse =
                      ChatHistory.fromJson(json.decode(message), userId);

                  if (userId != null &&
                      chatResponse.userId.toString() != userId) {
                    if (chatResponse.imagePath != null) {
                      print(
                          "Received image message: ${chatResponse.imagePath}");
                      try {
                        chatResponse = await fetchImageFromUrl(
                            chatResponse.imagePath!, chatResponse);
                        print("Image loaded: ${chatResponse.imagePath}");
                      } catch (error) {
                        print("Error loading image: $error");
                      }
                    }
                    _chatResponseController.add(chatResponse);
                  } else if (userId != null &&
                      chatResponse.userId.toString() == userId) {
                    _chatResponseController.add(chatResponse);
                  }
                  print("message: $message");
                } else {
                  print('Error: message is null');
                }
              },
            );

            // connectWebSocket 콜백 내에서의 처리
            // callback:
            // (frame) async {
            //   final message = frame.body;
            //   if (message != null) {
            //     print("connectWebSocket message: $message");
            //     print("connectWebSocket message userId: $userId");
            //     var chatResponse =
            //         ChatHistory.fromJson(json.decode(message), userId);

            //     final petExperience =
            //         json.decode(message)['petExperience'] as int;
            //     if ([100, 250, 450, 700, 1000].contains(petExperience)) {
            //       // 진화 이벤트를 트리거하는 코드
            //       Provider.of<ChatScreenState>(chatScreenContext, listen: false)
            //           .showPetEvolutionDialog(
            //         petExperience,
            //         Provider.of<ChatScreenState>(chatScreenContext,
            //                 listen: false)
            //             .collectionId,
            //       );
            //     }

            //     // 나머지 처리 코드...
            //   } else {
            //     print('Error: message is null');
            //   }
            // };

            //   callback: (frame) async {
            //     final message = frame.body;
            //     if (message != null) {
            //       print("connectWebSocket message: $message");
            //       print("connectWebSocket message userId: $userId");
            //       var chatResponse =
            //           ChatHistory.fromJson(json.decode(message), userId);

            //       if (userId != null &&
            //           chatResponse.userId.toString() != userId) {
            //         // if (chatResponse.imagePath != null) {
            //         //   print(
            //         //       "Received image message: ${chatResponse.imagePath}");
            //         //   try {
            //         //     chatResponse =
            //         //         await ChatScreen.of(chatScreenContext).fetchImage(
            //         //       chatResponse.imagePath!,
            //         //       chatResponse,
            //         //     );
            //         //     print("Image loaded: ${chatResponse.imagePath}");
            //         //   } catch (error) {
            //         //     print("Error loading image: $error");
            //         //   }
            //         // } else {
            //         //   print("Received text message: ${chatResponse.text}");
            //         //   print("Received text message userId: $userId");
            //         // }
            //         print("Received text message: ${chatResponse.text}")
            //         ChatScreen.of(chatScreenContext).chatStreamController.add(chatResponse);
            //       }
            //       print("message: $message");

            //       // petExperience 값이 goal_experience 일 경우
            //       // final petExperience = int.parse(
            //       //     json.decode(message)['petExperience'].toString());
            //       // if (petExperience == 100 ||
            //       //     petExperience == 250 ||
            //       //     petExperience == 450 ||
            //       //     petExperience == 700 ||
            //       //     petExperience == 1000) {
            //       //   Provider.of<ChatScreenState>(chatScreenContext,
            //       //           listen: false)
            //       //       .showPetEvolutionDialog(
            //       //     petExperience,
            //       //     Provider.of<ChatScreenState>(chatScreenContext,
            //       //             listen: false)
            //       //         .collectionId,
            //       //   );
            //       // }
            //     } else {
            //       print('Error: message is null');
            //     }
            //   },
            // );

            _stompClient?.subscribe(
              destination: '/sub/notice',
              callback: (frame) {
                // 서버로부터 받은 메시지 처리
                print('Received message from /sub/notice: ${frame.body}');
              },
            );
          },
        ),
      );

      _stompClient!.activate();
      notifyListeners();
    }
  }
}


// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:luvreed/constants.dart';
// import 'package:luvreed/screens/collection_screen.dart';
// import 'package:luvreed/screens/home_screen.dart';
// import 'package:luvreed/screens/chat_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:stomp_dart_client/stomp.dart';
// import 'package:stomp_dart_client/stomp_config.dart';

// class StompProvider extends ChangeNotifier {
//   StompClient? _stompClient;

//   StompClient? get stompClient => _stompClient;

//   final StreamController<ChatHistory> _chatResponseController =
//       StreamController<ChatHistory>.broadcast();

//   Stream<ChatHistory> get chatResponseStream => _chatResponseController.stream;

//   final StreamController<ChatHistory> _imageStreamController =
//       StreamController<ChatHistory>.broadcast();

//   Stream<ChatHistory> get imageStream => _imageStreamController.stream;

//   HomeProvider? _homeProvider; //추

//   void setStompClient(StompClient? client) {
//     _stompClient = client;
//     notifyListeners();
//   }

//   void setHomeProvider(HomeProvider homeProvider) {
//     //추
//     _homeProvider = homeProvider;
//   }

//   void disconnectStomp() {
//     if (_stompClient != null && _stompClient!.isActive) {
//       _stompClient!.deactivate();
//       _stompClient = null;
//       notifyListeners();
//     }
//   }

//   Future<void> connect(BuildContext chatScreenContext) async {
//     //백엔드 하나보냄, 클라이언트 수신 로그 두개 나옴 문제 해결 전.
//     if (_stompClient != null && _stompClient!.isActive) {
//       print('WebSocket is already connected');
//       return;
//     }
//     final secureStorage = const FlutterSecureStorage();
//     final token = await secureStorage.read(key: 'token');
//     final chatroomId = await secureStorage.read(key: 'chatroomId');
//     final userId = await secureStorage.read(key: 'userId');

//     if (chatroomId != null && token != null && userId != null) {
//       final uriWithHeaders = Uri.parse('ws://$websocketBaseUrl/ws').replace(
//         queryParameters: {
//           'Authorization': 'Bearer $token',
//         },
//       ).toString();

//       _stompClient = StompClient(
//         config: StompConfig(
//           url: uriWithHeaders,
//           onWebSocketDone: () {
//             print('WebSocket connection closed');
//           },
//           onConnect: (frame) {
//             print('WebSocket connection established');

//             _stompClient?.subscribe(
//               destination: '/sub/chat/$chatroomId',
//               callback: (frame) async {
//                 final message = frame.body;
//                 if (message != null) {
//                   print("connectWebSocket message: $message");
//                   print("connectWebSocket message userId: $userId");
//                   var chatResponse =
//                       ChatHistory.fromJson(json.decode(message), userId);

//                   if (userId != null &&
//                       chatResponse.userId.toString() != userId) {
//                     if (chatResponse.imagePath != null) {
//                       print(
//                           "Received image message: ${chatResponse.imagePath}");
//                       try {
//                         chatResponse = await fetchImageFromUrl(
//                             chatResponse.imagePath!, chatResponse);
//                         print("Image loaded: ${chatResponse.imagePath}");
//                       } catch (error) {
//                         print("Error loading image: $error");
//                       }
//                     }
//                     _chatResponseController.add(chatResponse);
                    
//                   } else if (userId != null &&
//                       chatResponse.userId.toString() == userId) {
//                     _chatResponseController.add(chatResponse);
//                   }

//                   // if (_homeProvider != null &&
//                   //     _homeProvider!.collectionId != 0) {
//                   //   await _homeProvider!.updateEmotion(chatResponse.emotion); //비동기 호출
//                   // }

//                   print("message: $message");
//                 } else {
//                   print('Error: message is null');
//                 }
//               },
//             );
//             //   callback: (frame) async {
//             //     final message = frame.body;
//             //     if (message != null) {
//             //       print("connectWebSocket message: $message");
//             //       print("connectWebSocket message userId: $userId");
//             //       var chatResponse =
//             //           ChatHistory.fromJson(json.decode(message), userId);

//             //       if (userId != null &&
//             //           chatResponse.userId.toString() != userId) {
//             //         // if (chatResponse.imagePath != null) {
//             //         //   print(
//             //         //       "Received image message: ${chatResponse.imagePath}");
//             //         //   try {
//             //         //     chatResponse =
//             //         //         await ChatScreen.of(chatScreenContext).fetchImage(
//             //         //       chatResponse.imagePath!,
//             //         //       chatResponse,
//             //         //     );
//             //         //     print("Image loaded: ${chatResponse.imagePath}");
//             //         //   } catch (error) {
//             //         //     print("Error loading image: $error");
//             //         //   }
//             //         // } else {
//             //         //   print("Received text message: ${chatResponse.text}");
//             //         //   print("Received text message userId: $userId");
//             //         // }
//             //         print("Received text message: ${chatResponse.text}")
//             //         ChatScreen.of(chatScreenContext).chatStreamController.add(chatResponse);
//             //       }
//             //       print("message: $message");

//             //       // petExperience 값이 goal_experience 일 경우
//             //       // final petExperience = int.parse(
//             //       //     json.decode(message)['petExperience'].toString());
//             //       // if (petExperience == 100 ||
//             //       //     petExperience == 250 ||
//             //       //     petExperience == 450 ||
//             //       //     petExperience == 700 ||
//             //       //     petExperience == 1000) {
//             //       //   Provider.of<ChatScreenState>(chatScreenContext,
//             //       //           listen: false)
//             //       //       .showPetEvolutionDialog(
//             //       //     petExperience,
//             //       //     Provider.of<ChatScreenState>(chatScreenContext,
//             //       //             listen: false)
//             //       //         .collectionId,
//             //       //   );
//             //       // }
//             //     } else {
//             //       print('Error: message is null');
//             //     }
//             //   },
//             // );

//             _stompClient?.subscribe(
//               destination: '/sub/notice',
//               callback: (frame) {
//                 // 서버로부터 받은 메시지 처리
//                 print('Received message from /sub/notice: ${frame.body}');
//               },
//             );
//           },
//         ),
//       );

//       _stompClient!.activate();
//       notifyListeners();
//     }
//   }
// }
