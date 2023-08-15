import 'package:http/http.dart' as http;

class HttpService {


  HttpService();

  Future<String> fetchData(String path) async {
    print("HttpService-fetchData yolu: "+path);
    final response = await http.get(Uri.parse(path));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('İstek başarısız oldu: ${response.statusCode}');
    }
  }
}
