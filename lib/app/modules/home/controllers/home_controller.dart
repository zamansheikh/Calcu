import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class HomeController extends GetxController {
  final RxBool isDarkTheme = true.obs;

  final count = 0.obs;
  @override
  void onInit() {
    readData();
    super.onInit();
    update();
  }

  @override
  void onReady() {
    super.onReady();
    update();
  }

  void increment() => count.value++;

  final ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;
  RxString output = ''.obs;
  RxString input = ''.obs;
  RxString result = ''.obs;
  final savedValue = <String>[].obs;
  RxBool equalIsClicked = false.obs;
  RxList<int> parenthesis = [0, 0].obs;

  readData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String>? loadedValues = pref.getStringList('remvalu');

    if (loadedValues != null) {
      savedValue.value = loadedValues;
    }
    savedValue.refresh();
    update();
  }

  writeData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setStringList('remvalu', savedValue.toList());
    update();
  }

  void addNewValue() {
    savedValue.add(output.value);
    update();
    savedValue.refresh();
  }

  void delFromInput() {
    if (input.value.isNotEmpty) {
      input.value = input.value.substring(0, input.value.length - 1);
    }
    update();
    input.refresh();
    HapticFeedback.heavyImpact();
  }

  void clickOnInputDisplay() {
    calculateFunction(input.value);
    output.value != 'Wrong Input!'
        ? savedValue.add(output.value)
        : output.value;
    writeData();
    update();
    output.refresh();
    HapticFeedback.heavyImpact();
  }

  void clickOnResult() {
    calculateFunction(input.value);
    output.value != 'Wrong Input!'
        ? savedValue.add(output.value)
        : output.value;
    writeData();
    update();
    output.refresh();
    HapticFeedback.heavyImpact();
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
    if (input.value.contains('.')) {
      input.value += double.parse(savedValue[index]).toInt().toString();
    } else {
      input.value += savedValue[index];
    }
    HapticFeedback.vibrate();
    update();
  }

  void delASingleItem(var index) {
    savedValue.removeAt(index);
    HapticFeedback.vibrate();
    update();
  }

  void delAllItem() {
    savedValue.clear();
    HapticFeedback.heavyImpact();
    update();
  }

  void acButton() {
    input.value = '';
    output.value = '';
    update();
    HapticFeedback.heavyImpact();
  }

  void parenThesisButton() {
    for (int i = 0; i < input.value.length; i++) {
      if (input.value[i] == '(') {
        parenthesis[0]++;
      } else if (input.value[i] == ')') {
        parenthesis[1]++;
      }
    }
    if (parenthesis[0] == parenthesis[1]) {
      input.value += '(';
    } else if (parenthesis[0] > parenthesis[1]) {
      input.value += ')';
    } else {
      input.value += '(';
    }
    parenthesis[0] = 0;
    parenthesis[1] = 0;
    update();
  }

  void parenThesisForward() {
    input.value += '(';
    update();
    HapticFeedback.heavyImpact();
  }

  void parenThesisBackward() {
    input.value += ')';
    update();
    HapticFeedback.heavyImpact();
  }

  void percentageButton() {
    input.value += '%';
    update();
    HapticFeedback.heavyImpact();
  }

  void squareButton() {
    input.value += '^';
    update();
    HapticFeedback.heavyImpact();
  }

  void rootOverButton() {
    input.value += '√';
    update();
    HapticFeedback.heavyImpact();
  }

  void modButton() {
    input.value += '|';
    update();
    HapticFeedback.vibrate();
  }

  void divisionButton() {
    input.value += '÷';
    update();
    HapticFeedback.heavyImpact();
  }

  void sevenButton() {
    input.value += '7';
    update();
    HapticFeedback.heavyImpact();
  }

  void eightButton() {
    input.value += '8';
    update();
    HapticFeedback.heavyImpact();
  }

  void nineButton() {
    input.value += '9';
    update();
    HapticFeedback.heavyImpact();
  }

  void multiButton() {
    input.value += 'x';
    update();
    HapticFeedback.heavyImpact();
  }

  void fourButton() {
    input.value += '4';
    update();
    HapticFeedback.heavyImpact();
  }

  void fiveButton() {
    input.value += '5';
    update();
    HapticFeedback.heavyImpact();
  }

  void sixButton() {
    input.value += '6';
    update();
    HapticFeedback.heavyImpact();
  }

  void minusButton() {
    input.value += '-';
    update();
    HapticFeedback.heavyImpact();
  }

  void oneButton() {
    input.value += '1';
    update();
    HapticFeedback.heavyImpact();
  }

  void twoButton() {
    input.value += '2';
    update();
    HapticFeedback.heavyImpact();
  }

  void threeButton() {
    input.value += '3';
    update();
    HapticFeedback.heavyImpact();
  }

  void plusButton() {
    input.value += '+';
    update();
    HapticFeedback.heavyImpact();
  }

  void zeroButton() {
    input.value += '0';
    update();
    HapticFeedback.heavyImpact();
  }

  void dotButton() {
    input.value += '.';
    update();
    HapticFeedback.heavyImpact();
  }

  void equalButton() {
    calculateFunction(input.value);
    update();
    HapticFeedback.heavyImpact();
  }

  void equalButtonLong() {
    calculateFunction(input.value);
    output.value = double.parse(output.value).toStringAsFixed(3);
    update();
    HapticFeedback.vibrate();
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
      output.value = result.toString();
    } catch (e) {
      output.value = 'Wrong Input!';
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

  String addCommasToNumbers(String input) {
    String result = '';
    String currentNumber = '';
    bool inNumber = false;

    for (int i = 0; i < input.length; i++) {
      String char = input[i];

      if (RegExp(r'[0-9]').hasMatch(char)) {
        currentNumber += char;
        inNumber = true;
      } else {
        if (inNumber) {
          String formattedNumber =
              NumberFormat("#,##0").format(int.parse(currentNumber));
          result += formattedNumber;
          currentNumber = '';
          inNumber = false;
        }
        result += char;
      }
    }

    if (inNumber) {
      String formattedNumber =
          NumberFormat("#,##0").format(int.parse(currentNumber));
      result += formattedNumber;
    }

    return result;
  }
}
