import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fijkplayer/fijkplayer.dart' as fijkplayer;

/// The live streaming tools for flutter.
class FlutterLive {
  /// The channel for platform.
  static const MethodChannel _channel = const MethodChannel('flutter_live');

  /// Get the platform information.
  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// Set the speaker phone on.
  // [enabled] Use Earpiece if false, or Loudspeaker if true.
  static Future<void> setSpeakerphoneOn(bool enabled) async {
    await _channel.invokeMethod(
        'setSpeakerphoneOn', <String, dynamic>{'enabled': enabled});
  }

  /// The constructor for flutter live.
  FlutterLive();
}

/// A realtime player, using [fijkplayer](https://pub.dev/packages/fijkplayer).
class RealtimePlayer {
  /// The under-layer fijkplayer.
  final fijkplayer.FijkPlayer _player;

  /// Create a realtime player with [fijkplayer](https://pub.dev/packages/fijkplayer).
  RealtimePlayer(this._player);

  /// Get the under-layer [fijkplayer](https://pub.dev/packages/fijkplayer).
  fijkplayer.FijkPlayer get fijk => _player;

  /// Initialize the player.
  void initState() {
    _player.enterFullScreen();
  }

  /// Start play a url.
  /// [url] must a path for [FijkPlayer.setDataSource](https://pub.dev/documentation/fijkplayer/latest/fijkplayer/FijkPlayer/setDataSource.html
  ///
  /// It can be a RTMP live streaming, like [FlutterLive.rtmp] or hls like [FlutterLive.hls],
  /// or flv like [FlutterLive.flv].
  ///
  /// For security live streaming over HTTPS, like [FlutterLive.flvs] for HTTPS-FLV, or
  /// hls over HTTPS [FlutterLive.hlss].
  ///
  /// Note that we support all urls which FFmpeg supports.
  Future<void> play(String url) async {
    print('Start play live streaming $url');

    await _player.setOption(
        fijkplayer.FijkOption.playerCategory, "mediacodec-all-videos", 1);
    await _player.setOption(
        fijkplayer.FijkOption.hostCategory, "request-screen-on", 1);
    await _player.setOption(
        fijkplayer.FijkOption.hostCategory, "request-audio-focus", 1);

    // Live low-latency: https://www.jianshu.com/p/d6a5d8756eec
    // For all options, read https://github.com/Bilibili/ijkplayer/blob/master/ijkmedia/ijkplayer/ff_ffplay_options.h
    await _player.setOption(fijkplayer.FijkOption.formatCategory, "probesize",
        16 * 1024); // in bytes
    await _player.setOption(fijkplayer.FijkOption.formatCategory,
        "analyzeduration", 100 * 1000); // in us
    await _player.setOption(fijkplayer.FijkOption.playerCategory,
        "packet-buffering", 0); // 0, no buffer.
    await _player.setOption(fijkplayer.FijkOption.playerCategory,
        "max_cached_duration", 800); // in ms
    await _player.setOption(fijkplayer.FijkOption.playerCategory,
        "max-buffer-size", 32 * 1024); // in bytes
    await _player.setOption(
        fijkplayer.FijkOption.playerCategory, "infbuf", 1); // 1 for realtime.
    await _player.setOption(
        fijkplayer.FijkOption.playerCategory, "min-frames", 1); // in frames

    await _player.setDataSource(url, autoPlay: true).catchError((e) {
      print("setDataSource error: $e");
    });
  }

  /// Dispose the player.
  void dispose() {
    _player.release();
  }
}

/// The uri for webrtc, for example, [FlutterLive.rtc]:
///   webrtc://d.ossrs.net:11985/live/livestream
/// is parsed as a WebRTCUri:
///   api: http://d.ossrs.net:11985/rtc/v1/play/
///   streamUrl: "webrtc://d.ossrs.net:11985/live/livestream"
class WebRTCUri {
  /// The api server url for WebRTC streaming.
  String api = "";

  /// The stream url to play or publish.
  String streamUrl = "";

  /// Parse the url to WebRTC uri.
  static WebRTCUri parse(String? url) {
    WebRTCUri r = WebRTCUri();
    if (url == null) {
      return r;
    }
    Uri uri = Uri.parse(url);

    String? schema = 'https'; // For native, default to HTTPS
    if (uri.queryParameters.containsKey('schema')) {
      schema = uri.queryParameters['schema'];
    } else {
      schema = 'https';
    }

    var port = (uri.port > 0) ? uri.port : 443;
    if (schema == 'https') {
      port = (uri.port > 0) ? uri.port : 1986; //443;
    } else if (schema == 'http') {
      port = (uri.port > 0) ? uri.port : 1985;
    }

    String? api = '/rtc/v1/play/';
    if (uri.queryParameters.containsKey('play')) {
      api = uri.queryParameters['play'];
    }

    var apiParams = [];
    for (var key in uri.queryParameters.keys) {
      if (key != 'api' && key != 'play' && key != 'schema') {
        apiParams.add('$key=${uri.queryParameters[key]}');
      }
    }

    var apiUrl = '$schema://${uri.host}:$port$api';
    if (apiParams.isNotEmpty) {
      apiUrl += '?' + apiParams.join('&');
    }

    r.api = apiUrl;
    r.streamUrl = url;
    print('Url $url parsed to api=${r.api}, stream=${r.streamUrl}');
    return r;
  }
}
