import 'package:flutter/material.dart';
import '../database/session_dao.dart';
import '../models/session.dart';

class HistoryProvider extends ChangeNotifier {
  List<Session> _sessions = [];
  bool _loading = false;

  List<Session> get sessions => _sessions;
  bool get loading => _loading;

  Future<void> load(int profileId) async {
    _loading = true;
    notifyListeners();
    _sessions = await SessionDao.getHistory(profileId);
    _loading = false;
    notifyListeners();
  }

  void clear() {
    _sessions = [];
    notifyListeners();
  }
}
