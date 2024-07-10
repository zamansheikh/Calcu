import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter/services.dart';

class HomeProvider extends ChangeNotifier {
  final bool isDarkTheme = true;

  var count = 0;

  //when the controller is initialized, the readData function is called
  void onInit() {
    readData();
    notifyListeners();
  }

  void increment(){
     count++;
      notifyListeners();
  }

  final ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;
  String output = '';
  String input = '';
  String result = '';
  var savedValue = <String>[];
  bool equalIsClicked = false;
  List<int> parenthesis = [0, 0];

  readData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String>? loadedValues = pref.getStringList('remvalu');

    if (loadedValues != null) {
      savedValue = loadedValues;
    }
    notifyListeners();
  }

  writeData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setStringList('remvalu', savedValue.toList());
    notifyListeners();
  }

  void addNewValue() {
    savedValue.add(output);
    notifyListeners();
  }

  void delFromInput() {
    if (input.isNotEmpty) {
      input = input.substring(0, input.length - 1);
    }
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  //New Function to Handle Input Display

  String convertDoubleToInt(String input) {
    double doubleValue;
    try {
      doubleValue = double.parse(input);
    } catch (e) {
      return input;
    }

    if (doubleValue == doubleValue.toInt()) {
      return doubleValue.toInt().toString();
    } else {
      return input;
    }
  }

  void clickOnInputDisplay() {
    calculateFunction(input);
    output != 'Wrong Input!'
        ? savedValue.add(convertDoubleToInt(output))
        : output;
    writeData();
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void clickOnResult() {
    calculateFunction(input);
    output != 'Wrong Input!'
        ? savedValue.add(convertDoubleToInt(output))
        : output;
    writeData();
    notifyListeners();
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
    notifyListeners();
  }

  void pasteFromResult(var index) {
    if (input.contains('.')) {
      input += double.parse(savedValue[index]).toInt().toString();
    } else {
      input += savedValue[index];
    }
    HapticFeedback.vibrate();
    notifyListeners();
  }

  void delASingleItem(var index) {
    savedValue.removeAt(index);
    HapticFeedback.vibrate();
    notifyListeners();
  }

  void delAllItem() {
    savedValue.clear();
    HapticFeedback.heavyImpact();
    notifyListeners();
  }

  void acButton() {
    input = '';
    output = '';
    notifyListeners();
    HapticFeedback.heavyImpact();
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
    notifyListeners();
  }

  void parenThesisForward() {
    input += '(';
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void parenThesisBackward() {
    input += ')';
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void percentageButton() {
    input += '%';
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void squareButton() {
    input += '^';
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void rootOverButton() {
    input += '√';
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void modButton() {
    input += '|';
    notifyListeners();
    HapticFeedback.vibrate();
  }

  void divisionButton() {
    input += '÷';
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void sevenButton() {
    input += '7';
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void eightButton() {
    input += '8';
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void nineButton() {
    input += '9';
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void multiButton() {
    input += 'x';
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void fourButton() {
    input += '4';
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void fiveButton() {
    input += '5';
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void sixButton() {
    input += '6';
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void minusButton() {
    input += '-';
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void oneButton() {
    input += '1';
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void twoButton() {
    input += '2';
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void threeButton() {
    input += '3';
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void plusButton() {
    input += '+';
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void zeroButton() {
    input += '0';
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void dotButton() {
    input += '.';
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void equalButton() {
    if (input.isNotEmpty) {
      calculateFunction(input);
    }
    notifyListeners();
    HapticFeedback.heavyImpact();
  }

  void equalButtonLong() {
    if (input.isNotEmpty) {
      calculateFunction(input);
      output = double.parse(output).toStringAsFixed(3);
    }
    notifyListeners();
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
      output = result.toString();
    } catch (e) {
      output = 'Wrong Input!';
    }
    notifyListeners();
  }

  String findAndReplace(String value, int index) {
    List<String> str = ['√(', '√', '%'];
    if (index >= str.length) {
      notifyListeners();
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
    return input.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(\.|$))'),
      (Match match) => '${match.group(1)},',
    );
  }
}
