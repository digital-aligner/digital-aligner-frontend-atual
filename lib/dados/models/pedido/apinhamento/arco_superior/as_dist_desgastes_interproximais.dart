class AsDistDesgastesInterproximais {
  int id;
  bool ate3mm;
  bool ate5mm;
  bool qtoNecessarioEvitarDip;
  String outros;

  AsDistDesgastesInterproximais({
    this.id,
    this.ate3mm,
    this.ate5mm,
    this.qtoNecessarioEvitarDip,
    this.outros,
  });

  factory AsDistDesgastesInterproximais.fromJson(Map<String, dynamic> data) {
    return AsDistDesgastesInterproximais(
      id: data['id'],
      ate3mm: data['ate_3mm'],
      ate5mm: data['ate_5mm'],
      qtoNecessarioEvitarDip: data['qto_necessario_evitar_dip'],
      outros: data['outros'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ate_3mm': ate3mm,
      'ate_5mm': ate5mm,
      'qto_necessario_evitar_dip': qtoNecessarioEvitarDip,
      'outros': outros,
    };
  }
}