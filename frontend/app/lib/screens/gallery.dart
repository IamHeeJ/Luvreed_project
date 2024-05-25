import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:luvreed/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  List<Map<String, dynamic>> _images = [];
  final secureStorage = const FlutterSecureStorage();
  late final http.Client client;
  bool _isStoragePermissionGranted = false;

  @override
  void initState() {
    super.initState();
    client = http.Client();
    _requestStoragePermission();
  }

  @override
  void dispose() {
    client.close(); // 클라이언트 리소스 해제
    super.dispose();
  }

  Future<void> _requestStoragePermission() async {
    final status = await Permission.storage.request();
    setState(() {
      _isStoragePermissionGranted = status.isGranted;
    });
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    final token = await secureStorage.read(key: 'token');
    final chatroomId = await secureStorage.read(key: 'chatroomId');
    final response = await client.get(
      Uri.parse('$apiBaseUrl/api/getmongodbimages?chatroomId=$chatroomId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> imageDataList = json.decode(response.body);
      final List<Map<String, dynamic>> images =
          imageDataList.asMap().entries.map((entry) {
        final imageInfo = entry.value;
        final String imageData = imageInfo['imageData'];
        final String imageUrl = imageInfo['imageUrl']; // 이미지 URL 추가
        final Uint8List imageBytes = base64Decode(imageData);
        final DateTime createdAt = DateTime.parse(imageInfo['createdAt']);
        return {
          'imageBytes': imageBytes,
          'imageUrl': imageUrl, // 이미지 URL 추가
          'createdAt': createdAt,
        };
      }).toList();

      setState(() {
        _images = images;
      });
    } else {
      // 에러 처리
    }
  }

  Future<void> _downloadImage(String imageUrl) async {
    final token = await secureStorage.read(key: 'token');

    try {
      final response = await client.get(
        Uri.parse('$apiBaseUrl/api/downloadimage?imageUrl=$imageUrl'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        _saveImageToDownloadFolder(imageUrl, bytes);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to download image. Status code: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download image. Error: $e'),
        ),
      );
    }
  }

  Future<void> _saveImageToDownloadFolder(
      String imageUrl, Uint8List bytes) async {
    final directory = await getExternalStorageDirectory();
    final downloadDirectory = Directory('${directory!.path}/Download');
    if (!await downloadDirectory.exists()) {
      await downloadDirectory.create(recursive: true);
    }

    // 경로 구분자를 역슬래시(\)로 변경하고, 파일 이름만 추출
    final fileName =
        Uri.decodeFull(imageUrl).replaceAll('/', '\\').split('\\').last;

    final file = File('${downloadDirectory.path}/$fileName');
    await file.writeAsBytes(bytes);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image downloaded successfully to ${file.path}')),
    );
  }

  Future<void> _deleteImage(String imageUrl) async {
    final token = await secureStorage.read(key: 'token');
    final response = await client.delete(
      Uri.parse('$apiBaseUrl/api/deleteimage?imageUrl=$imageUrl'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _images.removeWhere((image) => image['imageUrl'] == imageUrl);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 삭제 성공')),
      );
    } else {
      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 삭제 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 날짜별로 이미지 그룹화
    final Map<String, List<Map<String, dynamic>>> groupedImages = {};
    for (final image in _images) {
      final date = DateFormat('yyyy-MM-dd').format(image['createdAt']);
      if (groupedImages.containsKey(date)) {
        groupedImages[date]!.add(image);
      } else {
        groupedImages[date] = [image];
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('앨범'),
      ),
      body: ListView.builder(
        itemCount: groupedImages.length,
        itemBuilder: (context, index) {
          final date = groupedImages.keys.elementAt(index);
          final images = groupedImages[date]!;

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 4.0), // 좌우 마진 설정
            child: ExpansionTile(
              initiallyExpanded: true, // 초기에 열려있는 상태로 설정
              title: Text(date),
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3행으로 정렬
                    mainAxisSpacing: 4.0, // 수직 간격
                    crossAxisSpacing: 4.0, // 수평 간격
                    childAspectRatio: 1.0, // 정사각형 비율 유지
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final image = images[index];
                    final imageBytes = image['imageBytes'];
                    final imageUrl = image['imageUrl'];

                    // 현재 타일이 해당 행의 마지막 타일인지 여부 확인
                    final isLastInRow = (index + 1) % 3 == 0;
                    // 현재 행이 마지막 행인지 여부 확인
                    final isLastRow = index >= images.length - 3;

                    return Padding(
                      padding: EdgeInsets.only(
                        right: isLastInRow ? 4.0 : 0.0, // 마지막 열에만 오른쪽 마진 추가
                        bottom: isLastRow ? 4.0 : 0.0, // 마지막 행에만 아래쪽 마진 추가
                      ),
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.memory(imageBytes),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _downloadImage(imageUrl);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      surfaceTintColor: const Color(0xFF000000),
                                      backgroundColor: const Color(0xFF000000),
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(120, 40),
                                      elevation: 3,
                                    ),
                                    child: Text('Download'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Image.memory(imageBytes, fit: BoxFit.cover),
                      ),
                    );
                  },
                ),
              ],
            ),
          );

        },
      ),
    );
  }
}