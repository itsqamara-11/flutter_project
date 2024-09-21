import 'dart:convert';
import 'package:http/http.dart' as http;
import 'furniture.dart'; // Import the Furniture class

class ApiService {
  static const String _baseUrl = 'https://dummyjson.com/products';

  static Future<List<Furniture>> fetchFurniture() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['products'];
      return jsonResponse.map((item) => Furniture.fromJson(item)).toList();
    } else {
      print('Failed to load furniture: ${response.statusCode}');
      throw Exception('Failed to load furniture');
    }
  }
}
