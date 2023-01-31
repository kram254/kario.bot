import 'dart:async';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:kar_io/chatmessage.dart';
import 'package:kar_io/dots.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _chats = [];

  ChatGPT? kario;

  StreamSubscription? _subscription;

  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _sendText() {
    ChatMessage message = ChatMessage(text: _controller.text, sender: "user");

    setState(() {
      _chats.insert(0, message);
      _isTyping = true;
    });

    _controller.clear();

    final request = CompleteReq(
        prompt: message.text, model: kTranslateModelV3, max_tokens: 200);

    _subscription = kario!
        .builder("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",
            orgId: "KarioTech")
        .onCompleteStream(request: request)
        .listen((response) {
      Vx.log(response!.choices[0].text);
      ChatMessage karioMessage =
          ChatMessage(text: response.choices[0].text, sender: "kar.io");

      setState(() {
        _isTyping = false;
        _chats.insert(0, karioMessage);
      });
    });
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
            child: TextField(
          controller: _controller,
          onSubmitted: (value) => _sendText(),
          decoration: const InputDecoration.collapsed(hintText: "Send a text"),
        )),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () => _sendText(),
        )
      ],
    ).px16();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('kar.io')),
      body: Column(
        children: [
          Flexible(
              child: ListView.builder(
                  reverse: true,
                  padding: Vx.m8,
                  itemCount: _chats.length,
                  itemBuilder: (context, index) {
                    // return Container(
                    //   height: 50.0,
                    //   color: Colors.blue,
                    //   ).px16();
                    _chats[index];
                  })),
          if(_isTyping) const ThreeDots(),
          const Divider(
            height: 2.0,
          ),
          Container(
            decoration: BoxDecoration(
              color: context.cardColor,
            ),
            child: _buildTextComposer(),
          )
        ],
      ),
    );
  }
}
