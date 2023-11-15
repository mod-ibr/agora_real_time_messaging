import 'package:agora_real_time_messaging/core/constants/app_constants.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';

import '../../data/logs.dart';
import 'message_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _userId = TextEditingController();
  final _channelName = TextEditingController();

  AgoraRtmClient? _client;
  AgoraRtmChannel? _channel;
  LogController logController = LogController();

  @override
  void initState() {
    super.initState();
    _createClient();
  }

  void _createClient() async {
    _client = await AgoraRtmClient.createInstance(AppConstants.appId);
    _client!.onMessageReceived = (RtmMessage message, String peerId) {
      logController.addLog("Private Message from $peerId: ${message.text}");
    };
    _client!.onConnectionStateChanged2 =
        (RtmConnectionState state, RtmConnectionChangeReason reason) {
      logController.addLog('Connection state changed: $state, reason: $reason');
      if (state.index == 5) {
        _client!.logout();
        logController.addLog('Logout.');
      }
    };
  }

  void _login(BuildContext context) async {
    String userId = _userId.text;
    if (userId.isEmpty) {
      print('Please input your user id to login.');
      return;
    }

    try {
      await _client!.login(AppConstants.token, userId);
      logController.addLog('Login success: $userId');
      _joinChannel();
    } catch (errorCode) {
      print('Login error: $errorCode');
    }
  }

  void _joinChannel() async {
    String channelId = _channelName.text;
    if (channelId.isEmpty) {
      logController.addLog('Please input channel id to join.');
      return;
    }

    try {
      _channel = await _createChannel(channelId);
      await _channel!.join();
      logController.addLog('Join channel success.');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessageScreen(
            client: _client!,
            channel: _channel!,
            logController: logController,
          ),
        ),
      );
    } catch (errorCode) {
      print('Join channel error: $errorCode');
    }
  }

  Future<AgoraRtmChannel> _createChannel(String name) async {
    AgoraRtmChannel? channel = await _client!.createChannel(name);
    channel!.onMemberJoined = (RtmChannelMember member) {
      logController.addLog(
          "Member joined: " + member.userId + ', channel: ' + member.channelId);
    };
    channel.onMemberLeft = (RtmChannelMember member) {
      logController.addLog(
          "Member left: " + member.userId + ', channel: ' + member.channelId);
    };
    channel.onMessageReceived = (RtmMessage message, RtmChannelMember member) {
      logController
          .addLog("Public Message from ${member.userId}: ${message.text}");
    };
    return channel;
  }

  @override
  void dispose() {
    _client?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Real Time Message'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(
                controller: _userId,
                decoration: const InputDecoration(hintText: 'User ID')),
            TextField(
                controller: _channelName,
                decoration: const InputDecoration(hintText: 'Channel')),
            OutlinedButton(
              child: const Text('Login'),
              onPressed: () => _login(context),
            ),
          ],
        ),
      ),
    );
  }
}
