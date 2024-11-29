import 'package:flutter/material.dart';
import '../content_page.dart';
import 'gpt_question.dart';

class QuestionEndSheet extends StatefulWidget {
  const QuestionEndSheet({Key? key}) : super(key: key);

  @override
  _QuestionEndSheetState createState() => _QuestionEndSheetState();
}

class _QuestionEndSheetState extends State<QuestionEndSheet> {
  String? _recommendation;

  @override
  void initState() {
    super.initState();
    _getRecommendation();
  }

  Future<void> _getRecommendation() async {
    try {
      final recommendation = await GptQuestion().getRecommendation();
      setState(() {
        _recommendation = recommendation;
      });
      print('Recommendation loaded: $recommendation');
    } catch (e) {
      print('Failed to load recommendation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
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
            Center(
              child: _recommendation == null
                  ? CircularProgressIndicator()
                  : Text(
                      _recommendation!,
                      style: TextStyle(fontSize: 18.0),
                    ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
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
