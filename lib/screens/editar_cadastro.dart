import 'package:digital_aligner_app/dados/models/cadastro/aprovacao_usuario_model.dart';
import 'package:digital_aligner_app/dados/models/cadastro/role_model.dart';
import 'package:digital_aligner_app/dados/scrollbarWidgetConfig.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

import '../dados/country.dart';
import '../widgets/gerenciar_endereco.dart';

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

class EditarCadastro extends StatefulWidget {
  static const routeName = '/editar-cadastro';

  @override
  _EditarCadastroState createState() => _EditarCadastroState();
}

class _EditarCadastroState extends State<EditarCadastro> {
  bool _firstFetch = true;

  // ----- For flutter web scroll -------
  ScrollController _scrollController = ScrollController();
  // ---- For flutter web scroll end ---

  final _formKey = GlobalKey<FormState>();

  final _controllerDataNasc = TextEditingController();

  final _controllerCRO = TextEditingController();
  final _controllerCPF = TextEditingController();
  final _controllerNUM = TextEditingController();
  final _controllerCEP = TextEditingController();

  final _controllerTEL = TextEditingController();
  final _controllerCEL = TextEditingController();

  //Formating date to iso standard. Manditory to store date in db.
  DateFormat format = DateFormat("yyyy-MM-dd");

  void dispose() {
    _controllerCRO.dispose();
    _controllerCPF.dispose();
    _controllerNUM.dispose();
    _controllerCEP.dispose();

    _controllerTEL.dispose();
    _controllerCEL.dispose();
    super.dispose();
  }

  AuthProvider authStore;
  CadastroProvider cadastroStore;
  CadastroModel sc;
  /*
  _mapCountryToStateValues(_currentCountry) {
    if (_currentCountry == 'Brasil') {
      _state = STATE.st_br;
    } else if (_currentCountry == 'Portugal') {
      _state = STATE.st_pt;
    }
  }
  */
  //For country json mapping
  //final _country = COUNTRY.country;
  //Depends on country
  List<String> _state;

  @override
  Widget build(BuildContext context) {
    cadastroStore = Provider.of<CadastroProvider>(context);
    authStore = Provider.of<AuthProvider>(context);

    //to prevent errors on null (will be null on direct url access)
    if (cadastroStore.selectedCad() == null) {
      sc = CadastroModel();
      sc.usernameCpf = '';
      sc.email = '';
      sc.blocked = true;
      sc.role = RoleModel();
      sc.nome = '';
      sc.sobrenome = '';
      sc.cro_uf = '';
      sc.cro_num = '';
      sc.data_nasc = '';
      sc.telefone = '';
      sc.celular = '';
      sc.aprovacao_usuario = AprovacaoUsuarioModel();
      sc.aprovacao_usuario.status = '';
    } else {
      //Selected cadastro
      sc = cadastroStore.selectedCad();

      //Inserting data onto fields
      _controllerDataNasc.text = sc.data_nasc;

      _controllerCRO.text = sc.cro_num;
      _controllerCPF.text = sc.usernameCpf;

      _controllerTEL.text = sc.telefone;
      _controllerCEL.text = sc.celular;
    }

    //Direct acess to url, pop page to remove duplicate.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (sc.id == null) {
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[100]],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
          ),
          child: DraggableScrollbar.rrect(
            heightScrollThumb: ScrollBarWidgetConfig.scrollBarHeight,
            backgroundColor: ScrollBarWidgetConfig.color,
            alwaysVisibleScrollThumb: true,
            controller: _scrollController,
            child: ListView.builder(
                controller: _scrollController,
                itemCount: 1, // To load full row (will prevent state loss)
                itemExtent: null,
                itemBuilder: (context, index) {
                  return Row(
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
                                    Container(
                                      height: 80,
                                      child: TextFormField(
                                        initialValue: sc.nome,
                                        onSaved: (String value) {
                                          sc.nome = value;
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
                                        initialValue: sc.sobrenome,
                                        onSaved: (String value) {
                                          sc.sobrenome = value;
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
                                                sc.usernameCpf = value;
                                              },
                                              enabled: false,
                                              validator: (value) {
                                                if (value.length < 11) {
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
                                              onSaved: (DateTime value) {
                                                //If doesnt change date value, its null.
                                                //Send date loaded in controller
                                                if (value == null) {
                                                  sc.data_nasc =
                                                      _controllerDataNasc.text;
                                                } else {
                                                  sc.data_nasc =
                                                      value.toString();
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
                                    const SizedBox(height: 10),
                                    Container(
                                      height: 80,
                                      child: DropdownSearch<String>(
                                          onSaved: (String value) {
                                            sc.cro_uf = value;
                                          },
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.fromLTRB(
                                                10, 10, 10, 10),
                                          ),
                                          mode: Mode.MENU,
                                          showSearchBox: true,
                                          showSelectedItem: true,
                                          items: _state,
                                          label: 'CRO (UF): *',
                                          //hint: 'country in menu mode',
                                          popupItemDisabled: (String
                                              s) => /*s.startsWith('I')*/ null,
                                          onChanged: (value) {},
                                          selectedItem: sc.cro_uf),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      height: 80,
                                      child: TextFormField(
                                        onSaved: (String value) {
                                          sc.cro_num = value;
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
                                    const Divider(
                                      height: 75,
                                      thickness: 1,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            margin: EdgeInsets.fromLTRB(
                                                0, 25, 0, 0),
                                            height: 80,
                                            child: TextFormField(
                                              onSaved: (String value) {
                                                sc.telefone = value;
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
                                              onSaved: (String value) {
                                                sc.celular = value;
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
                                    const Divider(
                                      height: 75,
                                      thickness: 1,
                                    ),
                                    const Text(
                                      'GERENCIAR ENDEREÇOS',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    GerenciarEndereco(
                                      idUsuario: sc.id,
                                    ),
                                    const SizedBox(height: 40),
                                    //Aprovação de Usuário
                                    if (_firstFetch &&
                                        authStore.role == 'Administrador')
                                      Container(
                                        height: 80,
                                        child: FutureBuilder(
                                          future:
                                              cadastroStore.getAprovacaoTable(),
                                          builder: (ctx, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {
                                              return DropdownSearch<String>(
                                                onSaved: (String value) {
                                                  cadastroStore
                                                      .handleAprovRelation(
                                                          value);
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
                                                items: snapshot.data,
                                                label:
                                                    'Aprovação do Usuário: *',
                                                popupItemDisabled: (String
                                                    s) => /*s.startsWith('I')*/ null,
                                                onChanged: print,
                                                selectedItem:
                                                    sc.aprovacao_usuario.status,
                                              );
                                            } else {
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      new AlwaysStoppedAnimation<
                                                          Color>(Colors.blue),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    if (!_firstFetch)
                                      Container(
                                        height: 80,
                                        child: DropdownSearch<String>(
                                            onSaved: (String value) {
                                              cadastroStore
                                                  .handleAprovRelation(value);
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
                                            items: cadastroStore
                                                    .getAprovTableList() ??
                                                [''],
                                            label: 'Aprovação do Usuário: *',
                                            popupItemDisabled: (String
                                                s) => /*s.startsWith('I')*/ null,
                                            onChanged: print,
                                            selectedItem:
                                                sc.aprovacao_usuario.status),
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
                                    child: const Text(
                                      'ATUALIZAR',
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState.validate()) {
                                        _formKey.currentState.save();

                                        cadastroStore.enviarCadastro().then(
                                          (data) {
                                            if (data.containsKey('error')) {
                                              ScaffoldMessenger.of(context)
                                                  .removeCurrentSnackBar();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  duration: const Duration(
                                                      seconds: 8),
                                                  content: Text(
                                                      'Erro ao atualizar cadastro'),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .removeCurrentSnackBar();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  duration: const Duration(
                                                      seconds: 8),
                                                  content: Text(
                                                      'Cadastro atualizado!'),
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      }
                                    },
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
                  );
                }),
          ),
        ),
      ),
    );
  }
}