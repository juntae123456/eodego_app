import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../database_helper.dart';
import 'web_clawling.dart'; // web_clawling.dart 파일을 임포트

class DetailSheet extends StatefulWidget {
  final int id;

  const DetailSheet({required this.id, Key? key}) : super(key: key);

  @override
  _DetailSheetState createState() => _DetailSheetState();
}

class _DetailSheetState extends State<DetailSheet> {
  Map<String, dynamic>? _markerData;
  List<dynamic>? _apiData;
  Map<String, String>? _webData;

  @override
  void initState() {
    super.initState();
    _loadMarkerData();
    _loadWebData();
  }

  Future<void> _loadMarkerData() async {
    final markerData = await DatabaseHelper().getMarkerById(widget.id);
    setState(() {
      _markerData = markerData;
    });
    if (markerData != null) {
      await _fetchApiData(markerData['brno']);
    }
  }

  Future<void> _fetchApiData(String brno) async {
    final String apiKey = dotenv.env['DATA_API_KEY']!;
    final String apiUrl =
        'https://apis.data.go.kr/B551014/SRVC_OD_API_FACIL_COURSE/todz_api_facil_course_i?serviceKey=$apiKey&pageNo=1&numOfRows=1&resultType=JSON&brno=$brno';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _apiData = data['response']['body']['items']['item'];
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _loadWebData() async {
    try {
      final webData = await fetchAndParse(widget.id);
      setState(() {
        _webData = webData;
      });
    } catch (e) {
      print('Error fetching web data: $e');
    }
  }

  String _getOperatingDays(String weekdayVal) {
    List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
    List<String> operatingDays = [];
    for (int i = 0; i < weekdayVal.length; i++) {
      if (weekdayVal[i] == '1') {
        operatingDays.add(days[i]);
      }
    }
    return operatingDays.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    if (_markerData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Loading...')),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(right: 70.0),
          child: Center(
            child: Text(
              _markerData!['main_event_nm'],
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            FocusScope.of(context).unfocus(); // 키보드 닫기
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(13.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_markerData!['name'],
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(_markerData!['main_event_nm'],
                style: TextStyle(fontSize: 14, color: Color(0xFF4A709C))),
            SizedBox(height: 8),
            Row(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.access_time,
                        color: Colors.black, size: 26.0),
                  ),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('운영시간',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    if (_apiData != null && _apiData!.isNotEmpty) ...[
                      Text(
                        _getOperatingDays(_apiData![0]['lectr_weekday_val']),
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF4A709C)),
                      ),
                      Text(
                        '${_apiData![0]['start_tm']} ~ ${_apiData![0]['equip_tm']}',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF4A709C)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('상세정보',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 18),
            if (_apiData != null && _apiData!.isNotEmpty) ...[
              Text('강사명 : ${_apiData![0]['lectr_nm']}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 18),
            ],
            Text('사업자 번호 : ${_markerData!['brno']}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 18),
            if (_webData != null) ...[
              SizedBox(height: 8),
              Text('현재 상태 : ${_webData!['status']}',
                  style: TextStyle(fontSize: 16)),
            ],
            if (_apiData != null && _apiData!.isNotEmpty) ...[
              Text('강좌 가격 : ${_apiData![0]['settl_amt']}원',
                  style: TextStyle(fontSize: 16)),
            ],
            SizedBox(height: 18),
            if (_webData != null) ...[
              SizedBox(height: 8),
              Text('전화번호: ${_webData!['phone']}',
                  style: TextStyle(fontSize: 16)),
            ],
            SizedBox(height: 18),
            if (_webData != null) ...[
              Text('홈페이지 : ${_webData!['homepage']}',
                  style: TextStyle(fontSize: 16)),
            ],
            SizedBox(height: 18),
            Text('주소 : ${_markerData!['road_addr']}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 18),
            if (_apiData != null && _apiData!.isNotEmpty) ...[
              Text('상세 설명 : ${_apiData![0]['course_seta_desc_cn']}',
                  style: TextStyle(fontSize: 16)),
            ] else ...[
              Text('상세 설명 : -', style: TextStyle(fontSize: 16)),
            ],
            SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
