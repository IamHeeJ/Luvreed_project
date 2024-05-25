import 'dart:async'; //스크롤문제때문에 reverse false로 고치기 전. 코드임.
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luvreed/main.dart';
import 'package:luvreed/screens/collection_screen.dart';
import 'package:luvreed/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:luvreed/screens/main_screen.dart';
import 'package:luvreed/screens/stomp_provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:luvreed/screens/home_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:luvreed/screens/gallery.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static ChatScreenState of(BuildContext context) {
    return context.findAncestorStateOfType<ChatScreenState>()!;
  }

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  // HomeProvider 인스턴스 생성
  final HomeProvider _homeProvider = HomeProvider();
  final StompProvider _stompProvider = StompProvider();

  String? _userId;
  List<ChatHistory> _chatHistory = [];
  String? _lastMessageId;
  final int _pageSize = 20;
  bool _isLoading = false;
  final bool _isConnected = false;
  String? _chatroomId;
  StompClient? newStompClient;
  String _currentEmotion = 'neutral';
  final secureStorage = const FlutterSecureStorage();
  int collectionId = 0;
  String? loverNickname = '';
  Image? loverImage;
  Image? broadcastingImage;
  final ImagePicker picker = ImagePicker();
  XFile? _image;
  ChatHistory? _streamChatResponse;
  late StreamSubscription? _subscription;

  late ScrollController _scrollController = ScrollController();

  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final StreamController<ChatHistory> chatStreamController =
      StreamController<ChatHistory>.broadcast();

  // @override
  // void initState() {
  //   super.initState();
  //   fetchChatHistory(scrollToBottom: true); //scrollToBottom: true
  //   _fetchPetInfo();
  //   _fetchLoverNickname();
  //   _fetchLoverImage();

  //   final stompProvider = Provider.of<StompProvider>(context, listen: false);

  //   if (stompProvider.stompClient == null ||
  //       !stompProvider.stompClient!.isActive) {
  //     stompProvider.connect(context);
  //   }

  //   _subscription = stompProvider.chatResponseStream.listen((chatResponse) {
  //     updateEmotionAndImage(chatResponse);
  //     handleChatMessage(chatResponse);
  //   });

  //   _scrollController = ScrollController(initialScrollOffset: 0.0);
  //   _scrollController.addListener(() {
  //     if (_scrollController.position.pixels ==
  //         _scrollController.position.maxScrollExtent) {
  //       // fetchChatHistory();
  //       loadMoreChatHistory(); // 새로운 메서드 호출
  //     }
  //   });
  // }
  @override
  void initState() {
    super.initState();
    fetchChatHistory(scrollToBottom: true); // 처음에는 스크롤을 하단으로 이동
    _fetchPetInfo();
    _fetchLoverNickname();
    _fetchLoverImage();

    final stompProvider = Provider.of<StompProvider>(context, listen: false);

    if (stompProvider.stompClient == null ||
        !stompProvider.stompClient!.isActive) {
      stompProvider.connect(context);
    }

    _subscription = stompProvider.chatResponseStream.listen((chatResponse) {
      updateEmotionAndImage(chatResponse);
      handleChatMessage(chatResponse);
    });
  }

  @override
  void dispose() {
    chatStreamController.close();
    _subscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // 메시지를 받고 진화 이벤트를 처리하는 메서드
  void handleChatMessage(ChatHistory chatResponse) {
    final petExperience = chatResponse.petExperience;

    // 펫 경험치가 특정 값에 도달하면 진화 이벤트 처리
    if (petExperience == 100 && chatResponse.emotion == 'happy' ||
        petExperience == 250 && chatResponse.emotion == 'happy' ||
        petExperience == 450 && chatResponse.emotion == 'happy' ||
        petExperience == 700 && chatResponse.emotion == 'happy' ||
        petExperience == 1000 && chatResponse.emotion == 'happy') {
      showPetEvolutionDialog(petExperience, chatResponse.collectionId);
    }
  }

  void updateEmotionAndImage(ChatHistory chatResponse) {
    setState(() {
      _currentEmotion = chatResponse.emotion;
    });
    print("채팅화면 emotion (HomeProvider 업데이트 전): $_currentEmotion");
    Provider.of<HomeProvider>(context, listen: false)
        .updateEmotion(_currentEmotion);
    print("채팅화면 emotion (HomeProvider 업데이트 후): $_currentEmotion");
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Provider.of<HomeProvider>(context, listen: false).updateEmotion(_currentEmotion);
  }

  void handleImageReceived(ChatHistory chatResponse) {
    fetchImageFromUrl(chatResponse.imagePath!, chatResponse)
        .then((updatedChatResponse) {
      setState(() {
        _chatHistory.add(updatedChatResponse);
      });
    }).catchError((error) {
      print('Error loading image: $error');
    });
  }

  // 새로운 채팅 메시지를 처리하는 메서드
  // void _handleReceivedMessage(ChatHistory chatResponse) {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     setState(() {
  //       _chatHistory.add(chatResponse);
  //       chatResponse.processed = true;

  //       _currentEmotion = chatResponse.emotion;

  //       // 이미지 업데이트
  //       if (chatResponse.imagePath != null) {
  //         handleImageReceived(chatResponse);
  //       }
  //     });

  //     _scrollToBottom();
  //   });
  // }

  void _handleReceivedMessage(ChatHistory chatResponse) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        _chatHistory.insert(0, chatResponse);
        chatResponse.processed = true;

        if (chatResponse.emotion != null) {
          _currentEmotion = chatResponse.emotion!;
        }
      });
      _updateMainScreenState(true);
    });
  }

  void _updateMainScreenState(bool hasNewMessages) {
    final mainScreenState = context.findAncestorStateOfType<MainScreenState>();
    if (mainScreenState != null) {
      mainScreenState.setNewMessageIndicator(hasNewMessages);
    }
  }

  void showPetEvolutionDialog(int petExperience, int collectionId) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        petExperience: petExperience,
        collectionId: collectionId,
        onCollectionButtonPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CollectionScreen(),
            ),
          );
        },
        onCloseButtonPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

////////////상대방 닉네임 get요청 //////////////////
  Future<String?> _fetchLoverNickname() async {
    final token = await secureStorage.read(key: 'token');
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/getcoupleprofile'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = json.decode(decodedBody);

      loverNickname = data['loverNickname'];

      if (loverNickname != null) {
        print('상대방 닉네임(채팅화면) : $loverNickname');
        return loverNickname;
      } else {
        throw Exception('상대방의 닉네임이 없습니다.');
      }
    } else {
      return null;
    }
  }

  ////////////상대방 이미지 get요청 //////////////////
  Future<void> _fetchLoverImage() async {
    final token = await secureStorage.read(key: 'token');

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/getloverprofile'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = json.decode(decodedBody);

      final String? loverImageBase64 = data['loverImage'];

      if (loverImageBase64 != null && loverImageBase64.isNotEmpty) {
        final Uint8List loverImageBytes = base64Decode(loverImageBase64);
        setState(() {
          loverImage = Image.memory(loverImageBytes); // 수정
        });
      } else {
        setState(() {
          loverImage = null; // 수정
        });
      }
    } else {}
  }

  // Future getImageByImagePicker(ImageSource? imageSource) async {
  //   if (imageSource != null) {
  //     final XFile? pickedFile = await picker.pickImage(source: imageSource);
  //     if (pickedFile != null) {
  //       setState(() {
  //         _image = XFile(pickedFile.path);
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       _image = null;
  //     });
  //   }
  // }
  Future getImageByImagePicker(ImageSource? imageSource) async {
    if (imageSource != null) {
      final XFile? pickedFile = await picker.pickImage(source: imageSource);
      if (pickedFile != null) {
        _showImageSendDialog(pickedFile);
      }
    }
  }

  void _showImageSendDialog(XFile image) {
    showDialog(
      context: context,
      barrierDismissible: false, // 화면 탭하여 대화상자 닫기 방지
      builder: (context) {
        return Center(
          // AlertDialog를 Center 위젯으로 감싸기
          child: AlertDialog(
            // title: const Text('이미지 전송'),
            // title: Center(
            //   child: const Text('이미지 전송'),
            // ),
            title: Center(
              child: Text(
                '이미지 전송',
                style: TextStyle(
                  fontSize: 18.0, // 원하는 글자 크기로 변경
                  fontWeight: FontWeight.bold, // 굵게 하려면 추가
                ),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.file(
                  File(image.path),
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                const Text('이미지를 전송하시겠습니까?'),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Color.fromARGB(255, 202, 202, 202),
                      side: const BorderSide(
                          color: Color.fromARGB(255, 202, 202, 202)),
                      minimumSize: const Size(70, 40),
                    ),
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _image = image;
                      });
                      Navigator.pop(context);
                      onFieldSubmitted();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      minimumSize: const Size(70, 40),
                    ),
                    child: const Text('전송'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void clearImage() {
    setState(() {
      _image = null;
    });
  }

  ///////////////펫 collectionID GET요청//////////////////////////
  Future<void> _fetchPetInfo() async {
    final token = await secureStorage.read(key: 'token'); // 저장된 토큰 읽기

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/pet'),
      headers: {
        'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      collectionId = data['collection']['id']; // 펫 아이디

      /// 펫 정보를 가져온 후 로그 출력
      print('펫 Collection ID  가져오기 성공(채팅화면): - $collectionId');
    } else {
      throw Exception('펫 정보 로드 실패(채팅화면)');
    }
  }

  Future<void> onFieldSubmitted() async {
    try {
      if (_textEditingController.text.isEmpty && (_image == null)) {
        return;
      }

      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'token');
      _userId = await storage.read(key: 'userId');
      final chatroomId = await storage.read(key: 'chatroomId');

      String? imageUrl;
      //List<int>? imageBytes;
      if (_image != null) {
        // 이미지가 선택된 경우 서버로 업로드
        final url = Uri.parse('$apiBaseUrl/api/savechatimage');
        final request = http.MultipartRequest('POST', url);
        request.headers['Authorization'] = 'Bearer $token';
        final file = await http.MultipartFile.fromPath('image', _image!.path);
        request.files.add(file);

        final response = await request.send();

        if (response.statusCode == 200) {
          // 이미지 업로드 성공
          final responseData = await response.stream.bytesToString();
          final decodedData = json.decode(responseData);
          print(decodedData); //response 출력
          imageUrl = decodedData['imagePath'];
          //imageBytes = await _image!.readAsBytes();
        } else {
          // 이미지 업로드 실패
        }
      }

      final message = {
        'text': _textEditingController.text.isEmpty
            ? null
            : _textEditingController.text,
        'imageUrl': imageUrl,
      };

      StompClient? stompClientToUse;
      final stompProvider = Provider.of<StompProvider>(context, listen: false);
      final existingStompClient = stompProvider.stompClient;
      if (existingStompClient != null && existingStompClient.isActive) {
        stompClientToUse = existingStompClient;
        print('existingStompClient send message');
      } else if (newStompClient != null && newStompClient!.isActive) {
        stompClientToUse = newStompClient;
        print('newStompClient send message');
      }

      if (stompClientToUse != null) {
        stompClientToUse.send(
          destination: '/pub/chat/$chatroomId',
          body: json.encode(message),
          headers: {'Authorization': 'Bearer $token'},
        );
      } else {
        print('No active StompClient available');
      }

      final sentMessage = ChatHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: int.parse(_userId!),
        coupleId: 0,
        chatroomId: int.parse(chatroomId!),
        text: _textEditingController.text.isEmpty
            ? ''
            : _textEditingController.text,
        emotion: message['emotion'] ?? '',
        checked: '1',
        imagePath: imageUrl,
        imageBytes: null,
        broadcastingImage:
            _image != null ? Image.file(File(_image!.path)) : null,
        createdAt: DateTime.now(),
        sentByMe: true,
        processed: true,
        petExperience: 0, // 펫 경험치 값 설정
        collectionId: 0, // 펫의 컬렉션 ID 설정
      );

      setState(() {
        _chatHistory.insert(0, sentMessage);
        if (imageUrl != null) {
          precacheImage(NetworkImage(imageUrl), context);
        }
        _textEditingController.text = '';
        _image = null;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  // Future<void> fetchChatHistory({bool scrollToBottom = false}) async {
  //   if (_isLoading) return;

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   const storage = FlutterSecureStorage();
  //   final token = await storage.read(key: 'token');
  //   final chatroomId = await storage.read(key: 'chatroomId');
  //   final userId = await storage.read(key: 'userId');

  //   print("chatroomId is $chatroomId");

  //   final response = await http.get(
  //     Uri.parse(
  //         '$apiBaseUrl/api/chat/$chatroomId/history?page=${_chatHistory.length ~/ _pageSize}&size=$_pageSize'),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );

  //   if (response.statusCode == 200) {
  //     final decodedBody = utf8.decode(response.bodyBytes);
  //     final fetchedChatHistory = (json.decode(decodedBody) as List)
  //         .map((item) => ChatHistory.fromJson(item, userId))
  //         .toList();

  //     setState(() {
  //       _chatHistory.addAll(fetchedChatHistory);
  //       if (_chatHistory.isNotEmpty) {
  //         _lastMessageId = _chatHistory.first.id;
  //         _currentEmotion = _chatHistory.first.emotion;

  //         // 이미지 처리
  //         for (var chatItem in fetchedChatHistory) {
  //           if (chatItem.imagePath != null) {
  //             fetchImageFromUrl(chatItem.imagePath!, chatItem)
  //                 .then((updatedChatItem) {
  //               setState(() {
  //                 chatItem.broadcastingImage =
  //                     updatedChatItem.broadcastingImage;
  //               });
  //             });
  //           }
  //         }
  //       }
  //       _isLoading = false;
  //     });

  //     // 새로운 채팅 내역을 불러올 때만 스크롤 위치 조정
  //     _scrollToPosition(scrollToBottom);
  //   }
  // }

  // void _scrollToPosition(bool scrollToBottom) {
  //   WidgetsBinding.instance!.addPostFrameCallback((_) {
  //     print("scrollToBottom: $scrollToBottom");
  //     if (_scrollController.hasClients) {
  //       print("_scrollController.hasClients: ${_scrollController.hasClients}");
  //       if (scrollToBottom) {
  //         // 첫 번째 채팅 내역을 받아올 때만 스크롤을 하단으로 조정
  //         print("scrollToBottom: $scrollToBottom, if문 실행");
  //         _scrollController.animateTo(
  //           _scrollController.position.minScrollExtent,
  //           duration: const Duration(milliseconds: 300),
  //           curve: Curves.easeOut,
  //         );
  //       } else {
  //         // 추가 채팅 내역을 받아올 때는 현재 스크롤 위치 유지
  //         print("scrollToBottom: $scrollToBottom, else문 실행");
  //         _scrollController.animateTo(
  //           _scrollController.position.pixels,
  //           duration: const Duration(milliseconds: 300),
  //           curve: Curves.easeOut,
  //         );
  //       }
  //     }
  //   });
  // }
  Future<void> fetchChatHistory({bool scrollToBottom = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    final chatroomId = await storage.read(key: 'chatroomId');
    final userId = await storage.read(key: 'userId');

    print("chatroomId is $chatroomId");

    final response = await http.get(
      Uri.parse(
          '$apiBaseUrl/api/chat/$chatroomId/history?page=${_chatHistory.length ~/ _pageSize}&size=$_pageSize'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final fetchedChatHistory = (json.decode(decodedBody) as List)
          .map((item) => ChatHistory.fromJson(item, userId))
          .toList();

      setState(() {
        _chatHistory.addAll(fetchedChatHistory);
        if (_chatHistory.isNotEmpty) {
          _lastMessageId = _chatHistory.first.id;
          _currentEmotion = _chatHistory.first.emotion;
        }
        _isLoading = false;
      });

      // 이미지 처리
      for (var chatItem in fetchedChatHistory) {
        if (chatItem.imagePath != null) {
          await fetchImageFromUrl(chatItem.imagePath!, chatItem)
              .then((updatedChatItem) {
            setState(() {
              chatItem.broadcastingImage = updatedChatItem.broadcastingImage;
            });
          });
        }
      }

      // 스크롤 컨트롤러 초기화 및 리스너 추가
      _scrollController = ScrollController(initialScrollOffset: 0.0);
      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          loadMoreChatHistory();
        }
      });

      // 새로운 채팅 내역을 불러올 때만 스크롤 위치 조정
      _scrollToPosition(scrollToBottom);
    }
  }

//채팅내역 로드해서 수정하는거
// Future<void> loadMoreChatHistory() async {
//   if (_isLoading) return;

//   setState(() {
//     _isLoading = true;
//   });

//   const storage = FlutterSecureStorage();
//   final token = await storage.read(key: 'token');
//   final chatroomId = await storage.read(key: 'chatroomId');
//   final userId = await storage.read(key: 'userId');

//   print("(loadmoreHistory)chatroomId is $chatroomId");

//   final response = await http.get(
//     Uri.parse(
//         '$apiBaseUrl/api/chat/$chatroomId/history?page=${_chatHistory.length ~/ _pageSize}&size=$_pageSize'),
//     headers: {'Authorization': 'Bearer $token'},
//   );

//   if (response.statusCode == 200) {
//     final decodedBody = utf8.decode(response.bodyBytes);
//     final fetchedChatHistory = (json.decode(decodedBody) as List)
//         .map((item) => ChatHistory.fromJson(item, userId))
//         .toList();

//     setState(() {
//       _chatHistory.addAll(fetchedChatHistory);
//       if (_chatHistory.isNotEmpty) {
//         _lastMessageId = _chatHistory.first.id;
//         _currentEmotion = _chatHistory.first.emotion;
//       }
//       _isLoading = false;
//     });

//     // 이미지 처리
//     for (var chatItem in fetchedChatHistory) {
//       if (chatItem.imagePath != null) {
//         await fetchImageFromUrl(chatItem.imagePath!, chatItem).then((updatedChatItem) {
//           setState(() {
//             chatItem.broadcastingImage = updatedChatItem.broadcastingImage;
//           });
//         });
//       }
//     }
//   }
// }
  Future<void> loadMoreChatHistory() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    final chatroomId = await storage.read(key: 'chatroomId');
    final userId = await storage.read(key: 'userId');

    print("(loadmoreHistory)chatroomId is $chatroomId");

    final response = await http.get(
      Uri.parse(
          '$apiBaseUrl/api/chat/$chatroomId/history?page=${_chatHistory.length ~/ _pageSize}&size=$_pageSize&lastMessageId=$_lastMessageId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final fetchedChatHistory = (json.decode(decodedBody) as List)
          .map((item) => ChatHistory.fromJson(item, userId))
          .toList()
          .reversed
          .toList(); // 가장 최신 채팅이 마지막에 오도록 역순으로 정렬

      setState(() {
        _chatHistory.addAll(fetchedChatHistory);
        if (_chatHistory.isNotEmpty) {
          _lastMessageId = _chatHistory.last.id; // 가장 최신 채팅의 ID를 저장
          _currentEmotion = _chatHistory.last.emotion;
        }
        _isLoading = false;
      });

      // 이미지 처리
      for (var chatItem in fetchedChatHistory) {
        if (chatItem.imagePath != null) {
          await fetchImageFromUrl(chatItem.imagePath!, chatItem)
              .then((updatedChatItem) {
            setState(() {
              chatItem.broadcastingImage = updatedChatItem.broadcastingImage;
            });
          });
        }
      }
    }
  }

  void _scrollToPosition(bool scrollToBottom) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      print("scrollToBottom: $scrollToBottom");
      if (_scrollController.hasClients) {
        print("_scrollController.hasClients: ${_scrollController.hasClients}");
        if (scrollToBottom) {
          // 첫 번째 채팅 내역을 받아올 때만 스크롤을 하단으로 조정
          print("scrollToBottom: $scrollToBottom, if문 실행");
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          // 추가 채팅 내역을 받아올 때는 현재 스크롤 위치 유지
          print("scrollToBottom: $scrollToBottom, else문 실행");
          // Do nothing, keep the current scroll position
        }
      }
    });
  }

  void onFieldChanged(String value) {
    //setState(() {});
  }

  bool _isChecked = true; //지연슈정

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    return MaterialApp(
        home: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: AppBar(
                shape: const Border(
                  bottom: BorderSide(
                    color: Color(0xFFECECEC),
                    width: 0.8,
                  ),
                ),
                centerTitle: true,
                backgroundColor: const Color(0xFFFFFFFF),
                title: Transform.translate(
                  offset: const Offset(27, 0),
                  child: Image.asset(
                    'assets/images/luvreed.png',
                    height: 28,
                    width: 270,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const MainScreen(),
                        transitionDuration: Duration.zero,
                      ),
                    );
                  },
                ),
                actions: [
                  Transform.scale(
                    scale: .85,
                    child: CupertinoSwitch(
                      value: _isChecked,
                      activeColor: CupertinoColors.activeGreen,
                      onChanged: (bool? value) {
                        setState(() {
                          _isChecked = value ?? false;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Gallery()),
                    ),
                    icon: Image.asset(
                      'assets/images/gallery.png',
                      height: 30,
                      width: 30,
                    ),
                  ),
                ],
              ),
            ),
            body: Stack(children: [
              Column(children: [
                Expanded(
                  child: Stack(
                    children: [
                      if (_isChecked)
                        Container(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height,
                            minWidth: MediaQuery.of(context).size.width,
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                // getImagePathFromCollectionId(
                                //     collectionId, _currentEmotion),
                                getImagePathFromCollectionId(
                                  homeProvider.collectionId,
                                  homeProvider.currentEmotion,
                                ),
                              ),
                              fit: BoxFit.none,
                            ),
                          ),
                        ),
                      Column(
                        children: [
                          Expanded(
                            child: _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : GestureDetector(
                                    onTap: () {
                                      _focusNode.unfocus();
                                    },
                                    child: StreamBuilder<ChatHistory?>(
                                      stream:
                                          Provider.of<StompProvider>(context)
                                              .chatResponseStream,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData &&
                                            snapshot.data != null &&
                                            !snapshot.data!.processed) {
                                          final chatResponse = snapshot.data!;
                                          if (chatResponse.userId.toString() !=
                                              _userId) {
                                            _handleReceivedMessage(
                                                chatResponse);
                                          }
                                        }
                                        return _buildChatHistory();
                                      },
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      StreamBuilder<ChatHistory>(
                        stream: Provider.of<StompProvider>(context).imageStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final chatResponse = snapshot.data!;
                            handleImageReceived(chatResponse);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: _BottomInputField(
                          focusNode: _focusNode,
                          onFieldChanged: onFieldChanged,
                          textEditingController: _textEditingController,
                          onFieldSubmitted: onFieldSubmitted,
                          isTextFieldEnable:
                              _textEditingController.text.isNotEmpty ||
                                  (_image != null && _image!.path.isNotEmpty),
                          clearImage: clearImage,
                          image: _image,
                          getImageByImagePicker: getImageByImagePicker,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ])));
  }

  // Widget _buildChatHistory() { //전체채팅 불러오기
  //   return ListView.builder(
  //     //shrinkWrap: true,
  //     reverse: true,
  //     // padding: const EdgeInsets.only(top: 12, bottom: 80) +
  //     //     const EdgeInsets.symmetric(horizontal: 12),
  //     padding: const EdgeInsets.only(top: 12, bottom: 80),

  //     // controller: ScrollController(
  //     //   initialScrollOffset: _chatHistory.isNotEmpty
  //     //       ? _chatHistory.length * 100.0 // 메시지 길이에 따라 스크롤 오프셋 조정
  //     //       : 0.0, // 메시지가 없으면 오프셋 0
  //     //   keepScrollOffset: true, // 스크롤 위치 유지
  //     // ),
  //     controller: _scrollController,

  //     itemCount: _chatHistory.length,
  //     itemBuilder: (context, index) {
  //       final chat = _chatHistory[index];
  //       return Bubble(
  //         chat: chat,
  //         loverNickname: loverNickname,
  //         loverImage: loverImage,
  //       );
  //     },
  //   );
  // }
  // Widget _buildChatHistory() {
  //   return NotificationListener<ScrollNotification>(
  //     onNotification: (ScrollNotification scrollInfo) {
  //       if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
  //         fetchChatHistory();
  //       }
  //       return true;
  //     },
  //     child: ListView.builder(
  //       reverse: true,
  //       padding: const EdgeInsets.only(top: 12, bottom: 80),
  //       controller: _scrollController,
  //       itemCount: _chatHistory.length,
  //       itemBuilder: (context, index) {
  //         final chat = _chatHistory[index];
  //         return Bubble(
  //           chat: chat,
  //           loverNickname: loverNickname,
  //           loverImage: loverImage,
  //         );
  //       },
  //     ),
  //   );
  // }
  Widget _buildChatHistory() {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.only(top: 12, bottom: 80),
      controller: _scrollController,
      itemCount: _chatHistory.length,
      itemBuilder: (context, index) {
        final chat = _chatHistory[index];
        return Bubble(
          chat: chat,
          loverNickname: loverNickname,
          loverImage: loverImage,
        );
      },
    );
  }

  Widget _buildGroupedChatHistory() {
    final groupedChatHistory = <String, List<ChatHistory>>{};
    for (final chat in _chatHistory.reversed) {
      final date = DateFormat('yyyy-MM-dd').format(chat.createdAt);
      if (groupedChatHistory.containsKey(date)) {
        groupedChatHistory[date]!.insert(0, chat);
      } else {
        groupedChatHistory[date] = [chat];
      }
    }

    return ListView.builder(
      shrinkWrap: true,
      reverse: true,
      padding: const EdgeInsets.only(top: 12, bottom: 20) +
          const EdgeInsets.symmetric(horizontal: 12),
      controller: _scrollController,
      itemCount: groupedChatHistory.length,
      itemBuilder: (context, index) {
        final date = groupedChatHistory.keys.elementAt(index);
        final chats = groupedChatHistory[date]!;

        return Column(
          children: [
            const SizedBox(height: 16), // 날짜 위 간격 조정
            Align(
              alignment: Alignment.center, // 가운데 정렬
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF828282),
                ),
              ),
            ),
            const SizedBox(height: 16), // 날짜 아래 간격 조정
            ...chats.map((chat) => Bubble(
                  chat: chat,
                  loverNickname: loverNickname,
                  loverImage: loverImage,
                )),
            if (index == 0) const SizedBox(height: 70),
          ],
        );
      },
    );
  }
}

/////////////////////////////////////////////////////////////
/// 하단 채팅 입력창
/////////////////////////////////////////////////////////////
class _BottomInputField extends StatelessWidget {
  final FocusNode focusNode;
  final Function(String) onFieldChanged;
  final TextEditingController textEditingController;
  final Function() onFieldSubmitted;
  final bool isTextFieldEnable;
  final XFile? image;
  final VoidCallback clearImage;
  final Future Function(ImageSource imageSource) getImageByImagePicker;

  const _BottomInputField({
    super.key,
    required this.focusNode,
    required this.onFieldChanged,
    required this.textEditingController,
    required this.onFieldSubmitted,
    required this.isTextFieldEnable,
    required this.image,
    required this.clearImage,
    required this.getImageByImagePicker,
  });

  Future<Uint8List?> _loadImageBytes(XFile? image) async {
    if (image != null) {
      return await image.readAsBytes();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: GestureDetector(
                onTap: () {
                  getImageByImagePicker(ImageSource.gallery);
                },
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.25),
                        blurRadius: 13,
                        spreadRadius: 3,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/sendpic.png',
                      width: 45,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 48,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.25),
                        blurRadius: 13,
                        spreadRadius: 3,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      TextField(
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(255, 96, 96, 96),
                        ),
                        focusNode: focusNode,
                        onChanged: onFieldChanged,
                        controller: textEditingController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(
                            right: 42,
                            left: 16,
                            top: 18,
                            bottom: 16,
                          ),
                          hintText: '메시지를 입력하세요.',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onSubmitted: (_) => onFieldSubmitted(),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => (textEditingController.text.isNotEmpty)
                              ? onFieldSubmitted()
                              : null,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.asset(
                              'assets/images/send.png',
                              width: 45,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//                         ),
//                       if (image != null)
//                         Positioned.fill(
//                           child: FutureBuilder<Uint8List?>(
//                             future: _loadImageBytes(image),
//                             builder: (context, snapshot) {
//                               if (snapshot.hasData &&
//                                   snapshot.data!.isNotEmpty) {
//                                 return Image.memory(
//                                   snapshot.data!,
//                                   fit: BoxFit.contain,
//                                 );
//                               } else if (snapshot.hasError)
//                                 return const Center(child: Text('이미지 로드 실패'));
//                               else
//                                 return const Center(
//                                     child: CircularProgressIndicator());
//                             },
//                           ),
//                         ),
//                       Positioned(
//                         bottom: 2,
//                         right: 0,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             if (image != null)
//                               GestureDetector(
//                                 onTap: clearImage,
//                                 child: Container(
//                                   padding: const EdgeInsets.all(4),
//                                   decoration: const BoxDecoration(
//                                     color: Colors.black54,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(
//                                     Icons.close,
//                                     color: Colors.white,
//                                     size: 20,
//                                   ),
//                                 ),
//                               ),
//                             const SizedBox(width: 8),
//                             GestureDetector(
//                               onTap: () => (textEditingController
//                                           .text.isNotEmpty ||
//                                       (image != null && image!.path.isNotEmpty))
//                                   ? onFieldSubmitted()
//                                   : null,
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(25),
//                                 child: Image.asset(
//                                   'assets/images/send.png',
//                                   width: 45,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

/////////////////////////////////////////////////////////////
/// 말풍선
/////////////////////////////////////////////////////////////
class Bubble extends StatelessWidget {
  final ChatHistory chat;
  final String? loverNickname;
  final Image? loverImage;

  const Bubble({
    super.key,
    required this.chat,
    this.loverNickname,
    this.loverImage,
  });

  // const Bubble({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!chat.sentByMe)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: loverImage != null
                      ? loverImage!.image
                      : const AssetImage('assets/images/profile_default2.png'),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: chat.sentByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!chat.sentByMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        loverNickname ??
                            '상대방', // loverNickname이 null이면 '상대방'으로 표시
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF828282),
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: chat.sentByMe
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (chat.sentByMe)
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            DateFormat('a hh:mm').format(chat.createdAt),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF828282),
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 270,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: chat.sentByMe
                              ? const Color(0xFFFFE5D8)
                              : const Color(0xFFE5E5EA),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: chat.imagePath != null
                            ? chat.broadcastingImage ?? const SizedBox.shrink()
                            : chat.text.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    child: Text(
                                      chat.text,
                                      style: const TextStyle(
                                        color: Color(0xFF505050),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                      ),
                      if (!chat.sentByMe)
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            DateFormat('a hh:mm').format(chat.createdAt),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF828282),
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

class ChatHistory {
  final String id;
  final int userId;
  final int coupleId;
  final int chatroomId;
  final String text;
  final String emotion;
  final String checked;
  final int petExperience;
  final int collectionId;
  String? imagePath;
  late final List<int>? imageBytes;
  Image? broadcastingImage;
  Image? myImage;
  Future<Image?>? imageFuture;
  final DateTime createdAt;
  final bool sentByMe;
  bool processed;

  ChatHistory({
    required this.id,
    required this.userId,
    required this.coupleId,
    required this.chatroomId,
    required this.text,
    required this.emotion,
    required this.checked,
    required this.petExperience,
    required this.collectionId,
    this.imagePath,
    this.imageBytes,
    this.myImage,
    this.broadcastingImage,
    required this.createdAt,
    required this.sentByMe,
    required this.processed,
  });

  factory ChatHistory.fromJson(Map<String, dynamic> json, String? userId) {
    return ChatHistory(
      id: json['id'],
      userId: json['userId'],
      coupleId: json['coupleId'],
      chatroomId: json['chatroomId'],
      text: json['text'] ?? '',
      emotion: json['emotion'] ?? '',
      checked: json['checked'] ?? '',
      imagePath: json['imagePath'],
      imageBytes: json['imageBytes'] is List<dynamic>
          ? List<int>.from(json['imageBytes'].cast<int>())
          : null,
      broadcastingImage: null,
      createdAt: DateTime.parse(json['createdAt']),
      sentByMe: userId != null && json['userId'].toString() == userId,
      processed: false,
      // 기본값 설정
      petExperience: json['petExperience'] ?? 0, // 펫 경험치가 없을 경우 0으로 설정
      collectionId: json['petCollection'] ?? 0, // 컬렉션 ID가 없을 경우 0으로 설정
    );
  }
  // factory ChatHistory.fromJson(Map<String, dynamic> json, String? userId) {
  //   return ChatHistory(
  //     id: json['id'],
  //     userId: json['userId'],
  //     coupleId: json['coupleId'],
  //     chatroomId: json['chatroomId'],
  //     text: json['text'] ?? '',
  //     emotion: json['emotion'] ?? '',
  //     checked: json['checked'] ?? '',
  //     imagePath: json['imagePath'],
  //     imageBytes: json['imageBytes'] is List<dynamic>
  //         ? List<int>.from(json['imageBytes'].cast<int>())
  //         : null,
  //     broadcastingImage: null,
  //     createdAt: DateTime.parse(json['createdAt']),
  //     collectionId: json['petCollection'],
  //     petExperience: json['petExperience'],
  //     //sentByMe: json['userId'].toString() == userId, //주석
  //     sentByMe: userId != null && json['userId'].toString() == userId,
  //     processed: false,
  //   );
  // }
}

Future<ChatHistory> fetchImageFromUrl(
  String imageUrl,
  ChatHistory chatResponse,
) async {
  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token');
  final response = await http.get(
    Uri.parse('$apiBaseUrl/api/getbroadcastingimage?imageUrl=$imageUrl'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final Uint8List imageBytes = response.bodyBytes;
    chatResponse.broadcastingImage = Image.memory(imageBytes);
    return chatResponse;
  } else {
    final ByteData assetData =
        await rootBundle.load('assets/images/profile_default2.png');
    final Uint8List assetBytes = assetData.buffer.asUint8List();
    chatResponse.broadcastingImage = Image.memory(assetBytes);
    return chatResponse;
  }
}

///////////////////////////////////////////////////////////
///  펫 진화 메세지
//////////////////////////////////////////////////////////
class CustomDialog extends StatelessWidget {
  final int petExperience;
  final int collectionId; // 펫의 컬렉션 ID
  final VoidCallback onCollectionButtonPressed;
  final VoidCallback onCloseButtonPressed;

  const CustomDialog({
    super.key,
    required this.petExperience,
    required this.collectionId,
    required this.onCollectionButtonPressed,
    required this.onCloseButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    // 펫의 이미지 경로 가져오기
    String petImagePath = getImagePathFromCollectionId(collectionId, 'happy');
    print('진화이벤트(CustomDialog) 호출!!');
    print('collectionId : $collectionId, petExp : $petExperience');

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '축하합니다!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // 이미지 표시
            Image.asset(
              petImagePath,
              width: 250, // 이미지 너비 조정
              height: 250, // 이미지 높이 조정
            ),
            const SizedBox(height: 16),
            Text(
              // '펫의 경험치가 $petExperience에 도달하여\n ${collectionId % 10 + 1}단계로 진화했습니다!',
              '펫의 경험치가 $petExperience에 도달하여\n ${collectionId % 10}단계로 진화했습니다!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: onCloseButtonPressed,
                  child: const Text('닫기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////
//    현재 감정상태(_currentEmotion), 펫 레벨(collectionId)에 따라 이미지 설정
////////////////////////////////////////////////////////////////////////////

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
