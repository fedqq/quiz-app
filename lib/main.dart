import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

enum Type { multiple, green, blue }

class Question {
  final String type;
  final String difficulty;
  final String category;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;

  const Question({
    required this.type,
    required this.difficulty,
    required this.category,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
  });

  factory Question.fromJson(json) {
    return Question(
      type: json['type'],
      difficulty: json['difficulty'],
      category: json['category'],
      question: json['question'],
      correctAnswer: json['correct_answer'],
      incorrectAnswers:
          List.generate(json['incorrect_answers'].length, (index) => json['incorrect_answers'][index] as String),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  int selected = 0;
  bool showingAnswers = false;
  int tried = 0;
  int correct = 0;
  final List<(String, String)> usedQuestionAnswers = [];
  Question question = const Question(
      type: '', difficulty: '', category: '', question: '', correctAnswer: '', incorrectAnswers: ['', '', '', '']);

  Future loadQuestion() async {
    var res = await http.get(Uri.parse('https://opentdb.com/api.php?amount=1&type=multiple'));
    log(res.statusCode.toString());

    if (res.statusCode == 200) {
      Question test = Question.fromJson((jsonDecode(res.body))['results'][0] as Map<String, dynamic>);
      var obj = (test.correctAnswer, test.question);
      if (usedQuestionAnswers.contains(obj)) {
        loadQuestion();
        return;
      }
      usedQuestionAnswers.add(obj);
      setState(() => question = test);
    } else {
      log(res.headers.toString());
      await Future.delayed(Durations.short2, loadQuestion);
    }
    showingAnswers = false;
  }

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: Durations.long1);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    loadQuestion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> answers = [];
    for (String answer in question.incorrectAnswers) {
      answers.add(answer);
    }
    answers.add(question.correctAnswer);
    answers.shuffle();

    void submitAnswer(int index) {
      tried += 1;
      if (question.correctAnswer == answers[index]) correct += 1;
      showingAnswers = true;
      selected = index;
      controller.forward().then((value) => Future.delayed(Durations.short1, () {
            loadQuestion().then((value) => controller.reset());
          }));
    }

    double cardWidth = MediaQuery.of(context).size.width / 4;
    double cardHeight = MediaQuery.of(context).size.height / 4;

    Widget possibleAnswer(int index) {
      String text = answers[index];
      bool correct = text == question.correctAnswer;
      return AnimatedBuilder(
          animation: animation,
          builder: (_, __) => InkWell(
                onTap: () => submitAnswer(index),
                child: SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: Card(
                        surfaceTintColor: showingAnswers
                            ? (correct
                                ? Colors.green
                                : selected == index
                                    ? Colors.red
                                    : Colors.transparent)
                            : Colors.transparent,
                        elevation: 15 * animation.value,
                        child: Center(child: Text(HtmlUnescape().convert(text))))),
              ));
    }

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
                child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color.fromARGB(255, 0, 87, 158), Color.fromARGB(255, 111, 0, 131)]),
              ),
            )),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    possibleAnswer(0),
                    possibleAnswer(1),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    possibleAnswer(2),
                    possibleAnswer(3),
                  ],
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      Text(HtmlUnescape().convert(question.question), style: Theme.of(context).textTheme.headlineLarge),
                      Text(question.difficulty),
                      Text(HtmlUnescape().convert(question.category)),
                      Text('$correct out of $tried - (${(correct / tried) * 100}%)'),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
