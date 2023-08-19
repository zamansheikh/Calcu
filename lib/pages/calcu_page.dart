import 'dart:math';
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
  double value = 0;
  var previousValue = '';
  var currentValue = '';
  var operator = '';
  double? result;
  var str = '';
  bool equalIsClicked = false;
  List<double> remValue = [];
  final ScrollController _scrollController = ScrollController();

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
              height: 120,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: Colors.transparent,
              ),
              child: TextButton(
                onPressed: () {},
                onLongPress: () {
                  if (operator.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            const Text('Press = Button, Then Try to  Copy!'),
                        duration: const Duration(milliseconds: 400),
                        action: SnackBarAction(
                          label: 'Close',
                          onPressed: () {},
                        ),
                      ),
                    );
                  } else {
                    setState(() {
                      remValue.add(double.parse(previousValue));
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
                  }
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
                        previousValue,
                        style: AppText.header1
                            .copyWith(fontSize: 50, color: Colors.white),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        operator,
                        style: AppText.header1
                            .copyWith(fontSize: 50, color: Colors.red),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        currentValue,
                        style: AppText.header1
                            .copyWith(fontSize: 50, color: Colors.white),
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
                              if (operator.isNotEmpty) {
                                if (currentValue.contains('.')) {
                                  currentValue =
                                      '$currentValue${remValue[index].toInt()}';
                                } else {
                                  currentValue =
                                      currentValue + remValue[index].toString();
                                }
                              } else {
                                if (previousValue.contains('.')) {
                                  previousValue =
                                      '$previousValue${remValue[index].toInt()}';
                                } else {
                                  previousValue = previousValue +
                                      remValue[index].toString();
                                }
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
                                  "${index + 1} : ${remValue[index].toStringAsFixed(2)}",
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
                      equalIsClicked = false;
                      previousValue = '';
                      currentValue = '';
                      operator = '';
                      str = '';
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.spButton,
                  buttonName: "-",
                  onPressed: () {
                    setState(() {
                      if (previousValue.isNotEmpty &&
                          operator.isNotEmpty & currentValue.isEmpty) {
                        equalIsClicked = false;
                        currentValue = '-';
                      } else if (previousValue.isEmpty) {
                        equalIsClicked = false;
                        previousValue = '-';
                      }
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.spButton,
                  buttonName: "^",
                  onPressed: () {
                    setState(() {
                      if (previousValue != '-') {
                        if (currentValue.isEmpty && previousValue.isNotEmpty) {
                          equalIsClicked = false;
                          operator = '^';
                        } else {
                          if (currentValue.isNotEmpty) {
                            equalIsClicked = false;
                            previousValue = calcuFunc(
                                operator, previousValue, currentValue);
                            currentValue = '';
                            operator = '^';
                          }
                        }
                      }
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.spButton,
                  buttonName: "Del",
                  onPressed: () {
                    setState(() {
                      if (currentValue.isNotEmpty) {
                        equalIsClicked = false;
                        currentValue =
                            currentValue.substring(0, currentValue.length - 1);
                      } else {
                        if (operator.isNotEmpty) {
                          equalIsClicked = false;
                          operator = '';
                        } else {
                          if (previousValue.isNotEmpty) {
                            equalIsClicked = false;
                            previousValue = previousValue.substring(
                                0, previousValue.length - 1);
                          }
                        }
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
                  buttonName: "x²",
                  onPressed: () {
                    setState(() {
                      if (operator.isNotEmpty) {
                        if (currentValue.isNotEmpty &&
                            previousValue.isNotEmpty) {
                          equalIsClicked = false;
                          currentValue = (double.parse(currentValue) *
                                  double.parse(currentValue))
                              .toString();
                        }
                      } else {
                        //empty
                        if (currentValue.isEmpty && previousValue.isNotEmpty) {
                          equalIsClicked = true;
                          previousValue = (double.parse(previousValue) *
                                  double.parse(previousValue))
                              .toString();
                        }
                      }
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.spButton,
                  buttonName: "√",
                  onPressed: () {
                    setState(() {
                      if (operator.isNotEmpty) {
                        if (currentValue.isNotEmpty &&
                            previousValue.isNotEmpty) {
                          equalIsClicked = false;
                          currentValue =
                              (sqrt(double.parse(currentValue))).toString();
                        }
                      } else {
                        //empty
                        if (currentValue.isEmpty && previousValue.isNotEmpty) {
                          equalIsClicked = true;
                          previousValue =
                              (sqrt(double.parse(previousValue))).toString();
                        }
                      }
                    });
                  },
                )),
                Expanded(
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 0),
                        height: 60,
                        width: 80,
                        decoration: BoxDecoration(
                            color: AppColors.spButton,
                            borderRadius: BorderRadius.circular(16)),
                        child: TextButton(
                          onLongPress: () {
                            setState(() {
                              if (previousValue != '-') {
                                if (currentValue.isEmpty &&
                                    previousValue.isNotEmpty) {
                                  equalIsClicked = false;
                                  operator = '|';
                                } else {
                                  if (currentValue.isNotEmpty) {
                                    equalIsClicked = false;
                                    previousValue = calcuFunc(
                                        operator, previousValue, currentValue);
                                    currentValue = '';
                                    operator = '|';
                                  }
                                }
                              }
                            });
                          },
                          onPressed: () {
                            setState(() {
                              if (currentValue.isEmpty &&
                                  previousValue.isNotEmpty) {
                                equalIsClicked = true;
                                previousValue =
                                    (double.parse(previousValue) / 100)
                                        .toString();
                              } else {
                                if (currentValue.isNotEmpty) {
                                  equalIsClicked = false;
                                  currentValue =
                                      (double.parse(currentValue) / 100)
                                          .toString();
                                }
                              }
                            });
                          },
                          child: Text(
                            "%",
                            style: AppText.calc
                                .copyWith(color: AppColors.textColor),
                          ),
                        ),
                      ),
                      const Positioned(
                          right: 25,
                          top: 17,
                          child: Text(
                            "|",
                            style:
                                TextStyle(color: Colors.yellow, fontSize: 20),
                          )),
                    ],
                  ),
                ),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.opButton,
                  buttonName: "÷",
                  onPressed: () {
                    setState(() {
                      if (previousValue != '-') {
                        if (currentValue.isEmpty && previousValue.isNotEmpty) {
                          equalIsClicked = false;
                          operator = '÷';
                        } else {
                          if (currentValue.isNotEmpty) {
                            equalIsClicked = false;
                            previousValue = calcuFunc(
                                operator, previousValue, currentValue);
                            currentValue = '';
                            operator = '÷';
                          }
                        }
                      }
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
                      if (equalIsClicked) {
                        previousValue = '.';
                        equalIsClicked = false;
                      } else {
                        operator.isEmpty
                            ? {
                                equalIsClicked = false,
                                previousValue = '${previousValue}7',
                              }
                            : {
                                equalIsClicked = false,
                                currentValue = '${currentValue}7',
                              };
                      }
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: "8",
                  onPressed: () {
                    setState(() {
                      if (equalIsClicked) {
                        previousValue = '8';
                        equalIsClicked = false;
                      } else {
                        operator.isEmpty
                            ? {
                                equalIsClicked = false,
                                previousValue = '${previousValue}8',
                              }
                            : {
                                equalIsClicked = false,
                                currentValue = '${currentValue}8',
                              };
                      }
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: "9",
                  onPressed: () {
                    setState(() {
                      if (equalIsClicked) {
                        previousValue = '9';
                        equalIsClicked = false;
                      } else {
                        operator.isEmpty
                            ? {
                                equalIsClicked = false,
                                previousValue = '${previousValue}9',
                              }
                            : {
                                equalIsClicked = false,
                                currentValue = '${currentValue}9',
                              };
                      }
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.opButton,
                  buttonName: "x",
                  onPressed: () {
                    setState(() {
                      if (previousValue != '-') {
                        equalIsClicked = false;
                        if (currentValue.isEmpty && previousValue.isNotEmpty) {
                          operator = 'x';
                        } else {
                          if (currentValue.isNotEmpty) {
                            equalIsClicked = false;
                            previousValue = calcuFunc(
                                operator, previousValue, currentValue);
                            currentValue = '';
                            operator = 'x';
                          }
                        }
                      }
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
                      if (equalIsClicked) {
                        previousValue = '4';
                        equalIsClicked = false;
                      } else {
                        operator.isEmpty
                            ? {
                                equalIsClicked = false,
                                previousValue = '${previousValue}4',
                              }
                            : {
                                equalIsClicked = false,
                                currentValue = '${currentValue}4',
                              };
                      }
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: "5",
                  onPressed: () {
                    setState(() {
                      if (equalIsClicked) {
                        previousValue = '5';
                        equalIsClicked = false;
                      } else {
                        operator.isEmpty
                            ? {
                                equalIsClicked = false,
                                previousValue = '${previousValue}5',
                              }
                            : {
                                equalIsClicked = false,
                                currentValue = '${currentValue}5',
                              };
                      }
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: "6",
                  onPressed: () {
                    setState(() {
                      if (equalIsClicked) {
                        previousValue = '6';
                        equalIsClicked = false;
                      } else {
                        operator.isEmpty
                            ? {
                                equalIsClicked = false,
                                previousValue = '${previousValue}6',
                              }
                            : {
                                equalIsClicked = false,
                                currentValue = '${currentValue}6',
                              };
                      }
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.opButton,
                  buttonName: "-",
                  onPressed: () {
                    setState(() {
                      if (previousValue != '-') {
                        if (currentValue.isEmpty && previousValue.isNotEmpty) {
                          equalIsClicked = false;
                          operator = '-';
                        } else {
                          if (currentValue.isNotEmpty) {
                            equalIsClicked = false;
                            previousValue = calcuFunc(
                                operator, previousValue, currentValue);
                            currentValue = '';
                            operator = '-';
                          }
                        }
                      }
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
                      if (equalIsClicked) {
                        previousValue = '1';
                        equalIsClicked = false;
                      } else {
                        operator.isEmpty
                            ? {
                                equalIsClicked = false,
                                previousValue = '${previousValue}1',
                              }
                            : {
                                equalIsClicked = false,
                                currentValue = '${currentValue}1',
                              };
                      }
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: "2",
                  onPressed: () {
                    setState(() {
                      if (equalIsClicked) {
                        previousValue = '2';
                        equalIsClicked = false;
                      } else {
                        operator.isEmpty
                            ? {
                                equalIsClicked = false,
                                previousValue = '${previousValue}2',
                              }
                            : {
                                equalIsClicked = false,
                                currentValue = '${currentValue}2',
                              };
                      }
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: "3",
                  onPressed: () {
                    setState(() {
                      if (equalIsClicked) {
                        previousValue = '3';
                        equalIsClicked = false;
                      } else {
                        operator.isEmpty
                            ? {
                                equalIsClicked = false,
                                previousValue = '${previousValue}3',
                              }
                            : {
                                equalIsClicked = false,
                                currentValue = '${currentValue}3',
                              };
                      }
                    });
                  },
                )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.opButton,
                  buttonName: "+",
                  onPressed: () {
                    setState(() {
                      if (previousValue != '-') {
                        if (currentValue.isEmpty && previousValue.isNotEmpty) {
                          equalIsClicked = false;
                          operator = '+';
                        } else {
                          if (currentValue.isNotEmpty) {
                            equalIsClicked = false;
                            previousValue = calcuFunc(
                                operator, previousValue, currentValue);
                            currentValue = '';
                            operator = '+';
                          }
                        }
                      }
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
                          if (equalIsClicked) {
                            previousValue = '0';
                            equalIsClicked = false;
                          } else {
                            operator.isEmpty
                                ? {
                                    equalIsClicked = false,
                                    previousValue = '${previousValue}0',
                                  }
                                : {
                                    equalIsClicked = false,
                                    currentValue = '${currentValue}0',
                                  };
                          }
                        });
                      },
                    )),
                Expanded(
                    child: CalcuButton(
                  buttonColor: AppColors.numButton,
                  buttonName: ".",
                  onPressed: () {
                    setState(() {
                      if (equalIsClicked) {
                        previousValue = '0.';
                        equalIsClicked = false;
                      } else {
                        operator.isEmpty
                            ? {
                                if (!previousValue.contains("."))
                                  {
                                    if (previousValue.isEmpty)
                                      {
                                        equalIsClicked = false,
                                        previousValue = '0.',
                                      }
                                    else
                                      {
                                        equalIsClicked = false,
                                        previousValue = '$previousValue.',
                                      }
                                  }
                              }
                            : {
                                if (!currentValue.contains("."))
                                  {
                                    if (currentValue.isEmpty)
                                      {
                                        equalIsClicked = false,
                                        currentValue = '0.',
                                      }
                                    else
                                      {
                                        equalIsClicked = false,
                                        currentValue = '$currentValue.',
                                      }
                                  }
                              };
                      }
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
                      setState(
                        () {
                          if (currentValue.isNotEmpty) {
                            if (operator.isNotEmpty) {
                              equalIsClicked = true;
                              previousValue = calcuFunc(
                                  operator, previousValue, currentValue);
                              operator = '';
                              currentValue = '';
                            }
                          }
                        },
                      );
                    },
                    onLongPress: () {
                      setState(() {
                        if (currentValue.isEmpty) {
                          if (operator.isNotEmpty) {
                          } else {
                            if (previousValue.isNotEmpty) {
                              equalIsClicked = true;
                              previousValue = double.parse(previousValue)
                                  .toStringAsFixed(3);
                            }
                          }
                        }
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

  calcuFunc(var op, a, b) {
    var valA = double.parse(a);
    var valB = double.parse(b);
    switch (op) {
      case '÷':
        return (valA / valB).toString();
      case 'x':
        return (valA * valB).toString();
      case '-':
        return (valA - valB).toString();
      case '+':
        return (valA + valB).toString();
      case '|':
        return (valA % valB).toString();
      case '^':
        return (pow(valA, valB)).toString();
      default:
        return 'Error';
    }
  }
}
