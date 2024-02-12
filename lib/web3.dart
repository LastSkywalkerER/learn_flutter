import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:http/src/client.dart';
import 'package:learn_flutter/todo.g.dart';
import 'package:web3dart/web3dart.dart';

class Web3 {
  static Todo todo = Todo(
      address:
          EthereumAddress.fromHex("0x8F423771895bB10f0F5062af368E42da3f31BF0B"),
      client: Web3Client(
          "https://arbitrum-sepolia.infura.io/v3/${dotenv.env["INFURA"]}",
          Client()));

  static Web3Client web3client = Web3Client(
      "https://arbitrum-sepolia.infura.io/v3/${dotenv.env["INFURA"]}",
      Client());

  static Future<double> getEthBalance(EthPrivateKey credentials) async {
    EtherAmount balance = await web3client.getBalance(credentials.address);
    return balance.getValueInUnit(EtherUnit.ether);
  }

  static Future<List<String>> getTodos(EthPrivateKey credentials) async {
    List<dynamic> response = await todo.getTodosByAddress(credentials.address);
    return response.map((e) => String.fromCharCodes(e)).toList();
  }

  static Future<String> addTodo(
      String todoString, EthPrivateKey credentials) async {
    List<int> byteList = utf8.encode(todoString);
    if (byteList.length > 32) {
      throw ArgumentError(
          'Input string too long, must be less than or equal to 32 bytes');
    }

    return await todo.addToDo(
        Uint8List(32)..setRange(0, byteList.length, byteList),
        credentials: credentials);
  }

  static Future<String> removeTodo(int index, EthPrivateKey credentials) async {
    return await todo.removeToDo(BigInt.from(index), credentials: credentials);
  }
}
