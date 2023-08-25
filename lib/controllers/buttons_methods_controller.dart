import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_variable.dart';

class ButtonMethodsController extends GetxController {
  final ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;
  String output = '';
  String input = '';
  List<String> savedValue = [];
  bool equalIsClicked = false;
  List<int> parenthesis = [0, 0];

  void addNewValue() {
    if (result != null) {
      savedValue.add(output);
    }
    update();
  }

  void delFromInput() {
    if (input.isNotEmpty) {
      input = input.substring(0, input.length - 1);
    }
    update();
  }

  void clickOnInputDisplay() {
    calculateFunction(input);
    output != 'Wrong Input!' ? savedValue.add(output) : output;
    writeData();
    update();
  }

  void clickOnResult() {
    calculateFunction(input);
    output != 'Wrong Input!' ? savedValue.add(output) : output;
    writeData();
    update();
  }

  void scrollControllerFunc() {
    if (savedValue.isNotEmpty) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    }
    update();
  }

  void pasteFromResult(var index) {
    if (input.contains('.')) {
      input += double.parse(savedValue[index]).toInt().toString();
    } else {
      input += savedValue[index];
    }
    update();
  }

  void delASingleItem(var index) {
    savedValue.removeAt(index);
    update();
  }

  void acButton() {
    input = '';
    output = '';
    update();
  }

  void parenThesisButton() {
    for (int i = 0; i < input.length; i++) {
      if (input[i] == '(') {
        parenthesis[0]++;
      } else if (input[i] == ')') {
        parenthesis[1]++;
      }
    }
    if (parenthesis[0] == parenthesis[1]) {
      input += '(';
    } else if (parenthesis[0] > parenthesis[1]) {
      input += ')';
    } else {
      input += '(';
    }
    parenthesis[0] = 0;
    parenthesis[1] = 0;
    update();
  }

  void parenThesisForward() {
    input += '(';
    update();
  }
  void parenThesisBackward() {
    input += ')';
    update();
  }

  void percentageButton() {
    input += '%';
    update();
  }

  void squareButton() {
    input += '^';
    update();
  }

  void rootOverButton() {
    input += '√';
    update();
  }

  void modButton() {
    input += '|';
    update();
  }

  void divisionButton() {
    input += '÷';
    update();
  }

  void sevenButton() {
    input += '7';
    update();
  }

  void eightButton() {
    input += '8';
    update();
  }

  void nineButton() {
    input += '9';
    update();
  }

  void multiButton() {
    input += 'x';
    update();
  }

  void fourButton() {
    input += '4';
    update();
  }

  void fiveButton() {
    input += '5';
    update();
  }

  void sixButton() {
    input += '6';
    update();
  }

  void minusButton() {
    input += '-';
    update();
  }

  void oneButton() {
    input += '1';
    update();
  }

  void twoButton() {
    input += '2';
    update();
  }

  void threeButton() {
    input += '3';
    update();
  }

  void plusButton() {
    input += '+';
    update();
  }

  void zeroButton() {
    input += '0';
    update();
  }

  void dotButton() {
    input += '.';
    update();
  }

  void equalButton() {
    calculateFunction(input);
    update();
  }

  void equalButtonLong() {
    calculateFunction(input);
    output = double.parse(output).toStringAsFixed(3);
    update();
  }

  readData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String>? loadedValues = pref.getStringList('remvalu');

    if (loadedValues != null) {
      savedValue = loadedValues;
    }
    update();
  }

  writeData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setStringList('remvalu', savedValue);
    update();
  }

  themeLoadData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? isDarkMode = pref.getBool('isDark');
    isDark = isDarkMode ?? true;
    update();
  }

  themeData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool('isDark', isDark);
    update();
  }

  
  void calculateFunction(String str) {
    str = findAndReplace(str, 0);
    str = str.replaceAll('x', '*');
    str = str.replaceAll('÷', '/');
    str = str.replaceAll('|', '%');

    Parser p = Parser();
    try {
      Expression exp = p.parse(str);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm) as double;
      output = result.toString();
    } catch (e) {
      output = 'Wrong Input!';
    }
    update();
  }

  String findAndReplace(String value, int index) {
    List<String> str = ['√(', '√', '%'];
    if (index >= str.length) {
      update();
      return value;
    }
    num a = 0;
    int revStart = 0, revEnd = 0;
    String revValu = '';
    for (int i = 0; i < value.length; i++) {
      if (value.substring(i).startsWith(str[index])) {
        int j = 0;
        if (str[index] != '%') {
          for (j = i + str[index].length; j < value.length; j++) {
            if (int.tryParse(value[j]) != null) {
              a *= 10;
              a += int.tryParse(value[j])!;
            } else {
              break;
            }
          }
        } else if (str[index] == '%') {
          revEnd = i + str[index].length;
          for (j = i - str[index].length; j > -1; j--) {
            if (int.tryParse(value[j]) != null) {
              revValu = int.tryParse(value[j])!.toString() + revValu;
            } else {
              break;
            }
          }
        }
        if (str[index] != '%') {
          if (str[index] == '√') {
            value = value.replaceRange(i, j, 'sqrt($a)');
          } else if (str[index] == '√(') {
            value = value.replaceRange(i, j, 'sqrt($a');
          }
        } else if (str[index] == '%') {
          revStart = j + 1;
          value = value.replaceRange(revStart, revEnd, '($revValu/100)');
        }
        a = 0;
      }
    }
    return findAndReplace(value, index + 1);
  }

  // void _showDialog() {
  //   showDialog(
  //     builder: (context) {
  //       return AlertDialog(
  //         backgroundColor: isDark
  //             ? AppColors.calcuBackground
  //             : AppColors.calcuBackgroundLight,
  //         title: Text(
  //           "About App",
  //           style: TextStyle(color: isDark ? Colors.white : Colors.black),
  //         ),
  //         content: Text(
  //           AppStrings.infoText,
  //           style: TextStyle(color: isDark ? Colors.white : Colors.black),
  //         ),
  //       );
  //     },
  //     context: context,
  //   );
  // }
}
