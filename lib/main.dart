import 'package:flutter/material.dart';
import 'config/app_env.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(AppEnv.appName),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Environment: ${AppEnv.environment}'),
              Text('App Name: ${AppEnv.appName}'),
              Text('API Base URL: ${AppEnv.apiBaseUrl}'),
              Text('Debug Mode: ${AppEnv.debugMode}'),
            ],
          ),
        ),
      ),
    );
  }
}
