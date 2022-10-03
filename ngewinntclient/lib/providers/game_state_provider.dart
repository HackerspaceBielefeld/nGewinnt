import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/game_model.dart';

class GameStateProvider extends ChangeNotifier {
  late final Timer t;
  final String endpoint;

  bool active = false;

  NGewinntModel? ng;

  GameStateProvider({required this.endpoint}) {
    t = Timer.periodic(Duration(milliseconds: 500), ((timer) {
      if (active) {
        update().then(
          (value) {
            notifyListeners();
          },
        );
      }
    }));
  }

  void start() {
    active = true;
  }

  void stop() {
    active = false;
  }

  Future<void> update() async {
    final response = await http.get(Uri.parse(endpoint));

    if (response.statusCode == 200) {
      debugPrint(response.body);
      ng = NGewinntModel.fromJSON(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load');
    }
  }
}
