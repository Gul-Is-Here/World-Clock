import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/static_timezone_data.dart';
import '../models/timezone_model.dart';

class ClockController extends GetxController {
  var availableTimezones = staticTimezones.obs;
  var selectedTimezones = <TimezoneModel>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadSelectedTimezones();
  }

  Future<void> loadSelectedTimezones() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTimezones = prefs.getString('selected_timezones');
    
    if (storedTimezones != null) {
      try {
        final List<dynamic> jsonList = json.decode(storedTimezones);
        selectedTimezones.assignAll(
          jsonList.map((json) => TimezoneModel.fromJson(json)).toList()
        );
      } catch (e) {
        print('Error loading timezones: $e');
      }
    }
  }

  Future<void> _saveSelectedTimezones() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = selectedTimezones.map((tz) => tz.toJson()).toList();
    await prefs.setString('selected_timezones', json.encode(jsonList));
  }

  void addTimezone(TimezoneModel timezone) {
    if (!selectedTimezones.contains(timezone)) {
      selectedTimezones.add(timezone);
      _saveSelectedTimezones();
    }
  }

  void removeTimezone(TimezoneModel timezone) {
    selectedTimezones.remove(timezone);
    _saveSelectedTimezones();
  }
}