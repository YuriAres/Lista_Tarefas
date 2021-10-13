import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main(List<String> args) {
  runApp(MaterialApp(
      home: const Inicio(),
      theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          unselectedWidgetColor: Colors.blueGrey,
          textSelectionTheme:
              TextSelectionThemeData(cursorColor: Colors.blueGrey[800]),
          inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueGrey.shade800)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueGrey.shade800))))));
}

class Inicio extends StatefulWidget {
  const Inicio({Key? key}) : super(key: key);

  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  List lista = [];
  Map<String, dynamic> lastitem = {};
  late dynamic lastpos;

  TextEditingController dataController = TextEditingController();

  Future<File> getfile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/data.json");
  }

  Future<File> saveFile() async {
    final data = jsonEncode(lista);
    File arquivo = await getfile();
    return arquivo.writeAsString(data);
  }

  Future<String> readFile() async {
    try {
      File arquivo = await getfile();
      return arquivo.readAsString();
    } catch (e) {
      const e = "Erro!";
      return e;
    }
  }

  @override
  void initState() {
    super.initState();
    readFile().then((value) {
      setState(() {
        lista = json.decode(value);
      });
    });
  }

  adicionar() {
    setState(() {
      Map<String, dynamic> newtask = {};
      newtask["Nome"] = dataController.text;
      dataController.text = "";
      newtask["Valor"] = false;
      lista.add(newtask);
      saveFile();
    });
  }

  Widget itemBuilder(context, index) {
    return Dismissible(
      key: UniqueKey(),
      child: CheckboxListTile(
          title: Text(lista[index]["Nome"]),
          value: lista[index]["Valor"],
          onChanged: (c) {
            setState(() {
              lista[index]["Valor"] = c;
              saveFile();
            });
          },
          secondary: CircleAvatar(
              child: Icon(
                lista[index]["Valor"] ? Icons.done : Icons.access_time,
                color: Colors.white,
              ),
              backgroundColor: Colors.blueGrey[800])),
      background: Container(
          color: Colors.blueGrey[800],
          child: const Align(
              alignment: Alignment(-0.9, 0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ))),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        setState(() {
          lastitem = Map.from(lista[index]);
          lastpos = index;
          lista.removeAt(index);
          saveFile();

          final snack = SnackBar(
            content: Text("A tarefa \"${lastitem["Nome"]}\" foi removida! ",
                style: TextStyle(color: Colors.blueGrey[800])),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    lista.insert(lastpos, lastitem);
                    saveFile();
                  });
                }),
            backgroundColor: Colors.blueGrey[50],
            duration: const Duration(seconds: 3),
          );
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<void> refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      lista.sort((a, b) {
        if (a["Valor"] && !b["Valor"]) {
          return 1;
        } else if (!a["Valor"] && b["Valor"]) {
          return -1;
        } else {
          return 0;
        }
      });
    });
    saveFile();
  }

  Widget listbuilder() {
    return ListView.builder(
        itemCount: lista.length,
        itemBuilder: (context, index) {
          return itemBuilder(context, index);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Lista de tarefas"),
          centerTitle: true,
          backgroundColor: Colors.blueGrey[900],
        ),
        body: Column(
          // ignore: prefer_const_constructors
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 15, 10, 7),
                child: TextField(
                    decoration: InputDecoration(
                        label: const Text("Nova Tarefa"),
                        labelStyle: TextStyle(color: Colors.blueGrey[800])),
                    controller: dataController)),
            Align(
              alignment: const Alignment(0.9, 0.8),
              child: ElevatedButton(
                onPressed: adicionar,
                child: const Text("Adicionar"),
                style: ElevatedButton.styleFrom(primary: Colors.blueGrey[800]),
              ),
            ),
            Divider(color: Colors.blueGrey[300]),
            Expanded(
                child: RefreshIndicator(
                    color: Colors.blueGrey[600],
                    onRefresh: refresh,
                    child: listbuilder()))
          ],
        ));
  }
}
