class RotasUrl {
  //static const rotaHeroku = 'https://ancient-peak-42996.herokuapp.com/';
  //static const rotaBase = 'http://localhost:1337/';
  static const rotaBase = 'http://localhost:1337/';
  static const rotaGetPaisesAndState = rotaBase + 'paises';
  static const rotaLogin = rotaBase + 'auth/local/';
  static const rotaCadastro = rotaBase + 'users/';
  static const rotaPedidosAprovados = rotaBase + 'pedidos-aprovados/';
  static const rotaCadastrosAprovados = rotaBase + 'cadastros-aprovados/';
  static const rotaCadastrosAguardando = rotaBase + 'cadastros-aguardando/';
  static const rotaCadastrosNegado = rotaBase + 'cadastros-negado/';
  static const rotaCadastrosAdministrador =
      rotaBase + 'cadastros-administrador/';
  static const rotaCadastrosGerente = rotaBase + 'cadastros-gerente/';
  static const rotaCadastrosCredenciado = rotaBase + 'cadastros-credenciado/';
  static const rotaAprovacao = rotaBase + 'aprovacao-usuarios/';
  static const rotaNovoPaciente = rotaBase + 'novo-paciente/';
  static const rotaPaciente = rotaBase + 'pacientes/';
  static const rotaNovoPedido = rotaBase + 'novo-pedido/';
  static const rotaNovoRefinamento = rotaBase + 'novo-refinamento/';
  static const rotaUpload = rotaBase + 'upload/';
  static const rotaUserMe = rotaBase + 'users/me';
  static const rotaStatusPedido = rotaBase + 'status-pedidos/';
  static const rotaPedidos = rotaBase + 'pedidos/';
  static const rotaEnderecoUsuarios = rotaBase + 'endereco-usuarios/';
  static const rotaGetEnderecoUsuarios = rotaBase + 'get-enderecos-usuario/';
  static const rotaMeusPacientes = rotaBase + 'meus-pacientes/';
  static const rotaMeuHistorico = rotaBase + 'meu-historico/';
  static const rotaMeusPedidos = rotaBase + 'meus-pedidos/';
  static const rotaMeusRefinamentos = rotaBase + 'meus-refinamentos/';
  static const rotaPdfsList = rotaBase + 'pdfs-list/';
  static const rotaPptsList = rotaBase + 'ppts-list';
  static const rotafotografiasList = rotaBase + 'fotografias-list/';
  static const rotaRadiografiasList = rotaBase + 'radiografias-list/';
  static const rotaModeloSuperiorList = rotaBase + 'modelo-superior-list/';
  static const rotaModeloInferiorList = rotaBase + 'modelo-inferior-list/';
  static const rotaModeloCompactadoList = rotaBase + 'modelo-compactados-list/';
  static const rotaMeuRelatorio = rotaBase + 'meu-relatorio/';
  static const rotaCriarRelatorio = rotaBase + 'criar-relatorio/';
  static const rotaAtualizarRelatorio = rotaBase + 'atualizar-relatorio/';
  static const rotaDadosBaseRelatorio = rotaBase + 'dados-base-relatorio/';
  //Note: These delete routes only used on editing screens (editar pedido, editar relatório)
  //Not for deleting pedido or relatório
  static const rotaDeleteS3 = rotaBase + 'upload/files/';
  static const rotaDeletePhoto = rotaBase + 'upload/files/';
  static const rotaDeleteRadiografia = rotaBase + 'upload/files/';
  static const rotaDeleteModeloSup = rotaBase + 'upload/files/';
  static const rotaDeleteModeloInf = rotaBase + 'upload/files/';
  static const rotaDeletecompactUpload = rotaBase + 'upload/files/';
  static const rotaDeleteRelatorioUpload = rotaBase + 'upload/files/';
  //Delete routes
  static const rotaDeletePedido = rotaBase + 'deletar-pedido/';
}