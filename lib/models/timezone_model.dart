import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimezoneModel {
  final String city;
  final String timezone;
  final String country;
  final double utcOffset;
  DateTime currentTime;
  bool isDaytime;

  TimezoneModel({
    required this.city,
    required this.timezone,
    required this.utcOffset,
    required this.country,
    DateTime? currentTime,
  })  : currentTime = currentTime ?? DateTime.now().add(Duration(hours: utcOffset.toInt())),
        isDaytime = _calculateIsDaytime(currentTime ?? DateTime.now().add(Duration(hours: utcOffset.toInt())));

  // Initial state constructor
  static TimezoneModel initial() {
    return TimezoneModel(
      city: 'Local',
      timezone: 'Local',
      utcOffset: 0,
      country: 'Local Time',
    );
  }

  // Serialization methods
  Map<String, dynamic> toJson() => {
        'city': city,
        'timezone': timezone,
        'utcOffset': utcOffset,
        'country': country,
      };

  factory TimezoneModel.fromJson(Map<String, dynamic> json) {
    return TimezoneModel(
      city: json['city'],
      timezone: json['timezone'],
      utcOffset: json['utcOffset'].toDouble(),
      country: json['country'] ?? '',
    );
  }

  // Equality comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimezoneModel &&
          runtimeType == other.runtimeType &&
          city == other.city &&
          timezone == other.timezone &&
          country == other.country;

  @override
  int get hashCode => city.hashCode ^ timezone.hashCode ^ country.hashCode;

  // Helper method to update the current time
  void updateCurrentTime(DateTime baseTime) {
    currentTime = baseTime.add(Duration(hours: utcOffset.toInt()));
    isDaytime = _calculateIsDaytime(currentTime);
  }

  static bool _calculateIsDaytime(DateTime time) {
    final hour = time.hour;
    return hour >= 6 && hour < 18;
  }

  // Time formatting
  String formattedTime() {
    return DateFormat.Hm().format(currentTime);
  }

  String formattedTimeWithSeconds() {
    return DateFormat.Hms().format(currentTime);
  }

  String formattedDate() {
    return DateFormat('EEE, d MMM').format(currentTime);
  }

  String formattedFullDate() {
    return DateFormat('EEEE, MMMM d, y').format(currentTime);
  }

  String formattedUtcOffset() {
    final sign = utcOffset >= 0 ? '+' : '';
    return 'UTC $sign${utcOffset.toStringAsFixed(1)}';
  }

  // Time difference calculation
  String timeDifferenceFrom(TimezoneModel other) {
    final difference = utcOffset - other.utcOffset;
    final absDifference = difference.abs();
    final sign = difference >= 0 ? '+' : '-';
    
    if (absDifference % 1 == 0) {
      return '$sign${absDifference.toInt()}h';
    } else {
      return '$sign${absDifference.toStringAsFixed(1)}h';
    }
  }

  // For sorting
  int compareByCity(TimezoneModel other) => city.compareTo(other.city);
  int compareByCountry(TimezoneModel other) => country.compareTo(other.country);
  int compareByUtcOffset(TimezoneModel other) => utcOffset.compareTo(other.utcOffset);
}

List<TimezoneModel> staticTimezones = [
  // 🌎 North America
  TimezoneModel(
    city: 'New York',
    timezone: 'America/New_York',
    utcOffset: -4,
    country: 'United States',
  ),
  TimezoneModel(
    city: 'Los Angeles',
    timezone: 'America/Los_Angeles',
    utcOffset: -7,
    country: 'United States',
  ),
  TimezoneModel(
    city: 'Chicago',
    timezone: 'America/Chicago',
    utcOffset: -5,
    country: 'United States',
  ),
  TimezoneModel(
    city: 'Toronto',
    timezone: 'America/Toronto',
    utcOffset: -4,
    country: 'Canada',
  ),
  TimezoneModel(
    city: 'Mexico City',
    timezone: 'America/Mexico_City',
    utcOffset: -6,
    country: 'Mexico',
  ),

  // 🌍 Europe
  TimezoneModel(
    city: 'London',
    timezone: 'Europe/London',
    utcOffset: 0,
    country: 'United Kingdom',
  ),
  TimezoneModel(
    city: 'Paris',
    timezone: 'Europe/Paris',
    utcOffset: 1,
    country: 'France',
  ),
  TimezoneModel(
    city: 'Berlin',
    timezone: 'Europe/Berlin',
    utcOffset: 1,
    country: 'Germany',
  ),
  TimezoneModel(
    city: 'Moscow',
    timezone: 'Europe/Moscow',
    utcOffset: 3,
    country: 'Russia',
  ),
  TimezoneModel(
    city: 'Rome',
    timezone: 'Europe/Rome',
    utcOffset: 1,
    country: 'Italy',
  ),

  // 🌏 Asia
  TimezoneModel(
    city: 'Karachi',
    timezone: 'Asia/Karachi',
    utcOffset: 5,
    country: 'Pakistan',
  ),
  TimezoneModel(
    city: 'Dubai',
    timezone: 'Asia/Dubai',
    utcOffset: 4,
    country: 'UAE',
  ),
  TimezoneModel(
    city: 'Beijing',
    timezone: 'Asia/Shanghai',
    utcOffset: 8,
    country: 'China',
  ),
  TimezoneModel(
    city: 'Tokyo',
    timezone: 'Asia/Tokyo',
    utcOffset: 9,
    country: 'Japan',
  ),
  TimezoneModel(
    city: 'Delhi',
    timezone: 'Asia/Kolkata',
    utcOffset: 5.5,
    country: 'India',
  ),
  TimezoneModel(
    city: 'Jakarta',
    timezone: 'Asia/Jakarta',
    utcOffset: 7,
    country: 'Indonesia',
  ),
  TimezoneModel(
    city: 'Seoul',
    timezone: 'Asia/Seoul',
    utcOffset: 9,
    country: 'South Korea',
  ),
  TimezoneModel(
    city: 'Bangkok',
    timezone: 'Asia/Bangkok',
    utcOffset: 7,
    country: 'Thailand',
  ),
  TimezoneModel(
    city: 'Kuala Lumpur',
    timezone: 'Asia/Kuala_Lumpur',
    utcOffset: 8,
    country: 'Malaysia',
  ),

  // 🌍 Africa
  TimezoneModel(
    city: 'Cairo',
    timezone: 'Africa/Cairo',
    utcOffset: 2,
    country: 'Egypt',
  ),
  TimezoneModel(
    city: 'Lagos',
    timezone: 'Africa/Lagos',
    utcOffset: 1,
    country: 'Nigeria',
  ),
  TimezoneModel(
    city: 'Nairobi',
    timezone: 'Africa/Nairobi',
    utcOffset: 3,
    country: 'Kenya',
  ),
  TimezoneModel(
    city: 'Cape Town',
    timezone: 'Africa/Johannesburg',
    utcOffset: 2,
    country: 'South Africa',
  ),
  TimezoneModel(
    city: 'Algiers',
    timezone: 'Africa/Algiers',
    utcOffset: 1,
    country: 'Algeria',
  ),

  // 🌏 Oceania
  TimezoneModel(
    city: 'Sydney',
    timezone: 'Australia/Sydney',
    utcOffset: 10,
    country: 'Australia',
  ),
  TimezoneModel(
    city: 'Melbourne',
    timezone: 'Australia/Melbourne',
    utcOffset: 10,
    country: 'Australia',
  ),
  TimezoneModel(
    city: 'Auckland',
    timezone: 'Pacific/Auckland',
    utcOffset: 12,
    country: 'New Zealand',
  ),
  TimezoneModel(
    city: 'Fiji',
    timezone: 'Pacific/Fiji',
    utcOffset: 12,
    country: 'Fiji',
  ),
  TimezoneModel(
    city: 'Port Moresby',
    timezone: 'Pacific/Port_Moresby',
    utcOffset: 10,
    country: 'Papua New Guinea',
  ),

  // 🌎 South America
  TimezoneModel(
    city: 'São Paulo',
    timezone: 'America/Sao_Paulo',
    utcOffset: -3,
    country: 'Brazil',
  ),
  TimezoneModel(
    city: 'Buenos Aires',
    timezone: 'America/Argentina/Buenos_Aires',
    utcOffset: -3,
    country: 'Argentina',
  ),
  TimezoneModel(
    city: 'Lima',
    timezone: 'America/Lima',
    utcOffset: -5,
    country: 'Peru',
  ),
  TimezoneModel(
    city: 'Bogotá',
    timezone: 'America/Bogota',
    utcOffset: -5,
    country: 'Colombia',
  ),
  TimezoneModel(
    city: 'Santiago',
    timezone: 'America/Santiago',
    utcOffset: -4,
    country: 'Chile',
  ),
];