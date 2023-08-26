import 'package:calcu/controllers/buttons_methods_controller.dart';
import 'package:calcu/controllers/theme_controller.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:calcu/components/calcu_button.dart';
import 'package:calcu/config/app_strings.dart';
import 'package:calcu/styles/app_colors.dart';
import 'package:calcu/styles/app_text.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ButtonMethodsController methodController = Get.put(ButtonMethodsController());
  ThemeController themeController = Get.find();

  @override
  void initState() {
    super.initState();
    themeController.themeLoadData();
    methodController.readData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: themeController.isNightMode.value
            ? AppColors.calcuBackground
            : AppColors.calcuBackgroundLight,
        elevation: 0,
        centerTitle: true,
        leading: TextButton(
            onPressed: _showDialog,
            child: Icon(
              Icons.info,
              color: themeController.isNightMode.value
                  ? Colors.white
                  : Colors.black,
            )),
        title: Text(
          AppStrings.appBarName,
          style: TextStyle(
              color: themeController.isNightMode.value
                  ? Colors.white
                  : Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                themeController.isNightMode.toggle();
                themeController.themeDataSave();
                themeController
                    .updateThemeData(themeController.isNightMode.value);
              });
            },
            icon: Icon((themeController.isNightMode.value)
                ? Icons.light_mode_rounded
                : Icons.dark_mode_sharp),
            color:
                themeController.isNightMode.value ? Colors.white : Colors.black,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
        child: Column(
          children: [
            Obx(
              () => Divider(
                color: !themeController.isNightMode.value
                    ? null
                    : Colors.white.withOpacity(.5),
                indent: 0,
                endIndent: 0,
                height: 0,
                thickness: 2,
              ),
            ),
            Obx(
              () => Container(
                padding: const EdgeInsets.all(8),
                alignment: Alignment.centerRight,
                width: double.infinity,
                height: 80,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: Colors.transparent,
                ),
                child: TextButton(
                  onPressed: () {},
                  onLongPress: () {
                    methodController.clickOnInputDisplay();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Copied & Saved!'),
                        duration: const Duration(milliseconds: 400),
                        action: SnackBarAction(
                          label: 'Close',
                          onPressed: () {},
                        ),
                      ),
                    );
                    methodController.scrollControllerFunc();
                  },
                  child: SingleChildScrollView(
                    reverse: true,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          methodController.input.value,
                          style: AppText.header1.copyWith(
                              fontSize: 40,
                              color: themeController.isNightMode.value
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Obx(
              () => Container(
                padding: const EdgeInsets.all(8),
                alignment: Alignment.centerRight,
                width: double.infinity,
                height: 80,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: Colors.transparent,
                ),
                child: TextButton(
                  onPressed: () {},
                  onLongPress: () {
                    methodController.clickOnResult();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Result Saved'),
                        duration: const Duration(milliseconds: 400),
                        action: SnackBarAction(
                          label: 'Close',
                          onPressed: () {},
                        ),
                      ),
                    );
                    methodController.scrollControllerFunc();
                  },
                  child: SingleChildScrollView(
                    reverse: false,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          methodController.output.value,
                          style: AppText.header1.copyWith(
                              fontSize: 40,
                              color: themeController.isNightMode.value
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Obx(
              () => Container(
                //margin: const EdgeInsets.only(left: 8, right: 8),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: .5,
                      blurRadius: 2,
                      offset: Offset(0, 2), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                  color: themeController.isNightMode.value
                      ? Colors.white.withOpacity(.08)
                      : Colors.black.withOpacity(.08),
                ),
                height: 60,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        controller: methodController.scrollController,
                        itemCount: methodController.savedValue.length,
                        separatorBuilder: (context, index) => Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          color: themeController.isNightMode.value
                              ? Colors.white
                              : Colors.black,
                          width: 1,
                          child: const Divider(),
                        ),
                        itemBuilder: (context, index) {
                          return TextButton(
                            onLongPress: () {
                              setState(() {
                                themeController.isNightMode;
                              });
                            },
                            onPressed: () {
                              methodController.pasteFromResult(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(milliseconds: 400),
                                  content: const Text('Pasted!'),
                                  action: SnackBarAction(
                                    label: 'Close',
                                    onPressed: () {
                                      setState(() {});
                                    },
                                  ),
                                ),
                              );
                            },
                            key: (index ==
                                    methodController.savedValue.length - 1)
                                ? const Key('lastItem.')
                                : null,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(.2),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8))),
                                  child: Text(
                                    "${index + 1} : ${double.parse(methodController.savedValue[index]).toStringAsFixed(2)}.",
                                    style: TextStyle(
                                        color: themeController.isNightMode.value
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 3),
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(.8),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(100))),
                                    child: IconButton(
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        methodController.delASingleItem(index);
                                        setState(() {});

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            duration: const Duration(
                                                milliseconds: 400),
                                            content: const Text('Deleted!'),
                                            action: SnackBarAction(
                                              label: 'Close',
                                              onPressed: () {
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.clear),
                                      color: Colors.white,
                                      iconSize: 16,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    TextButton(
                        onLongPress: () {
                          setState(() {
                            methodController.savedValue.clear();
                            methodController.writeData();
                          });
                          Fluttertoast.showToast(
                            msg: 'All Deleted',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.grey[800],
                            textColor: Colors.white,
                          );
                        },
                        onPressed: () {
                          Fluttertoast.showToast(
                            msg: 'Long-Press to delete all',
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.grey[800],
                            textColor: Colors.white,
                          );
                        },
                        child: Icon(
                          Icons.delete_forever_rounded,
                          color: themeController.isNightMode.value
                              ? Colors.white
                              : Colors.black,
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: CalcuButton(
                  buttonColor: Colors.red.withOpacity(.8),
                  buttonName: "AC",
                  onPressed: () {
                    methodController.acButton();
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.spButton,
                  buttonName: "(",
                  onPressed: () {
                    methodController.parenThesisForward();
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.spButton,
                  buttonName: ")",
                  onPressed: () {
                    methodController.parenThesisBackward();
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonName: "Del",
                  buttonColor: AppColors.spButton,
                  onPressed: () {
                    methodController.delFromInput();
                  },
                  isHasIcon: true,
                )),
              ],
            ),
            SizedBox(height: themeController.buttonSpaceHeight.toDouble()),
            Row(
              children: [
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.spButton,
                  buttonName: "☐^",
                  onPressed: () {
                    methodController.squareButton();
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.spButton,
                  buttonName: "√(☐)",
                  onPressed: () {
                    methodController.rootOverButton();
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.spButton,
                  buttonName: "%",
                  onPressed: () {
                    methodController.percentageButton();
                  },
                  onLongPressed: () {
                    methodController.modButton();
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.opButton,
                  buttonName: "÷",
                  onPressed: () {
                    methodController.divisionButton();
                  },
                )),
              ],
            ),
            SizedBox(height: themeController.buttonSpaceHeight.toDouble()),
            Row(
              children: [
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: "7",
                  onPressed: () {
                    methodController.sevenButton();
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: "8",
                  onPressed: () {
                    methodController.eightButton();
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: "9",
                  onPressed: () {
                    methodController.nineButton();
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.opButton,
                  buttonName: "x",
                  onPressed: () {
                    methodController.multiButton();
                  },
                )),
              ],
            ),
            SizedBox(height: themeController.buttonSpaceHeight.toDouble()),
            Row(
              children: [
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: "4",
                  onPressed: () {
                    methodController.fourButton();
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: "5",
                  onPressed: () {
                    methodController.fiveButton();
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: "6",
                  onPressed: () {
                    methodController.sixButton();
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.opButton,
                  buttonName: "-",
                  onPressed: () {
                    methodController.minusButton();
                  },
                )),
              ],
            ),
            SizedBox(height: themeController.buttonSpaceHeight.toDouble()),
            Row(
              children: [
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: "1",
                  onPressed: () {
                    methodController.oneButton();
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: "2",
                  onPressed: () {
                    methodController.twoButton();
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: "3",
                  onPressed: () {
                    methodController.threeButton();
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.opButton,
                  buttonName: "+",
                  onPressed: () {
                    methodController.plusButton();
                  },
                )),
              ],
            ),
            SizedBox(height: themeController.buttonSpaceHeight.toDouble()),
            Row(
              children: [
                Expanded(
                    flex: 2,
                    child: CalcuButton(
                      buttonColor: AppColors.numButton,
                      buttonName: "0",
                      onPressed: () {
                        methodController.zeroButton();
                      },
                    )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: ".",
                  onPressed: () {
                    methodController.dotButton();
                  },
                )),
                Expanded(
                    child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  height: 60,
                  width: 80,
                  decoration: BoxDecoration(
                      color: themeController.isNightMode.value
                          ? Colors.white.withOpacity(.7)
                          : Colors.black.withOpacity(.7),
                      borderRadius: BorderRadius.circular(16)),
                  child: TextButton(
                    onPressed: () {
                      methodController.equalButton();
                    },
                    onLongPress: () {
                      methodController.equalButtonLong();
                    },
                    child: Text(
                      "=",
                      style: AppText.calc.copyWith(
                          color: themeController.isNightMode.value
                              ? Colors.black
                              : Colors.white,
                          fontSize: 35),
                    ),
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: themeController.isNightMode.value
              ? AppColors.calcuBackground
              : AppColors.calcuBackgroundLight,
          title: Text(
            "About App",
            style: TextStyle(
                color: themeController.isNightMode.value
                    ? Colors.white
                    : Colors.black),
          ),
          content: Text(
            AppStrings.infoText,
            style: TextStyle(
                color: themeController.isNightMode.value
                    ? Colors.white
                    : Colors.black),
          ),
        );
      },
    );
  }
}
