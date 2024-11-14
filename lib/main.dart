import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/material.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
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
  @override
  Widget build(BuildContext context) {
    /// This function will be executed in a separate isolate
    completeTask1(SendPort sendPort) {
      double total = 0.0;
      for (int i = 0; i < 1000000000; i++) {
        total += i;
      }
      sendPort.send(total);
    }

    /// This function will be executed in the main isolate
    Future<double> completeTask2() async {
      double total = 0.0;
      for (int i = 0; i < 1000000000; i++) {
        total += i;
      }
      return total;
    }

    /// This function will be executed in a separate isolate with adding parameters
    completeTask3((int, SendPort) data) {
      double total = 0.0;
      for (int i = 0; i < data.$1; i++) {
        total += i;
      }
      SendPort port = data.$2;
      port.send(total);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 120),
            Image.asset('assets/images/jumping-ball.gif', width: 250, height: 250),
            TextButton(
              child: const Text('Button 1 Simple ISOLATE'),
              onPressed: () async {
                final ReceivePort receivePort = ReceivePort();
                log('Button 1 Simple ISOLATE');
                await Isolate.spawn(completeTask1, receivePort.sendPort);
                receivePort.listen((message) {
                  log('Task 1 completed with result: $message');
                });
              },
            ),
            TextButton(
              child: const Text('Button 2 - UI FREEZES'),
              onPressed: () async {
                log('Button 2 - UI FREEZES');
                double result = await completeTask2();
                log('Task 2 completed with result: $result');
              },
            ),
            TextButton(
              child: const Text('Button 3 More complex ISOLATE'),
              onPressed: () async {
                final ReceivePort receivePort = ReceivePort();
                log('Button 3 More complex ISOLATE');
                await Isolate.spawn(completeTask3, (1000000000, receivePort.sendPort));
                receivePort.listen((message) {
                  log('Task 3 completed with result: $message');
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
