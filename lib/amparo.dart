import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pendiente_app/AmparoModel.dart';
import 'package:pendiente_app/Database.dart';
import 'package:sqflite/sqflite.dart';          // fixCombo (16 feb 2019): new variable
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:pendiente_app/players.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

class AmparoPage extends StatefulWidget {

  Amparo actual;
  AmparoPage({Key key, @required this.actual}) : super(
      key: key); // Manejo DB - Recibe en actual=datos(update) o actual=null(insert)

  @override
  _AmparoPageState createState() => _AmparoPageState();
}

class _AmparoPageState extends State<AmparoPage> {

  DBAmparo dbAmparo = DBAmparo();               // fixCombo (16 feb 2019): new variable
  List<Concepto> conceptos;                     // fixCombo (16 feb 2019): new variable

  int _amparo;
  var _concepto = null;                         // fixCombo (16 feb 2019): new variable
  var _id      = TextEditingController();
  var _nombre  = TextEditingController();

  DateTime fechaInicial    = DateTime.now();
  DateTime fechaFinal      = DateTime.now();
  final FocusNode _idFocus = FocusNode();

  InputType inputType = InputType.date;
  bool editable = false;

  final formats = {
    InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
    InputType.date: DateFormat('dd-MM-yyyy'),
    InputType.time: DateFormat("HH:mm"),
  };


  final bloc = AmparoBloc( 0 );                  // Manejo DB - llamado con el parametro de Póliza

  GlobalKey<AutoCompleteTextFieldState<String>> autoCompKey = GlobalKey();  // newFix
  AutoCompleteTextField searchTextField;
  TextEditingController controller = TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<Players>> key = new GlobalKey();

  void _loadData() async {
    await PlayersViewModel.loadPlayers();
  }

  void _actualizarFecha() {

    int ano = fechaInicial.year;
    ano = ano +  int.parse(_id.text);

    DateTime dt = DateTime.parse(
        ano.toString()+'-'+
            fechaInicial.month.toString().padLeft(2,'0')+'-'+
            fechaInicial.day.toString().padLeft(2,'0')+' 00:00:00.000');

    setState(() => fechaFinal = dt);
  }

  @override
  void initState() {

//    PlayersViewModel.loadPlayers();               // newFix

    if (widget.actual == null) {                 // Manejo DB es Insertar
      print('I N S E R T ...');
      _amparo = 0;
      _id.text      = '1';
      _nombre.text  = 'Guillermo';
    }
    else { // Manejo DB es Actualizar
      print('U P D A T E ...');
      _concepto    = widget.actual.concepto.toString();
      _amparo      = widget.actual.amparo;
      _id.text     = widget.actual.id.toString();
      _nombre.text = widget.actual.nombre.toString();
    }

    _loadData();
    super.initState();

  }

  _AmparoPageState();         // newFix

  @override
  Widget build(BuildContext context) {

    TextStyle textStyle = Theme.of(context).textTheme.title;
    if(conceptos == null) {
      conceptos = List<Concepto>();

      updateListView();
    }

    Widget datosIdentificacion = ExpansionTile(

      initiallyExpanded: true,
      title: Text(
        "Identificación",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      children: <Widget>[

        searchTextField = AutoCompleteTextField<Players>(
          style: new TextStyle(color: Colors.black, fontSize: 16.0),
          decoration: new InputDecoration(
            suffixIcon: Container(
              width: 85.0,
              height: 60.0,
            ),
            contentPadding: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 20.0),
            filled: true,
            hintText: 'Search Player Name',
            hintStyle: TextStyle(color: Colors.black)
          ),

          itemBuilder: (context, item) {    // listaDeResultado
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(item.autocompleteterm,
                  style: TextStyle(
                    fontSize: 16.0
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(15.0),
                ),
                Text(item.country,
                )
              ],
            );
          },
//todo suyo
          itemFilter: (item, query) {
            print('buscar:'+query.toString());
            return item.autocompleteterm.toLowerCase().startsWith(query.toLowerCase());
          },

          itemSorter: (a, b) {
            return a.autocompleteterm.compareTo(b.autocompleteterm);
          },

          itemSubmitted: (item) {
            setState(() => searchTextField.textField.controller.text = item.autocompleteterm);
            print('$item.id - $item.autocompleteterm');
          },

          key: key,

          suggestions: PlayersViewModel.players,

        ),

        ListTile (                              // fixCombo (16 feb 2019): new variable
          title: DropdownButton<String> (
            items: conceptos.map((dynamic item){
              return DropdownMenuItem<String>(
                value: item.registro.toString(),
                child: Text(item.descripcion),
              );
            }).toList(),
            value: _concepto,
            hint: new Text("Seleccione un amparo"),
            onChanged: (String newValueSelected) {
              print(newValueSelected);
              _onDropDownItemSelected(newValueSelected);
            },
          ),
        ),// concepto

        TextFormField(
          controller: _id,
          decoration: const InputDecoration(
            icon: const Icon(Icons.build ),
            hintText: 'ID',
            labelText: 'ID',
          ),

          focusNode: _idFocus,
          onFieldSubmitted: (_) {
            _idFocus.unfocus();
            _actualizarFecha();
          },

          keyboardType: TextInputType.phone,
          inputFormatters: [
            WhitelistingTextInputFormatter.digitsOnly,
          ],
        ),// id

        TextFormField(
          controller: _nombre,
          decoration: const InputDecoration(
            hintText: 'Nombre',
            labelText: 'Nombre',
          ),
        ),// nombre

      ],
    );

    // TODO: implement build
    return Scaffold (
      appBar: AppBar( title: Text("Amparo"), ),

      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          children: <Widget>[

            SizedBox(height: 12.0),

            datosIdentificacion,

            DateTimePickerFormField(
              inputType: inputType,
              format: formats[inputType],
              editable: editable,
              initialValue: fechaFinal,
              decoration: InputDecoration(
                  icon: const Icon(Icons.date_range),
                  labelText: 'Fecha final'),
              onChanged: (dt) => setState(() => fechaFinal = dt),
            ),

            Text(
              '$fechaFinal',
              style: Theme.of(context).textTheme.display1,
            ),

            SizedBox(height: 74.0),

          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.update,color: Colors.white,),

        onPressed: () async {
          Amparo ctv = Amparo(
            amparo:   _amparo,
            id:       int.parse(_id.text ),
            concepto: int.parse(_concepto.toString()),
            nombre:   _nombre.text,

          );

          if (widget.actual == null) {  // Manejo DB Insertar
            bloc.add( ctv );
          }
          else {                        // Manejo DB Actualizar
            bloc.update( ctv );
          }

          Navigator.pop(context);       // Regresa a la pantalla inicial

          setState(() {});              // Manejo DB Refrescar
        },
      ),


    );
  }


  void _onDropDownItemSelected(String newValueSelected) { // fixCombo (16 feb 2019): new function
    setState(() {
      this._concepto = newValueSelected;
    });
  }

  updateListView() async {                                 // fixCombo (16 feb 2019): new function
    final Future<Database> db = dbAmparo.initDB();
    db.then((datavalorAsegurado) {
      Future<List<Concepto>> conceptoListFuture = dbAmparo.getConceptoList();
      conceptoListFuture.then((conceptoList){
        setState(() {
          this.conceptos = conceptoList;
        });
      });
    }
    );
  }

  void updateInputType({bool date, bool time}) {}

}