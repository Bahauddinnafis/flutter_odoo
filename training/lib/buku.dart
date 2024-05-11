// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'config.dart';
import 'package:provider/provider.dart';
import 'session_manager.dart'; // import class yang sudah dibuat

// import 'package:hive/hive.dart';

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

  Future<void> loadOdoo() async {
    var odooBox = await Hive.openBox('odoo');
    username = odooBox.get('username');
    password = odooBox.get('password');

    const baseUrl = AppConfig.odooUrl;
    final client = OdooClient(baseUrl);
    final session =
        await client.authenticate(AppConfig.database, username, password);

    var bukus = await client.callKw({
      //tipenya list
      'model': 'product.template',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'fields': ['id', 'name'],
        'domain': [
          ['categ_id', '=', 1]
        ],
      },
    });
    dataRows = [];
    for (var buku in bukus) {
      String name = buku["name"];
      setState(() {
        dataRows.add(
          DataRow(cells: [
            DataCell(Text(name)),
            DataCell(
              ElevatedButton(
                onPressed: () {
                  // editBukuPop();
                  // Logika untuk mengedit
                },
                child: Text('Edit'),
              ),
            ),
            DataCell(
              ElevatedButton(
                onPressed: () {
                  // Logika untuk menghapus
                },
                child: Text('Delete'),
              ),
            ),
          ]),
        );
      });
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
          'categ_id': 1,
        },
      ],
      'kwargs': {},
    });

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
