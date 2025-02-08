import 'package:flutter/material.dart';

class ConnectingDeviceScreen extends StatelessWidget {
  const ConnectingDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          'Connecting Device...',
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
    );
  }
}
