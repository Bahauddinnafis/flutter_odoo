// ignore_for_file: unused_local_variable, avoid_print, unused_element, prefer_final_fields

import 'package:flutter/material.dart';
import 'config.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
    // Lakukan inisialisasi data atau tugas-tugas lain di sini
  }

  void sessionChanged(OdooSession sessionId) async {
    print('We got new session ID: ${sessionId.id}');
    // write to persistent storage
  }

  void loginStateChanged(OdooLoginEvent event) async {
    if (event == OdooLoginEvent.loggedIn) {
      print('Logged in');
    }
    if (event == OdooLoginEvent.loggedOut) {
      print('Logged out');
    }
  }

  void inRequestChanged(bool event) async {
    if (event) print('Request is executing'); // draw progress indicator
    if (!event) print('Request is finished'); // hide progress indicator
  }

  Future<void> otentikasi() async {
    const baseUrl = AppConfig.odooUrl;
    final client = OdooClient(baseUrl);
    var subscription = client.sessionStream.listen(sessionChanged);
    var loginSubscription = client.loginStream.listen(loginStateChanged);
    var inRequestSubscription = client.inRequestStream.listen(inRequestChanged);

    try {
      final session = await client.authenticate(AppConfig.database,
          _userNameController.text, _passwordController.text);
      print(session);
      print('Authenticated');
      _showLoginResultDialog('Berhasil Login');
    } on OdooException catch (e) {
      // Cleanup on odoo exception
      print(e);
      subscription.cancel();
      loginSubscription.cancel();
      inRequestSubscription.cancel();
      client.close();
      _showLoginResultDialog('Gagal Login');
    }
  }

  void _showLoginResultDialog(String result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Result'),
          content: Text(result),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog saat tombol ditekan
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  TextEditingController _userNameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(10),
              child: TextField(
                controller: _userNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your username',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                otentikasi();
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
