import 'package:dart_openai/openai.dart';
import 'package:dart_openai/openai.dart';
import 'package:dart_openai/openai.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tryagain/util/buttons/addButton.dart';

class AiPage extends StatelessWidget {

  // final apiKey = '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';
  // final model = 'davinci';
  // final prompt = 'Hello, world!';

  String text = 'help me pee';

  Future<String> completeChat(String message) async {

    final chatCompletion = await OpenAI.instance.chat.create(
      model: 'gpt-3.5-turbo',
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content: message,
          role: OpenAIChatMessageRole.user,
        ),
      ],
    );
    return chatCompletion.choices.first.message.content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenAI API Example'),
      ),
      body: ElevatedButton(
        onPressed: () async {
          String result = await completeChat('help me');
          print(result);
        },
        child: Text(text),
    ),
    );
  }
}