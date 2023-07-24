import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';


class GoldPrice{
  final dynamic buy_pretax;
  final dynamic date_time;

  GoldPrice(this.buy_pretax,this.date_time);
}

class UserProvider with ChangeNotifier {

  static const String apiUrl = 'https://cemuat.mmtcpamp.com';

  String? _jwtToken;

  double _todayGoldValue = 0.0;

  double get todayGoldValue => _todayGoldValue;

  String? get jwtToken => _jwtToken;

  Future<bool> login(String username, String password) async {
    try {

      final String basicAuth =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';

      // Replace 'YOUR_LOGIN_ENDPOINT' with your API endpoint for login
      final response = await http.post(
        Uri.parse('$apiUrl/security/login'),
        headers: {'Content-Type': 'application/json',
          'Authorization': basicAuth,
        'partner_id':username,},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _jwtToken = data['sessionId'];
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _jwtToken = null;
    notifyListeners();
  }

  Future<void> getTodayGoldValue(BuildContext context) async{
    try{
      String cookie='sessionId=$_jwtToken';
      final response = await http.post(
        Uri.parse('$apiUrl/price/XAU/INR'),
        headers: {'Content-Type': 'application/json',
          'Cookie':cookie,
          },
        body: jsonEncode(<String, String>{
          'timeFrame': '1W',
        }),
      );
      final  data = jsonDecode(response.body);

      if(data is Map){
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }



      final buyPretax = data[data.length - 1]['buy_pretax'];

      _todayGoldValue =buyPretax;
      notifyListeners();
    }catch(e){
      print("this is error while fetching the gold price ${e}");

    }
  }
}

