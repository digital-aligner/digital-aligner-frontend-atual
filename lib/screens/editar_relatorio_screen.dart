import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/dados/scrollbarWidgetConfig.dart';
import 'package:digital_aligner_app/providers/relatorio_provider.dart';
import 'package:digital_aligner_app/providers/s3_relatorio_delete_provider.dart';
import 'package:digital_aligner_app/widgets/file_uploads/relatorio_pdf_upload.dart';
import 'package:digital_aligner_app/widgets/file_uploads/relatorio_ppt_upload.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

import '../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';

class EditarRelatorioScreen extends StatefulWidget {
  static const routeName = '/editar-relatorio';
  @override
  _EditarRelatorioScreenState createState() => _EditarRelatorioScreenState();
}

class _EditarRelatorioScreenState extends State<EditarRelatorioScreen> {
  // ----- For flutter web scroll -------
  ScrollController _scrollController = ScrollController();
  // ---- For flutter web scroll end ---

  final _formKey = GlobalKey<FormState>();
  AuthProvider _authStore;
  RelatorioProvider _relatorioStore;
  S3RelatorioDeleteProvider _s3RelatorioDeleteStore;

  final _numeroPedido = TextEditingController();
  final _nome = TextEditingController();
  final _sobrenome = TextEditingController();
  final _email = TextEditingController();
  final _cpf = TextEditingController();
  final _paciente = TextEditingController();
  final _visualizador3d = TextEditingController();
  final _visualizador3d2 = TextEditingController();

  bool _fetchData = true;

  Map _argMap;

  @override
  void dispose() {
    _numeroPedido.dispose();
    _nome.dispose();
    _sobrenome.dispose();
    _email.dispose();
    _cpf.dispose();
    _paciente.dispose();

    _visualizador3d.dispose();
    _visualizador3d2.dispose();

    _s3RelatorioDeleteStore.clearData();

    super.dispose();
  }

  void _mapDataToFields() {
    setState(() {
      _numeroPedido.text =
          _relatorioStore.getSelectedRelatorio().codigoPedido ?? '';
      _nome.text = _relatorioStore.getSelectedRelatorio().nome ?? '';
      _sobrenome.text = _relatorioStore.getSelectedRelatorio().sobrenome ?? '';
      _email.text = _relatorioStore.getSelectedRelatorio().email ?? '';
      _cpf.text = _relatorioStore.getSelectedRelatorio().cpf ?? '';
      _paciente.text =
          _relatorioStore.getSelectedRelatorio().nomePaciente ?? '';
      _visualizador3d.text =
          _relatorioStore.getSelectedRelatorio().visualizador3d ?? '';
      _visualizador3d2.text =
          _relatorioStore.getSelectedRelatorio().visualizador3dOpcao2 ?? '';
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authStore = Provider.of<AuthProvider>(context);
    _relatorioStore = Provider.of<RelatorioProvider>(context, listen: false);
    _relatorioStore.clearSelectedRelatorio();
    _relatorioStore.setToken(_authStore.token);
    _argMap = ModalRoute.of(context).settings.arguments;

    if (_fetchData && _argMap != null) {
      _relatorioStore
          .fetchMyRelatorio(
        _argMap['pedidoId'],
      )
          .then((_) {
        _mapDataToFields();

        _fetchData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //If unauthenticated return login screen
    if (!_authStore.isAuth) {
      return LoginScreen();
    }

    _s3RelatorioDeleteStore = Provider.of<S3RelatorioDeleteProvider>(
      context,
      listen: false,
    );
    _s3RelatorioDeleteStore.setToken(_authStore.token);

    return Scaffold(
      appBar: SecondaryAppbar(),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Form(
          key: _formKey,
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
                            Center(
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 40),
                                child: Text(
                                  'Editar Relatório',
                                  style: Theme.of(context).textTheme.headline1,
                                ),
                              ),
                            ),
                            //Num pedido
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              height: 80,
                              child: TextFormField(
                                controller: _numeroPedido,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  hintText: 'Número do Pedido: *',
                                  labelText: 'Número do Pedido: *',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            //Nome
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              height: 80,
                              child: TextFormField(
                                controller: _nome,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  hintText: 'Nome: *',
                                  labelText: 'Nome: *',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            //Sobrenome
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              height: 80,
                              child: TextFormField(
                                controller: _sobrenome,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  hintText: 'Sobrenome: *',
                                  labelText: 'Sobrenome: *',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            //Email
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              height: 80,
                              child: TextFormField(
                                controller: _email,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  hintText: 'Email: *',
                                  labelText: 'Email: *',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            //CPF
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              height: 80,
                              child: TextFormField(
                                controller: _cpf,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  hintText: 'CPF: *',
                                  labelText: 'CPF: *',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            //Paciente
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              height: 80,
                              child: TextFormField(
                                controller: _paciente,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  hintText: 'Paciente: *',
                                  labelText: 'Paciente: *',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            //Relatório PDF button
                            RelatorioPdfUpload(
                              isEdit: true,
                              relatorioDados: _argMap['relatorioData'],
                            ),
                            RelatorioPPTUpload(
                              isEdit: true,
                              relatorioDados: _argMap['relatorioData'],
                            ),
                            const SizedBox(
                              height: 60,
                            ),
                            //link visualizador 3d
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              height: 80,
                              child: TextFormField(
                                onSaved: (value) {
                                  _relatorioStore
                                      .getSelectedRelatorio()
                                      .visualizador3d = value;
                                },
                                controller: _visualizador3d,
                                readOnly: false,
                                decoration: const InputDecoration(
                                  //hintText: 'Visualizador 3D: *',
                                  labelText: 'Visualizador 3D: *',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            //link visualizador 3d
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              height: 80,
                              child: TextFormField(
                                onSaved: (value) {
                                  _relatorioStore
                                      .getSelectedRelatorio()
                                      .visualizador3dOpcao2 = value;
                                },
                                controller: _visualizador3d2,
                                readOnly: false,
                                decoration: const InputDecoration(
                                  //hintText: 'Visualizador 3D (segunda opção): *',
                                  labelText:
                                      'Visualizador 3D (segunda opção): *',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            //ENVIAR (atualizar)
                            Container(
                              width: 300,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();

                                    _relatorioStore
                                        .atualizarRelatorio()
                                        .then((res) {
                                      //Delete from s3 if pedido is deleted
                                      _s3RelatorioDeleteStore
                                          .batchDeleteFiles();
                                      ScaffoldMessenger.of(context)
                                          .removeCurrentSnackBar();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          duration: const Duration(seconds: 8),
                                          content: Text(res['message']),
                                        ),
                                      );
                                    });
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text(
                                  'ATUALIZAR',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 60,
                            ),
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