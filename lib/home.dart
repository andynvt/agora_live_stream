import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

class Home extends StatefulWidget {
  final String channelName;
  final ClientRole role;
  Home({Key? key, required this.channelName, required this.role}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const APP_ID = '41980ace4a2046b8ae18eacbeab94fba';

  final _users = <int>[];
  final info = <String>[];
  bool muted = false;
  late RtcEngine _engine;

  void onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void onSwitchCamera() {
    _engine.switchCamera();
  }

  @override
  void dispose() {
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (APP_ID.isEmpty) {
      setState(() {
        info.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        info.add('Agora Engine is not starting');
      });
      return;
    }
    // Init the client instance
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(1920, 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    // Join channel
    await _engine.joinChannel(null, widget.channelName, null, 0);
  }

  /// Create client instance
  Future<void> _initAgoraRtcEngine() async {
    RtcEngineConfig config = RtcEngineConfig(APP_ID);
    _engine = await RtcEngine.createWithConfig(config);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role);
  }

  /// Event handling
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        info.add('onError: $code');
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      setState(() {
        info.add('onJoinChannel: $channel, uid: $uid');
      });
    }, leaveChannel: (stats) {
      setState(() {
        info.add('onLeaveChannel');
        _users.clear();
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        info.add('userJoined: $uid');
        _users.add(uid);
      });
    }, userOffline: (uid, elapsed) {
      setState(() {
        info.add('userOffline: $uid');
        _users.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        info.add('firstRemoteVideo: $uid ${width}x $height');
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livestreaming'),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: [
            viewRows(),
            panel(),
            toolbar(),
          ],
        ),
      ),
    );
  }

  /// Helper function to get list of native views
  List<Widget> getRenderViews() {
    final List<StatefulWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(RtcLocalView.SurfaceView());
    }
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video view wrapper
  Widget videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget viewRows() {
    final views = getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            expandedVideoRow([views[0]]),
            expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[expandedVideoRow(views.sublist(0, 2)), expandedVideoRow(views.sublist(2, 3))],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[expandedVideoRow(views.sublist(0, 2)), expandedVideoRow(views.sublist(2, 4))],
        ));
      default:
    }
    return Container();
  }

  /// Toolbar layout
  Widget toolbar() {
    if (widget.role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  /// Info panel to show logs
  Widget panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: info.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          info[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
