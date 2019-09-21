import 'package:scoped_model/scoped_model.dart';

class MainModel extends Model {
  String _socketId = "";

  String get socketId {
    return _socketId;
  }

  void updateSocketId(String socketId) {
    _socketId = socketId;
  }
}