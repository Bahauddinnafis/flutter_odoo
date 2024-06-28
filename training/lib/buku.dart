// ignore_for_file: prefer_final_fields, unused_local_variable, unused_field, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'config.dart';
// import 'package:provider/provider.dart';
// import 'session_manager.dart'; // import class yang sudah dibuat

// import 'package:hive/hive.dart';

class EditBukuPop extends StatefulWidget {
  final int id;
  final String namaBuku;

  EditBukuPop(this.id, this.namaBuku);

  @override
  _EditBukuPopState createState() => _EditBukuPopState();
}

class _EditBukuPopState extends State<EditBukuPop> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.namaBuku);
  }

  Future<void> updateKeOdoo(int id, String namaBuku) async {
    const baseUrl = AppConfig.odooUrl;
    final client = OdooClient(baseUrl);

    var odooBox = await Hive.openBox('odoo');
    String username = odooBox.get('username');
    String password = odooBox.get('password');

    final session =
        await client.authenticate(AppConfig.database, username, password);

    var res = await client.callKw({
      'model': 'product.template',
      'method': 'write',
      'args': [
        id,
        {
          'name': namaBuku,
        },
      ],
      'kwargs': {},
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // title: Text('Edit Buku ${widget.id}'),
      title: Text('Edit Buku'),
      content: TextField(
        controller: _textEditingController,
        decoration: InputDecoration(hintText: widget.namaBuku),
      ),
      actions: <Widget>[
        MaterialButton(
          onPressed: () {
            // Aksi ketika tombol Update ditekan
            String newText = _textEditingController.text;
            updateKeOdoo(widget.id, newText);
            // Lakukan sesuatu dengan newText
            Navigator.of(context).pop();
            // refresh tampilan
          },
          child: Text('Update'),
        ),
        MaterialButton(
          onPressed: () {
            // Aksi ketika tombol Cancel ditekan
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}

class Buku extends StatefulWidget {
  const Buku({super.key});

  @override
  State<Buku> createState() => _BukuState();
}

class _BukuState extends State<Buku> {
  List<DataRow> dataRows = []; // Variabel untuk menyimpan DataRow
  final orpc = OdooClient(AppConfig.odooUrl);
  String username = '';
  String password = '';

  TextEditingController _controllerNamaBuku = TextEditingController();
  String _textValueNamaBuku = '';

  Future<void> loadRowBuku() async {
    // load data
    // var odooBox = await Hive.openBox('odoo');
    // var orpc = odooBox.get('orpc');

    // setState(() {
    //   dataRows.add(
    //     DataRow(cells: [
    //       const DataCell(Text('Data 1')),
    //       DataCell(ElevatedButton(onPressed: () {}, child: const Text('Edit'))),
    //       DataCell(
    //           ElevatedButton(onPressed: () {}, child: const Text('Delete'))),
    //     ]),
    //   );
    // });
  }

  void editBukuPop(int id, String namaBuku) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditBukuPop(id, namaBuku);
      },
    ).then((_) {
      loadOdoo();
    });
  }

  Future<void> loadOdoo() async {
    var odooBox = await Hive.openBox('odoo');
    username = odooBox.get('username');
    password = odooBox.get('password');

    const baseUrl = AppConfig.odooUrl;
    final client = OdooClient(baseUrl);
    final session =
        await client.authenticate(AppConfig.database, username, password);

    try {
      var bukus = await client.callKw({
        'model': 'product.template',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': [
            'id',
            'name',
            'is_book',
            'qty',
            'qty_pinjam',
            'book_available',
            'categ_id',
            'active'
          ],
          'domain': [
            [
              'is_book',
              '=',
              true
            ], 
            ['active', '=', true]
          ],
        },
      });
      dataRows = [];
      print('Books loaded from Odoo: $bukus'); 
      for (var buku in bukus) {
        String name = buku["name"];
        print(
            'Book: ${buku["id"]}, Name: $name, Is Book: ${buku["is_book"]}, Qty: ${buku["qty"]}, Qty Pinjam: ${buku["qty_pinjam"]}, Book Available: ${buku["book_available"]}, Categ ID: ${buku["categ_id"]}, Active: ${buku["active"]}');
        setState(() {
          dataRows.add(
            DataRow(cells: [
              DataCell(Text(name)),
              DataCell(
                ElevatedButton(
                  onPressed: () {
                    editBukuPop(buku['id'], name);
                  },
                  child: Text('Edit'),
                ),
              ),
              DataCell(
                ElevatedButton(
                  onPressed: () async {
                    final session = await client.authenticate(
                        AppConfig.database, username, password);
                    var res = await client.callKw({
                      'model': 'product.template',
                      'method': 'write',
                      'args': [
                        buku['id'],
                        {
                          'active': false,
                        },
                      ],
                      'kwargs': {},
                    });
                    setState(() {
                      loadOdoo();
                    });
                  },
                  child: Text('Delete'),
                ),
              ),
            ]),
          );
        });
      }
    } on Exception catch (e) {
      print('Gagal memuat data buku: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadOdoo();
      loadRowBuku();

      // ambil dari odoo
    });
  }

  Future<void> createBook() async {
    String namaBuku = _controllerNamaBuku.text;
    const baseUrl = AppConfig.odooUrl;
    final client = OdooClient(baseUrl);

    final session =
        await client.authenticate(AppConfig.database, username, password);

    var bukuId = await client.callKw({
      'model': 'product.template',
      'method': 'create',
      'args': [
        {
          'name': namaBuku,
          'is_book': true, 
          'categ_id': 1, 
          'qty': 10 
        },
      ],
      'kwargs': {},
    });
    print('Created Book ID: $bukuId');
    setState(() {
      loadOdoo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Nama Buku : '),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _controllerNamaBuku,
                    onChanged: (text) {},
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      createBook();
                    },
                    child: const Text('Add'))
              ],
            ),
          ),
          DataTable(
            columns: const [
              DataColumn(label: Text('Nama Buku')),
              DataColumn(label: Text('')),
              DataColumn(label: Text('')),
            ],
            rows: dataRows,
          ),
        ],
      ),
    ));
  }
}
