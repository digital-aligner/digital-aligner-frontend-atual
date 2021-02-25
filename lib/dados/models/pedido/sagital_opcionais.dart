class SagitalOpcionais {
  int id;
  bool desgastesInterproximais;
  bool recorteElasticoAlinhador;
  bool recorteAlinhadorBotao;
  bool alivioAlinhadorBracoForca;
  String localRecElastAlinh;
  String localRecAlinhBotao;
  String localAlivioAlinhador;

  SagitalOpcionais({
    this.id,
    this.desgastesInterproximais,
    this.recorteElasticoAlinhador,
    this.recorteAlinhadorBotao,
    this.alivioAlinhadorBracoForca,
    this.localRecElastAlinh,
    this.localRecAlinhBotao,
    this.localAlivioAlinhador,
  });

  factory SagitalOpcionais.fromJson(Map<String, dynamic> data) {
    return SagitalOpcionais(
      id: data['id'],
      desgastesInterproximais: data['desgastes_interproximais'],
      recorteElasticoAlinhador: data['recorte_elastico_alinhador'],
      recorteAlinhadorBotao: data['recorte_alinhador_botao'],
      alivioAlinhadorBracoForca: data['alivio_alinhador_braco_forca'],
      localRecElastAlinh: data['local_rec_elast_alinh'],
      localRecAlinhBotao: data['local_rec_alinh_botao'],
      localAlivioAlinhador: data['local_alivio_alinhador'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'desgastes_interproximais': desgastesInterproximais,
      'recorte_elastico_alinhador': recorteElasticoAlinhador,
      'recorte_alinhador_botao': recorteAlinhadorBotao,
      'alivio_alinhador_braco_forca': alivioAlinhadorBracoForca,
      'local_rec_elast_alinh': localRecElastAlinh,
      'local_rec_alinh_botao': localRecAlinhBotao,
      'local_alivio_alinhador': localAlivioAlinhador,
    };
  }
}