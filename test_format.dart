// test_format.dart
import 'lib/utils.dart';

void main() {
  print('Test 100000: ${formatNumberWithSpaces(100000, 2)}');
  print('Test 3030: ${formatNumberWithSpaces(3030, 2)}');
  print('Test 1234567.89: ${formatNumberWithSpaces(1234567.89, 2)}');
  print('Test 100: ${formatNumberWithSpaces(100, 2)}');
  print('Test 1000: ${formatNumberWithSpaces(1000, 2)}');
  print('Test 10000: ${formatNumberWithSpaces(10000, 2)}');
}