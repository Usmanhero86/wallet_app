import 'package:shared_preferences/shared_preferences.dart';
Future<void> saveAccountName(String accountName) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('accountName', accountName);

}

Future<String?> getAccountName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('accountName');
}