import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import '../database_helper.dart';

Future<Map<String, String>> fetchAndParse(int id) async {
  final markerData = await DatabaseHelper().getMarkerById(id);
  final brno = markerData?['brno'];

  if (brno == null) {
    throw Exception('brno not found');
  }

  final response =
      await http.get(Uri.parse('https://www.bizno.net/article/$brno'));
  if (response.statusCode == 200) {
    var document = html_parser.parse(response.body);

    // 홈페이지 주소 추출
    var homepageElement = document.querySelector('a[href^="http"]');
    var homepage = homepageElement?.attributes['href'] ?? '-';

    // 전화번호 추출
    var phoneElement = document.querySelector('a[href^="tel:"]');
    var phone = phoneElement?.text ?? '-';

    // 사업자 현재 상태 추출 (대체 로직)
    var statusElement = document.querySelectorAll('th').firstWhere(
          (element) => element.text.contains("사업자 현재 상태"),
          orElse: () =>
              html_parser.parseFragment('<th></th>').querySelector('th')!,
        );
    String status = '-';
    if (statusElement != null) {
      var parentRow = statusElement.parent;
      if (parentRow != null) {
        var statusValueElement = parentRow.querySelector('td');
        if (statusValueElement != null) {
          status = statusValueElement.text;
        }
      }
    }

    return {
      'homepage': homepage,
      'phone': phone,
      'status': status,
    };
  } else {
    throw Exception('Failed to load page');
  }
}

void main() {
  fetchAndParse(1).then((data) {
    print('Homepage: ${data['homepage']}');
    print('Phone: ${data['phone']}');
    print('Status: ${data['status']}');
  }).catchError((error) {
    print('Error fetching web data: $error');
  });
}
