//import './aprovacao_usuario_model.dart';
//import './role_model.dart';

class RepresentanteModel {
  int id;
  String usernameCpf;
  String email;
  String nome;
  String sobrenome;

  RepresentanteModel({
    this.id,
    this.usernameCpf,
    this.email,
    this.nome,
    this.sobrenome,
  });

  factory RepresentanteModel.fromJson(Map<String, dynamic> data) {
    return RepresentanteModel(
      id: data['id'],
      usernameCpf: data['username'],
      email: data['email'],
      nome: data['nome'],
      sobrenome: data['sobrenome'],
    );
  }
  //Just returning id for db update
  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}