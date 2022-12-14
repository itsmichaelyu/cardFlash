import 'package:card_flash/database.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lzstring/lzstring.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../widgets.dart';
import '../home_page.dart';

class QRImportPage extends StatefulWidget {

  const QRImportPage({super.key});

  @override
  State<QRImportPage> createState() => QRImportPageState();
  }

class QRImportPageState extends State<QRImportPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  String data = "";
  int counter = 1;
  String display = "Scan a cardFlash QR Code";
  QRViewController? controller;

  @override
  void initState() {
    super.initState();
    data = "";
    counter = 1;
    display = "Scan a cardFlash QR Code";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BetterAppBar("QR Import", <Widget>[
          Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
              child: GestureDetector(
                onTap: () {
                  data = "";
                  counter = 1;
                  display = "Scan a cardFlash QR Code";
                  setState(() {});
                },
                child: Icon(
                  Icons.delete_rounded,
                  color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.black : Colors.white,
                ),
              )
          )
        ], Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
              ),
            )
        ), null),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child:
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Text(
                      display,
                      textAlign: TextAlign.center,
                    ),
                  )
            )
            )
          ],
        ),
    );
  }
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (result?.code != scanData.code) {
        setState(() {
          result = scanData;
          process();
        });
      }
    });
  }

  void process() async {
    final navigator = Navigator.of(context);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final terms = <String>[];
    final defs = <String>[];

    var id = result?.code;
    var dio = Dio();
    var response = await dio.get(
      "https://api.paste.ee/v1/pastes/${id!}",
      queryParameters: {
        'key': Constants.pasteAPIKey,
      },
    );
    if (response.data['success']) {
      data = response.data['paste']["sections"][0]["contents"];
      final uncompressed = LZString.decompressFromUTF16Sync(data);
      final list = uncompressed?.split("????");
      if (list?.last == "") {
        list?.removeLast();
      }
      for (int i = 5; i < list!.length; i+=2) {
        terms.add(list[i]);
        defs.add(list[i+1]);
      }
      await prefs.setInt("currentTitleID",
          await LocalDatabase.insertSet(CardSet(await LocalDatabase.getNextPosition(), list[0], list[1], IconData(int.parse(list[2]), fontFamily: list[3], fontPackage: list[4] == "null" ? null : list[4]), terms, defs))
      );
      navigator.push(
          PageRouteBuilder(
            pageBuilder: (c, a1, a2) => const HomeNavigator(),
            settings: const RouteSettings(name: "/HOME"),
            transitionDuration: Duration.zero,
          )
      );
      navigator.pushNamed('/HOME/SET');
      navigator.pushNamed('/HOME/SET/EDIT');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}