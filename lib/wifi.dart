import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:quiver/core.dart';

enum WifiState { error, success, already }

class Wifi {
  static const MethodChannel _channel = const MethodChannel('plugins.ly.com/wifi');

  static Future<String> get ssid async {
    return await _channel.invokeMethod('ssid');
  }

  static Future<int> get level async {
    return await _channel.invokeMethod('level');
  }

  static Future<String> get ip async {
    return await _channel.invokeMethod('ip');
  }

  static Future<List<WifiResult>> list(String key) async {
    final Map<String, dynamic> params = {
      'key': key,
    };
    var results = await _channel.invokeMethod('list', params);
    List<WifiResult> resultList = [];
    for (int i = 0; i < results.length; i++) {
      resultList.add(WifiResult(
        ssid: results[i]['ssid'],
        bssid: results[i]['bssid'],
        level: results[i]['level'],
        protected: results[i]['protected'],
      ));
    }
    return resultList;
  }

  static Future<WifiState> connection(String ssid, [String password]) async {
    final Map<String, dynamic> params = {
      'ssid': ssid
    };
    if (password != null && password.isNotEmpty) {
      params.addEntries([MapEntry('password', password)]);
    }
    int state = await _channel.invokeMethod('connection', params);
    switch (state) {
      case 0:
        return WifiState.error;
      case 1:
        return WifiState.success;
      case 2:
        return WifiState.already;
      default:
        return WifiState.error;
    }
  }
}

class WifiResult {
  final String ssid;
  final String bssid;

  final int level;
  final bool protected;

  WifiResult({
    @required this.ssid,
    @required this.bssid,

    @required this.level,
    @required this.protected,
  });

  @override
  bool operator ==(o) => o is WifiResult && ssid == o.ssid && bssid == o.bssid && protected == o.protected;

  @override
  int get hashCode => hash3(ssid, bssid, protected);
}
