import 'dart:io';

import 'package:odoo_rpc/odoo_rpc.dart';

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

void main() async {
  final baseUrl = 'http://localhost:8069';
  final client = OdooClient(baseUrl);
  // Subscribe to session changes to store most recent one
  var subscription = client.sessionStream.listen(sessionChanged);
  var loginSubscription = client.loginStream.listen(loginStateChanged);
  var inRequestSubscription = client.inRequestStream.listen(inRequestChanged);

  try {
    // Authenticate to server with db name and credentials
    final session = await client.authenticate('training', 'admin', 'mn');
    print(session);
    print('Authenticated');

    // create user

    print('\nDestroying session');
    await client.destroySession();
    print('ok');
  } on OdooException catch (e) {
    // Cleanup on odoo exception
    print(e);
    await subscription.cancel();
    await loginSubscription.cancel();
    await inRequestSubscription.cancel();
    client.close();
    exit(-1);
  }
}
