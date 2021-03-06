import 'package:digital_aligner_app/dados/models/cadastro/onboarding_model.dart';

import './aprovacao_usuario_model.dart';
import './role_model.dart';
import 'representante_model.dart';

class CadastroModel {
  int id;
  String usernameCpf;
  String email;
  bool blocked;
  RoleModel? role;
  String nome;
  String sobrenome;
  String cro_uf;
  String cro_num;
  String data_nasc;
  String telefone;
  String celular;
  AprovacaoUsuarioModel? aprovacao_usuario;
  RepresentanteModel? representante;
  int onboardingNum;

  CadastroModel({
    this.id = 0,
    this.usernameCpf = '',
    this.email = '',
    this.blocked = true,
    this.role,
    this.nome = '',
    this.sobrenome = '',
    this.cro_uf = '',
    this.cro_num = '',
    this.data_nasc = '',
    this.telefone = '',
    this.celular = '',
    this.aprovacao_usuario,
    this.representante,
    this.onboardingNum = 0,
  });

  factory CadastroModel.fromJson(Map<String, dynamic> data) {
    return CadastroModel(
      id: data['id'] ?? 0,
      usernameCpf: data['username'] ?? '',
      email: data['email'] ?? '',
      blocked: data['blocked'] ?? false,
      role: RoleModel.fromJson(data['role']),
      nome: data['nome'] ?? '',
      sobrenome: data['sobrenome'] ?? '',
      cro_uf: data['cro_uf'] ?? '',
      cro_num: data['cro_num'] ?? '',
      data_nasc: data['data_nasc'] ?? '',
      telefone: data['telefone'] ?? '',
      celular: data['celular'] ?? '',
      aprovacao_usuario: AprovacaoUsuarioModel.fromJson(
        data['aprovacao_usuario'],
      ),
      representante: RepresentanteModel.fromJson(
        data['representante'] ??
            {
              'id': -1,
              'username': '',
              'email': '',
              'blocked': false,
              'role': {'id': -1, 'name': ''},
              'nome': '',
              'sobrenome': '',
              'cro_uf': '',
              'cro_num': '',
              'data_nasc': '',
              'telefone': '',
              'celular': '',
              'aprovacao_usuario': {'id': -1, 'status': ''},
            },
      ),
      onboardingNum: data['onboarding_num'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      //'username': usernameCpf,
      'email': email,
      'blocked': blocked,
      'role': role!.toJson(),
      'nome': nome,
      'sobrenome': sobrenome,
      'cro_uf': cro_uf,
      'cro_num': cro_num,
      'data_nasc': data_nasc,
      'telefone': telefone,
      'celular': celular,
      'aprovacao_usuario': aprovacao_usuario!.toJson(),
      'representante': representante!.toJson(),
      'onboarding_num': onboardingNum,
    };
  }
}
