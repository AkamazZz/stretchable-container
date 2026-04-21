import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stretchable_container/stretchable_container.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runZonedGuarded(
    () {
      runApp(
        const MaterialApp(
          home: StretchableContainer(
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1505832018823-50331d70d237?q=80&w=1980',
            ),
          ),
        ),
      );
    },
    (error, stackTrace) {
      log(error.toString());
      log(stackTrace.toString());
    },
  );
}
