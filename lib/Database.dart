
import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pendiente_app/AmparoModel.dart';

class DBAmparo {

  DBAmparo._();
  static DBAmparo db = DBAmparo._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();                                    // if _database is null we instantiate it
    return _database;
  }

  Future<Database> factory DBAmparo() {                           // fixCombo (16 feb 2019): new factory para el combo, diferente forma de relacionar el db
    if(db == null) {
      db = DBAmparo._();
    }
    return db;
  }

  Future<Database> initDB() async {                                // fixCombo (16 feb 2019): add Future<Database>
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "Prueba.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {

          print('Creación base datos...');

          await db.execute(
              "create table g_registro ("
                  "registro integer  not null,"
                  "descripcion text not null )"
          );

          await db.execute(
              "create table amparo ("
                  "amparo integer primary key autoincrement,"
                  "concepto integer not null,"
                  "id integer not null,"
                  "nombre text not null,"

                  "foreign key (concepto) references g_registro ( registro ) on delete cascade on update no action )"
          );

          print('Creación tablas...');

          await db.execute(
              "insert into g_registro (registro, descripcion ) values"
                  "(11, 'Eliminado'   ),"  // -1   // auxiliar.sincronizar   y  g_perfil.estado
                  "(21,  'Desactivado'),"  // 0
                  "(31,  'Activo'     ),"  // 1
                  "(41,  'Ya casi'    ),"  // 1
                  "(51,  'Acion '     ) "  // 1
          );

          await db.execute(
              "insert into amparo ( concepto, id, nombre ) values"
                  "(11, 1, 'Pepe' ),"  // -1   // auxiliar.sincronizar   y  g_perfil.estado
                  "(21, 2, 'kiko' ),"  // 0
                  "(31, 3, 'July' ),"  // 1
                  "(11, 4, 'Anni' ) "  // 1
          );

          print('Inserción datos...');

          await db.execute(

              "create view v_amparo as "
                  "select xl.amparo, xl.concepto, xl.id, xl.nombre, rg.descripcion from amparo xl, g_registro rg "
                  "where xl.concepto = rg.registro "
          );

          print('Creación vistas...');

        });

  }

  Future<List<Map<String, dynamic>>> getConceptoMapList() async {  // fixCombo (16 feb 2019): gets all conceptos from database
    Database db = await this.database;
    var result = await db.rawQuery('select registro, descripcion from g_registro order by registro');
    return result;
  }

  Future<List<Concepto>> getConceptoList() async {                 // fixCombo (16 feb 2019): gets all conceptos from database => memory (conceptoList)
    var conceptoMapList = await getConceptoMapList();
    int count = conceptoMapList.length;
    List<Concepto> conceptoList = List<Concepto>();
    for(int i = 0; i < count; i++) {
      conceptoList.add(Concepto.fromMapObject(conceptoMapList[i]));
    }
    return conceptoList;
  }


  newAmparo(Amparo registro) async {

    final db = await database;

    //   'amparo ,orden ,poliza ,concepto ,dias ,fechaInicial ,fechaFinal ,tasa ,base ,tarifa ,valor ,tarifa0 ,valor0

    var crud = await db.rawInsert (
        "insert into amparo ( concepto, id, nombre ) "
            "values( ?, ?, ? )",
        [
          registro.concepto,
          registro.id,
          registro.nombre
        ]
    );   // newAmparo.sincronizar

    var consulta = await db.rawQuery("select max(amparo) as id from amparo");
    int id = consulta.first["id"];
    print('Última amparo: '+id.toString());

    return crud;
  }

  updateAmparo(Amparo registro) async {
    final db = await database;

    Amparo sincronizar = Amparo (
        concepto: registro.concepto,
        id: registro.id,
        nombre: registro.nombre
    );

    var crud = await db.update("amparo", sincronizar.toMap(),
        where: "amparo = ?", whereArgs: [registro.amparo]);

    return crud;
  }

  deleteAmparo( int id ) async {

    final db = await database;
    db.delete("amparo", where: "amparo = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("delete * from amparo");
  }

  getAmparo( int id ) async {
    final db = await database;
    var consulta = await db.query("v_amparo", where: "amparo = ? ", whereArgs: [id]);
    return consulta.isNotEmpty ? Amparo.fromMap(consulta.first) : null;
  }

  Future<List<Amparo>> getAllAmparo( ) async {

    String  poliza="1 = 1";
    final db = await database;
    var consulta = await db.query("v_amparo", orderBy: "amparo");

    List<Amparo> list =
    consulta.isNotEmpty ? consulta.map((c) => Amparo.fromMap(c)).toList() : [];
    return list;
  }

}

class AmparoBloc {

  AmparoBloc( int poliza ) {
    getAmparo( );
  }

  final _amparoController = StreamController<List<Amparo>>.broadcast();
  get amparos => _amparoController.stream;

  add( Amparo client ) {
    DBAmparo.db.newAmparo( client );
    getAmparo( );
  }

  update( Amparo client ) {
    DBAmparo.db.updateAmparo(client);
    getAmparo( );
  }

  delete( int id) {
    DBAmparo.db.deleteAmparo( id );
    getAmparo( );
  }

  dispose() {
    _amparoController.close();
  }

  getAmparo( ) async {
    _amparoController.sink.add(await DBAmparo.db.getAllAmparo( ));
  }

  blockUnblock( Amparo client ) {
//    DBAmparo.db.blockOrUnblock(client);
    getAmparo( );
  }

}