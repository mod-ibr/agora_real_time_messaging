import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';

import '../../data/logs.dart';

class MessageScreen extends StatefulWidget {
  final AgoraRtmClient client;
  final AgoraRtmChannel channel;
  final LogController logController;

  const MessageScreen(
      {super.key,
      required this.client,
      required this.channel,
      required this.logController});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final _peerUserId = TextEditingController();
  final _peerMessage = TextEditingController();
  final _channelMessage = TextEditingController();

  void _isUserOnline() async {
    if (_peerUserId.text.isEmpty) {
      widget.logController.addLog('Please input peer user id to query.');
      return;
    }
    try {
      Map<dynamic, dynamic> result =
          await widget.client.queryPeersOnlineStatus([_peerUserId.text]);
      widget.logController.addLog('Query result: $result');
    } catch (errorCode) {
      widget.logController.addLog('Query error: $errorCode');
    }
  }

  void _sendPeerMessage() async {
    if (_peerUserId.text.isEmpty) {
      widget.logController.addLog('Please input peer user id to send message.');
      return;
    }
    if (_peerMessage.text.isEmpty) {
      widget.logController.addLog('Please input text to send.');
      return;
    }

    try {
      RtmMessage message = RtmMessage.fromText(_peerMessage.text);
      await widget.client.sendMessageToPeer2(_peerUserId.text, message,
          SendMessageOptions(enableOfflineMessaging: false));
      widget.logController.addLog('Send peer message success.');
    } catch (errorCode) {
      widget.logController.addLog('Send peer message error: $errorCode');
    }
  }

  void _sendChannelMessage() async {
    if (_channelMessage.text.isEmpty) {
      widget.logController.addLog('Please input text to send.');
      return;
    }
    try {
      await widget.channel
          .sendMessage2(RtmMessage.fromText(_channelMessage.text));
      widget.logController.addLog('Send channel message success.');
    } catch (errorCode) {
      widget.logController.addLog('Send channel message error: $errorCode');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            widget.client.logout();
            Navigator.pop(context);
          },
        ),
        title: const Text('Agora Real Time Message'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                        controller: _peerUserId,
                        decoration: const InputDecoration(
                            hintText: 'Input peer user id'))),
                OutlinedButton(
                  onPressed: _isUserOnline,
                  child: const Text(
                    'Check if User Online',
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                        controller: _peerMessage,
                        decoration: const InputDecoration(
                            hintText: 'Input peer message'))),
                OutlinedButton(
                  onPressed: _sendPeerMessage,
                  child: const Text('Send to Peer'),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                        controller: _channelMessage,
                        decoration: const InputDecoration(
                            hintText: 'Input channel message'))),
                OutlinedButton(
                  onPressed: _sendChannelMessage,
                  child: const Text(
                    'Send to Channel',
                  ),
                )
              ],
            ),
            ValueListenableBuilder(
              valueListenable: widget.logController,
              builder: (context, log, widget) {
                return Expanded(
                  child: ListView.builder(
                    itemExtent: 24,
                    itemBuilder: (context, i) {
                      return ListTile(
                        contentPadding: const EdgeInsets.all(0.0),
                        title: Text(log[i]),
                      );
                    },
                    itemCount: log.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
