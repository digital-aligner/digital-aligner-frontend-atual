import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/status_pedidov1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/usuario_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/uploader/model/FileModel.dart';
import 'package:digital_aligner_app/widgets/endereco_v1/endereco_model_.dart';

class PedidoV1Model {
  int id;
  String codigoPedido;
  FileModel? fotoPerfil;
  String nomePaciente;
  String dataNascimento;
  String tratar;
  String queixaPrincipal;
  String objetivosTratamento;
  String linhaMediaSuperior;
  String linhaMediaInferior;
  String overjet;
  String overbite;
  String dentesExtVirtual;
  String dentesNaoMov;
  String dentesSemAttach;
  String opcAceitoDesg;
  String opcRecorteElas;
  String opcRecorteAlin;
  String opcAlivioAlin;
  String linkModelos;
  String resApinSup;
  String resApinInf;
  bool modeloGesso;
  bool pedidoRefinamento;
  List<FileModel> fotografias;
  List<FileModel> radiografias;
  List<FileModel> modeloSuperior;
  List<FileModel> modeloInferior;
  List<FileModel> modeloCompactado;
  UsuarioV1Model? usuario;
  StatusPedidoV1Model? statusPedido;
  String createdAt;
  String? updatedAt;
  Map<String, dynamic>? payload;
  int idPedOriginal;
  //para alteracao de pedido
  String? alteracaoTexto;
  String? alteracaoData;
  bool? novaAtualizacao;
  String bairro;
  String cidade;
  String complemento;
  String endereco;
  String uf;
  String pais;
  String numero;
  String cep;

  PedidoV1Model({
    this.id = 0,
    this.codigoPedido = '',
    this.fotoPerfil,
    this.nomePaciente = '',
    this.dataNascimento = '',
    this.tratar = '',
    this.queixaPrincipal = '',
    this.objetivosTratamento = '',
    this.linhaMediaSuperior = '',
    this.linhaMediaInferior = '',
    this.overjet = '',
    this.overbite = '',
    this.dentesExtVirtual = '',
    this.dentesNaoMov = '',
    this.dentesSemAttach = '',
    this.opcAceitoDesg = '',
    this.opcRecorteElas = '',
    this.opcRecorteAlin = '',
    this.opcAlivioAlin = '',
    this.linkModelos = '',
    this.resApinSup = '',
    this.resApinInf = '',
    this.modeloGesso = false,
    this.pedidoRefinamento = false,
    this.fotografias = const <FileModel>[],
    this.radiografias = const <FileModel>[],
    this.modeloSuperior = const <FileModel>[],
    this.modeloInferior = const <FileModel>[],
    this.modeloCompactado = const <FileModel>[],
    this.usuario,
    this.statusPedido,
    this.createdAt = '',
    this.updatedAt = '',
    this.payload,
    this.idPedOriginal = 0,
    this.alteracaoTexto,
    this.alteracaoData,
    this.novaAtualizacao,
    this.bairro = '',
    this.cidade = '',
    this.complemento = '',
    this.endereco = '',
    this.uf = '',
    this.pais = '',
    this.numero = '',
    this.cep = '',
  });

  factory PedidoV1Model.fromJson(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return PedidoV1Model();

    try {
      List<FileModel> f = [];
      List<FileModel> r = [];
      List<FileModel> ms = [];
      List<FileModel> mi = [];
      List<FileModel> mc = [];
      //fotografias list to objects list
      if (data['fotografias'] != null) {
        data['fotografias'].forEach((fotografia) {
          f.add(FileModel.fromJson(fotografia));
        });
      }
      //radiografias list to objects list
      if (data['radiografias'] != null) {
        data['radiografias'].forEach((radiografia) {
          r.add(FileModel.fromJson(radiografia));
        });
      } //modelo superior list to objects list
      if (data['modelo_superior'] != null) {
        data['modelo_superior'].forEach((modeloSup) {
          ms.add(FileModel.fromJson(modeloSup));
        });
      } //modelo inferior list to objects list
      if (data['modelo_inferior'] != null) {
        data['modelo_inferior'].forEach((modeloInf) {
          mi.add(FileModel.fromJson(modeloInf));
        });
      }
      //modelo compactado list to objects list
      if (data['modelo_compactado'] != null) {
        data['modelo_compactado'].forEach((modeloComp) {
          mc.add(FileModel.fromJson(modeloComp));
        });
      }

      return PedidoV1Model(
        id: data['id'] ?? 0,
        codigoPedido: data['codigo_pedido'] ?? '',
        nomePaciente: data['nome_paciente'] ?? '',
        dataNascimento: data['data_nascimento'] ?? '',
        tratar: data['tratar'] ?? '',
        queixaPrincipal: data['queixa_principal'] ?? '',
        objetivosTratamento: data['objetivos_tratamento'] ?? '',
        linhaMediaSuperior: data['linha_media_superior'] ?? '',
        linhaMediaInferior: data['linha_media_inferior'] ?? '',
        overjet: data['overjet'] ?? '',
        overbite: data['overbite'] ?? '',
        dentesExtVirtual: data['dentes_ext_virtual'] ?? '',
        dentesNaoMov: data['dentes_nao_mov'] ?? '',
        dentesSemAttach: data['dentes_sem_attach'] ?? '',
        opcAceitoDesg: data['opc_aceito_desg'] ?? '',
        opcRecorteElas: data['opc_recorte_elas'] ?? '',
        opcRecorteAlin: data['opc_recorte_alin'] ?? '',
        opcAlivioAlin: data['opc_alivio_alin'] ?? '',
        linkModelos: data['link_modelos'] ?? '',
        resApinSup: data['res_apin_sup'] ?? '',
        resApinInf: data['res_apin_inf'] ?? '',
        modeloGesso: data['modelo_gesso'] ?? false,
        pedidoRefinamento: data['pedido_refinamento'] ?? false,
        fotografias: f,
        radiografias: r,
        modeloSuperior: ms,
        modeloInferior: mi,
        modeloCompactado: mc,
        usuario: UsuarioV1Model.fromJson(data['usuario'] ?? Map()),
        statusPedido:
            StatusPedidoV1Model.fromJson(data['status_pedido'] ?? Map()),
        createdAt: data['created_at'],
        updatedAt: data['updated_at'],
        idPedOriginal: data['id_ped_original'] ?? 0,
        alteracaoTexto: data['alteracao_texto'] ?? '',
        alteracaoData: data['alteracao_data'] ?? '',
        novaAtualizacao: data['nova_atualizacao'] ?? false,
        bairro: data['bairro'] ?? '',
        cidade: data['cidade'] ?? '',
        complemento: data['complemento'] ?? '',
        endereco: data['endereco'] ?? '',
        uf: data['uf'] ?? '',
        pais: data['pais'] ?? '',
        numero: data['numero'] ?? '',
        cep: data['cep'] ?? '',
      );
    } catch (e) {
      print(e);
      return PedidoV1Model(
        id: -1,
        codigoPedido: 'Erro:' + data['codigo_pedido'],
        nomePaciente: '',
        dataNascimento: '',
        tratar: '',
        queixaPrincipal: '',
        objetivosTratamento: '',
        linhaMediaSuperior: '',
        linhaMediaInferior: '',
        overjet: '',
        overbite: '',
        dentesExtVirtual: '',
        dentesNaoMov: '',
        dentesSemAttach: '',
        opcAceitoDesg: '',
        opcRecorteElas: '',
        opcRecorteAlin: '',
        opcAlivioAlin: '',
        linkModelos: '',
        resApinSup: '',
        resApinInf: '',
        modeloGesso: false,
        pedidoRefinamento: false,
        fotografias: [],
        radiografias: [],
        modeloSuperior: [],
        modeloInferior: [],
        modeloCompactado: [],
        usuario: UsuarioV1Model.fromJson(Map()),
        statusPedido: StatusPedidoV1Model.fromJson(Map()),
        createdAt: '',
        updatedAt: '',
        idPedOriginal: 0,
        alteracaoTexto: '',
        alteracaoData: '',
        novaAtualizacao: false,
        bairro: '',
        cidade: '',
        complemento: '',
        endereco: '',
        uf: '',
        pais: '',
        numero: '',
        cep: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    List<dynamic> f = [];
    List<dynamic> r = [];
    List<dynamic> ms = [];
    List<dynamic> mi = [];
    List<dynamic> mc = [];

    fotografias.forEach((fotografia) {
      f.add(fotografia.toJson());
    });
    radiografias.forEach((radiografia) {
      r.add(radiografia.toJson());
    });
    modeloSuperior.forEach((modeloSup) {
      ms.add(modeloSup.toJson());
    });
    modeloInferior.forEach((modeloInf) {
      mi.add(modeloInf.toJson());
    });
    modeloCompactado.forEach((modeloComp) {
      mc.add(modeloComp.toJson());
    });

    return {
      'id': id,
      'codigo_pedido': codigoPedido,
      'nome_paciente': nomePaciente,
      'data_nascimento': dataNascimento,
      'tratar': tratar,
      'queixa_principal': queixaPrincipal,
      'objetivos_tratamento': objetivosTratamento,
      'linha_media_superior': linhaMediaSuperior,
      'linha_media_inferior': linhaMediaInferior,
      'overjet': overjet,
      'overbite': overbite,
      'dentes_ext_virtual': dentesExtVirtual,
      'dentes_nao_mov': dentesNaoMov,
      'dentes_sem_attach': dentesSemAttach,
      'opc_aceito_desg': opcAceitoDesg,
      'opc_recorte_elas': opcRecorteElas,
      'opc_recorte_alin': opcRecorteAlin,
      'opc_alivio_alin': opcAlivioAlin,
      'link_modelos': linkModelos,
      'res_apin_sup': resApinSup,
      'res_apin_inf': resApinInf,
      'modelo_gesso': modeloGesso,
      'pedido_refinamento': pedidoRefinamento,
      'fotografias': f,
      'radiografias': r,
      'modelo_superior': ms,
      'modelo_inferior': mi,
      'modelo_compactado': mc,
      'usuario': usuario?.toJson() ?? '',
      'status_pedido': statusPedido?.toJson() ?? '',
      'created_at': createdAt,
      'updated_at': updatedAt,
      'payload': payload,
      'id_ped_original': idPedOriginal,
      'bairro': bairro,
      'cidade': cidade,
      'complemento': complemento,
      'endereco': endereco,
      'estado': uf,
      'pais': pais,
      'numero': numero,
      'cep': cep,
    };
  }
}
