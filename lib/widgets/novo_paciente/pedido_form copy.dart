import 'package:digital_aligner_app/providers/pedidos_list_provider.dart';
import 'package:digital_aligner_app/screens/meus_pacientes.dart';
import 'package:digital_aligner_app/widgets/file_uploads/compactado_upload.dart';
import 'package:digital_aligner_app/widgets/file_uploads/modelo_inferior_upload.dart';
import 'package:digital_aligner_app/widgets/file_uploads/modelo_superior_upload.dart';
import 'package:digital_aligner_app/widgets/file_uploads/radiografia_upload.dart';
import 'package:digital_aligner_app/widgets/novo_paciente/6_endereco/editar_endereco_entrega.dart';
import 'package:digital_aligner_app/widgets/novo_paciente/7_termos/termos.dart';
import 'package:digital_aligner_app/widgets/novo_paciente/8_status_pedido/status_pedido.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

import '../../widgets/novo_paciente/5_problemas_individuais/problemas_individuais.dart';

import '../file_uploads/photo_upload.dart';

import '../../providers/auth_provider.dart';
import '../../providers/pedido_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//Widgets
import './1_dados_iniciais/dados_iniciais.dart';
import './2_sagital/sagital.dart';
import './3_vertical/vertical.dart';
import './4_transversal/transversal.dart';
import '6_endereco/endereco_entrega.dart';

class PedidoForm extends StatefulWidget {
  final int pedidoId;
  final int userId;
  final int enderecoId;
  final bool isEditarPedido;
  final bool isNovoPedido;
  final bool isNovoPaciente;
  final bool isNovoRefinamento;
  final String pedidoHeader;
  final Map pedidoDados;
  final Map pacienteDados;

  PedidoForm({
    this.pedidoId,
    this.userId,
    @required this.isNovoPedido,
    @required this.isNovoPaciente,
    @required this.isEditarPedido,
    @required this.isNovoRefinamento,
    this.enderecoId,
    this.pedidoHeader,
    this.pedidoDados,
    this.pacienteDados,
  });

  @override
  _PedidoFormState createState() => _PedidoFormState();
}

class _PedidoFormState extends State<PedidoForm> {
  final _formKey = GlobalKey<FormState>();
  bool _initialSetup = true;

  // ----- For flutter web scroll -------
  ScrollController _scrollController = ScrollController();
  // ---- For flutter web scroll end ---

  @override
  Widget build(BuildContext context) {
    AuthProvider _authStore = Provider.of<AuthProvider>(context);
    PedidoProvider _novoPedStore = Provider.of<PedidoProvider>(context);

    double _sWidth = MediaQuery.of(context).size.width;
    double _sHeight = MediaQuery.of(context).size.height;

    PedidosListProvider _pedidosListStore = Provider.of<PedidosListProvider>(
      context,
      listen: false,
    );

    if (widget.isEditarPedido && _initialSetup) {
      _novoPedStore.clearAll();
      _novoPedStore.setToken(_authStore.token);
      _novoPedStore.setPedidoId(widget.pedidoId);
      _novoPedStore.setPedido(widget.pedidoDados);
      _initialSetup = false;
    } else {
      if (_initialSetup) {
        _novoPedStore.clearAll();
        _initialSetup = false;
      }
    }

    if (widget.isNovoPedido || widget.isNovoRefinamento) {
      _novoPedStore.setPacienteId(widget.pacienteDados['id']);
    }

    //Id set if novo pedido or editar pedido
    _novoPedStore.setUserId(widget.userId);

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: _form(
        _novoPedStore,
        _authStore,
        _pedidosListStore,
        _sWidth,
        _sHeight,
      ),
    );
  }

  Widget _form(
    PedidoProvider _novoPedStore,
    AuthProvider _authStore,
    PedidosListProvider _pedidosListStore,
    double _sWidth,
    double _sHeight,
  ) {
    return Form(
      key: _formKey,
      child: DraggableScrollbar.rrect(
        backgroundColor: Colors.black12,
        alwaysVisibleScrollThumb: true,
        controller: _scrollController,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: 1,
          itemExtent: null,
          itemBuilder: (context, index2) {
            return _pedidoFormUi(
              _authStore,
              _novoPedStore,
              _pedidosListStore,
              _sWidth,
              _sHeight,
            );
          },
        ),
      ),
    );
  }

  Widget _pedidoFormUi(
    AuthProvider _authStore,
    PedidoProvider _novoPedStore,
    PedidosListProvider _pedidosListStore,
    double _sWidth,
    double _sHeight,
  ) {
    return Container(
      width: _sWidth,
      child: Row(
        children: [
          Expanded(
            child: Container(),
          ),
          //Form
          Expanded(
            flex: 8,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    widget.pedidoHeader,
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
                SizedBox(height: 80),
                DadosIniciais(
                  isNovoPedidoOrRefinamento:
                      widget.isNovoPedido != null && widget.isNovoPedido ||
                              widget.isNovoRefinamento != null &&
                                  widget.isNovoRefinamento
                          ? true
                          : false,
                  pacienteDados: widget.pacienteDados,
                ),
                const SizedBox(
                  height: 50,
                  child: const Divider(
                    thickness: 2,
                  ),
                ),
                Sagital(),
                const SizedBox(
                  height: 50,
                  child: const Divider(
                    thickness: 2,
                  ),
                ),
                Vertical(),
                const SizedBox(
                  height: 50,
                  child: const Divider(
                    thickness: 2,
                  ),
                ),
                Transversal(),
                const SizedBox(
                  height: 50,
                  child: const Divider(
                    thickness: 2,
                  ),
                ),
                ProblemasIndividuais(),
                const SizedBox(
                  height: 50,
                  child: const Divider(
                    thickness: 2,
                  ),
                ),
                //Envio de Imagens (Exames)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Envio de Imagens (Exames)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                //Text: Fotografias
                const SizedBox(height: 20),
                PhotoUpload(
                  isEdit: widget.isEditarPedido,
                  pedidoDados: widget.pedidoDados,
                ),
                const SizedBox(height: 20),
                //Text: Radiografias
                const SizedBox(height: 20),
                RadiografiaUpload(
                  isEdit: widget.isEditarPedido,
                  pedidoDados: widget.pedidoDados,
                ),
                const SizedBox(
                  height: 50,
                  child: const Divider(
                    thickness: 2,
                  ),
                ),
                //Text: Formato dos Modelos
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Formato dos Modelos',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _manageModelType(_novoPedStore),
                const SizedBox(height: 20),
                if (_novoPedStore.getFormatoModelos() == 0)
                  Container()
                else if (_novoPedStore.getFormatoModelos() == 1)
                  _modelosDigitais()
                else
                  _modelosGesso(),
                const SizedBox(
                  height: 50,
                  child: const Divider(
                    thickness: 2,
                  ),
                ),
                //Text: Endereço Entrega
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'ENDEREÇO DE ENTREGA',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                if (widget.isNovoPaciente ||
                    widget.isNovoPedido ||
                    widget.isNovoRefinamento)
                  EnderecoEntrega(
                    idUsuario: widget.userId,
                  ),
                if (widget.isEditarPedido)
                  EditarEnderecoEntrega(
                    idUsuario: widget.userId,
                    idEndereco: widget.enderecoId,
                  ),
                const SizedBox(
                  height: 50,
                  child: const Divider(
                    thickness: 2,
                  ),
                ),
                //Termos
                Termos(),
                //Status pedido
                const SizedBox(height: 40),
                //Widget makes request to server
                StatusPedido(),
                const SizedBox(height: 20),
                //Enviar
                Row(
                  children: [
                    Expanded(child: Container()),
                    //Atualizar pedido btn
                    if (widget.isEditarPedido)
                      Container(
                        width: 300,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              //Get token from auth provider
                              //and send to pedido provider
                              _novoPedStore.setToken(_authStore.token);
                              _novoPedStore
                                  .atualizarPedido(widget.pedidoDados['id'])
                                  .then((data) {
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 8),
                                    content: Text(data[0]['message']),
                                  ),
                                );
                                if (!data[0].containsKey('error')) {
                                  _pedidosListStore.clearPedidosAndUpdate();
                                  Navigator.pop(context);
                                }
                              });
                            }
                          },
                          child: const Text(
                            'ATUALIZAR PEDIDO',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ),
                    //Novo paciente
                    if (widget.isNovoPaciente)
                      Container(
                        width: 300,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              //Get token from auth provider
                              //and send to pedido provider
                              _novoPedStore.setToken(_authStore.token);
                              _novoPedStore.enviarPaciente().then((data) {
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 8),
                                    content: Text(data[0]['message']),
                                  ),
                                );
                                if (!data[0].containsKey('error')) {
                                  Navigator.of(context).pushReplacementNamed(
                                    MeusPacientes.routeName,
                                  );
                                }
                              });
                            }
                          },
                          child: const Text(
                            'ENVIAR NOVO PACIENTE',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ),
                    //Novo pedido
                    if (widget.isNovoPedido)
                      Container(
                        width: 300,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              //Get token from auth provider
                              //and send to pedido provider
                              _novoPedStore.setToken(_authStore.token);
                              _novoPedStore.enviarNovoPedido().then((data) {
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 8),
                                    content: Text(data[0]['message']),
                                  ),
                                );
                                if (!data[0].containsKey('error')) {
                                  Navigator.pop(context);
                                }
                              });
                            }
                          },
                          child: const Text(
                            'ENVIAR NOVO PEDIDO',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ),
                    //Novo refinamento
                    if (widget.isNovoRefinamento)
                      Container(
                        width: 300,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              //Get token from auth provider
                              //and send to pedido provider
                              _novoPedStore.setToken(_authStore.token);
                              _novoPedStore
                                  .enviarNovoRefinamento()
                                  .then((data) {
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 8),
                                    content: Text(data[0]['message']),
                                  ),
                                );
                                if (!data[0].containsKey('error')) {
                                  Navigator.pop(context);
                                }
                              });
                            }
                          },
                          child: const Text(
                            'ENVIAR NOVO REFINAMENTO',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ),

                    Expanded(child: Container()),
                  ],
                ),
                const SizedBox(height: 160),
              ],
            ),
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget _modelosDigitais() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Modelos digitais',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ModeloSuperiorUpload(
          isEdit: widget.isEditarPedido,
          pedidoDados: widget.pedidoDados,
        ),
        const SizedBox(height: 20),
        ModeloInferiorUpload(
          isEdit: widget.isEditarPedido,
          pedidoDados: widget.pedidoDados,
        ),
        const SizedBox(height: 20),
        CompactadoUpload(
          isEdit: widget.isEditarPedido,
          pedidoDados: widget.pedidoDados,
        ),
      ],
    );
  }

  Widget _modelosGesso() {
    return Container(
      width: 600,
      height: 300,
      child: Column(
        children: <Widget>[
          Flexible(
            child: const Text(
              'AVISO PARA MODELOS EM GESSO:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Flexible(
            child: const Text(
                '\nOs modelos de gesso enviados devem ser feitos com Gesso pedra tipo IV, sempre superior e inferior. Deve ser enviado o registro de oclusão do paciente juntamente com os modelos em gesso. Devem estar bem embalados, para evitar a quebra. Se possível, a base do modelo deve vir recortada. Enviar com as informações referentes ao paciente (nome, data de nascimento e dentista responsável pelo caso). *Os casos que não seguirem essas recomendações não serão escaneados. *O prazo para planejamento só será contado a partir do recebimento da documentação completa (fotos, radiografia e a prescrição do pedido devem ser enviados via plataforma Digital Aligner). Favor enviar os modelos em gesso para o escaneamento no endereço abaixo:'),
          ),
          Flexible(
            child: const Text(
                '\nUPDENTALL - TECNOLOGIA EM ODONTOLOGIA LTDA. Rua das Pernambucanas, 407, sala 203 Graças 52011-010 Recife, PE'),
          ),
        ],
      ),
    );
  }

  Widget _manageModelType(_novoPedStore) {
    //Digital ou Gesso
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Radio(
          activeColor: Colors.blue,
          groupValue: _novoPedStore.getFormatoModelos(),
          onChanged: (value) {
            _novoPedStore.setFormatoModelos(value);
          },
          value: 1,
        ),
        Text('Digital'),
        Radio(
          activeColor: Colors.blue,
          groupValue: _novoPedStore.getFormatoModelos(),
          onChanged: (value) {
            _novoPedStore.setFormatoModelos(value);
          },
          value: 2,
        ),
        Text('Gesso'),
      ],
    );
  }
}