import 'dart:convert';
import 'package:http/http.dart' as http;

import 'newsModel.dart';

Future fetchPost() async {
  var client = http.Client();
  var uri = Uri.parse(
      'https://newsapi.org/v2/everything?q=window&sortBy=popularity&apiKey=c3f684c549b74b0c8ba0459f382b123a');
  var response = await client.get(uri);
  print(response.statusCode);
  if (response.statusCode == 200) {
    // var res = response.body;
    var jsondecode = jsonDecode(response.body);

    // return NewsModel.fromJson(json.decode(res));
    return jsondecode;
  } else {
    throw Exception("Can't get photos");
  }
}
