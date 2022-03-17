import 'package:osc/src/TCP.dart';
import 'dart:io';

Future<void> main() async {
  var address = await getIP();
  print(address);
  var externalDevice = OSCTCPSocket(consoleAddress: address, consolePort: 3032);
  externalDevice.setupConnection();
  externalDevice.listen((msg) {});
  externalDevice.send('/eos/get/cue/1/1', List.empty());
}

Future<String> getIP() async {
  var interfaces = await NetworkInterface.list();
  print(interfaces[0].addresses[0].address);
  var address = interfaces[0].addresses[0].address;
  return address;
}
