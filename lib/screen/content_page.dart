import 'package:flutter/material.dart';
import 'widget/question_sheet.dart';
import 'widget/custom_bottom_navigation_bar.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  int _selectedIndex = 2;
  bool _showQuestionSheet = false;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _startQuestionnaire() {
    setState(() {
      _showQuestionSheet = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _showQuestionSheet
          ? const QuestionSheet()
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/question/question_img.png',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'AI 운동 추천',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '나에게 맞는 운동을 추천받아보세요.',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: const Text(
                        'AI가 당신을 위해 준비한 질문을 통해 운동 추천을 받아보세요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.teal),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _startQuestionnaire,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('시작하기',
                        style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
