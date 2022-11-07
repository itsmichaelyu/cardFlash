import 'package:flutter/material.dart';

import '../../widgets.dart';

class QRImportPage2 extends StatelessWidget {

  const QRImportPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BetterAppBar("QR Import", null, Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/ADD/QR1');
              },
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
              ),
            )
        ),null),
        body: const Text("", semanticsLabel: "",)
    );
  }
}