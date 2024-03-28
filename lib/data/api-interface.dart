import 'dart:developer';

import 'package:http/http.dart' as http;
class ApiInterface{

  static Future<String?> getRequest({required final String url,Map<String, String>? headers})async{
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        return response.body;
      }
      return null;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
  
}