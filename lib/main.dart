import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:research_writer/consts.dart';
import 'package:research_writer/message.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
        ),
        textTheme: GoogleFonts.nunitoSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController myController = TextEditingController();
  bool waiting = false;
  final List<Message> chat = [];
  late final GenerativeModel model;
  late ScrollController _scrollController;

  void scrollToBottom() {
    final bottomOffset = _scrollController.position.maxScrollExtent;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        bottomOffset,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _incrementCounter(String prompt) async {
    setState(() {
      chat.add(
          Message(sender: 'user', content: prompt, timestamp: DateTime.now()));
      scrollToBottom();
      waiting = true;
      myController.clear();
    });

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    setState(() {
      chat.add(
        Message(
          sender: 'bot',
          content: response.text ?? '',
          timestamp: DateTime.now(),
        ),
      );
      scrollToBottom();
      waiting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'google_generative_ai',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leadingWidth: .1,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(18.0, 12.0, 18.0, 12.0),
                  itemCount: chat.length,
                  itemBuilder: (context, index) {
                    if (chat[index].sender == 'user') {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: chat[index].content.toString().length > 40
                                ? MediaQuery.of(context).size.width * .55
                                : null,
                            padding: const EdgeInsets.fromLTRB(15, 14, 16, 14),
                            margin: const EdgeInsets.fromLTRB(0, 8.0, 0, 0.0),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(22.0),
                                topRight: Radius.circular(6.0),
                                bottomLeft: Radius.circular(22.0),
                                bottomRight: Radius.circular(18.0),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xffFF4593),
                                  Color(0xffFF006B),
                                ],
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SelectableText(
                                  chat[index].content,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    letterSpacing: -.1,
                                    fontWeight: FontWeight.w400,
                                    height: 1.4,
                                    color: Colors.white,
                                  ),
                                  cursorColor: const Color(0xffFF006B),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            timeAgoUtil(chat[index].timestamp),
                            style: const TextStyle(
                              fontSize: 12,
                              letterSpacing: -.1,
                              fontWeight: FontWeight.w400,
                              height: 3,
                              color: Color(0xff9C9CA3),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: chat[index].content.toString().length > 40
                                ? MediaQuery.of(context).size.width * .55
                                : null,
                            padding: const EdgeInsets.fromLTRB(15, 14, 16, 14),
                            margin: const EdgeInsets.fromLTRB(0, 8.0, 0, 0.0),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(22.0),
                                topRight: Radius.circular(6.0),
                                bottomLeft: Radius.circular(22.0),
                                bottomRight: Radius.circular(18.0),
                              ),
                              color: Color(0xff1A1A1A),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SelectableText(
                                  chat[index].content,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    letterSpacing: -.1,
                                    fontWeight: FontWeight.w400,
                                    height: 1.4,
                                    color: Colors.white,
                                  ),
                                  cursorColor: const Color(0xffFF006B),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            timeAgoUtil(chat[index].timestamp),
                            style: const TextStyle(
                              fontSize: 12,
                              letterSpacing: -.1,
                              fontWeight: FontWeight.w400,
                              height: 3,
                              color: Color(0xff9C9CA3),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade100,
                ),
                margin: const EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: myController,
                          onSubmitted: (text) => _incrementCounter(text),
                          maxLines: 10,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter your prompt here...",
                          ),
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: waiting
                          ? null
                          : () => _incrementCounter(myController.text),
                      tooltip: 'Send Prompt',
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String timeAgoUtil(DateTime timestamp) {
  DateTime currentTime = DateTime.now();
  Duration difference = currentTime.difference(timestamp);

  // Define time intervals
  const int minute = 60;
  const int hour = 60 * minute;
  const int day = 24 * hour;
  const int week = 7 * day;

  // Calculate age in terms of the largest applicable time interval
  if (difference.inSeconds >= week) {
    int intervalCount = difference.inSeconds ~/ week;
    return '$intervalCount week${intervalCount != 1 ? 's' : ''} ago';
  } else if (difference.inSeconds >= day) {
    int intervalCount = difference.inSeconds ~/ day;
    return '$intervalCount day${intervalCount != 1 ? 's' : ''} ago';
  } else if (difference.inSeconds >= hour) {
    int intervalCount = difference.inSeconds ~/ hour;
    return '$intervalCount hour${intervalCount != 1 ? 's' : ''} ago';
  } else if (difference.inSeconds >= minute) {
    int intervalCount = difference.inSeconds ~/ minute;
    return '$intervalCount minute${intervalCount != 1 ? 's' : ''} ago';
  } else {
    return 'just now';
  }
}
