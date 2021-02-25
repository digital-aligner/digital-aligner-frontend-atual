import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/dados/scrollbarWidgetConfig.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../rotas_url.dart';

class PrimeiroCadastro extends StatefulWidget {
  @override
  _PrimeiroCadastroState createState() => _PrimeiroCadastroState();
}

class _PrimeiroCadastroState extends State<PrimeiroCadastro> {
  AuthProvider _authStore;
  bool firstFetch = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ----- For flutter web scroll -------
  ScrollController _scrollController = ScrollController();

  //DateFormat formatIso = DateFormat("yyyy-MM-dd");
  DateFormat format = DateFormat("dd/MM/yyyy");

  //GET THE COUNTRY AND STATE VALUES FROM DB
  List<dynamic> _stateCountryData;

  //For ui
  List<String> _countries;
  List<String> _states;
  String _email;
  String _password;
  String _nome;
  String _sobrenome;
  String _cro_uf;
  String _endereco;
  String _complemento;
  String _bairro;
  String _cidade;
  String _uf;
  String _pais;

  String _emailConfirm;
  String _passwordConfirm;

  final _controllerDataNasc = TextEditingController();

  final _controllerCRO = TextEditingController();
  final _controllerCPF = TextEditingController();
  final _controllerNUM = TextEditingController();
  final _controllerCEP = TextEditingController();

  final _controllerTEL = TextEditingController();
  final _controllerCEL = TextEditingController();

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              Expanded(
                flex: 9,
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      child: TextFormField(
                        onSaved: (String value) {
                          _nome = value;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Por favor insira seu nome.';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Nome: *',
                          //hintText: 'Insira seu nome',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 80,
                      child: TextFormField(
                        onSaved: (String value) {
                          _sobrenome = value;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Por favor insira seu sobrenome.';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Sobrenome: *',
                          //hintText: 'Insira seu nome',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 80,
                            child: TextFormField(
                              onSaved: (String value) {
                                _controllerCPF.text = value;
                              },
                              validator: (value) {
                                if (value.length < 11) {
                                  return 'Por favor insira seu cpf';
                                }
                                return null;
                              },
                              maxLength: 11,
                              controller: _controllerCPF,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                              ],
                              initialValue: null,
                              decoration: const InputDecoration(
                                //To hide cpf length num
                                counterText: '',
                                labelText: 'CPF: *',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            height: 80,
                            child: DateTimeField(
                              onSaved: (value) {
                                _controllerDataNasc.text = value.toString();
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Por favor insira sua data de nascimento';
                                }
                                return null;
                              },
                              controller: _controllerDataNasc,
                              decoration: const InputDecoration(
                                labelText: 'Data de Nascimento: *',
                                border: const OutlineInputBorder(),
                              ),
                              format: format,
                              onShowPicker: (context, currentValue) {
                                return showDatePicker(
                                    initialEntryMode: DatePickerEntryMode.input,
                                    locale: Localizations.localeOf(context),
                                    errorFormatText: 'Escolha data válida',
                                    errorInvalidText: 'Data invalida',
                                    context: context,
                                    firstDate: DateTime(1900),
                                    initialDate: currentValue ?? DateTime.now(),
                                    lastDate: DateTime(2100));
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 80,
                            child: DropdownSearch<String>(
                              validator: (value) {
                                if (value == null) {
                                  return 'Por favor selecione CRO (UF)';
                                }
                                return null;
                              },
                              dropdownSearchDecoration: InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 10, 10, 10),
                              ),
                              mode: Mode.MENU,
                              showSearchBox: true,
                              showSelectedItem: true,
                              items: _states,
                              label: 'CRO (UF): *',
                              //hint: 'country in menu mode',
                              popupItemDisabled:
                                  (String s) => /*s.startsWith('I')*/ null,
                              onChanged: (value) {
                                _cro_uf = value;
                              },
                              selectedItem: _cro_uf,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            height: 80,
                            child: TextFormField(
                              onSaved: (String value) {
                                _controllerCRO.text = value;
                              },
                              validator: (value) {
                                if (value.length == 0) {
                                  return 'Por favor escolha CRO';
                                }
                                return null;
                              },
                              controller: _controllerCRO,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                              ],
                              initialValue: null,
                              decoration: InputDecoration(
                                labelText: 'CRO (Número): *',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 1),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
                      height: 80,
                      child: TextFormField(
                        onSaved: (String value) {
                          _endereco = value;
                        },
                        validator: (value) {
                          if (value.length == 0) {
                            return 'Por favor insira seu endereço';
                          }
                          return null;
                        },
                        initialValue: null,
                        decoration: const InputDecoration(
                          labelText: 'Endereço: *',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 80,
                            child: TextFormField(
                              onSaved: (String value) {
                                _controllerNUM.text = value;
                              },
                              validator: (value) {
                                if (value.length == 0) {
                                  return 'Por favor insira o número';
                                }
                                return null;
                              },
                              controller: _controllerNUM,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                              ],
                              initialValue: null,
                              decoration: InputDecoration(
                                labelText: 'Número: *',
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
                              onSaved: (String value) {
                                _complemento = value;
                              },
                              validator: (value) {
                                if (value.length == 0) {
                                  return 'Por favor insira o complemento';
                                }
                                return null;
                              },
                              initialValue: null,
                              decoration: InputDecoration(
                                labelText: 'Complemento: *',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 80,
                      child: TextFormField(
                        onSaved: (String value) {
                          _bairro = value;
                        },
                        validator: (value) {
                          if (value.length == 0) {
                            return 'Por favor insira seu bairro';
                          }
                          return null;
                        },
                        initialValue: null,
                        decoration: InputDecoration(
                          labelText: 'Bairro: *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 80,
                      child: TextFormField(
                        onSaved: (String value) {
                          _controllerCEP.text = value;
                        },
                        validator: (value) {
                          if (value.length == 0) {
                            return 'Por favor insira seu CEP';
                          }
                          return null;
                        },
                        maxLength: 8,
                        controller: _controllerCEP,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        initialValue: null,
                        decoration: InputDecoration(
                          //To hide cep length num
                          counterText: '',
                          labelText: 'CEP: *',

                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 80,
                      child: DropdownSearch<String>(
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor escolha um pais';
                          }
                          return null;
                        },
                        dropdownSearchDecoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        ),
                        mode: Mode.MENU,
                        showSearchBox: true,
                        showSelectedItem: true,
                        items: _countries,
                        label: 'País: *',
                        //hint: 'country in menu mode',
                        popupItemDisabled:
                            (String s) => /*s.startsWith('I')*/ null,
                        onChanged: (value) {
                          setState(() {
                            _pais = value;
                            _states = _authStore.mapCountryToStatesToUiList(
                              local: _stateCountryData,
                              selectedCountry: _pais,
                            );
                          });
                        },
                        selectedItem: _pais,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 80,
                            child: DropdownSearch<String>(
                              validator: (value) {
                                if (value == null) {
                                  return 'Por favor escolha uf';
                                }
                                return null;
                              },
                              dropdownSearchDecoration: InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 10, 10, 10),
                              ),
                              mode: Mode.MENU,
                              showSearchBox: true,
                              showSelectedItem: true,
                              items: _states,
                              label: 'UF: *',
                              //hint: 'country in menu mode',
                              popupItemDisabled:
                                  (String s) => /*s.startsWith('I')*/ null,
                              onChanged: (value) {
                                _uf = value;
                              },
                              selectedItem: _uf,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            height: 80,
                            child: TextFormField(
                              onSaved: (String value) {
                                _cidade = value;
                              },
                              validator: (value) {
                                if (value.length == 0) {
                                  return 'Por favor insira sua cidade';
                                }
                                return null;
                              },
                              initialValue: null,
                              decoration: InputDecoration(
                                labelText: 'Cidade: *',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 1),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
                            height: 80,
                            child: TextFormField(
                              onSaved: (String value) {
                                _controllerTEL.text = value;
                              },
                              validator: (value) {
                                if (value.length == 0) {
                                  return 'Por favor insira seu número de telefone';
                                }
                                return null;
                              },
                              maxLength: 10,
                              controller: _controllerTEL,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                              ],
                              initialValue: null,
                              onChanged: (value) {
                                //_loginStore.setEmail(value);
                              },
                              decoration: InputDecoration(
                                //To hide cep length num
                                counterText: '',
                                labelText: 'Telefone Fixo (Comercial): *',
                                //hintText: 'Insira seu nome',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
                            height: 80,
                            child: TextFormField(
                              onSaved: (String value) {
                                _controllerCEL.text = value;
                              },
                              validator: (value) {
                                if (value.length == 0) {
                                  return 'Por favor insira seu número de celular';
                                }
                                return null;
                              },
                              maxLength: 11,
                              controller: _controllerCEL,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                              ],
                              initialValue: null,
                              onChanged: (value) {
                                //_loginStore.setEmail(value);
                              },
                              decoration: InputDecoration(
                                //To hide cep length num
                                counterText: '',
                                labelText: 'Celular (Whatsapp): *',
                                //hintText: 'Insira seu nome',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 1),
                    Row(
                      children: [
                        //Email
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
                            height: 80,
                            child: TextFormField(
                              onSaved: (String value) {
                                _email = value;
                              },
                              validator: (value) {
                                if (value.length == 0) {
                                  return 'Por favor insira seu email';
                                }
                                if (value != _emailConfirm) {
                                  return 'Emails não correspondem';
                                }
                                return null;
                              },
                              initialValue: null,
                              decoration: InputDecoration(
                                labelText: 'Email: *',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        //Confirm email
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
                            height: 80,
                            child: TextFormField(
                              onChanged: (String value) {
                                _emailConfirm = value;
                              },
                              validator: (value) {
                                if (value.length == 0) {
                                  return 'Por favor confirme seu email';
                                }
                                return null;
                              },
                              initialValue: null,
                              decoration: InputDecoration(
                                labelText: 'Confirme seu email.',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        //password
                        Expanded(
                          child: Container(
                            height: 80,
                            child: TextFormField(
                              obscureText: true,
                              onSaved: (String value) {
                                _password = value;
                              },
                              validator: (value) {
                                if (value.length == 0) {
                                  return 'Por favor insira sua senha';
                                }
                                if (value != _passwordConfirm) {
                                  return 'Senhas não correspondem';
                                }
                                return null;
                              },
                              initialValue: null,
                              decoration: InputDecoration(
                                labelText: 'Senha: *',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        //password confirm
                        Expanded(
                          child: Container(
                            height: 80,
                            child: TextFormField(
                              obscureText: true,
                              onChanged: (String value) {
                                _passwordConfirm = value;
                              },
                              validator: (value) {
                                if (value.length == 0) {
                                  return 'Por favor confirme sua senha';
                                }
                                return null;
                              },
                              initialValue: null,
                              decoration: InputDecoration(
                                labelText: 'Confirme sua senha.',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 300,
          child: ElevatedButton(
            child: const Text(
              'ENVIAR INFORMAÇÕES',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                _enviarCadastro().then((data) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 3),
                      content: Text(
                        data['message'],
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                  if (data['statusCode'] == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 8),
                        content: Text(
                          data[
                              'Seu cadastro está sendo averiguado e será aprovado em até 48h.'],
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  }
                });
              }
            },
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Container(
          width: 300,
          child: ElevatedButton(
            child: const Text(
              'CANCELAR',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }

  Future<Map> _enviarCadastro() async {
    Map<String, dynamic> _cadastro = {
      'bairro': _bairro,
      'celular': _controllerCEL.text,
      'cep': _controllerCEP.text,
      'cidade': _cidade,
      'complemento': _complemento,
      'cro_num': _controllerCRO.text,
      'cro_uf': _cro_uf,
      'data_nasc': _controllerDataNasc.text,
      'email': _email,
      'endereco': _endereco,
      'nome': _nome,
      'numero': _controllerNUM.text,
      'sobrenome': _sobrenome,
      'telefone': _controllerTEL.text,
      'uf': _uf,
      'pais': _pais,
      'username': _controllerCPF.text,
      'password': _password,
    };

    //Changing iso string to local (just for input view)
    DateTime dataNasc = DateTime.parse(_controllerDataNasc.text).toLocal();
    _controllerDataNasc.text =
        DateFormat('dd/MM/yyyy').format(dataNasc).toString();

    var _response = await http.post(
      RotasUrl.rotaCadastro,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(_cadastro),
    );

    Map data = json.decode(_response.body);

    return data;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (firstFetch) {
      _authStore = Provider.of<AuthProvider>(context, listen: false);
      //GET THE COUNTRY AND STATE VALUES FROM DB
      _stateCountryData = await _authStore.getCountryAndStateData();
      //Map countries to ui
      _countries = _authStore.mapCountriesDataToUiList(_stateCountryData);
      //Map initial states (will be null to fetch pt-br)
      _states = _authStore.mapCountryToStatesToUiList(
        local: _stateCountryData,
        selectedCountry: _pais,
      );
      firstFetch = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controllerCRO.dispose();
    _controllerCPF.dispose();
    _controllerNUM.dispose();
    _controllerCEP.dispose();

    _controllerTEL.dispose();
    _controllerCEL.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SecondaryAppbar(),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: DraggableScrollbar.rrect(
          heightScrollThumb: ScrollBarWidgetConfig.scrollBarHeight,
          backgroundColor: ScrollBarWidgetConfig.color,
          alwaysVisibleScrollThumb: true,
          controller: _scrollController,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: 1,
            itemExtent: null,
            itemBuilder: (context, index2) {
              return Column(
                children: <Widget>[
                  if (firstFetch && _stateCountryData == null)
                    Column(
                      children: [
                        const SizedBox(height: 50),
                        CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  if (!firstFetch && _stateCountryData != null)
                    Column(
                      children: <Widget>[
                        const SizedBox(height: 50),
                        //HEADLINE TEXT
                        Center(
                          child: const Text(
                            'CADASTRO',
                            style: const TextStyle(
                              color: Colors.indigo,
                              fontSize: 50,
                              fontFamily: 'BigNoodleTitling',
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                        _form(),
                        const SizedBox(height: 50),
                        _buttons(),
                        const SizedBox(height: 50),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}