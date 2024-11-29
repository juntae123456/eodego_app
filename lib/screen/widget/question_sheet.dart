import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'gpt_question.dart';

class QuestionSheet extends StatefulWidget {
  final VoidCallback onFinish;

  const QuestionSheet({Key? key, required this.onFinish}) : super(key: key);

  @override
  _QuestionSheetState createState() => _QuestionSheetState();
}

class _QuestionSheetState extends State<QuestionSheet> {
  int _currentPage = 0;
  final int _totalPages = 10;
  int? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50.0),
      child: Column(
        children: [
          LinearPercentIndicator(
            lineHeight: 6.0,
            percent: (_currentPage + 1) / _totalPages,
            backgroundColor: Colors.grey[200],
            progressColor: Colors.black,
          ),
          Expanded(
            child: Visibility(
              visible: _currentPage <= _totalPages - 1,
              child: Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        _getQuestionText(_currentPage),
                        style: const TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _getOptionsCount(_currentPage),
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.all(10.0),
                            child: ListTile(
                              title: Text(_getOptionText(_currentPage, index)),
                              leading: Radio<int>(
                                value: index,
                                groupValue: _selectedOption,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedOption = value;
                                  });
                                },
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedOption = index;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ), // Text color
            ),
            onPressed: () {
              setState(() {
                if (_currentPage < _totalPages - 1) {
                  GptQuestion().saveAnswer(
                      _currentPage, _selectedOption); // 현재 질문에 대한 답변 저장
                  _currentPage++;
                  _selectedOption =
                      null; // Reset selected option for next question
                } else {
                  GptQuestion().saveAnswer(
                      _currentPage, _selectedOption); // 마지막 질문에 대한 답변 저장
                  widget.onFinish();
                }
              });
            },
            child: Text(_currentPage < _totalPages - 1 ? 'Next' : 'Finish'),
          ),
        ],
      ),
    );
  }

  String _getQuestionText(int index) {
    switch (index) {
      case 0:
        return '운동을 하려는 주요 목적은 무엇인가요?';
      case 1:
        return '운동 중 선호하는 활동 유형은 무엇인가요?';
      case 2:
        return '운동을 배우는 방식을 선호하시나요?';
      case 3:
        return '어떤 운동 강도를 선호하시나요?';
      case 4:
        return '운동을 위한 준비물이나 도구를 사용하는 것을 선호하시나요?';
      case 5:
        return '운동 가능한 시간이 얼마나 되나요?';
      case 6:
        return '운동 중 어떤 분위기를 선호하시나요?';
      case 7:
        return '운동을 통해 가장 얻고 싶은 것은 무엇인가요?';
      case 8:
        return '현재 신체 활동에 제한이 있나요?';
      case 9:
        return '운동을 선택할 때 가장 중요하게 고려하는 점은 무엇인가요?';
      default:
        return '';
    }
  }

  int _getOptionsCount(int index) {
    switch (index) {
      case 0:
        return 5;
      case 1:
        return 4;
      case 2:
        return 4;
      case 3:
        return 4;
      case 4:
        return 4;
      case 5:
        return 4;
      case 6:
        return 4;
      case 7:
        return 4;
      case 8:
        return 4;
      case 9:
        return 5;
      default:
        return 0;
    }
  }

  String _getOptionText(int index, int optionIndex) {
    switch (index) {
      case 0:
        switch (optionIndex) {
          case 0:
            return '체중감량';
          case 1:
            return '스트레스 해소';
          case 2:
            return '근력 강화';
          case 3:
            return '유연성 향상';
          case 4:
            return '새로운 기술';
          default:
            return '';
        }
      case 1:
        switch (optionIndex) {
          case 0:
            return '개인운동(헬스, 요가 등)';
          case 1:
            return '단체 운동(태권도, 검도 등)';
          case 2:
            return '야외 활동(수영, 러닝 등)';
          case 3:
            return '실내 활동(기구 운동 등)';
          default:
            return '';
        }
      case 2:
        switch (optionIndex) {
          case 0:
            return '스스로 독립적으로 배우기';
          case 1:
            return '전문 강사의 지도를 받기';
          case 2:
            return '친구나 가족과 함께 배우기';
          case 3:
            return '단체 훈련에서 배우기';
          default:
            return '';
        }
      case 3:
        switch (optionIndex) {
          case 0:
            return '낮음';
          case 1:
            return '중간';
          case 2:
            return '높음';
          case 3:
            return '조절 가능 (상황에 따라 다름)';
          default:
            return '';
        }
      case 4:
        switch (optionIndex) {
          case 0:
            return '도구 없이 가능한 운동';
          case 1:
            return '간단한 도구';
          case 2:
            return '전문 장비가 필요한 운동';
          case 3:
            return '장소 제한 없이 가능한 운동';
          default:
            return '';
        }
      case 5:
        switch (optionIndex) {
          case 0:
            return '30분 이하';
          case 1:
            return '30분 - 1시간';
          case 2:
            return '1시간 - 1시간 30분';
          case 3:
            return '시간이 고정되지 않음';
          default:
            return '';
        }
      case 6:
        switch (optionIndex) {
          case 0:
            return '조용하고 집중할 수 있는 운동';
          case 1:
            return '에너지가 넘치는 단체 활동';
          case 2:
            return '자연과 함께하는 야외 활동';
          case 3:
            return '장소와 분위기 상관 없음';
          default:
            return '';
        }
      case 7:
        switch (optionIndex) {
          case 0:
            return '체력 증진';
          case 1:
            return '기술 습득';
          case 2:
            return '긴장 완화와 마음의 평화';
          case 3:
            return '재미와 성취감';
          default:
            return '';
        }
      case 8:
        switch (optionIndex) {
          case 0:
            return '없음';
          case 1:
            return '무릎 통증';
          case 2:
            return '허리 통증';
          case 3:
            return '어깨 통증';
          case 4:
            return '재활 운동이 필요';
          default:
            return '';
        }
      case 9:
        switch (optionIndex) {
          case 0:
            return '새로운 기술이나 동작을 배울 수 있는지';
          case 1:
            return '체력을 효율적으로 강화할 수 있는지';
          case 2:
            return '재미있고 지속하기 쉬운지';
          case 3:
            return '몸과 마음의 균형을 맞출 수 있는지';
          case 4:
            return '특별한 환경이나 장소가 필요한지';
          default:
            return '';
        }
      default:
        return '';
    }
  }
}
