import 'package:calcu/app/data/components/appbar.dart';
import 'package:calcu/app/data/components/button_row1.dart';
import 'package:calcu/app/data/components/button_row2.dart';
import 'package:calcu/app/data/components/button_row3.dart';
import 'package:calcu/app/data/components/button_row4.dart';
import 'package:calcu/app/data/components/button_row5.dart';
import 'package:calcu/app/data/components/button_row6.dart';
import 'package:calcu/app/data/components/input_view_row.dart';
import 'package:calcu/app/data/components/result_view_row.dart';
import 'package:calcu/app/data/components/saved_view_row.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  // final HomeController homeController = Get.put(HomeController());
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (_) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: const AppBarCustom(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                  flex: 2,
                  child: InputViewRow(
                    controller: controller,
                  )),
              const SizedBox(height: 10),
              Expanded(
                  child: ResultViewRow(
                controller: controller,
              )),
              const SizedBox(height: 10),
              Expanded(
                  child: SavedViewRaw(
                controller: controller,
              )),
              const SizedBox(height: 10),
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    Expanded(
                        child: Buttonrow1(
                      controller: controller,
                    )),
                    Expanded(
                        child: Buttonrow2(
                      controller: controller,
                    )),
                    Expanded(
                        child: Buttonrow3(
                      controller: controller,
                    )),
                    Expanded(
                        child: Buttonrow4(
                      controller: controller,
                    )),
                    Expanded(
                        child: Buttonrow5(
                      controller: controller,
                    )),
                    Expanded(
                        child: Buttonrow6(
                      controller: controller,
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
