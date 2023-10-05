import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class HttpService {
  HttpService();

  Future<String> fetchData(String path, {String encoding = 'utf8'}) async {
    print("HttpService-fetchData yolu: " + path);
    final response = await http.get(Uri.parse(path));

    if (response.statusCode == 200) {
      var data=utf8.decode(response.bodyBytes);
      //print("HttpService-fetchData yolu: " + data);
      return data;
    } else {
      throw Exception('İstek başarısız oldu: ${response.statusCode}');
    }
  }
  Future<Uint8List> fetchBytes(String path) async {
    print("HttpService-fetchBytes yolu: " + path);
    final response = await http.get(Uri.parse(path));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('İstek başarısız oldu: ${response.statusCode}');
    }
  }
}

