import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class GptQuestion {
  static final GptQuestion _instance = GptQuestion._internal();
  factory GptQuestion() => _instance;

  GptQuestion._internal();

  List<int?> _answers = List<int?>.filled(10, null);
  String? _prompt;

  void saveAnswer(int questionIndex, int? answer) {
    _answers[questionIndex] = answer;
  }

  List<int?> get answers => _answers;

  String _buildPrompt() {
    return '''
        운동 한가지를 추천해주세요 150자 내로 작성해주세요.:
        1. 운동을 하려는 주요 목적: ${_getOptionText(0, _answers[0])}
        2. 운동 중 선호하는 활동 유형: ${_getOptionText(1, _answers[1])}
        3. 운동을 배우는 방식: ${_getOptionText(2, _answers[2])}
        4. 운동 강도: ${_getOptionText(3, _answers[3])}
        5. 운동을 위한 준비물: ${_getOptionText(4, _answers[4])}
        6. 운동 가능한 시간: ${_getOptionText(5, _answers[5])}
        7. 운동 중 선호하는 분위기: ${_getOptionText(6, _answers[6])}
        8. 운동을 통해 얻고 싶은 것: ${_getOptionText(7, _answers[7])}
        9. 현재 신체 활동에 제한: ${_getOptionText(8, _answers[8])}
        10. 운동 선택 시 고려 사항: ${_getOptionText(9, _answers[9])}
        ''';
  }

  String _getOptionText(int questionIndex, int? optionIndex) {
    if (optionIndex == null) return '선택 안 함';
    switch (questionIndex) {
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

  void savePrompt() {
    _prompt = _buildPrompt();
    print('Prompt saved: $_prompt');
  }

  String? get prompt => _prompt;

  Future<String> getRecommendation() async {
    final apiKey = dotenv.env['GPT_API_KEY'];
    if (apiKey == null) {
      throw Exception('API key not found');
    }

    final messages = [
      {
        'role': 'system',
        'content':
            'You are a helpful assistant that provides exercise recommendations.'
      },
      {'role': 'user', 'content': _buildPrompt()}
    ];

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': messages,
        'max_tokens': 200,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      // Response body decoding
      final data = jsonDecode(utf8.decode(response.bodyBytes)); // UTF-8 디코딩
      return data['choices'][0]['message']['content'];
    } else {
      print(
          'Failed to load recommendation: ${utf8.decode(response.bodyBytes)}');
      throw Exception('Failed to load recommendation');
    }
  }
}
