import 'package:flutter/material.dart';
import '../../core/widgets/appbar.dart';
import '../../core/widgets/button_row1.dart';
import '../../core/widgets/button_row2.dart';
import '../../core/widgets/button_row3.dart';
import '../../core/widgets/button_row4.dart';
import '../../core/widgets/button_row5.dart';
import '../../core/widgets/button_row6.dart';
import '../../core/widgets/input_view_row.dart';
import '../../core/widgets/result_view_row.dart';
import '../../core/widgets/saved_view_row.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: const AppBarCustom(),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(flex: 2, child: InputViewRow()),
            SizedBox(height: 10),
            Expanded(child: ResultViewRow()),
            SizedBox(height: 10),
            Expanded(child: SavedViewRaw()),
            SizedBox(height: 10),
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Expanded(child: Buttonrow1()),
                  Expanded(child: Buttonrow2()),
                  Expanded(child: Buttonrow3()),
                  Expanded(child: Buttonrow4()),
                  Expanded(child: Buttonrow5()),
                  Expanded(child: Buttonrow6()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
