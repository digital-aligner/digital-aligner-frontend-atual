import 'dart:convert';

import 'package:digital_aligner_app/dados/models/cadastro/novo_cadastro_model.dart';

import '../dados/models/cadastro/cadastro_model.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../rotas_url.dart';

class CadastroProvider with ChangeNotifier {
  // FOR FIRST TIME CADASTRO
  NovoCadastroModel novoCad = NovoCadastroModel();

  //Converted json string to map
  List<dynamic> _cadastros = [];
  //Currently selected cadastro obj
  CadastroModel? _selectedCad;
  //Token for requests
  String _token = '';

  //For gerenciar cadastro screen
  String _cadDropdownValue = 'Todos';
  //For permissões cadastro screen
  String _permDropdownValue = 'Todos';

  void setCadDropdownValue(String value) {
    _cadDropdownValue = value;
  }

  String getCadDropdownValue() {
    return _cadDropdownValue;
  }

  void setPermDropdownValue(String value) {
    _permDropdownValue = value;
  }

  String getPermDropdownValue() {
    return _permDropdownValue;
  }

  //For query
  String _queryString = '';

  void setQuery(String value) {
    _queryString = value;
  }

  void clearCadastrosAndUpdate() {
    _cadastros = [];
    _selectedCad = null;
    notifyListeners();
  }

  void setNotify() {
    notifyListeners();
  }

  CadastroModel? selectedCad() {
    return _selectedCad;
  }

  void clearCadastros() {
    _cadastros = [];
    _cadDropdownValue = 'Todos';
    _permDropdownValue = 'Todos';
    _queryString = '';
  }

  void clearSelectedCad() {
    _selectedCad = null;
  }

  void clearToken() {
    _token = '';
  }

  void setToken(var t) {
    _token = t;
  }

  List<dynamic> getCadastros() {
    return _cadastros;
  }

  void setSelectedCad(int index) {
    _selectedCad = CadastroModel.fromJson(_cadastros[index]);
  }

  void setMyCad(List<dynamic> data) {
    _selectedCad = CadastroModel.fromJson(data[0]);
  }

  Future<Map> enviarPrimeiroCadastro(bool isPortugal) async {
    /*
    //Changing iso string to local (just for input view)
    DateTime dataNasc = DateTime.parse(_controllerDataNasc.text).toLocal();
    _controllerDataNasc.text =
        DateFormat('dd/MM/yyyy').format(dataNasc).toString();
    */

    String rota = '';

    if (isPortugal)
      rota = RotasUrl.rotaCadastroExteriorV1;
    else
      rota = RotasUrl.rotaCadastro;

    var _response = await http.post(
      Uri.parse(rota),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(novoCad.toJson()),
    );

    Map data = json.decode(_response.body);

    if (data['statusCode'] == 200) novoCad = NovoCadastroModel();

    return data;
  }

  Future<List<dynamic>> fetchMyCadastro() async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.get(
        Uri.parse(RotasUrl.rotaUserMe),
        headers: requestHeaders,
      );

      _cadastros = json.decode(response.body);

      setMyCad(_cadastros);

      return _cadastros;
    } catch (error) {
      print('xx1' + error.toString());
    }
    return _cadastros;
  }

  Future<List<dynamic>> fetchCadastros(
    int startPage,
    bool cadastrosExterior,
  ) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    //Check dropdown to change route: Todos, pedidos aprovados, etc.
    String _routeType = '';
    if (_cadDropdownValue == 'Todos') {
      _routeType = RotasUrl.rotaCadastro;
    } else if (_cadDropdownValue == 'Aprovado') {
      _routeType = RotasUrl.rotaCadastrosAprovados;
    } else if (_cadDropdownValue == 'Aguardando') {
      _routeType = RotasUrl.rotaCadastrosAguardando;
    } else if (_cadDropdownValue == 'Negado') {
      _routeType = RotasUrl.rotaCadastrosNegado;
    } else if (_permDropdownValue == 'Administrador') {
      _routeType = RotasUrl.rotaCadastrosAdministrador;
    } else if (_permDropdownValue == 'Gerente') {
      _routeType = RotasUrl.rotaCadastrosGerente;
    } else if (_permDropdownValue == 'Credenciado') {
      _routeType = RotasUrl.rotaCadastrosCredenciado;
    }

    try {
      final response = await http.get(
        Uri.parse(
          _routeType +
              '?queryString=' +
              _queryString +
              '&startPage=' +
              startPage.toString() +
              '&cadastrosExterior=' +
              cadastrosExterior.toString(),
        ),
        headers: requestHeaders,
      );

      _cadastros = json.decode(response.body);

      return _cadastros;
    } catch (error) {
      print(error);
      return [];
    }
  }

  Future<List<dynamic>> fetchCadastrosPerm(
    int startPage,
    bool cadastrosExterior,
  ) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    //Check dropdown to change route: Todos, pedidos aprovados, etc.
    String _routeType = '';
    if (_permDropdownValue == 'Todos') {
      _routeType = RotasUrl.rotaCadastro;
    } else if (_permDropdownValue == 'Administrador') {
      _routeType = RotasUrl.rotaCadastrosAdministrador;
    } else if (_permDropdownValue == 'Gerente') {
      _routeType = RotasUrl.rotaCadastrosGerente;
    } else if (_permDropdownValue == 'Credenciado') {
      _routeType = RotasUrl.rotaCadastrosCredenciado;
    }

    try {
      final response = await http.get(
        Uri.parse(
          _routeType +
              '?queryString=' +
              _queryString +
              '&startPage=' +
              startPage.toString() +
              '&cadastrosExterior=' +
              cadastrosExterior.toString(),
        ),
        headers: requestHeaders,
      );
      print(response.body);
      _cadastros = json.decode(response.body);

      return _cadastros;
    } catch (error) {
      print(error);
      return [];
    }
  }

  Future<dynamic> aprovarCadastro(int id) async {
    String url = RotasUrl.rotaCadastro + id.toString();

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: requestHeaders,
        body: json.encode(
          {
            'aprovacao_usuario': '1',
            'blocked': false,
          },
        ),
      );
      Map responseData = json.decode(response.body);

      clearCadastrosAndUpdate();
      return responseData;
    } catch (error) {
      print('Error! Status code: ' + error.toString());
    }
  }

  Future<dynamic> sendCadistaState(int id, bool value) async {
    String url = RotasUrl.rotaCadastro + id.toString();

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: requestHeaders,
        body: json.encode(
          {
            'is_cadista': value,
          },
        ),
      );
      Map responseData = json.decode(response.body);

      clearCadastrosAndUpdate();
      return responseData;
    } catch (error) {
      print('Error! Status code: ' + error.toString());
    }
  }

  Future<dynamic> sendRepresentanteState(int id, bool value) async {
    String url = RotasUrl.rotaCadastro + id.toString();

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: requestHeaders,
        body: json.encode(
          {
            'is_representante': value,
          },
        ),
      );
      Map responseData = json.decode(response.body);

      clearCadastrosAndUpdate();
      return responseData;
    } catch (error) {
      print('Error! Status code: ' + error.toString());
    }
  }

  Future<dynamic> sendRevisorState(int id, bool value) async {
    String url = RotasUrl.rotaCadastro + id.toString();

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: requestHeaders,
        body: json.encode(
          {
            'is_revisor': value,
          },
        ),
      );
      Map responseData = json.decode(response.body);

      clearCadastrosAndUpdate();
      return responseData;
    } catch (error) {
      print('Error! Status code: ' + error.toString());
    }
  }

  Future<dynamic> enviarCadastro() async {
    print(json.encode(_selectedCad!.toJson()));
    var _response = await http.put(
        Uri.parse(RotasUrl.rotaCadastro + _selectedCad!.id.toString()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token'
        },
        body: json.encode(_selectedCad!.toJson()));

    Map _data = json.decode(_response.body);
    print(_data);
    return _data;
  }

  //Converted json string to map
  List<dynamic> _aprovTableMap = [];
  //List of string just for widget
  List<String> _aprovTableList = [];

  List<String> getAprovTableList() {
    return _aprovTableList;
  }

  void handleAprovRelation(String status) {
    _aprovTableMap.forEach((element) {
      if (element['status'] == status) {
        _selectedCad!.aprovacao_usuario!.id = element['id'];
        _selectedCad!.aprovacao_usuario!.status = status;

        if (element['status'] != 'Aprovado') {
          _selectedCad!.blocked = true;
        } else {
          _selectedCad!.blocked = false;
        }
      }
    });
  }

  Future<List<String>> getAprovacaoTable() async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final _response = await http.get(
        Uri.parse(RotasUrl.rotaAprovacao),
        headers: requestHeaders,
      );
      _aprovTableMap = json.decode(_response.body);

      _aprovTableList = _aprovTableMap.map((tablevalue) {
        return tablevalue['status'].toString();
      }).toList();

      return _aprovTableList;
    } catch (error) {
      print('Error! Status code: ' + error.toString());
    }
    return [];
  }
}
