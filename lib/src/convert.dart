// Copyright (c) 2021, Google LLC. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
//import 'dart:ffi';
//import 'dart:html';
import 'dart:typed_data';

import 'message.dart';

const BlobCodec blobCodec = BlobCodec();

const FalseCodec falseCodec = FalseCodec();

const FloatCodec floatCodec = FloatCodec();

const ImpulseCodec impulseCodec = ImpulseCodec();

const IntCodec intCodec = IntCodec();

const NullCodec nullCodec = NullCodec();

const OSCMessageCodec oscMessageCodec = OSCMessageCodec();

const StringCodec stringCodec = StringCodec();

const TimetagCodec timetagCodec = TimetagCodec();

const TrueCodec trueCodec = TrueCodec();

abstract class DataCodec<T> extends Codec<T, List<int>> {
  static final List<DataCodec<Object>> codecs =
      List<DataCodec<Object>>.unmodifiable(<DataCodec<Object>>[
    blobCodec,
    falseCodec,
    floatCodec,
    impulseCodec,
    intCodec,
    nullCodec,
    stringCodec,
    timetagCodec,
    trueCodec
  ]);

  final String typeTag;

  const DataCodec({required this.typeTag});

  bool appliesTo(Object? value) => value is T;

  int length(T value);

  T toValue(String string);

  /// TODO: Rename?
  static DataCodec<T> forType<T>(String typeTag) =>
      codecs.firstWhere((codec) => codec.typeTag == typeTag,
              orElse: (() =>
                  throw ArgumentError('Unsupported codec typeTag: $typeTag')))
          as DataCodec<T>;

  static DataCodec<T> forValue<T>(T value) =>
      codecs.firstWhere((codec) => codec.appliesTo(value),
          orElse: (() => throw ArgumentError(
              'Unsupported codec type: ${value.runtimeType}'))) as DataCodec<T>;
}

abstract class DataDecoder<T> extends Converter<List<int>, T> {
  const DataDecoder();
}

abstract class DataEncoder<T> extends Converter<T, List<int>> {
  const DataEncoder();
}

class BlobCodec extends DataCodec<Uint8List> {
  const BlobCodec() : super(typeTag: 'b');

  @override
  Converter<List<int>, Uint8List> get decoder => const BlobDecoder();

  @override
  Converter<Uint8List, List<int>> get encoder => const BlobEncoder();

  @override
  int length(Uint8List value) => value.lengthInBytes;

  @override
  Uint8List toValue(String string) => string.codeUnits as Uint8List;
}

class BlobDecoder extends DataDecoder<Uint8List> {
  const BlobDecoder();

  @override
  Uint8List convert(List<int> value) {
    final buffer = Uint8List.fromList(value).buffer;
    final byteData = ByteData.view(buffer);
    final len = byteData.getInt32(0);
    final retval = value.sublist(4, len + 4);
    return retval as Uint8List;
  }
}

class BlobEncoder extends DataEncoder<Uint8List> {
  const BlobEncoder();

  @override
  List<int> convert(Uint8List value) {
    final len = value.length;
    final list = Uint8List(4);
    final byteData = ByteData.view(list.buffer);
    byteData.setInt32(0, len);
    final retval = list.toList();
    retval.addAll(value);
    return retval;
  }
}

class FalseCodec extends DataCodec<String> {
  const FalseCodec() : super(typeTag: 'F');

  @override
  Converter<List<int>, String> get decoder => const FalseDecoder();

  @override
  Converter<String, List<int>> get encoder => const FalseEncoder();

  @override
  int length(String string) => string.length;

  @override
  String toValue(String string) => string;
}

class FalseDecoder extends DataDecoder<String> {
  const FalseDecoder();

  @override
  String convert(List<int> input) {
    return 'False';
  }
}

class FalseEncoder extends DataEncoder<String> {
  const FalseEncoder();

  @override
  List<int> convert(String input) {
    return List<int>.empty();
  }
}

class FloatCodec extends DataCodec<double> {
  const FloatCodec() : super(typeTag: 'f');

  @override
  Converter<List<int>, double> get decoder => const FloatDecoder();

  @override
  Converter<double, List<int>> get encoder => const FloatEncoder();

  @override
  int length(double value) => 4;

  @override
  double toValue(String string) => double.parse(string);
}

class FloatDecoder extends DataDecoder<double> {
  const FloatDecoder();

  @override
  double convert(List<int> value) {
    final buffer = Uint8List.fromList(value).buffer;
    final byteData = ByteData.view(buffer);
    return byteData.getFloat32(0);
  }
}

class FloatEncoder extends DataEncoder<double> {
  const FloatEncoder();

  @override
  List<int> convert(double value) {
    final list = Uint8List(4);
    final byteData = ByteData.view(list.buffer);
    byteData.setFloat32(0, value);
    return list;
  }
}

class ImpulseCodec extends DataCodec<String> {
  const ImpulseCodec() : super(typeTag: 'I');

  @override
  Converter<List<int>, String> get decoder => const ImpulseDecoder();

  @override
  Converter<String, List<int>> get encoder => const ImpulseEncoder();

  @override
  int length(String string) => string.length;

  @override
  String toValue(String string) => string;
}

class ImpulseDecoder extends DataDecoder<String> {
  const ImpulseDecoder();

  @override
  String convert(List<int> input) {
    return 'Impulse';
  }
}

class ImpulseEncoder extends DataEncoder<String> {
  const ImpulseEncoder();

  @override
  List<int> convert(String input) {
    return List<int>.empty();
  }
}

class IntCodec extends DataCodec<int> {
  const IntCodec() : super(typeTag: 'i');

  @override
  Converter<List<int>, int> get decoder => const IntDecoder();

  @override
  Converter<int, List<int>> get encoder => const IntEncoder();

  @override
  int length(int value) => 4;

  @override
  int toValue(String string) => int.parse(string);
}

class IntDecoder extends DataDecoder<int> {
  const IntDecoder();

  @override
  int convert(List<int> value) {
    final buffer = Uint8List.fromList(value).buffer;
    final byteData = ByteData.view(buffer);
    return byteData.getInt32(0);
  }
}

class IntEncoder extends DataEncoder<int> {
  const IntEncoder();

  @override
  List<int> convert(int value) {
    final list = Uint8List(4);
    final byteData = ByteData.view(list.buffer);
    byteData.setInt32(0, value);
    return list;
  }
}

class NullCodec extends DataCodec<String> {
  const NullCodec() : super(typeTag: 'N');

  @override
  Converter<List<int>, String> get decoder => const NullDecoder();

  @override
  Converter<String, List<int>> get encoder => const NullEncoder();

  @override
  int length(String string) => string.length;

  @override
  String toValue(String string) => string;
}

class NullDecoder extends DataDecoder<String> {
  const NullDecoder();

  @override
  String convert(List<int> input) {
    return 'Null';
  }
}

class NullEncoder extends DataEncoder<String> {
  const NullEncoder();

  @override
  List<int> convert(String input) {
    return List<int>.empty();
  }
}

class StringCodec extends DataCodec<String> {
  const StringCodec() : super(typeTag: 's');

  @override
  Converter<List<int>, String> get decoder => const StringDecoder();

  @override
  Converter<String, List<int>> get encoder => const StringEncoder();

  @override
  int length(String value) => value.length;

  @override
  String toValue(String string) => string;
}

class StringDecoder extends DataDecoder<String> {
  const StringDecoder();

  @override
  String convert(List<int> input) {
    final nextNull = input.indexOf(0);
    if (nextNull == -1) {
      return utf8.decode(input);
    } else {
      return utf8.decode(input.sublist(0, nextNull));
    }
  }
}

class StringEncoder extends DataEncoder<String> {
  const StringEncoder();

  @override
  List<int> convert(String input) {
    // final bytes = utf8.encode(input).toList();
    final bytes = input.codeUnits.toList();
    bytes.add(0);

    final pad = (4 - bytes.length % 4) % 4;
    bytes.addAll(List.generate(pad, (i) => 0));

    return bytes;
  }
}

class TimetagCodec extends DataCodec<int> {
  const TimetagCodec() : super(typeTag: 't');

  @override
  Converter<List<int>, int> get decoder => const TimetagDecoder();

  @override
  Converter<int, List<int>> get encoder => const TimetagEncoder();

  @override
  int length(int value) => 8;

  @override
  int toValue(String string) => int.parse(string);
}

class TimetagDecoder extends DataDecoder<int> {
  const TimetagDecoder();

  @override
  int convert(List<int> value) {
    final buffer = Uint8List.fromList(value).buffer;
    final byteData = ByteData.view(buffer);
    return byteData.getInt64(0);
  }
}

class TimetagEncoder extends DataEncoder<int> {
  const TimetagEncoder();

  @override
  List<int> convert(int value) {
    final list = Uint8List(8);
    final byteData = ByteData.view(list.buffer);
    byteData.setInt64(0, value);
    return list;
  }
}

class TrueCodec extends DataCodec<String> {
  const TrueCodec() : super(typeTag: 'T');

  @override
  Converter<List<int>, String> get decoder => const TrueDecoder();

  @override
  Converter<String, List<int>> get encoder => const FalseEncoder();

  @override
  int length(String string) => string.length;

  @override
  String toValue(String string) => string;
}

class TrueDecoder extends DataDecoder<String> {
  const TrueDecoder();

  @override
  String convert(List<int> input) {
    return 'True';
  }
}

class TrueEncoder extends DataEncoder<String> {
  const TrueEncoder();

  @override
  List<int> convert(String input) {
    return List<int>.empty();
  }
}

class OSCMessageBuilder {
  final _builder = BytesBuilder();

  int get length => _builder.length;

  void addAddress(String address) {
    addString(address);
  }

  void addArguments(List<Object> args) {
    final codecs = args.map(DataCodec.forValue).toList();

    // Type tag (e.g., `,iis`).
    final sb = StringBuffer();
    sb.write(',');
    for (var codec in codecs) {
      sb.write(codec.typeTag);
    }
    addString(sb.toString());

    // Args.
    for (var i = 0; i < args.length; ++i) {
      addBytes(codecs[i].encode(args[i]));
    }
  }

  void addBytes(List<int> bytes) {
    _builder.add(bytes);
  }

  void addString(String string) {
    _builder.add(stringCodec.encode(string));
  }

  List<int> toBytes() => _builder.toBytes();
}

class OSCMessageCodec extends Codec<OSCMessage, List<int>> {
  const OSCMessageCodec();

  @override
  Converter<List<int>, OSCMessage> get decoder => const OSCMessageDecoder();

  @override
  Converter<OSCMessage, List<int>> get encoder => const OSCMessageEncoder();
}

class OSCMessageDecoder extends DataDecoder<OSCMessage> {
  const OSCMessageDecoder();

  @override
  OSCMessage convert(List<int> input) => OSCMessageParser(input).parse();
}

class OSCMessageEncoder extends DataEncoder<OSCMessage> {
  const OSCMessageEncoder();

  @override
  List<int> convert(OSCMessage msg) {
    final builder = OSCMessageBuilder();
    builder.addAddress(msg.address);
    builder.addArguments(msg.arguments);
    return builder.toBytes();
  }
}

class OSCMessageParser {
  int index = 0;

  final List<int> input;
  OSCMessageParser(this.input);

  void advance({required String char}) {
    if (input[index++] != stringCodec.encode(char)[0]) {
      //TODO: throw
    }
  }

  void align() {
    index += (4 - index % 4) % 4;
  }

  String asString(List<int> bytes) => stringCodec.decode(bytes);

  void eat({required int byte}) {
    if (input[++index] != byte) {
      //TODO: throw
    }
  }

  OSCMessage parse() {
    final addressBytes = takeUntil(byte: 0);
    final address = asString(addressBytes);

    eat(byte: 0);
    align();

    advance(char: ',');
    final args = <Object>[];
    final typeTagBytes = takeUntil(byte: 0);
    if (typeTagBytes.isNotEmpty) {
      eat(byte: 0);
      align();

      final codecs =
          typeTagBytes.map((b) => DataCodec.forType(asString(<int>[b])));
      for (var codec in codecs) {
        switch (codec) {
          case trueCodec:
            args.add("true");
            break;
          case falseCodec:
            args.add("false");
            break;
          case impulseCodec:
            args.add("impulse");
            break;
          case nullCodec:
            args.add("null");
            break;
          default:
            final value = codec.decode(input.sublist(index));
            args.add(value);
            index += codec.length(value);
        }
        //index += codec.length(value);
        // if (value is String) eat(byte: 0);
        align();
      }
    }

    return OSCMessage(address, arguments: args);
  }

  List<int> takeUntil({required int byte}) {
    final count = input.indexOf(byte, index) - index;
    if (count < 1) {
      //TODO: throw
    }

    return input.sublist(index, index += count);
  }
}
