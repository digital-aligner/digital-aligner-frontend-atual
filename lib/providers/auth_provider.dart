import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart';
import '../rotas_url.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  //Dados token
  String _token = '';
  DateTime? _expiryDate;

  //Dados usuário
  int _userId = 0;
  String _userName = '';
  String _userLastName = '';
  String _email = '';
  String _role = '';
  int _roleId = 0;

  int get id {
    return _userId;
  }

  int get roleId {
    return _roleId;
  }

  String get email {
    return _email;
  }

  String get name {
    return _userName;
  }

  String get lastName {
    return _userLastName;
  }

  String get role {
    return _role;
  }

  String get token {
    if (_expiryDate == null && _token.isNotEmpty) {
      return '';
    } else if (_expiryDate!.isAfter(DateTime.now())) {
      return _token;
    }
    return '';
  }

  bool get isAuth {
    if (_token.isEmpty) {
      return false;
    } else if (_expiryDate!.isBefore(DateTime.now())) {
      logout();
      return false;
    }
    return true;
  }

  Future<bool> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('digitalAlignerData')) {
        return false;
      }
      final extractedUserData =
          json.decode(prefs.getString('digitalAlignerData') ?? '')
              as Map<String, dynamic>;
      final DateTime? expiryDate =
          DateTime.parse(extractedUserData['expiryDate']);

      if (expiryDate!.isBefore(DateTime.now())) {
        return false;
      }

      _token = extractedUserData['token'];
      _userId = extractedUserData['userId'];
      _userName = extractedUserData['userName'];
      _email = extractedUserData['email'];
      _userLastName = extractedUserData['userLastName'];
      _role = extractedUserData['role'];
      _roleId = extractedUserData['roleId'];
      _expiryDate = expiryDate;
      //notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _token = '';
    _userId = 0;
    _userName = '';
    _userLastName = '';
    _role = '';
    _email = '';
    _expiryDate = null;
    _roleId = 0;

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('digitalAlignerData');
    //notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/x-www-form-urlencoded',
      'Authorization': ''
    };

    try {
      final response = await http.post(
        Uri.parse(RotasUrl.rotaLogin),
        headers: requestHeaders,
        body: {
          'identifier': email,
          'password': password,
        },
      );
      final responseData = json.decode(response.body);

      if (responseData.containsKey('error') || response.statusCode == 400) {
        print(responseData);
        if (responseData['message'][0]['messages'][0]['id'] ==
            'Auth.form.error.blocked') {
          return {
            'message':
                'Seu cadastro está sendo averiguado e será aprovado em até 48h.',
            'error': true
          };
        }
        if (responseData['message'][0]['messages'][0]['id'] ==
            'Auth.form.error.invalid') {
          return {
            'message': 'Usuário ou senha incorreta.',
            'error': true,
          };
        }
      }

      //Extracting user dada
      _token = responseData['jwt'];

      _expiryDate = Jwt.getExpiryDate(_token);

      /*
      _expiryDate = DateTime.now().add(
        Duration(days: 1),
      );*/

      _userId = responseData['user']['id'];
      _userName = responseData['user']['nome'];
      _userLastName = responseData['user']['sobrenome'];
      _email = responseData['user']['email'];
      _role = responseData['user']['role']['name'];
      _roleId = responseData['user']['role']['id'];

      //Save token in device (web or mobile)
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'userName': _userName,
        'userLastName': _userLastName,
        'email': _email,
        'role': _role,
        'roleId': _roleId,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      prefs.setString('digitalAlignerData', userData);

      return {'message': 'login realizado com sucesso!'};
    } catch (error) {
      //If managed to get here, error connecting to strapi server
      print(error);
      return {
        'message': 'Erro ao se connectar com o servidor.',
        'error': true,
      };
    }
  }
}
