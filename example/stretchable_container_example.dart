import 'package:flutter/material.dart';
import 'package:stretchable_container/stretchable_container.dart';

void main() {
  runApp(const StretchableContainerExampleApp());
}

class StretchableContainerExampleApp extends StatelessWidget {
  const StretchableContainerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: StretchableContainer(
          backgroundImage: NetworkImage(
            'https://images.unsplash.com/photo-1505832018823-50331d70d237?q=80&w=1980',
          ),
        ),
      ),
    );
  }
}
