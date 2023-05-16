import 'package:dart_openai/openai.dart';

Future<String> generateResponse(String prompt) async {

  final chatCompletion = await OpenAI.instance.chat.create(
    model: 'gpt-3.5-turbo',
    messages: [
      OpenAIChatCompletionChoiceMessageModel(
        content: prompt,
        role: OpenAIChatMessageRole.user,
      ),
    ],
  );
  return chatCompletion.choices.first.message.content;
}
