import 'package:flutter/material.dart';
import 'package:pendiente_app/Database.dart';
import 'package:pendiente_app/AmparoModel.dart';
import 'amparo.dart';                    // (Verificar)
import 'package:loader_search_bar/loader_search_bar.dart';

class AmparoList extends StatefulWidget {

  int actualPoliza;
  AmparoList( @required this.actualPoliza ); // Manejo DB - Recibe en actualPoliza=datos(update) o actualPoliza=null(insert)

  @override
  _AmparoListState createState() => _AmparoListState();
}

class _AmparoListState extends State<AmparoList> {

  @override
  Widget build(BuildContext context) {

    final bloc = AmparoBloc( this.widget.actualPoliza );  //new separate
    TextEditingController busqueda = TextEditingController();

    DateTime fechaFinal   = DateTime.now();

    @override
    void initState() {
    }

    @override//new separate
    void dispose() {
      bloc.dispose();
      super.dispose();
    }

    return new Scaffold(
      //appBar: AppBar(
      //  title: new Text("Lista", style: new TextStyle(color: Colors.white),),
      //),
        appBar: SearchBar(
          iconified: true,
          searchHint: 'Buscar amparos...',

          defaultBar: AppBar(),
/*
          loader: QuerySetLoader<Amparo>(
            querySetCall: Amparo.filterAmparosByQuery,
            itemBuilder: Amparo.buildAmparoRow,
            loadOnEachChange: true,
            animateChanges: true,
          ),
*/
        ),


        body: Container(
          child: Column(
            children: <Widget>[

/*
              Container (
                margin: EdgeInsets.fromLTRB(8, 32, 8, 9),
                height: 40,
                alignment: Alignment.topCenter,

                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: new Border.all(color: Colors.grey[400],),
                    borderRadius: BorderRadius.all(Radius.circular(8.0))
                ),
                child: TextField (
                  onChanged: (value) {
                    //filterSearchResults(value);
                    print('A buscar:'+busqueda.toString());
                  },
                  controller: busqueda,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                    hintText: "Buscar",
                  ),
                ),
              ),// seekWidget
*/

              Expanded(
                child: StreamBuilder<List<Amparo>>(  //new separate
                  stream: bloc.amparos, //new separate

                  //body: FutureBuilder<List<Amparo>>(  //new separate
                  //future: DBProvider.db.getAllAmparo(), //new separate

                  builder: (BuildContext context, AsyncSnapshot<List<Amparo>> snapshot) {
                    if (snapshot.hasData) {
                      //          return ListView.builder(
                      return ListView.separated(

                        separatorBuilder: (context, index) => Divider(
                          color: Colors.grey[300],
                        ),

                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          Amparo item = snapshot.data[index];
                          //                ok = snapshot.data[index].amparo;
                          return Dismissible (
                            key: UniqueKey(),

                            background: Container(
                              alignment: AlignmentDirectional.centerEnd,
                              color: Theme.of(context).accentColor,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                                child:
                                Icon(Icons.delete, color: Colors.white,
                                ),
                              ),
                            ),

                            onDismissed: (direction) {
                              bloc.delete( item.amparo );     // Manejo DB Borrar
                            },

                            child: ListTile(
                              onTap: () {
                                Navigator.push(                           // Manejo DB Actualizar
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AmparoPage(actual: item)
                                    )
                                );
                              },

                              leading: CircleAvatar(
                                  child: Text( item.amparo.toString() )
                              ),

                              title: Text( '( '+item.id.toString()+' ) '+item.nombre,
                                style: TextStyle(fontWeight: FontWeight.bold),   // fontSize: 18,
                              ),

                              //child: row(
                              //children[
                              subtitle: Text(item.descripcion.toString()),
                              //],
                              //),

                            ), // ListTile
                          );  // Dismissible
                        }, //itemBuilder
                      );
                    }
                    else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),

              SizedBox(height: 54.0),

            ],
          ),
        ),


        floatingActionButton:Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[

              FloatingActionButton(
                heroTag: null,
                child: Icon(Icons.add,color: Colors.white,),

                onPressed: () async {
                  Navigator.push( context,
                      new MaterialPageRoute(
                          builder: (context) => new AmparoPage()    // Manejo DB Adicionar Actividad (Verificar)
                      )
                  );
                },
              ),

            ]
        )

    );
  } // Widget build

}
