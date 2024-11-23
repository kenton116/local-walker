import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Walker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Local Walker', style: TextStyle(fontSize: 30)),
        const Text('Rediscover your local', style: TextStyle(fontSize: 15)),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(decoration: InputDecoration(labelText: 'e-mail')),
              const TextField(
                decoration: InputDecoration(labelText: 'password'),
                obscureText: true,
              ),
              SizedBox(
                  child: ElevatedButton(onPressed: () {}, child: Text('ログイン')),
                  width: double.infinity),
            ],
          ),
        ),
      ]),
    ));
  }
}
