import 'dart:convert';

import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';

import 'package:digital_aligner_app/providers/auth_provider.dart';

import 'package:digital_aligner_app/providers/pedidos_list_provider.dart';
import 'package:digital_aligner_app/rotas_url.dart';

import 'package:digital_aligner_app/screens/gerar_relatorio_screen.dart';
import 'package:digital_aligner_app/screens/login_screen.dart';

import 'package:digital_aligner_app/screens/relatorio_view_screen.dart';
import 'package:easy_web_view/easy_web_view.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'editar_pedido.dart';

import 'package:transparent_image/transparent_image.dart';

class PedidoViewScreen extends StatefulWidget {
  static const routeName = '/pedido-view';
  @override
  _PedidoViewScreenState createState() => _PedidoViewScreenState();
}

class _PedidoViewScreenState extends State<PedidoViewScreen> {
  PedidosListProvider _pedidosListStore;

  AuthProvider _authStore;
  List<dynamic> pedList;
  List<dynamic> relatorioData;

  String _modeloSupLink;
  String _modeloInfLink;

  int index;

  bool relatorioFirstFetch = true;

  ValueKey key = ValueKey('key_0');
  ValueKey key1 = ValueKey('key_1');

  bool modelsVisible = false;

  //Set the urls to file on disk (local storage) to be retrieved by
  //html file in web folder
  Future<void> _setModelosUrlToStorage(String _mSupUrl, String _mInfUrl) async {
    //Save token in device (web or mobile)
    final prefs = await SharedPreferences.getInstance();

    final modelosData = json.encode({
      'modelo_superior': _mSupUrl,
      'modelo_inferior': _mInfUrl,
    });
    prefs.setString('modelos_3d_url', modelosData);
  }

  Widget _mapImagesUrlToUi(
    BuildContext ctx,
    Map<String, dynamic> images,
  ) {
    List<Widget> networkImgList = [];

    for (int i = 1; i <= images.length; i++) {
      if (images['foto' + i.toString()] != null) {
        networkImgList.add(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    _viewImage(ctx, images['foto' + i.toString()]);
                  },
                  child: FadeInImage.memoryNetwork(
                    imageScale: 0.5,
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    image: images['foto' + i.toString()],
                    placeholder: kTransparentImage,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }
    }
    return Wrap(
      direction: Axis.horizontal,
      spacing: 10,
      children: networkImgList,
    );
  }

  Widget _pedidoUi(
    BuildContext ctx,
    List<dynamic> pedList,
    int index,
  ) {
    return Column(
      children: [
        //Modelos 3d text
        const SizedBox(height: 40),
        Container(
          //color: Colors.black12.withOpacity(0.04),
          height: 50,
          child: Align(
            alignment: Alignment.topCenter,
            child: const Text(
              'Modelos Superior/Inferior:',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 18,
                //fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            setState(() {
              modelsVisible = !modelsVisible;
            });
          },
          icon: modelsVisible
              ? const Icon(Icons.visibility)
              : const Icon(Icons.visibility_off),
          label: modelsVisible ? const Text('Esconder') : const Text('mostrar'),
        ),
        Visibility(
          visible: modelsVisible,
          maintainState: true,
          child: Column(
            children: [
              //Modelo Superior
              _modelo3d(
                key: key,
                modelUrl: _modeloSupLink,
                title: 'Modelo Superior',
                viewer3dUrl:
                    'https://digital-aligner-e0e72.web.app/stl_viewer/modelo_sup_viewer.html',
              ),
              const SizedBox(height: 20),
              //Modelo Inferior
              _modelo3d(
                key: key1,
                modelUrl: _modeloInfLink,
                title: 'Modelo Inferior',
                viewer3dUrl:
                    'https://digital-aligner-e0e72.web.app/stl_viewer/modelo_inf_viewer.html',
              ),
            ],
          ),
        ),

        //Fotografias
        //text
        const SizedBox(height: 40),
        Container(
          //color: Colors.black12.withOpacity(0.04),
          height: 50,
          child: Align(
            alignment: Alignment.topCenter,
            child: const Text(
              'Fotografias:',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 18,
                //fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        Container(
          child: _mapImagesUrlToUi(
            ctx,
            pedList[index]['fotografias'],
          ),
        ),
        //Radiografias
        const SizedBox(height: 40),
        Container(
          //color: Colors.black12.withOpacity(0.04),
          height: 50,
          child: Align(
            alignment: Alignment.topCenter,
            child: const Text(
              'Radiografias:',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 18,
                //fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        Container(
          child: _mapImagesUrlToUi(
            ctx,
            pedList[index]['radiografias'],
          ),
        ),
        const SizedBox(height: 50),
        ElevatedButton.icon(
          onPressed: () async {
            _downloadAll();
          },
          icon: const Icon(Icons.download_done_rounded),
          label: const Text('Baixar Tudo'),
        ),
      ],
    );
  }

  Widget _modelo3d({
    String title,
    String modelUrl,
    String viewer3dUrl,
    ValueKey key,
  }) {
    //Modelos digitais
    if (modelUrl == null) {
      return Center(
        child: const Text('Sem modelo'),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 50,
          vertical: 50,
        ),
        child: Column(
          children: [
            Center(child: Text(title)),
            Card(
              elevation: 0,
              child: EasyWebView(
                key: key,
                src: viewer3dUrl,
                isHtml: false, // Use Html syntax
                isMarkdown: false, // Use markdown syntax
                convertToWidgets: false, // Try to convert to flutter widgets
                onLoaded: () => null,
                width: 800,
                height: 500,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await launch(modelUrl);
              },
              icon: const Icon(Icons.download_done_rounded),
              label: const Text('Baixar'),
            ),
          ],
        ),
      );
    }
  }

  Future<bool> _deletePedidoDialog(BuildContext ctx, int index) async {
    return showDialog(
      barrierDismissible: true,
      context: ctx,
      builder: (BuildContext ctx2) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Deletar'),
              content: const Text('Deletar pedido?'),
              actions: [
                TextButton(
                  onPressed: () {
                    _pedidosListStore
                        .deletarPedido(pedList[index]['id'])
                        .then((_) {
                      Navigator.of(ctx).pop(true);
                    });
                  },
                  child: const Text('Sim'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(false);
                  },
                  child: const Text('Não'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _viewImage(BuildContext ctx, String imgUrl) async {
    return showDialog(
      barrierDismissible: true,
      context: ctx,
      builder: (BuildContext ctx2) {
        return AlertDialog(
          title: Center(child: const Text('Imagem')),
          content: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: InteractiveViewer(
              panEnabled: true, // Set it to false to prevent panning.
              boundaryMargin: const EdgeInsets.all(80),
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                imgUrl,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  return loadingProgress == null
                      ? child
                      : Center(
                          child: Container(
                            width: 300,
                            height: 300,
                            child: CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.blue),
                            ),
                          ),
                        );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Future<List<dynamic>> _fetchRelatorio(int pedidoId) async {
    var _response = await http.get(
      Uri.parse(RotasUrl.rotaMeuRelatorio + '?pedidoId=' + pedidoId.toString()),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${_authStore.token}'
      },
    );

    List<dynamic> data = json.decode(_response.body);

    if (!data[0].containsKey('error')) {
      relatorioData = data;
      relatorioFirstFetch = false;
    }

    return data;
  }

  Widget _manageRelatorioBtn(
    BuildContext ctx,
    int index,
    List<dynamic> data,
    String codPedido,
  ) {
    //Prevent null bug if connection failed
    if (data == null) {
      return Container(
        width: 300,
        child: const ElevatedButton(
          child: const Text(
            'ERRO AO BUSCAR RELATÓRIO',
          ),
          onPressed: null,
        ),
      );
    }
    if (data[0].containsKey('error')) {
      if (_authStore.role == 'Credenciado') {
        return Container(
          width: 300,
          child: ElevatedButton(
            child: const Text(
              'RELATÓRIO NÃO FINALIZADO',
            ),
            onPressed: () {},
          ),
        );
      }
      return Container(
        width: 300,
        child: ElevatedButton(
          child: const Text(
            'GERAR RELATÓRIO',
          ),
          onPressed: () {
            Navigator.of(context).pushNamed(
              GerarRelatorioScreen.routeName,
              arguments: {
                'pedidoId': pedList[index]['id'],
                'pacienteId': pedList[index]['paciente']['id']
              },
            ).then((didUpdate) {
              Navigator.pop(context);
              Future.delayed(Duration(milliseconds: 800),
                  () => _pedidosListStore.clearPedidosAndUpdate());
            });
          },
        ),
      );
    } else if (data[0]['pronto'] == false) {
      return Container(
        width: 300,
        child: ElevatedButton(
          child: const Text(
            'RELATÓRIO NÃO FINALIZADO',
          ),
          onPressed: () {},
        ),
      );
    } else {
      return Container(
        width: 300,
        child: ElevatedButton(
          child: const Text(
            'VISUALIZAR RELATÓRIO',
          ),
          onPressed: () {
            Navigator.of(context).pushNamed(
              RelatorioViewScreen.routeName,
              arguments: {
                'pedido': pedList[index],
              },
            ).then((didUpdate) {
              if (didUpdate) {
                Navigator.pop(context, true);
              }
            });
          },
        ),
      );
    }
  }

  Widget _manageNemoBtn(
    BuildContext ctx,
    int index,
  ) {
    if (pedList[index]['modelo_nemo']['modelo_nemo'] == null) {
      return Container(
        width: 300,
        child: ElevatedButton(
          child: const Text(
            'SEM MODELO NEMO',
          ),
          onPressed: null,
        ),
      );
    } else {
      return Container(
        width: 300,
        child: ElevatedButton(
          child: const Text(
            'BAIXAR MODELO NEMO',
          ),
          onPressed: () async {
            String nemo = pedList[index]['modelo_nemo']['modelo_nemo'];
            if (nemo.contains('http')) {
              await launch(nemo);
            }
          },
        ),
      );
    }
  }

  Widget _optionsBtns(BuildContext ctx, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (_authStore.role != 'Credenciado')
            Container(
              width: 300,
              child: ElevatedButton(
                child: const Text(
                  "EXCLUIR PEDIDO",
                ),
                onPressed: () async {
                  var didDelete = await _deletePedidoDialog(ctx, index);
                  if (didDelete) {
                    Navigator.pop(context, true);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _downloadAll() async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Row(children: [
          const Text('Baixando tudo...'),
          CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(
              Colors.blue,
            ),
          ),
        ]),
      ),
    );
    //Download all photoss
    await pedList[index]['fotografias'].forEach((key, foto) async {
      if (foto.contains('http')) {
        launch(foto);
      }
    });

    //Download all radiografias
    await pedList[index]['radiografias'].forEach((key, foto) async {
      if (foto.contains('http')) {
        launch(foto);
      }
    });

    //Download modelo superior
    if (pedList[index]['modelo_superior']['modelo_superior'].contains('http')) {
      await Future.delayed(Duration(seconds: 1), () async {
        await launch(pedList[index]['modelo_superior']['modelo_superior']);
      });
    }
    //Download modelo inferior
    if (pedList[index]['modelo_inferior']['modelo_inferior'].contains('http')) {
      await Future.delayed(Duration(seconds: 1), () async {
        await launch(pedList[index]['modelo_inferior']['modelo_inferior']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _authStore = Provider.of<AuthProvider>(context);
    _pedidosListStore = Provider.of<PedidosListProvider>(context);
    Map args = ModalRoute.of(context).settings.arguments;
    if (!_authStore.isAuth) {
      return LoginScreen();
    }

    pedList = _pedidosListStore.getPedidosList();
    if (pedList == null) {
      return Container(
        child: Align(
          alignment: Alignment.topCenter,
          child: const Text('Aguarde..'),
        ),
      );
    }

    if (pedList[0].containsKey('error')) {
      return Container(
        child: Align(
          alignment: Alignment.topCenter,
          child: const Text('Aguarde..'),
        ),
      );
    }

    index = args['index'];

    _setModelosUrlToStorage(
      pedList[index]['modelo_superior']['modelo_superior'],
      pedList[index]['modelo_inferior']['modelo_inferior'],
    );
    //Setting modelos links to global var for download btn
    _modeloSupLink = pedList[index]['modelo_superior']['modelo_superior'];
    _modeloInfLink = pedList[index]['modelo_inferior']['modelo_inferior'];

    final double sWidth = MediaQuery.of(context).size.width;
    final double sHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: SecondaryAppbar(),
      // *BUG* Verify closing drawer automaticlly when under 1200
      //drawer: sWidth < 1200 ? MyDrawer() : null,
      body: Container(
        width: sWidth,
        height: sHeight,
        child: Scrollbar(
          thickness: 15,
          isAlwaysShown: true,
          showTrackOnHover: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sWidth > 760 ? 100 : 8,
                vertical: 50,
              ),
              child: Column(
                children: [
                  //Código pedido
                  Container(
                    //color: Colors.black12.withOpacity(0.04),
                    height: 50,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        '${'PEDIDO: ' + pedList[index]['codigo_pedido']}' ?? '',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 36,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  //Divider
                  Container(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Divider(
                      color: Colors.grey,
                    ),
                  ),

                  //VISUALIZAR/EDITAR PEDIDO
                  Container(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          EditarPedido.routeName,
                          arguments: {
                            'codigoPedido': pedList[index]['codigo_pedido'],
                            'pedidoId': pedList[index]['id'],
                            'userId': pedList[index]['users_permissions_user']
                                ['id'],
                            'enderecoId': pedList[index]['endereco_usuario']
                                ['id'],
                            'pedidoDados': pedList[index],
                          },
                        ).then((needsUpdate) {
                          if (needsUpdate) {
                            Navigator.pop(context, true);
                          }
                        });
                      },
                      child: const Text(
                        'VISUALIZAR/EDITAR PEDIDO',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  //RELATÓRIO
                  const SizedBox(height: 20),
                  if (relatorioFirstFetch)
                    FutureBuilder(
                      future: _fetchRelatorio(pedList[index]['id']),
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return _manageRelatorioBtn(
                            ctx,
                            index,
                            snapshot.data,
                            pedList[index]['codigo_pedido'],
                          );
                        } else {
                          return CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                          );
                        }
                      },
                    ),
                  if (!relatorioFirstFetch &&
                      !relatorioData[0].containsKey('error'))
                    _manageRelatorioBtn(
                      context,
                      index,
                      relatorioData,
                      pedList[index]['codigo_pedido'],
                    ),
                  const SizedBox(height: 20),
                  if (_authStore.role != 'Credenciado')
                    _manageNemoBtn(
                      context,
                      index,
                    ),
                  _optionsBtns(
                    context,
                    index,
                  ),
                  _pedidoUi(
                    context,
                    pedList,
                    index,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}