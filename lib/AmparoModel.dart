import 'dart:convert';

Amparo amparoFromJson(String str) {
  final jsonData = json.decode(str);
  return Amparo.fromMap(jsonData);
}

String amparoToJson(Amparo data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}


class Amparo {
  int amparo;

  int concepto;
  int id;
  String nombre;
  String descripcion;

  Amparo({
    this.amparo,

    this.concepto,
    this.id,
    this.nombre,
    this.descripcion,
  });

  static get amparos => null;

  static List<Amparo> filterAmparosByQuery(String query) {
    return amparos
        .where(
            (amparo) => amparo.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  factory Amparo.fromMap(Map<String, dynamic> json) => new Amparo(
    amparo: json["amparo"],

    concepto: json["concepto"],
    id: json["id"],
    nombre: json["nombre"],
    descripcion: json["descripcion"],
  );

  Map<String, dynamic> toMap() => {
    "concepto": concepto,
    "id": id,
    "nombre": nombre,
  };
}

class Concepto {                  // fixCombo (16 feb 2019): Nueva clase para el combo

  int    _registro;
  String _descripcion;

  Concepto(this._descripcion);
  Concepto.withId(this._registro,this._descripcion);

  int    get registro =>    _registro;
  String get descripcion => _descripcion;

  set descripcion(String value) {
    _descripcion = value;
  }

  //This function is to convert Concepto Object to Map Object for datavalorAsegurado
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if(registro != null) {
      map['registro'] = _registro;
    }
    map['descripcion'] = _descripcion;
    return map;
  }

  Concepto.fromMapObject(Map<String, dynamic> map){
    this._registro    = map['registro'];
    this._descripcion = map['descripcion'];
  }
}
