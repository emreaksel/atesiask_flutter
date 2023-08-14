import 'package:http/http.dart' as http;

class HttpService {
  final String baseUrl;

  HttpService(this.baseUrl);

  Future<String> fetchData(String path) async {
    print("baseUrl: "+baseUrl);
    final response = await http.get(Uri.parse('$baseUrl/$path'));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('İstek başarısız oldu: ${response.statusCode}');
    }
  }
}
