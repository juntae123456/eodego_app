import 'package:flutter/material.dart';
import '../content_page.dart';

class QuestionEndSheet extends StatefulWidget {
  const QuestionEndSheet({Key? key}) : super(key: key);

  @override
  _QuestionEndSheetState createState() => _QuestionEndSheetState();
}

class _QuestionEndSheetState extends State<QuestionEndSheet> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '축하합니다!',
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              '모든 질문에 답변하셨습니다.',
              style: TextStyle(fontSize: 20.0, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const ContentPage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );
  }
}
