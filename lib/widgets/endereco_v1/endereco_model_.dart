class EnderecoModel {
  int id;
  String bairro;
  String cidade;
  String complemento;
  String endereco;
  String uf;
  String pais;
  String numero;
  String cep;
  int usuario;

  EnderecoModel({
    this.id = 0,
    this.bairro = '',
    this.cidade = '',
    this.complemento = '',
    this.endereco = '',
    this.uf = '',
    this.pais = '',
    this.numero = '',
    this.cep = '',
    this.usuario = 0,
  });

  factory EnderecoModel.fromJson(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return EnderecoModel();
    //just using this for relations to other entities
    return EnderecoModel(
      id: data['id'] ?? 0,
      bairro: data['bairro'] ?? '',
      cidade: data['cidade'] ?? '',
      complemento: data['complemento'] ?? '',
      endereco: data['endereco'] ?? '',
      uf: data['uf'] ?? '',
      pais: data['pais'] ?? '',
      numero: data['numero'] ?? '',
      cep: data['cep'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bairro': bairro,
      'cidade': cidade,
      'complemento': complemento,
      'endereco': endereco,
      'estado': uf,
      'pais': pais,
      'numero': numero,
      'cep': cep,
      'usuario': usuario,
    };
  }
}
