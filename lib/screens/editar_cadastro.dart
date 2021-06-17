import 'dart:convert';

import 'package:digital_aligner_app/dados/models/cadastro/aprovacao_usuario_model.dart';
import 'package:digital_aligner_app/dados/models/cadastro/onboarding_model.dart';
import 'package:digital_aligner_app/dados/models/cadastro/representante_model.dart';
import 'package:digital_aligner_app/dados/models/cadastro/role_model.dart';

import '../rotas_url.dart';

import '../dados/models/cadastro/cadastro_model.dart';

import '../providers/cadastro_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
//import '../dados/state.dart';

import 'login_screen.dart';
import '../appbar/SecondaryAppbar.dart';

import '../widgets/endereco_v1/endereco_v1.dart';

import 'package:http/http.dart' as http;

class EditarCadastro extends StatefulWidget {
  static const routeName = '/editar-cadastro';

  @override
  _EditarCadastroState createState() => _EditarCadastroState();
}

class _EditarCadastroState extends State<EditarCadastro> {
  bool _firstFetch = true;
  bool _sendingCadastro = false;

  final _formKey = GlobalKey<FormState>();

  final _controllerDataNasc = TextEditingController();

  final _controllerCRO = TextEditingController();
  final _controllerCPF = TextEditingController();
  final _controllerNUM = TextEditingController();
  final _controllerCEP = TextEditingController();

  final _controllerTEL = TextEditingController();
  final _controllerCEL = TextEditingController();

  //Formating date to iso standard. Manditory to store date in db.
  DateFormat format = DateFormat("dd/MM/yyyy");

  String _formatCpf(String cpf) {
    String _formatedCpf = cpf.substring(0, 3) +
        '.' +
        cpf.substring(3, 6) +
        '.' +
        cpf.substring(6, 9) +
        '-' +
        cpf.substring(9, 11);
    return _formatedCpf;
  }

  String _getCpfFromSelectedValue(String value) {
    String onlyCpf = value.substring(value.indexOf('|') + 1, value.length);
    String removeCpfSpace = onlyCpf.replaceAll(' ', '');
    String removeCpfDots = removeCpfSpace.replaceAll('.', '');
    String removeCpfDash = removeCpfDots.replaceAll('-', '');

    return removeCpfDash;
  }

  void dispose() {
    _controllerCRO.dispose();
    _controllerCPF.dispose();
    _controllerNUM.dispose();
    _controllerCEP.dispose();

    _controllerTEL.dispose();
    _controllerCEL.dispose();
    super.dispose();
  }

  late AuthProvider authStore;
  late CadastroProvider cadastroStore;
  CadastroModel? sc;

  //Representantes data list
  List<dynamic> _representantes = [];

  //onboarding data list
  List<dynamic> _onboardings = [];

  Future<List<String>> _fetchStates() async {
    final response = await http.get(
      Uri.parse(
        RotasUrl.rotaEstadosV1 + '?pais=Brasil',
      ),
    );
    List<String> states = [];
    List<dynamic> statesData = json.decode(response.body);
    statesData.forEach((c) {
      states.add(c['estado']);
    });
    return states;
  }

  Future<List<dynamic>> fetchRepresentantes() async {
    //Fetch cadistas if last fetch was with error
    if (_representantes.isNotEmpty &&
        !_representantes[0].containsKey('error')) {
      return _representantes;
    }
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${authStore.token}',
    };

    try {
      final response = await http.get(
        Uri.parse(RotasUrl.rotaRepresentantes),
        headers: requestHeaders,
      );
      _representantes = json.decode(response.body);
    } catch (error) {
      print(error.toString());
    }
    return _representantes;
  }

  Future<List<dynamic>> fetchOnboarding() async {
    //Fetch onboarding if last fetch was with error
    if (_onboardings.isNotEmpty & !_onboardings[0].containsKey('error')) {
      return _onboardings;
    }
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${authStore.token}',
    };

    try {
      final response = await http.get(
        Uri.parse(RotasUrl.rotaOnboardings),
        headers: requestHeaders,
      );
      _onboardings = json.decode(response.body);
    } catch (error) {
      print(error.toString());
    }
    return _onboardings;
  }

  @override
  Widget build(BuildContext context) {
    cadastroStore = Provider.of<CadastroProvider>(context);
    authStore = Provider.of<AuthProvider>(context);

    //to prevent errors on null (will be null on direct url access)
    if (cadastroStore.selectedCad() == null) {
      sc = CadastroModel(
        role: RoleModel(),
        aprovacao_usuario: AprovacaoUsuarioModel(),
      );
    } else {
      if (_firstFetch) {
        //Selected cadastro
        sc = cadastroStore.selectedCad();

        DateTime d = DateTime.parse(sc!.data_nasc);

        //Inserting data onto fields
        _controllerDataNasc.text = DateFormat('dd/MM/yyyy').format(d);

        _controllerCRO.text = sc!.cro_num;
        _controllerCPF.text = sc!.usernameCpf;

        _controllerTEL.text = sc!.telefone;
        _controllerCEL.text = sc!.celular;
      }
    }

    //Direct acess to url, pop page to remove duplicate.
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (sc!.id == 0) {
        Navigator.pop(context);
      }
      _firstFetch = false;
    });

    if (!authStore.isAuth) {
      return LoginScreen();
    }

    final double sWidth = MediaQuery.of(context).size.width;
    final double sHeight = MediaQuery.of(context).size.height;

    //Some verification of the current country of the user

    //_mapCountryToStateValues(sc.pais);

    return Scaffold(
      appBar: SecondaryAppbar(),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
          width: sWidth,
          height: sHeight,
          child: RawScrollbar(
              thumbColor: Colors.grey,
              thickness: 15,
              isAlwaysShown: true,
              child: SingleChildScrollView(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(),
                    ),
                    Expanded(
                      flex: 9,
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 60),
                          Center(
                            child: Text(
                              'CADASTRO',
                              style: const TextStyle(
                                color: Colors.indigo,
                                fontSize: 50,
                                fontFamily: 'BigNoodleTitling',
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                          Container(
                            width: sWidth,
                            //height: 2040,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  //nome
                                  Container(
                                    height: 80,
                                    child: TextFormField(
                                      maxLength: 29,
                                      initialValue: sc!.nome,
                                      onSaved: (String? value) {
                                        sc!.nome = value ?? '';
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Por favor insira seu nome.';
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Nome: *',
                                        counterText: '',
                                        //hintText: 'Insira seu nome',
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  //sobrenome
                                  Container(
                                    height: 80,
                                    child: TextFormField(
                                      maxLength: 29,
                                      initialValue: sc!.sobrenome,
                                      onSaved: (String? value) {
                                        sc!.sobrenome = value ?? '';
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Por favor insira seu sobrenome.';
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                        counterText: '',
                                        labelText: 'Sobrenome: *',
                                        //hintText: 'Insira seu nome',
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    width: sWidth,
                                    height: sWidth > 600 ? 80 : 180,
                                    child: Flex(
                                      direction: sWidth > 600
                                          ? Axis.horizontal
                                          : Axis.vertical,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 80,
                                            child: TextFormField(
                                              onSaved: (String? value) {
                                                sc!.usernameCpf = value ?? '';
                                              },
                                              enabled: false,
                                              validator: (value) {
                                                if (value!.length < 11) {
                                                  return 'Por favor insira seu cpf';
                                                }
                                                return null;
                                              },
                                              maxLength: 11,
                                              controller: _controllerCPF,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(r'[0-9]')),
                                              ],
                                              decoration: const InputDecoration(
                                                //To hide cpf length num
                                                counterText: '',
                                                labelText: 'CPF: *',
                                                border:
                                                    const OutlineInputBorder(),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Container(
                                            height: 80,
                                            child: DateTimeField(
                                              onSaved: (DateTime? value) {
                                                //If doesnt change date value, its null.
                                                //Send date loaded in controller
                                                if (value != null) {
                                                  sc!.data_nasc =
                                                      value.toIso8601String();
                                                }
                                              },
                                              controller: _controllerDataNasc,
                                              decoration: const InputDecoration(
                                                labelText:
                                                    'Data de Nascimento: *',
                                                border:
                                                    const OutlineInputBorder(),
                                              ),
                                              format: format,
                                              onShowPicker:
                                                  (context, currentValue) {
                                                return showDatePicker(
                                                    initialEntryMode:
                                                        DatePickerEntryMode
                                                            .input,
                                                    locale:
                                                        Localizations.localeOf(
                                                            context),
                                                    errorFormatText:
                                                        'Escolha data válida',
                                                    errorInvalidText:
                                                        'Data invalida',
                                                    context: context,
                                                    firstDate: DateTime(1900),
                                                    initialDate: currentValue ??
                                                        DateTime.now(),
                                                    lastDate: DateTime(2100));
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  //cro uf
                                  Container(
                                    height: 80,
                                    child: DropdownSearch<String>(
                                      dropdownBuilder:
                                          (buildContext, string, string2) {
                                        return Text(sc!.cro_uf);
                                      },
                                      emptyBuilder: (buildContext, string) {
                                        return Center(child: Text('Sem dados'));
                                      },
                                      loadingBuilder: (buildContext, string) {
                                        return Center(
                                            child: Text('Carregando...'));
                                      },
                                      errorBuilder:
                                          (buildContext, string, dynamic) {
                                        return Center(child: Text('Erro'));
                                      },
                                      onFind: (string) {
                                        return _fetchStates();
                                      },
                                      onSaved: (String? value) {
                                        sc!.cro_uf = value ?? '';
                                      },
                                      onChanged: (String? value) {
                                        sc!.cro_uf = value ?? '';
                                      },
                                      validator: (String? value) {
                                        return value == null || value.isEmpty
                                            ? 'Campo vazio'
                                            : null;
                                      },
                                      dropdownSearchDecoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        contentPadding:
                                            EdgeInsets.fromLTRB(10, 10, 10, 10),
                                      ),
                                      mode: Mode.MENU,
                                      showSearchBox: true,
                                      showSelectedItem: true,
                                      label: 'CRO (UF): *',
                                      selectedItem: sc!.cro_uf,
                                    ),
                                  ),

                                  const SizedBox(height: 10),
                                  //cro número
                                  Container(
                                    height: 80,
                                    child: TextFormField(
                                      maxLength: 30,
                                      onSaved: (String? value) {
                                        sc!.cro_num = value ?? '';
                                      },
                                      controller: _controllerCRO,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9]')),
                                      ],
                                      initialValue: null,
                                      decoration: InputDecoration(
                                        counterText: '',
                                        labelText: 'CRO (Número): *',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  //representante
                                  if (authStore.role != 'Credenciado' &&
                                      sc!.id != authStore.id)
                                    DropdownSearch<String>(
                                      label: 'Representante:',
                                      errorBuilder:
                                          (context, searchEntry, exception) {
                                        return Center(
                                            child: const Text(
                                                'Algum erro ocorreu.'));
                                      },
                                      emptyBuilder: (context, searchEntry) {
                                        return Center(
                                            child: const Text('Nada'));
                                      },
                                      loadingBuilder: (context, searchEntry) {
                                        return Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                new AlwaysStoppedAnimation<
                                                    Color>(
                                              Colors.blue,
                                            ),
                                          ),
                                        );
                                      },
                                      onFind: (_) async {
                                        await fetchRepresentantes();
                                        //Error handling
                                        if (_representantes[0]
                                            .containsKey('error')) {
                                          if (_representantes[0]
                                                  ['statusCode'] !=
                                              404) {
                                            //Will go to errorBuilder
                                            throw Error();
                                          } else {
                                            //Will go to emptyBuilder
                                            return [];
                                          }
                                        }
                                        List<String> _repUi = [];
                                        for (var _representante
                                            in _representantes) {
                                          _repUi.add(
                                            _representante['nome'] +
                                                ' ' +
                                                _representante['sobrenome'] +
                                                ' | ' +
                                                _formatCpf(
                                                    _representante['username']),
                                          );
                                        }
                                        return _repUi;
                                      },
                                      dropdownSearchDecoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        contentPadding:
                                            EdgeInsets.fromLTRB(10, 10, 10, 10),
                                      ),
                                      maxHeight: 350,
                                      mode: Mode.MENU,
                                      showSearchBox: true,
                                      showSelectedItem: true,
                                      onChanged: (value) {
                                        String _selectedCpf =
                                            _getCpfFromSelectedValue(
                                                value ?? '');
                                        //Match with list of representantes cpf
                                        for (var _representante
                                            in _representantes) {
                                          if (_representante['username'] ==
                                              _selectedCpf) {
                                            sc!.representante =
                                                RepresentanteModel.fromJson(
                                              _representante,
                                            );
                                          }
                                        }
                                      },
                                      selectedItem: sc!.representante!.id == -1
                                          ? 'selecione um representante'
                                          : sc!.representante!.nome +
                                              ' ' +
                                              sc!.representante!.sobrenome +
                                              ' | ' +
                                              _formatCpf(
                                                sc!.representante!.usernameCpf,
                                              ),
                                    ),
                                  if (authStore.role != 'Credenciado')
                                    const SizedBox(height: 40),
                                  //onboarding
                                  if (authStore.role != 'Credenciado' &&
                                      sc!.id != authStore.id)
                                    DropdownSearch<String>(
                                      label: 'Onboarding:',
                                      errorBuilder:
                                          (context, searchEntry, exception) {
                                        return Center(
                                          child:
                                              const Text('Algum erro ocorreu.'),
                                        );
                                      },
                                      emptyBuilder: (context, searchEntry) {
                                        return Center(
                                            child: const Text('Nada'));
                                      },
                                      loadingBuilder: (context, searchEntry) {
                                        return Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                new AlwaysStoppedAnimation<
                                                    Color>(
                                              Colors.blue,
                                            ),
                                          ),
                                        );
                                      },
                                      onFind: (_) async {
                                        await fetchOnboarding();

                                        //Error handling
                                        if (_onboardings[0]
                                            .containsKey('error')) {
                                          if (_onboardings[0]['statusCode'] !=
                                              404) {
                                            //Will go to errorBuilder
                                            throw Error();
                                          } else {
                                            //Will go to emptyBuilder
                                            return [];
                                          }
                                        }
                                        List<String> _onboardingUi = [];
                                        for (var _onboarding in _onboardings) {
                                          _onboardingUi.add(
                                            _onboarding['onboarding'],
                                          );
                                        }
                                        return _onboardingUi;
                                      },
                                      dropdownSearchDecoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        contentPadding:
                                            EdgeInsets.fromLTRB(10, 10, 10, 10),
                                      ),
                                      maxHeight: 350,
                                      mode: Mode.MENU,
                                      showSearchBox: true,
                                      showSelectedItem: true,
                                      //items: _enderecoUiList,
                                      //label: 'UF: *',
                                      //hint: 'UF: *',
                                      onChanged: (value) {
                                        //Match with list of representantes cpf
                                        for (var _onboarding in _onboardings) {
                                          if (_onboarding['onboarding'] ==
                                              value) {
                                            sc!.onboarding =
                                                OnboardingModel.fromJson(
                                              _onboarding,
                                            );
                                          }
                                        }
                                      },
                                      selectedItem: sc!.onboarding!.id == -1
                                          ? 'Selecionar qual onboarding participou'
                                          : sc!.onboarding!.onboarding,
                                    ),

                                  const Divider(
                                    height: 75,
                                    thickness: 1,
                                  ),
                                  Container(
                                    width: sWidth,
                                    height: sWidth > 600 ? 80 : 180,
                                    child: Flex(
                                      direction: sWidth > 600
                                          ? Axis.horizontal
                                          : Axis.vertical,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            margin: EdgeInsets.fromLTRB(
                                                0, 25, 0, 0),
                                            height: 80,
                                            child: TextFormField(
                                              onSaved: (String? value) {
                                                sc!.telefone = value ?? '';
                                              },
                                              maxLength: 10,
                                              controller: _controllerTEL,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(r'[0-9]')),
                                              ],
                                              initialValue: null,
                                              onChanged: (value) {
                                                //_loginStore.setEmail(value);
                                              },
                                              decoration: InputDecoration(
                                                //To hide cep length num
                                                counterText: '',
                                                labelText:
                                                    'Telefone Fixo (Comercial): *',
                                                //hintText: 'Insira seu nome',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Container(
                                            margin: EdgeInsets.fromLTRB(
                                                0, 25, 0, 0),
                                            height: 80,
                                            child: TextFormField(
                                              onSaved: (String? value) {
                                                sc!.celular = value ?? '';
                                              },
                                              maxLength: 11,
                                              controller: _controllerCEL,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(r'[0-9]')),
                                              ],
                                              initialValue: null,
                                              onChanged: (value) {
                                                //_loginStore.setEmail(value);
                                              },
                                              decoration: InputDecoration(
                                                //To hide cep length num
                                                counterText: '',
                                                labelText:
                                                    'Celular (Whatsapp): *',
                                                //hintText: 'Insira seu nome',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(
                                    height: 75,
                                    thickness: 1,
                                  ),
                                  const Text(
                                    'GERENCIAR ENDEREÇOS',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Endereco(
                                    enderecoType: 'gerenciar endereco',
                                    userId: sc!.id,
                                  ),
                                  const SizedBox(height: 40),
                                  //Aprovação de Usuário
                                  if (_firstFetch &&
                                      authStore.role != 'Credenciado' &&
                                      sc!.id != authStore.id)
                                    Container(
                                      height: 80,
                                      child: FutureBuilder(
                                        future:
                                            cadastroStore.getAprovacaoTable(),
                                        builder: (ctx, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            return DropdownSearch<String>(
                                              onSaved: (String? value) {
                                                cadastroStore
                                                    .handleAprovRelation(
                                                        value ?? '');
                                              },
                                              dropdownSearchDecoration:
                                                  InputDecoration(
                                                border: OutlineInputBorder(),
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        10, 10, 10, 10),
                                              ),
                                              mode: Mode.MENU,
                                              showSearchBox: false,
                                              showSelectedItem: true,
                                              items:
                                                  snapshot.data as List<String>,
                                              label: 'Aprovação do Usuário: *',
                                              onChanged: print,
                                              selectedItem:
                                                  sc!.aprovacao_usuario!.status,
                                            );
                                          } else {
                                            return Center(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    new AlwaysStoppedAnimation<
                                                        Color>(Colors.blue),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  if (!_firstFetch &&
                                      authStore.role != 'Credenciado' &&
                                      sc!.id != authStore.id)
                                    Container(
                                      height: 80,
                                      child: DropdownSearch<String>(
                                          onSaved: (String? value) {
                                            cadastroStore.handleAprovRelation(
                                                value ?? '');
                                          },
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.fromLTRB(
                                                10, 10, 10, 10),
                                          ),
                                          mode: Mode.MENU,
                                          showSearchBox: false,
                                          showSelectedItem: true,
                                          items:
                                              cadastroStore.getAprovTableList(),
                                          label: 'Aprovação do Usuário: *',
                                          onChanged: print,
                                          selectedItem:
                                              sc!.aprovacao_usuario!.status),
                                    ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                          Center(
                            child: Builder(
                              builder: (ctx) => Container(
                                width: 300,
                                child: ElevatedButton(
                                  child: !_sendingCadastro
                                      ? const Text(
                                          'ATUALIZAR',
                                        )
                                      : CircularProgressIndicator(
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                            Colors.blue,
                                          ),
                                        ),
                                  onPressed: !_sendingCadastro
                                      ? () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _formKey.currentState!.save();
                                            setState(() {
                                              _sendingCadastro = true;
                                            });
                                            cadastroStore.enviarCadastro().then(
                                              (data) {
                                                if (data.containsKey('error')) {
                                                  ScaffoldMessenger.of(context)
                                                      .removeCurrentSnackBar();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      duration: const Duration(
                                                          seconds: 3),
                                                      content: Text(
                                                          'Erro ao atualizar cadastro'),
                                                    ),
                                                  );
                                                } else {
                                                  Navigator.pop(context, true);
                                                  ScaffoldMessenger.of(context)
                                                      .removeCurrentSnackBar();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      duration: const Duration(
                                                          seconds: 3),
                                                      content: Text(
                                                          'Cadastro atualizado!'),
                                                    ),
                                                  );
                                                }
                                                setState(() {
                                                  _sendingCadastro = false;
                                                });
                                              },
                                            );
                                          }
                                        }
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
