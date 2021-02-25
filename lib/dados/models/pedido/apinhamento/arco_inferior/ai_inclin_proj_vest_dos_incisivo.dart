class AiInclinProjVestDosIncisivo {
  int id;
  bool ate8graus2mm;
  bool qtoNecessarioEvitarDip;
  String outros;

  AiInclinProjVestDosIncisivo({
    this.id,
    this.ate8graus2mm,
    this.qtoNecessarioEvitarDip,
    this.outros,
  });

  factory AiInclinProjVestDosIncisivo.fromJson(Map<String, dynamic> data) {
    return AiInclinProjVestDosIncisivo(
      id: data['id'],
      ate8graus2mm: data['ate_8_graus_2mm'],
      qtoNecessarioEvitarDip: data['qto_necessario_evitar_dip'],
      outros: data['outros'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ate_8_graus_2mm': ate8graus2mm,
      'qto_necessario_evitar_dip': qtoNecessarioEvitarDip,
      'outros': outros,
    };
  }
}