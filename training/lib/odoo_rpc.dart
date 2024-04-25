// ignore_for_file: unused_local_variable, avoid_print, prefer_const_declarations

import 'config.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class Odoorpc {
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

  // Odoorpc() {
  //   final baseUrl = AppConfig.odooUrl;
  //   final client = OdooClient(baseUrl);
  //   // Subscribe to session changes to store most recent one
  //   var subscription = client.sessionStream.listen(sessionChanged);
  //   var loginSubscription = client.loginStream.listen(loginStateChanged);
  //   var inRequestSubscription = client.inRequestStream.listen(inRequestChanged);
  //   client.authenticate('training', 'admin', 'mn').then((session) {
  //     print(session);
  //     print('Authenticated');
  //   }).catchError((e) {
  //     // Cleanup on Odoo exception
  //     print(e);
  //     subscription.cancel();
  //     loginSubscription.cancel();
  //     inRequestSubscription.cancel();
  //     client.close();
  //   });
  // }
  login() async {
    final baseUrl = AppConfig.odooUrl;
    final client = OdooClient(baseUrl);
    // Subscribe to session changes to store most recent one
    var subscription = client.sessionStream.listen(sessionChanged);
    var loginSubscription = client.loginStream.listen(loginStateChanged);
    var inRequestSubscription = client.inRequestStream.listen(inRequestChanged);
    await client.authenticate('training', 'admin', 'mn').then((session) {
      // return session;
      print(session);
      return 'berhasil';

      // print('Authenticated');
    }).catchError((e) {
      // Cleanup on Odoo exception
      print(e);
      subscription.cancel();
      loginSubscription.cancel();
      inRequestSubscription.cancel();
      client.close();
      return e;
    });
  }
}
