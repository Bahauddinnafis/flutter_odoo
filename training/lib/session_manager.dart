import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class SessionManager with ChangeNotifier {
  OdooSession? _session;

  OdooSession? get session => _session;

  void setSession(OdooSession session) {
    _session = session;
    notifyListeners();
  }
}
