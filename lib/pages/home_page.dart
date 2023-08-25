import 'package:calcu/config/app_variable.dart';
import 'package:calcu/controllers/buttons_methods_controller.dart';
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
  final methodController = Get.put(ButtonMethodsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 40,
          backgroundColor: isDark
              ? AppColors.calcuBackground
              : AppColors.calcuBackgroundLight,
          elevation: 0,
          centerTitle: true,
          leading: TextButton(
              onPressed: _showDialog,
              child: Icon(
                Icons.info,
                color: isDark ? Colors.white : Colors.black,
              )),
          title: Text(
            AppStrings.appBarName,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  isDark = isDark ? false : true;
                });
              },
              icon: Icon(
                  (isDark) ? Icons.light_mode_rounded : Icons.dark_mode_sharp),
              color: isDark ? Colors.white : Colors.black,
            )
          ]),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
        child: Column(
          children: [
            Divider(
              color: !isDark ? null : Colors.white.withOpacity(.5),
              indent: 0,
              endIndent: 0,
              height: 0,
              thickness: 2,
            ),
            Container(
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
                        methodController.input,
                        style: AppText.header1.copyWith(
                            fontSize: 40,
                            color: isDark ? Colors.white : Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
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
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(
                  //     content: const Text('Result Saved'),
                  //     duration: const Duration(milliseconds: 400),
                  //     action: SnackBarAction(
                  //       label: 'Close',
                  //       onPressed: () {},
                  //     ),
                  //   ),
                  // );
                  methodController.scrollControllerFunc();
                },
                child: SingleChildScrollView(
                  reverse: false,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(
                        methodController.output,
                        style: AppText.header1.copyWith(
                            fontSize: 40,
                            color: isDark ? Colors.white : Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            Divider(
              color: isDark ? null : Colors.black.withOpacity(.5),
              indent: 12,
              endIndent: 12,
              height: 0,
              thickness: 1,
            ),
            Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark
                    ? Colors.white.withOpacity(.08)
                    : Colors.black.withOpacity(.08),
              ),
              height: 50,
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
                        color: isDark ? Colors.white : Colors.black,
                        width: 1,
                        child: const Divider(),
                      ),
                      itemBuilder: (context, index) {
                        return TextButton(
                          onLongPress: () {},
                          onPressed: () {
                            methodController.pasteFromResult(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(milliseconds: 400),
                                content: const Text('Pasted!'),
                                action: SnackBarAction(
                                  label: 'Close',
                                  onPressed: () {},
                                ),
                              ),
                            );
                          },
                          key: (index == methodController.savedValue.length - 1)
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
                                      color:
                                          isDark ? Colors.white : Colors.black),
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

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          duration:
                                              const Duration(milliseconds: 400),
                                          content: const Text('Deleted!'),
                                          action: SnackBarAction(
                                            label: 'Close',
                                            onPressed: () {},
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
                        color: isDark ? Colors.white : Colors.black,
                      )),
                ],
              ),
            ),
            Divider(
              color: isDark ? null : Colors.black.withOpacity(.5),
              indent: 12,
              endIndent: 12,
              height: 0,
              thickness: 1,
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
                  buttonName: "()",
                  onPressed: () {
                    methodController.parenThesisButton();
                  },
                  onLongPressed: () {
                    methodController.parenThesisLong();
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.spButton,
                  buttonName: "%",
                  onPressed: () {
                    methodController.percentageButton();
                  },
                )),
                Expanded(
                  child: InkWell(
                    radius: 16,
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 60,
                        width: 80,
                        decoration: BoxDecoration(
                            color: AppColors.spButton,
                            borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.backspace),
                      ),
                    ),
                    onTap: () {
                      methodController.delFromInput();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.spButton,
                  buttonName: "[]^",
                  onPressed: () {
                    methodController.squareButton();
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.spButton,
                  buttonName: "√()",
                  onPressed: () {
                    methodController.rootOverButton();
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.spButton,
                  buttonName: "|",
                  onPressed: () {
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
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
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
                      color: isDark
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
                          color: isDark ? Colors.black : Colors.white,
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
          backgroundColor: isDark
              ? AppColors.calcuBackground
              : AppColors.calcuBackgroundLight,
          title: Text(
            "About App",
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Text(
            AppStrings.infoText,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        );
      },
    );
  }
}
