import 'package:isar/isar.dart';

//this is schema file

part 'server.g.dart';

@collection
class Server {
  Id id = Isar.autoIncrement;
  late String deviceName;
  late String deviceIp;
  late bool status;
}
