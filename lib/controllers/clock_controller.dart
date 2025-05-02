import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/static_timezone_data.dart';
import '../models/timezone_model.dart';

class ClockController extends GetxController {
  var availableTimezones = staticTimezones.obs;
  var selectedTimezones = <TimezoneModel>[].obs;
  var filteredTimezones = <TimezoneModel>[].obs;
  var currentTime = DateTime.now().obs;
  var isLoading = false.obs;
  var primaryTimezone = TimezoneModel.initial().obs;
  
  @override
  void onInit() {
    super.onInit();
    loadSelectedTimezones();
    startTimeUpdates();
    // Initialize filtered list with all available timezones
    filteredTimezones.assignAll(availableTimezones);
  }

  Future<void> loadSelectedTimezones() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedTimezones = prefs.getString('selected_timezones');
      final storedPrimary = prefs.getString('primary_timezone');
      
      if (storedTimezones != null) {
        final List<dynamic> jsonList = json.decode(storedTimezones);
        selectedTimezones.assignAll(
          jsonList.map((json) => TimezoneModel.fromJson(json)).toList()
        );
      }
      
      if (storedPrimary != null) {
        primaryTimezone.value = TimezoneModel.fromJson(json.decode(storedPrimary));
      } else if (selectedTimezones.isNotEmpty) {
        primaryTimezone.value = selectedTimezones.first;
      }
    } catch (e) {
      print('Error loading timezones: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveSelectedTimezones() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = selectedTimezones.map((tz) => tz.toJson()).toList();
    await prefs.setString('selected_timezones', json.encode(jsonList));
  }

  Future<void> _savePrimaryTimezone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('primary_timezone', json.encode(primaryTimezone.value.toJson()));
  }

  void addTimezone(TimezoneModel timezone) {
    if (!selectedTimezones.contains(timezone)) {
      selectedTimezones.add(timezone);
      if (selectedTimezones.length == 1) {
        primaryTimezone.value = timezone;
        _savePrimaryTimezone();
      }
      _saveSelectedTimezones();
    }
  }

  void removeTimezone(TimezoneModel timezone) {
    selectedTimezones.remove(timezone);
    if (primaryTimezone.value == timezone && selectedTimezones.isNotEmpty) {
      primaryTimezone.value = selectedTimezones.first;
      _savePrimaryTimezone();
    }
    _saveSelectedTimezones();
  }

  // void setAsPrimaryTimezone(TimezoneModel timezone) {
  //   primaryTimezone.value = timezone;
  //   _savePrimaryTimezone();
  // }

  void filterTimezones(String query) {
    if (query.isEmpty) {
      filteredTimezones.assignAll(availableTimezones);
    } else {
      filteredTimezones.assignAll(availableTimezones.where((tz) =>
        tz.city.toLowerCase().contains(query.toLowerCase()) ||
        tz.country.toLowerCase().contains(query.toLowerCase())));
    }
  }

  void sortTimezonesAlphabetically() {
    selectedTimezones.sort((a, b) => a.city.compareTo(b.city));
    _saveSelectedTimezones();
  }

  void sortTimezonesByRegion() {
    selectedTimezones.sort((a, b) => a.country.compareTo(b.country));
    _saveSelectedTimezones();
  }

  void sortTimezonesByTimeDifference() {
    selectedTimezones.sort((a, b) => a.utcOffset.compareTo(b.utcOffset));
    _saveSelectedTimezones();
  }

  DateTime getLocalTime(TimezoneModel timezone) {
    final now = currentTime.value;
    final offsetDifference = timezone.utcOffset - primaryTimezone.value.utcOffset;
    return now.add(Duration(hours: offsetDifference.toInt()));
  }

  Future<void> refreshTime() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    currentTime.value = DateTime.now();
    isLoading.value = false;
  }

  void startTimeUpdates() {
    // Update time every second
    Future.delayed(const Duration(seconds: 1), () {
      currentTime.value = DateTime.now();
      startTimeUpdates();
    });
  }

  // Add some popular timezones for quick selection
  List<TimezoneModel> get popularTimezones {
    return [
      availableTimezones.firstWhere((tz) => tz.city == 'New York'),
      availableTimezones.firstWhere((tz) => tz.city == 'London'),
      availableTimezones.firstWhere((tz) => tz.city == 'Tokyo'),
      availableTimezones.firstWhere((tz) => tz.city == 'Sydney'),
      availableTimezones.firstWhere((tz) => tz.city == 'Dubai'),
    ];
  }
}