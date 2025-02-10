import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiModels {
  Future getLocation(
      double lat, double lng, String locationSearch, String authToken) async {
    String url =
        'https://route-init.gallimap.com/api/v1/search/autocomplete?accessToken=$authToken&word=$locationSearch&lat=$lat&lng=$lng';
    var response =
        await http.get(Uri.parse(url), headers: {'accept': 'application/json'});
    var data = json.decode(response.body)['data'];
    return data;
  }
}
