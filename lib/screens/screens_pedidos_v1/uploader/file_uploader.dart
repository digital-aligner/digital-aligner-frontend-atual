import 'dart:async';
import 'dart:convert';
import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/uploader/model/FileModel.dart';
import 'package:http/http.dart' as http;

import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../../../rotas_url.dart';

class FileUploader extends StatefulWidget {
  final int? filesQt;
  final List<String>? acceptedFileExt;
  final String? sendButtonText;
  final bool firstPedidoSaveToProvider;
  final String uploaderType;
  final List<String> uploaderTypes = const [
    'fotografias',
    'radiografias',
    'modelo superior',
    'modelo inferior',
    'modelo compactado',
  ];

  FileUploader({
    @required this.filesQt,
    @required this.acceptedFileExt,
    @required this.sendButtonText,
    this.firstPedidoSaveToProvider = false,
    this.uploaderType = '',
  });

  @override
  _FileUploaderState createState() => _FileUploaderState();
}

class _FileUploaderState extends State<FileUploader> {
  late AuthProvider _authStore;
  late PedidoProvider _pedidoStore;

  List<PlatformFile> _filesData = <PlatformFile>[];
  List<FileModel> _serverFiles = [];

  //manage ui states
  bool isDeleting = false;
  bool isUploading = false;
  double progress = 0;

  void _checkIfWidgetIsValid() {
    int verify = 0;
    widget.uploaderTypes.forEach((element) {
      if (widget.uploaderType == element) verify++;
    });
    if (verify == 0) throw 'Erro em uploaderType. Escolha um tipo compatível.';
  }

  void _firstPedidoSaveToProvider() {
    _checkIfWidgetIsValid();
    _pedidoStore.saveFilesForFirstPedido(
      fileList: _serverFiles,
      uploaderType: widget.uploaderType,
    );
  }

  Future<void> _openFileExplorer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: widget.acceptedFileExt,
      allowMultiple: true,
      withReadStream: true,
    );

    if (result != null) {
      if (result.files.length + _serverFiles.length <=
          int.parse(widget.filesQt.toString())) {
        _filesData = result.files;
      } else {
        throw ('Selecione até ${widget.filesQt.toString()} arquivos.');
      }
    } else {
      throw ('Nenhum arquivo escolhido.');
    }
  }

  MultipartRequest _buildRequest(PlatformFile currentFile) {
    final uri = Uri.parse(RotasUrl.rotaUpload);

    final request = MultipartRequest(
      'POST',
      uri,
    );

    request.headers['authorization'] = 'Bearer ${_authStore.token}';

    request.files.add(http.MultipartFile(
      'files',
      currentFile.readStream!,
      currentFile.size,
      filename: currentFile.name,
    ));
    return request;
  }

  void _fakeTimer() {
    const oneSec = const Duration(milliseconds: 100);
    Timer.periodic(oneSec, (Timer t) {
      if (_serverFiles.last.id != -1 && progress < 1) {
        setState(() {
          double currentProgess = progress;
          progress = currentProgess + 0.01;
        });
      } else {
        t.cancel();
      }
    });
  }

  ScaffoldFeatureController _scaffoldMessage(String e) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          e,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> _sendFile(PlatformFile currentFile) async {
    //create file model and insert in list
    setState(() {
      _serverFiles.add(FileModel.fromJson(null));
    });

    //build request
    MultipartRequest r = _buildRequest(currentFile);

    try {
      //TIMER (for fake ui progress)
      _fakeTimer();

      //send file
      var response = await r.send();
      var resStream = await response.stream.bytesToString();
      //decode data
      var resData = json.decode(resStream);

      //put timer progress at 1
      setState(() {
        progress = 1;
      });

      if (resData[0].containsKey('id')) {
        setState(() {
          _serverFiles.removeLast();
          _serverFiles.add(FileModel.fromJson(resData[0]));
          progress = 0;
        });
      }
    } catch (e) {
      setState(() {
        _serverFiles.last.id = -1;
        progress = 0;
      });
      print(e);
    }
  }

  Future<bool> _newFiledelete(int id) async {
    var _response = await http.delete(
      Uri.parse(RotasUrl.rotaDeletePhoto + id.toString()),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${_authStore.token}',
      },
    );
    var data = json.decode(_response.body);

    if (data.containsKey('id')) return true;

    return false;
  }

  Widget _fileUiImg(int pos) {
    if (widget.acceptedFileExt?[0] == 'stl') {
      return Stack(
        children: [
          const Image(
            fit: BoxFit.cover,
            width: 100,
            image: const AssetImage('logos/cubo.jpg'),
          ),
          Center(
            child: Center(
              child: CircularProgressIndicator(
                value: progress == 1 ? progress = 0 : progress,
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ),
        ],
      );
    } else if (_serverFiles[pos].id == -1) {
      return const Image(
        fit: BoxFit.cover,
        width: 100,
        image: const AssetImage('logos/error.jpg'),
      );
    } else {
      return Image.network(
        _serverFiles[pos].url ?? '',
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Center(
              child: CircularProgressIndicator(
                value: progress,
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          );
        },
      );
    }
  }

  Widget _fileUi(int pos) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          children: <Widget>[
            _fileUiImg(pos),
            if (isUploading && pos == _serverFiles.length)
              Center(
                child: CircularProgressIndicator(
                  value: progress,
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            if (!isUploading)
              IconButton(
                color: Colors.blueAccent,
                icon: const Icon(Icons.delete),
                onPressed: isUploading || isDeleting
                    ? null
                    : () async {
                        setState(() => isDeleting = true);
                        bool result =
                            await _newFiledelete(_serverFiles[pos].id as int);
                        if (result)
                          setState(() {
                            _serverFiles.remove(_serverFiles[pos]);
                            if (widget.firstPedidoSaveToProvider) {
                              _firstPedidoSaveToProvider();
                            }

                            isDeleting = false;
                          });
                      },
              ),
          ],
        ),
      ),
    );
  }

  Widget _fileUiList() {
    List<Widget> l = [];
    for (int i = 0; i < _serverFiles.length; i++) {
      l.add(_fileUi(i));
    }
    return Wrap(children: l);
  }

  Widget _uploadBtn() {
    return ElevatedButton(
      onPressed: isUploading || isDeleting
          ? null
          : () async {
              await _openFileExplorer().catchError((e) {
                _scaffoldMessage(e);
              });

              setState(() {
                isUploading = true;
              });
              if (_filesData.isNotEmpty) {
                for (var file in _filesData) {
                  await _sendFile(file);
                  if (widget.firstPedidoSaveToProvider as bool) {
                    _firstPedidoSaveToProvider();
                  }
                  _filesData = [];
                }
              }

              setState(() {
                isUploading = false;
              });
            },
      child: Text(
        widget.sendButtonText!,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    _authStore = Provider.of<AuthProvider>(context);
    _pedidoStore = Provider.of<PedidoProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _uploadBtn(),
          _fileUiList(),
        ],
      ),
    );
  }
}