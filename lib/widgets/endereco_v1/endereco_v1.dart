import 'dart:convert';

import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/cadastro_provider.dart';
import 'package:digital_aligner_app/widgets/endereco_v1/endereco_model_.dart';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;

import '../../rotas_url.dart';

class Endereco extends StatefulWidget {
  final String enderecoType;
  final GlobalKey<FormState> formKey; // for criar endereco only
  final int userId;

  Endereco({
    @required this.enderecoType,
    this.formKey,
    this.userId = 0,
  });
  @override
  _EnderecoState createState() => _EnderecoState();
}

class _EnderecoState extends State<Endereco> {
  AuthProvider _authStore;
  CadastroProvider _cadastroStore;

  //The types allowed
  final String _type1 = 'criar endereco';
  final String _type2 = 'gerenciar endereco';
  final String _type3 = 'view only';

  //-------------- formkey for gerenciar endereco --------

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //-------------- general variables ----------------

  EnderecoModel _endModel = EnderecoModel(
    bairro: '',
    cep: '',
    cidade: '',
    complemento: '',
    endereco: '',
    numero: '',
    pais: '',
    uf: '',
  );

  double sWidth;
  bool sendingEndereco = false;

  //For handling type2 Gerenciar endereco
  Future<List<EnderecoModel>> _fetchUserEndereco() async {
    final response = await http.get(
      Uri.parse(
        RotasUrl.rotaEnderecosV1 + '?userId=' + widget.userId.toString(),
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_authStore.token}',
      },
    );
    try {
      List<dynamic> _enderecos = json.decode(response.body);
      if (_enderecos[0].containsKey('endereco')) {
        List<EnderecoModel> eModel = [];
        _enderecos.forEach((e) {
          eModel.add(
            EnderecoModel(
              bairro: e['bairro'],
              cep: e['cep'],
              cidade: e['cidade'],
              complemento: e['complemento'],
              endereco: e['endereco'],
              numero: e['numero'],
              pais: e['pais'],
              uf: e['uf'],
            ),
          );
        });
        return eModel;
      }
    } catch (e) {
      print(e);
      return [];
    }
    return [];
  }

  Widget _type2Btns() {
    /*
    if (_novoEndereco) {
      return Container(
        width: 300,
        child: ElevatedButton(
          onPressed: !sendingEndereco
              ? () {
                  if (_formKey.currentState.validate()) {
                    setState(() {
                      sendingEndereco = true;
                    });
                    _formKey.currentState.save();
                    _sendEndereco().then((_data) {
                      if (!_data[0].containsKey('error')) {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 4),
                            content: Text(
                              _data[0]['message'],
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 8),
                            content: Text(
                              _data[0]['message'],
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      setState(() {
                        sendingEndereco = false;
                      });
                    });
                  }
                }
              : null,
          child: !sendingEndereco
              ? const Text(
                  'ENVIAR ENDEREÇO',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                )
              : CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                    Colors.blue,
                  ),
                ),
        ),
      );
    } else if (_atualizarEndereco) {
      return Container(
        width: sWidth,
        height: sWidth > 600 ? 100 : 180,
        child: Flex(
          mainAxisAlignment: MainAxisAlignment.center,
          direction: sWidth > 800 ? Axis.horizontal : Axis.vertical,
          children: <Widget>[
            //Atualizar
            Container(
              width: sWidth < 400 ? 200 : 300,
              child: ElevatedButton(
                onPressed: !sendingEndereco
                    ? () {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            sendingEndereco = true;
                          });
                          _formKey.currentState.save();
                          _updateEndereco().then((_data) {
                            if (!_data[0].containsKey('error')) {
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 4),
                                  content: const Text(
                                    'Endereço atualizado',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 4),
                                  content: Text(
                                    'Erro ao atualizar endereço.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                            setState(() {
                              sendingEndereco = false;
                            });
                          });
                        }
                      }
                    : null,
                child: !sendingEndereco
                    ? const Text(
                        'ATUALIZAR ENDEREÇO',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      )
                    : CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                      ),
              ),
            ),
            if (sWidth < 800)
              const SizedBox(height: 20)
            else
              const SizedBox(width: 20),
            //Deletar
            Container(
              width: sWidth < 400 ? 200 : 300,
              child: ElevatedButton(
                onPressed: true
                    ? null
                    : () {
                        //blocked the functionality
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          _deleteEndereco().then((_data) {
                            if (!_data[0].containsKey('error')) {
                              _restartInicialValues();
                              _clearInputFields();
                              _getAllData();
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 4),
                                  content: Text(
                                    _data[0]['message'],
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 8),
                                  content: Text(
                                    _data[0]['message'],
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                          });
                        }
                      },
                child: const Text(
                  'DELETAR ENDEREÇO',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    } */
  }

  Widget _selecioneEnderecoField() {
    return DropdownSearch<EnderecoModel>(
      dropdownSearchDecoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      ),
      emptyBuilder: (buildContext, string) {
        return Center(child: Text('Sem dados'));
      },
      loadingBuilder: (buildContext, string) {
        return Center(child: Text('Carregando...'));
      },
      errorBuilder: (buildContext, string, dynamic) {
        return Center(child: Text('Erro'));
      },
      onFind: (string) => _fetchUserEndereco(),
      itemAsString: (EnderecoModel e) => e.endereco,
      mode: Mode.MENU,
      label: 'Selecione endereço: *',
      onChanged: (EnderecoModel selectedEnd) {
        _endModel.bairro = selectedEnd.bairro;
        _endModel.cidade = selectedEnd.cidade;
        _endModel.complemento = selectedEnd.complemento;
        _endModel.endereco = selectedEnd.endereco;
        _endModel.uf = selectedEnd.uf;
        _endModel.pais = selectedEnd.pais;
        _endModel.numero = selectedEnd.numero;
        _endModel.cep = selectedEnd.cep;
      },
    );
  }

  Widget _enderecoField() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      height: 80,
      child: TextFormField(
        initialValue: _endModel.endereco,
        maxLength: 60,
        onSaved: (String value) {
          if (widget.enderecoType == _type1) {
            _cadastroStore.novoCad.endereco = value;
          } else {
            _endModel.endereco = value;
          }
        },
        validator: (String value) {
          return value.isEmpty ? 'Campo vazio' : null;
        },
        decoration: const InputDecoration(
          counterText: '',
          hintText: 'Endereço: *',
          labelText: 'Endereço: *',
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _numeroEComplementoField() {
    return Container(
      width: sWidth,
      height: sWidth > 600 ? 80 : 180,
      child: Flex(
        direction: sWidth > 600 ? Axis.horizontal : Axis.vertical,
        children: <Widget>[
          Expanded(
            child: Container(
              height: 80,
              child: TextFormField(
                maxLength: 10,
                onSaved: (String value) {
                  if (widget.enderecoType == _type1) {
                    _cadastroStore.novoCad.numero = value;
                  } else {
                    _endModel.numero = value;
                  }
                },
                validator: (String value) {
                  return value.isEmpty ? 'Campo vazio' : null;
                },
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                initialValue: _endModel.numero,
                decoration: InputDecoration(
                  counterText: '',
                  labelText: 'Número: *',
                  hintText: 'Número: *',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              height: 80,
              child: TextFormField(
                initialValue: _endModel.complemento,
                maxLength: 40,
                onSaved: (String value) {
                  if (widget.enderecoType == _type1) {
                    _cadastroStore.novoCad.complemento = value;
                  } else {
                    _endModel.complemento = value;
                  }
                },
                validator: (String value) {
                  return value.isEmpty ? 'Campo vazio' : null;
                },
                decoration: InputDecoration(
                  counterText: '',
                  labelText: 'Complemento: *',
                  hintText: 'Complemento: *',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bairroField() {
    return Container(
      height: 80,
      child: TextFormField(
        initialValue: _endModel.bairro,
        maxLength: 60,
        onSaved: (String value) {
          if (widget.enderecoType == _type1) {
            _cadastroStore.novoCad.bairro = value;
          } else {
            _endModel.bairro = value;
          }
        },
        validator: (String value) {
          return value.isEmpty ? 'Campo vazio' : null;
        },
        decoration: InputDecoration(
          counterText: '',
          labelText: 'Bairro: *',
          hintText: 'Bairro: *',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _cepField() {
    return Container(
      height: 80,
      child: TextFormField(
        onSaved: (String value) {
          if (widget.enderecoType == _type1) {
            _cadastroStore.novoCad.cep = value;
          } else {
            _endModel.cep = value;
          }
        },
        validator: (String value) {
          return value.isEmpty ? 'Campo vazio' : null;
        },
        maxLength: 8,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        initialValue: _endModel.cep,
        decoration: InputDecoration(
          //To hide cep length num
          counterText: '',
          labelText: 'CEP: *',
          hintText: 'CEP: *',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _paisField() {
    return Container(
      height: 80,
      child: DropdownSearch<String>(
        emptyBuilder: (buildContext, string) {
          return Center(child: Text('Sem dados'));
        },
        loadingBuilder: (buildContext, string) {
          return Center(child: Text('Carregando...'));
        },
        errorBuilder: (buildContext, string, dynamic) {
          return Center(child: Text('Erro'));
        },
        onFind: (string) {
          return _fetchCountries();
        },
        onSaved: (String value) {
          if (widget.enderecoType == _type1) {
            _cadastroStore.novoCad.pais = value;
          } else {
            _endModel.pais = value;
          }
        },
        validator: (String value) {
          return value == null || value.isEmpty ? 'Campo vazio' : null;
        },
        dropdownSearchDecoration: InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        ),
        mode: Mode.MENU,
        showSearchBox: true,
        showSelectedItem: true,
        items: [],
        label: 'País: *',
        hint: 'País: *',
        popupItemDisabled: (String s) => /*s.startsWith('I')*/ null,
        onChanged: (value) {
          //clear to force user select new uf and city
          _endModel.uf = '';
          _endModel.cidade = '';
          _endModel.pais = value;
        },
        selectedItem: _endModel.pais,
      ),
    );
  }

  Widget _ufCidadeField() {
    return Container(
      width: sWidth,
      height: sWidth > 600 ? 80 : 180,
      child: Flex(
        direction: sWidth > 600 ? Axis.horizontal : Axis.vertical,
        children: [
          //Uf
          Expanded(
            child: Container(
              height: 80,
              child: DropdownSearch<String>(
                dropdownBuilder: (buildContext, string, string2) {
                  return Text(_endModel.uf);
                },
                emptyBuilder: (buildContext, string) {
                  return Center(child: Text('Sem dados'));
                },
                loadingBuilder: (buildContext, string) {
                  return Center(child: Text('Carregando...'));
                },
                errorBuilder: (buildContext, string, dynamic) {
                  return Center(child: Text('Erro'));
                },
                onFind: (string) {
                  return _fetchStates();
                },
                onSaved: (String value) {
                  if (widget.enderecoType == _type1) {
                    _cadastroStore.novoCad.uf = value;
                  } else {
                    _endModel.uf = value;
                  }
                },
                validator: (String value) {
                  return value == null || value.isEmpty ? 'Campo vazio' : null;
                },
                dropdownSearchDecoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                ),
                mode: Mode.MENU,
                showSearchBox: true,
                showSelectedItem: true,
                items: [],
                label: 'UF: *',
                //hint: 'country in menu mode',
                popupItemDisabled: (String s) => /*s.startsWith('I')*/ null,
                onChanged: (value) async {
                  //clear to force user select new uf and city

                  _endModel.cidade = '';
                  _endModel.uf = value;
                },
                selectedItem: _endModel.uf,
              ),
            ),
          ),
          const SizedBox(width: 20),
          //cidade
          Expanded(
            child: Container(
              height: 80,
              child: DropdownSearch<String>(
                dropdownBuilder: (buildContext, string, string2) {
                  return Text(_endModel.cidade);
                },
                emptyBuilder: (buildContext, string) {
                  return Center(child: Text('Sem dados'));
                },
                loadingBuilder: (buildContext, string) {
                  return Center(child: Text('Carregando...'));
                },
                errorBuilder: (buildContext, string, dynamic) {
                  return Center(child: Text('Erro'));
                },
                onFind: (string) {
                  return _fetchCities();
                },
                onSaved: (String value) {
                  if (widget.enderecoType == _type1) {
                    _cadastroStore.novoCad.cidade = value;
                  } else {
                    _endModel.cidade = value;
                  }
                },
                validator: (String value) {
                  return value == null || value.isEmpty ? 'Campo vazio' : null;
                },
                dropdownSearchDecoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                ),
                mode: Mode.MENU,
                showSearchBox: true,
                showSelectedItem: true,
                items: [],
                label: 'Cidade: *',
                //hint: 'country in menu mode',
                popupItemDisabled: (String s) => /*s.startsWith('I')*/ null,
                onChanged: (value) {
                  _endModel.cidade = value;
                },
                selectedItem: _endModel.cidade,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //if no formkey passed from parent, then create a form as will be for editing
  Widget _type2Form() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _selecioneEnderecoField(),
          const SizedBox(height: 25),
          _enderecoField(),
          _numeroEComplementoField(),
          _bairroField(),
          _cepField(),
          _paisField(),
          _ufCidadeField(),
          //if (widget.enderecoType == _type2) _type2Btns(),
        ],
      ),
    );
  }

  Widget _type1Form() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _enderecoField(),
        _numeroEComplementoField(),
        _bairroField(),
        _cepField(),
        _paisField(),
        _ufCidadeField(),
      ],
    );
  }

  //Manage async localization data (city, state and country)

  Future<List<String>> _fetchCountries() async {
    final response = await http.get(Uri.parse(RotasUrl.rotaPaisesV1));
    List<String> countries = [];
    List<dynamic> countryData = json.decode(response.body);
    countryData.forEach((c) {
      countries.add(c['pais']);
    });
    print(countries);
    return countries;
  }

  Future<List<String>> _fetchCities() async {
    //can't fetch states if no state is selected
    if (_endModel.uf.length == 0) {
      return [];
    }
    final response = await http.get(
      Uri.parse(
        RotasUrl.rotaCidadesV1 + '?estado=' + _endModel.uf,
      ),
    );
    List<String> cities = [];
    List<dynamic> cityData = json.decode(response.body);
    cityData.forEach((c) {
      cities.add(c['cidade']);
    });

    return cities;
  }

  Future<List<String>> _fetchStates() async {
    //can't fetch states if no country is selected
    if (_endModel.pais.length == 0) {
      return [];
    }
    final response = await http.get(
      Uri.parse(
        RotasUrl.rotaEstadosV1 + '?pais=' + _endModel.pais,
      ),
    );
    List<String> states = [];
    List<dynamic> statesData = json.decode(response.body);
    statesData.forEach((c) {
      states.add(c['estado']);
    });

    return states;
  }

  @override
  void didChangeDependencies() async {
    sWidth = MediaQuery.of(context).size.width;
    _cadastroStore = Provider.of<CadastroProvider>(context);
    _authStore = Provider.of<AuthProvider>(context, listen: false);
    super.didChangeDependencies();
  }

  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: widget.formKey != null || widget.userId <= 0
          ? _type1Form()
          : _type2Form(),
    );
  }
}