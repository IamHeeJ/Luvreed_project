import 'package:flutter/material.dart';
import 'package:luvreed/screens/sendedpw_screen.dart';

class FindPwScreen extends StatelessWidget {
  const FindPwScreen({super.key});

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
          child: const SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Text(
                      '반갑습니다!',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Text(
                      '로그인을 위한 정보를 입력해주세요.',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: '이메일',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFB8B8BC),
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      size: 29,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(
                  height: 30,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: '비밀번호',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFB8B8BC),
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      size: 29,
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  obscureText: true,
                ),
                SizedBox(
                  height: 50,
                ),
                Center(
                  child: SendPwBtn(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SendPwBtn extends StatelessWidget {
  const SendPwBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SendedPwScreen(),
          )),
      style: ElevatedButton.styleFrom(
        surfaceTintColor: const Color(0xFF000000),
        backgroundColor: const Color(0xFF000000),
        foregroundColor: Colors.white,
        minimumSize: const Size(180, 53),
        elevation: 3,
      ),
      child: const Text(
        '임시 비밀번호 전송',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
