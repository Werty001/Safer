import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class NewRiskView extends StatefulWidget {
  const NewRiskView({super.key});

  @override
  State<NewRiskView> createState() => _NewRiskViewState();
}

class _NewRiskViewState extends State<NewRiskView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Risk'),
      ),
      body: const Text('decrive your risk here'),
    );
  }
}
