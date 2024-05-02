import 'package:flutter/material.dart';
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

  Future<void> loadRowBuku() async {
    // load data
    // var odooBox = await Hive.openBox('odoo');
    // var orpc = odooBox.get('orpc');

    setState(() {
      dataRows.add(
        DataRow(cells: [
          const DataCell(Text('Data 1')),
          DataCell(ElevatedButton(onPressed: () {}, child: const Text('Edit'))),
          DataCell(
              ElevatedButton(onPressed: () {}, child: const Text('Delete'))),
        ]),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadRowBuku();

      // ambil dari odoo
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
                    onChanged: (text) {},
                  ),
                ),
                ElevatedButton(onPressed: () {}, child: const Text('Add'))
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
