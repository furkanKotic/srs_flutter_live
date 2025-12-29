import 'dart:async';

import 'package:fijkplayer/fijkplayer.dart' as fijkplayer;

class RealtimePlayer {
  /// The under-layer fijkplayer.
  final fijkplayer.FijkPlayer _player;

  RealtimePlayer() : _player = fijkplayer.FijkPlayer();

  fijkplayer.FijkPlayer get fijk => _player;

  void enterFullScreen() {
    _player.enterFullScreen();
  }

  /// Start play a stream.
  /// [url] must a path for [FijkPlayer.setDataSource]
  ///
  /// It can be a RTMP live streaming, like [FlutterLive.rtmp] or hls like [FlutterLive.hls],
  /// or flv like [FlutterLive.flv].
  ///
  /// For security live streaming over HTTPS, like [FlutterLive.flvs] for HTTPS-FLV, or
  /// hls over HTTPS [FlutterLive.hlss].
  ///
  /// Note that we support all urls which FFmpeg supports.
  Future<void> playStream(String url) async {
    await _player.setOption(
        fijkplayer.FijkOption.playerCategory, "mediacodec-all-videos", 1);
    await _player.setOption(
        fijkplayer.FijkOption.hostCategory, "request-screen-on", 1);
    await _player.setOption(
        fijkplayer.FijkOption.hostCategory, "request-audio-focus", 1);

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

  /// Start play a url.
  Future<void> playVideo(String url) async {
    print('Start play live streaming $url');

    await _player.setOption(
        fijkplayer.FijkOption.playerCategory, "mediacodec-all-videos", 1);
    await _player.setOption(
        fijkplayer.FijkOption.hostCategory, "request-screen-on", 1);
    await _player.setOption(
        fijkplayer.FijkOption.hostCategory, "request-audio-focus", 1);

    await _player.setDataSource(url, autoPlay: true).catchError((e) {
      print("setDataSource error: $e");
    });
  }

  /// Dispose the player.
  void dispose() {
    _player.release();
  }
}
