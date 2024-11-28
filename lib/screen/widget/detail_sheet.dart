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
        'https://apis.data.go.kr/B551014/SRVC_OD_API_FACIL_COURSE/todz_api_facil_course_i?serviceKey=$apiKey&pageNo=1&numOfRows=10&resultType=JSON&brno=$brno';

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

  @override
  Widget build(BuildContext context) {
    if (_markerData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Loading...'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_markerData!['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Address:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(_markerData!['road_addr'], style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text(
              'Main Event:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(_markerData!['main_event_nm'], style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text(
              '사업자 번호:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(_markerData!['brno'], style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            if (_apiData != null) ...[
              Text(
                'API Data:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _apiData!.length,
                  itemBuilder: (context, index) {
                    final item = _apiData![index];
                    return ListTile(
                      title: Text(item['course_nm']),
                      subtitle: Text(item['facil_sn']),
                    );
                  },
                ),
              ),
            ],
            SizedBox(height: 16),
            if (_webData != null) ...[
              Text(
                'Web Data:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text('Homepage: ${_webData!['homepage']}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Phone: ${_webData!['phone']}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Status: ${_webData!['status']}',
                  style: TextStyle(fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }
}
