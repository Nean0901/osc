// Copyright (c) 2021, Google LLC. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';

import '../osc.dart';

class OSCTCPSocket {
  final String? consoleAddress;
  final int? consolePort; //NOTE: Eos will always do TCP on port 3032

  Socket? _socket;

  OSCTCPSocket({this.consoleAddress, this.consolePort});

  void close() {
    _socket!.close();
  }

  Future<Socket> setupConnection() async {
    var address = consoleAddress ?? InternetAddress.anyIPv4;
    var port = consolePort ?? 3032; //Eos Defaults to 3032
    return Socket.connect(address, port);
  }

  Future<void> listen(void Function(OSCMessage msg) onData) async {
    _socket ??= await setupConnection();
    print(
        'connected to ${_socket!.remoteAddress.address}:${_socket!.remotePort}');
    _socket!.listen(
      // handle data from the server
      (Uint8List data) {
        var dataList = data
            .toList(); //Convert from Uint8 to Normal List to enable growable list options
        //find number of commands in the packet
        var numCommands = 0; //Number of packets in the bundle (default 1)
        //find number of instances of 192
        dataList.forEach((element) {
          if (element == 192) {
            numCommands++;
          }
        });
        numCommands = (numCommands / 2).round();
        //cleave into portions
        var strippedData = List<List<int>>.generate(
            numCommands, (i) => List.empty(growable: true));
        //Create List of Lists for stripped data
        //feed each packet to it sequentially
        for (var i = 0; i < numCommands; i++) {
          strippedData[i] = dataList.sublist(1, dataList.indexOf(192, 2));
          dataList.removeRange(0, dataList.indexOf(192, 2) + 1);
          var msg = OSCMessage.fromBytes(strippedData[i]);
          onData(msg);
        }
      },
      onError: (error) {
        print(error);
        _socket!.destroy();
      },
    );
  }

  Future<void> send(String address, List<Object> args) async {
    _socket ??= await setupConnection();
    var message = OSCMessage(address,
        arguments:
            args); //Build OSC Message using the Builder function in the OSC Library
    var messageBytes = List.from(message
        .toBytes()); //Convert message to growable list ready to add the SLIP start & end bytes.

    //Add SLIP bytes
    messageBytes.insert(0, 192);
    messageBytes.add(192);

    print('Sent: $message');
    print('Sent: ${message.toBytes()}');

    var messageInts = messageBytes.cast<
        int>(); //Convert the OSC Message bytes into a fixed length list for sending (socket.add only takes ints)

    _socket!.add(messageInts);
    await listen((msg) {});
  }
}
