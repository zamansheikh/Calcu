import 'package:math_expressions/math_expressions.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:calcu/components/calcu_button.dart';
import 'package:calcu/components/tool_bar.dart';
import 'package:calcu/config/app_strings.dart';
import 'package:calcu/styles/app_colors.dart';
import 'package:calcu/styles/app_text.dart';
import 'package:flutter/material.dart';

class CalcuPage extends StatefulWidget {
  const CalcuPage({super.key});

  @override
  State<CalcuPage> createState() => _CalcuPageState();
}

class _CalcuPageState extends State<CalcuPage> {
  bool equalIsClicked = false;
  List<String> remValue = [];
  final ScrollController _scrollController = ScrollController();
  String input = '';
  String output = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ToolBar(appBarName: AppStrings.calcu),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
        child: Column(
          children: [
            const Divider(
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
                  setState(() {
                    calculateFunction(input);
                    remValue.add(output);
                  });
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
                  if (remValue.isNotEmpty) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: SingleChildScrollView(
                  reverse: (equalIsClicked) ? false : true,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(
                        input,
                        style: AppText.header1
                            .copyWith(fontSize: 40, color: Colors.white),
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
                  setState(() {
                    calculateFunction(input);
                    remValue.add(output);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Press = Button, Then Try to  Copy!'),
                      duration: const Duration(milliseconds: 400),
                      action: SnackBarAction(
                        label: 'Close',
                        onPressed: () {},
                      ),
                    ),
                  );
                  if (remValue.isNotEmpty) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: SingleChildScrollView(
                  reverse: (equalIsClicked) ? false : true,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(
                        output,
                        style: AppText.header1
                            .copyWith(fontSize: 40, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            const Divider(
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
                color: Colors.white.withOpacity(.08),
              ),
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      itemCount: remValue.length,
                      separatorBuilder: (context, index) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        color: Colors.white,
                        width: 1,
                        child: const Divider(),
                      ),
                      itemBuilder: (context, index) {
                        return TextButton(
                          onLongPress: () {},
                          onPressed: () {
                            setState(() {
                              if (input.contains('.')) {
                                input += double.parse(remValue[index])
                                    .toInt()
                                    .toString();
                              } else {
                                input += remValue[index];
                              }
                            });
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
                          key: (index == remValue.length - 1)
                              ? const Key('lastItem')
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
                                  "${index + 1} : ${remValue[index]}",
                                  style: TextStyle(
                                      color: (index % 2 == 0)
                                          ? const Color(0xFFFFFFFF)
                                          : const Color(0xFFFF1100)),
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
                                      setState(() {
                                        remValue.removeAt(index);
                                      });

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
                          remValue.clear();
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
                      child: const Icon(Icons.delete_forever_rounded)),
                ],
              ),
            ),
            const Divider(
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
                    setState(() {
                      input = '';
                      output = '';
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.spButton,
                  buttonName: "()",
                  onPressed: () {
                    setState(() {
                      input += '()';
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.spButton,
                  buttonName: "%",
                  onPressed: () {
                    setState(() {
                      input += '%';
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.spButton,
                  buttonName: "Del",
                  onPressed: () {
                    setState(() {
                      if (input.isNotEmpty) {
                        input = input.substring(0, input.length - 1);
                      }
                    });
                  },
                )),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.spButton,
                  buttonName: "[]²",
                  onPressed: () {
                    setState(() {
                      input += '^2';
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.spButton,
                  buttonName: "√.",
                  onPressed: () {
                    setState(() {
                      input += '√';
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.spButton,
                  buttonName: "|.",
                  onPressed: () {
                    setState(() {
                      input += '|';
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.opButton,
                  buttonName: "÷",
                  onPressed: () {
                    setState(() {
                      input += '÷';
                    });
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
                    setState(() {
                      input += '7';
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: "8",
                  onPressed: () {
                    setState(() {
                      input += '8';
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: "9",
                  onPressed: () {
                    setState(() {
                      input += '9';
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.opButton,
                  buttonName: "x",
                  onPressed: () {
                    setState(() {
                      input += 'x';
                    });
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
                    setState(() {
                      input += '4';
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: "5",
                  onPressed: () {
                    setState(() {
                      input += '5';
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: "6",
                  onPressed: () {
                    setState(() {
                      input += '6';
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.opButton,
                  buttonName: "-",
                  onPressed: () {
                    setState(() {
                      input += '-';
                    });
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
                    setState(() {
                      input += '1';
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: "2",
                  onPressed: () {
                    setState(() {
                      input += '2';
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: "3",
                  onPressed: () {
                    setState(() {
                      input += '3';
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.opButton,
                  buttonName: "+",
                  onPressed: () {
                    setState(() {
                      input += '+';
                    });
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
                        setState(() {
                          input += '0';
                        });
                      },
                    )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: ".",
                  onPressed: () {
                    setState(() {
                      input += '.';
                    });
                  },
                )),
                Expanded(
                    child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  height: 60,
                  width: 80,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.7),
                      borderRadius: BorderRadius.circular(16)),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        calculateFunction(input);
                        output;
                      });
                    },
                    onLongPress: () {
                      setState(() {
                        calculateFunction(input);
                        output = double.parse(output).toStringAsFixed(3);
                      });
                    },
                    child: Text(
                      "=",
                      style: AppText.calc
                          .copyWith(color: Colors.black, fontSize: 35),
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

  void calculateFunction(String str) {
    str = str.replaceAll('√', 'sqrt');

    
    //replace for remiander
    str = str.replaceAll('Rem', '   what is this?');
    
    str = str.replaceAll('x', '*');
    str = str.replaceAll('÷', '/');
    str = str.replaceAll('%', '/100');

    Parser p = Parser();
    Expression exp = p.parse(str);
    ContextModel cm = ContextModel();

    // Evaluate the expression
    double result = exp.evaluate(EvaluationType.REAL, cm) as double;

    setState(() {
      output = result.toString();
    });
  }
}
