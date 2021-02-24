class AiExpansaoTransversal {
  int id;
  bool ate2_5mmPorLado;
  bool qtoNecessarioEvitarDip;

  AiExpansaoTransversal({
    this.id,
    this.ate2_5mmPorLado,
    this.qtoNecessarioEvitarDip,
  });

  factory AiExpansaoTransversal.fromJson(Map<String, dynamic> data) {
    return AiExpansaoTransversal(
      id: data['id'],
      ate2_5mmPorLado: data['ate_2_5mm_por_lado'],
      qtoNecessarioEvitarDip: data['qto_necessario_evitar_dip'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ate_2_5mm_por_lado': ate2_5mmPorLado,
      'qto_necessario_evitar_dip': qtoNecessarioEvitarDip,
    };
  }
}
