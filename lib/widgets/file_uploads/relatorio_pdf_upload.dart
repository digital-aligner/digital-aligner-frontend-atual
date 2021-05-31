import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:digital_aligner_app/providers/relatorio_provider.dart';
import 'package:digital_aligner_app/providers/s3_relatorio_delete_provider.dart';
import 'package:digital_aligner_app/widgets/file_uploads/relatorio_pdf_model.dart';
import 'package:http/http.dart' as http;
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../rotas_url.dart';
import './multipart_request.dart' as mt;

//https://stackoverflow.com/questions/63314063/upload-image-file-to-strapi-flutter-web

class RelatorioPdfUpload extends StatefulWidget {
  final bool isEdit;
  final Map relatorioDados;

  RelatorioPdfUpload({
    this.isEdit,
    this.relatorioDados,
  });

  @override
  _RelatorioPdfUploadState createState() => _RelatorioPdfUploadState();
}

class _RelatorioPdfUploadState extends State<RelatorioPdfUpload>
    with AutomaticKeepAliveClientMixin<RelatorioPdfUpload> {
  @override
  bool get wantKeepAlive => true;
  bool _isFetchEdit = true;
  RelatorioProvider _relatorioStore;
  S3RelatorioDeleteProvider _s3RelatorioDeleteStore;
  //Map<String, dynamic> _relatorioPdfMap = Map<String, dynamic>();
  //RelatorioPdf _relatorioPdf = RelatorioPdf();

  //Clear after sending to server
  List<PlatformFile> _relatorioPdfUploadsDataList = <PlatformFile>[];

  //New relatorioPdfUpload object with id and image url from server
  List<RelatorioPdfModel> _relatorioPdfUploadsList = <RelatorioPdfModel>[];

  Future<dynamic> _deleterelatorioPdfUpload(
      _token, relatorioPdfUploadId) async {
    var _response = await http.delete(
      Uri.parse(
          RotasUrl.rotaDeleteRelatorioUpload + relatorioPdfUploadId.toString()),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    return _response;
  }

  Future<void> _openFileExplorer() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
      withReadStream: true,
    );
    if (result != null &&
        result.files.length + _relatorioPdfUploadsList.length <= 1) {
      _relatorioPdfUploadsDataList = result.files;
    } else {
      throw ('Selecione apenas 1 arquivo PDF.');
    }
  }

  List<Widget> _uiManagerelatorioPdfUploads(_token) {
    List<Widget> _ump = <Widget>[];
    for (var currelatorioPdfUpload in _relatorioPdfUploadsList) {
      _ump.add(
        Material(
          elevation: 5,
          child: Row(
            children: [
              if (currelatorioPdfUpload.imageUrl == null)
                Center(
                  child: CircularProgressIndicator(
                    value: currelatorioPdfUpload.progress,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                )
              else if (currelatorioPdfUpload.id == -1)
                Image(
                  fit: BoxFit.cover,
                  width: 100,
                  image: AssetImage('logos/error.jpg'),
                )
              else
                Image(
                  fit: BoxFit.cover,
                  width: 100,
                  image: AssetImage('logos/pdf.png'),
                ),
              const SizedBox(width: 10),
              currelatorioPdfUpload.fileName == null
                  ? Text(
                      'Carregando...',
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    )
                  : Text(
                      currelatorioPdfUpload.fileName,
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    ),
              Expanded(
                child: Container(),
              ),
              currelatorioPdfUpload.id != null
                  ? IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        if (widget.isEdit) {
                          //If negative, error ocurred só delete only from list
                          if (currelatorioPdfUpload.id < 0) {
                            setState(() {
                              _relatorioPdfUploadsList.removeWhere(
                                (photo) => photo.id == currelatorioPdfUpload.id,
                              );
                            });
                          } else {
                            _s3RelatorioDeleteStore.setIdToDelete(
                              currelatorioPdfUpload.id,
                            );
                            setState(() {
                              _relatorioPdfUploadsList.removeWhere(
                                (relatorioPdfUpload) =>
                                    relatorioPdfUpload.id ==
                                    currelatorioPdfUpload.id,
                              );
                            });
                          }
                        } else {
                          //If negative, error ocurred só delete only from list
                          if (currelatorioPdfUpload.id < 0) {
                            setState(() {
                              _relatorioPdfUploadsList.removeWhere(
                                (photo) => photo.id == currelatorioPdfUpload.id,
                              );
                            });
                          } else {
                            _deleterelatorioPdfUpload(
                                    _token, currelatorioPdfUpload.id)
                                .then((res) {
                              var data = json.decode(res.body);
                              if (data['id'] != null) {
                                setState(() {
                                  _relatorioPdfUploadsList.removeWhere(
                                    (relatorioPdfUpload) =>
                                        relatorioPdfUpload.id == data['id'],
                                  );
                                });
                              }
                            });
                          }
                        }
                      },
                    )
                  : Container(),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      );
    }

    return _ump;
  }

  Future<void> _sendrelatorioPdfUpload(
    String _token,
    PlatformFile _currentrelatorioPdfUpload,
  ) async {
    int min = 100000; //min and max values act as your 6 digit range
    int max = 999999;
    var randomizer = new Random();
    var rNum = min + randomizer.nextInt(max - min);

    RelatorioPdfModel pm = RelatorioPdfModel(
      listId: rNum,
      progress: 0,
      fileName: 'Enviando...',
    );
    int posContainingWidget = 0;

    setState(() {
      _relatorioPdfUploadsList.add(pm);
      for (int i = 0; i < _relatorioPdfUploadsList.length; i++) {
        if (_relatorioPdfUploadsList[i].listId == rNum) {
          posContainingWidget = i;
        }
      }
    });

    final uri = Uri.parse(RotasUrl.rotaUpload);

    final request = mt.MultipartRequest(
      'POST',
      uri,
    );

    request.headers['authorization'] = 'Bearer $_token';

    request.files.add(http.MultipartFile(
      'files',
      _currentrelatorioPdfUpload.readStream,
      _currentrelatorioPdfUpload.size,
      filename: _currentrelatorioPdfUpload.name,
    ));

    try {
      //TIMER (for fake ui progress)
      const oneSec = const Duration(milliseconds: 100);
      bool isUploading = true;

      Timer.periodic(oneSec, (Timer t) {
        if (_relatorioPdfUploadsList[posContainingWidget].progress < 1 ||
            isUploading) {
          setState(() {
            double currentProgess =
                _relatorioPdfUploadsList[posContainingWidget].progress;
            _relatorioPdfUploadsList[posContainingWidget].progress =
                currentProgess + 0.01;
          });
        } else {
          t.cancel();
        }
      });

      var response = await request.send();
      var resStream = await response.stream.bytesToString();
      var resData = json.decode(resStream);

      if (resData[0]['id'] != null) {
        //STOP UI PROGRESS IF NOT FINISHED
        isUploading = false;

        _relatorioStore.updateRelatorioPdfS3Urls(resData[0]);

        setState(() {
          _relatorioPdfUploadsList[posContainingWidget].id = resData[0]['id'];
          _relatorioPdfUploadsList[posContainingWidget].fileName =
              resData[0]['name'];
          _relatorioPdfUploadsList[posContainingWidget].imageUrl =
              resData[0]['url'];
        });
      }
    } catch (e) {
      setState(() {
        _relatorioPdfUploadsList[posContainingWidget].id = -1;
        _relatorioPdfUploadsList[posContainingWidget].fileName =
            'Erro de conexão. Por favor tente novamente.';
        _relatorioPdfUploadsList[posContainingWidget].imageUrl = '';
      });
    }
  }

  //FOR EDIT SCREEN
  Future<dynamic> _getPdfs(_token) async {
    RelatorioPdfModel pm = RelatorioPdfModel(
      listId: -1,
      progress: 1,
      fileName: 'carregando...',
    );

    setState(() {
      _relatorioPdfUploadsList = [];
      _relatorioPdfUploadsList.add(pm);
    });

    var _response = await http.post(
      Uri.parse(RotasUrl.rotaPdfsList),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: json.encode({
        'relatorio1_id':
            widget.relatorioDados['relatorio_pdf']['relatorio1_id'].toString(),
      }),
    );
    var resData = json.decode(_response.body);

    try {
      /*
      for (int i = 0; i < resData.length; i++) {
        if (resData[i]['id'] != null) {
          RelatorioPdfModel pm = RelatorioPdfModel(listId: resData[i]['id']);
          pm.id = resData[i]['id'];
          pm.fileName = resData[i]['name'];
          //pm.thumbnail = resData[i]['formats']['thumbnail']['url'];
          pm.imageUrl = resData[i]['url'];
          _relatorioPdfUploadsList.add(pm);
        }
      }*/

      if (resData[0].containsKey('id')) {
        _relatorioPdfUploadsList = [];
        RelatorioPdfModel pm = RelatorioPdfModel(listId: resData[0]['id']);
        pm.id = resData[0]['id'];
        pm.fileName = resData[0]['name'];
        //pm.thumbnail = resData[i]['formats']['thumbnail']['url'];
        pm.imageUrl = resData[0]['url'];
        _relatorioPdfUploadsList.add(pm);
      } else {
        _relatorioPdfUploadsList = [];
      }
      setState(() {
        _isFetchEdit = false;
      });
    } catch (error) {
      setState(() {
        _relatorioPdfUploadsList = [];
        _isFetchEdit = false;
      });
      print(error);
    }

    return resData;
  }

  @override
  Widget build(BuildContext context) {
    //For the "wantToKeepAlive" mixin
    super.build(context);

    AuthProvider _authStore = Provider.of<AuthProvider>(context);

    _relatorioStore = Provider.of<RelatorioProvider>(context);

    _s3RelatorioDeleteStore = Provider.of<S3RelatorioDeleteProvider>(
      context,
      listen: false,
    );

    if (widget.isEdit && _isFetchEdit) {
      _getPdfs(_authStore.token);
    }
    /*
    if (_relatorioPdfUploadsList.isNotEmpty) {
      _relatorioStore.setPdfList(_relatorioPdfUploadsList);
    } else {
      _relatorioStore.setPdfList(null);
    }
  */
    return Container(
      width: 600,
      child: SingleChildScrollView(
        child: Column(
          children: [
            //If sending, but not this (pdf)
            if (_relatorioStore.getFstSendingState() !=
                    _relatorioStore.getFstNotSendingState() &&
                _relatorioStore.getFstSendingState() !=
                    _relatorioStore.getFstRelPdf())
              Container(
                width: 300,
                child: const ElevatedButton(
                  onPressed: null,
                  child: const Text(
                    'AGUARDE...',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            //If sending, and is this
            else if (_relatorioStore.getFstSendingState() !=
                    _relatorioStore.getFstNotSendingState() &&
                _relatorioStore.getFstSendingState() ==
                    _relatorioStore.getFstRelPdf())
              Container(
                width: 300,
                child: ElevatedButton(
                  onPressed: null,
                  child: const Text(
                    'ENVIANDO...',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 300,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 8),
                        content: const Text('Aguarde...'),
                      ),
                    );

                    _openFileExplorer().then((_) {
                      //Change btn states/block ui while sending
                      _relatorioStore.setFstSendState(
                        fstSendValue: _relatorioStore.getFstRelPdf(),
                      );
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 10),
                          content: const Text('Enviando relatório PDF...'),
                        ),
                      );

                      Future.delayed(
                        const Duration(seconds: 1),
                        () async {
                          for (var relatorioPdfUpload
                              in _relatorioPdfUploadsDataList) {
                            await _sendrelatorioPdfUpload(
                              _authStore.token,
                              relatorioPdfUpload,
                            );
                          }
                          //Unblock when finished
                          _relatorioStore.setFstSendState(
                            fstSendValue:
                                _relatorioStore.getFstNotSendingState(),
                          );
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        },
                      );
                    }).catchError((e) {
                      //Unblock when finished
                      _relatorioStore.setFstSendState(
                        fstSendValue: _relatorioStore.getFstNotSendingState(),
                      );
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 8),
                          content: Text(e),
                        ),
                      );
                    });
                  },
                  child: const Text(
                    'RELATÓRIO PDF',
                  ),
                ),
              ),
            const SizedBox(height: 20),
            //Showing loaded images, if any.
            _relatorioPdfUploadsList != null
                ? Column(
                    children: _uiManagerelatorioPdfUploads(_authStore.token),
                  )
                : Container(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
