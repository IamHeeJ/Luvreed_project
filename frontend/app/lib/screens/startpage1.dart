//import 'dart:js';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:luvreed/screens/login_screen.dart';
import 'package:luvreed/screens/signup_screen.dart';

class StartPage1 extends StatefulWidget {
  const StartPage1({super.key});

  @override
  State<StartPage1> createState() => _StartPage1State();
}

class _StartPage1State extends State<StartPage1> {
  int _current = 0;
  final CarouselController _controller = CarouselController();
  List imageList = [
    "assets/images/intro1.png",
    "assets/images/intro2.png",
    "assets/images/intro3.png",
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFFFE5D8),
        body: Column(
          children: [
            const SizedBox(
              height: 130,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'StartLogo',
                  child: Image.asset(
                    'assets/images/luvreed.png',
                    height: 43,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            sliderWidget(),
            sliderIndicator(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SignupBtn(),
                SizedBox(
                  width: 30,
                ),
                LoginBtn(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget sliderWidget() {
    return CarouselSlider(
      carouselController: _controller,
      items: imageList.map(
        (imgLink) {
          return Builder(
            builder: (context) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  imgLink, // 이미지 경로 전달
                  fit: BoxFit.cover,
                ),
              );
            },
          );
        },
      ).toList(),
      options: CarouselOptions(
        height: 450,
        viewportFraction: 1.0,
        onPageChanged: (index, reason) {
          setState(() {
            _current = index;
          });
        },
      ),
    );
  }

  Widget sliderIndicator() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: imageList.asMap().entries.map((entry) {
          return GestureDetector(
            onTap: () => _controller.animateToPage(entry.key),
            child: Container(
              width: 12,
              height: 12,
              margin:
                  const EdgeInsets.symmetric(vertical: 35.0, horizontal: 15.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Colors.grey.withOpacity(_current == entry.key ? 0.9 : 0.4),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SignupBtn extends StatelessWidget {
  const SignupBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SignUpScreen(),
          )),
      style: ElevatedButton.styleFrom(
        surfaceTintColor: const Color(0xFFFFFFFF),
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: Colors.black,
        minimumSize: const Size(110, 53),
        shadowColor: Colors.grey[350],
        elevation: 4,
      ),
      child: const Text(
        '회원가입',
      ),
    );
  }
}

class LoginBtn extends StatelessWidget {
  const LoginBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          )),
      style: ElevatedButton.styleFrom(
        surfaceTintColor: const Color(0xFFFFFFFF),
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: Colors.black,
        minimumSize: const Size(110, 53),
        shadowColor: Colors.grey[350],
        elevation: 4,
      ),
      child: const Text(
        '로그인',
      ),
    );
  }
}
