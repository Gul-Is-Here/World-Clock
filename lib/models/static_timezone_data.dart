// import 'package:flutter/material.dart';

// class TimezoneModel {
//   final String city;
//   final String timezone;
//   final double utcOffset;
//   DateTime currentTime;

//   TimezoneModel({
//     required this.city,
//     required this.timezone,
//     required this.utcOffset,
//     DateTime? currentTime,
//   }) : currentTime = currentTime ?? DateTime.now().add(Duration(hours: utcOffset.toInt()));

//   // Serialization methods
//   Map<String, dynamic> toJson() => {
//         'city': city,
//         'timezone': timezone,
//         'utcOffset': utcOffset,
//       };

//   factory TimezoneModel.fromJson(Map<String, dynamic> json) {
//     return TimezoneModel(
//       city: json['city'],
//       timezone: json['timezone'],
//       utcOffset: json['utcOffset'].toDouble(),
//     );
//   }

//   // Equality comparison
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is TimezoneModel &&
//           runtimeType == other.runtimeType &&
//           city == other.city &&
//           timezone == other.timezone;

//   @override
//   int get hashCode => city.hashCode ^ timezone.hashCode;

//   // Helper method to update the current time
//   void updateCurrentTime() {
//     currentTime = DateTime.now().add(Duration(hours: utcOffset.toInt()));
//   }

//   // Format time for display
//   String formattedTime() {
//     return '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}';
//   }

//   // Format date for display
//   String formattedDate() {
//     return '${_weekday(currentTime.weekday)}, ${currentTime.day} ${_month(currentTime.month)}';
//   }

//   String _weekday(int day) {
//     switch (day) {
//       case 1: return 'Mon';
//       case 2: return 'Tue';
//       case 3: return 'Wed';
//       case 4: return 'Thu';
//       case 5: return 'Fri';
//       case 6: return 'Sat';
//       case 7: return 'Sun';
//       default: return '';
//     }
//   }

//   String _month(int month) {
//     switch (month) {
//       case 1: return 'Jan';
//       case 2: return 'Feb';
//       case 3: return 'Mar';
//       case 4: return 'Apr';
//       case 5: return 'May';
//       case 6: return 'Jun';
//       case 7: return 'Jul';
//       case 8: return 'Aug';
//       case 9: return 'Sep';
//       case 10: return 'Oct';
//       case 11: return 'Nov';
//       case 12: return 'Dec';
//       default: return '';
//     }
//   }
// }

// List<TimezoneModel> staticTimezones = [
//   // 🌎 North America
//   TimezoneModel(city: 'New York', timezone: 'America/New_York', utcOffset: -4),
//   TimezoneModel(
//     city: 'Los Angeles',
//     timezone: 'America/Los_Angeles',
//     utcOffset: -7,
//   ),
//   TimezoneModel(city: 'Chicago', timezone: 'America/Chicago', utcOffset: -5),
//   TimezoneModel(city: 'Toronto', timezone: 'America/Toronto', utcOffset: -4),
//   TimezoneModel(
//     city: 'Mexico City',
//     timezone: 'America/Mexico_City',
//     utcOffset: -6,
//   ),

//   // 🌍 Europe
//   TimezoneModel(city: 'London', timezone: 'Europe/London', utcOffset: 0),
//   TimezoneModel(city: 'Paris', timezone: 'Europe/Paris', utcOffset: 1),
//   TimezoneModel(city: 'Berlin', timezone: 'Europe/Berlin', utcOffset: 1),
//   TimezoneModel(city: 'Moscow', timezone: 'Europe/Moscow', utcOffset: 3),
//   TimezoneModel(city: 'Rome', timezone: 'Europe/Rome', utcOffset: 1),

//   // 🌏 Asia
//   TimezoneModel(city: 'Karachi', timezone: 'Asia/Karachi', utcOffset: 5),
//   TimezoneModel(city: 'Dubai', timezone: 'Asia/Dubai', utcOffset: 4),
//   TimezoneModel(city: 'Beijing', timezone: 'Asia/Shanghai', utcOffset: 8),
//   TimezoneModel(city: 'Tokyo', timezone: 'Asia/Tokyo', utcOffset: 9),
//   TimezoneModel(city: 'Delhi', timezone: 'Asia/Kolkata', utcOffset: 5),
//   TimezoneModel(city: 'Jakarta', timezone: 'Asia/Jakarta', utcOffset: 7),
//   TimezoneModel(city: 'Seoul', timezone: 'Asia/Seoul', utcOffset: 9),
//   TimezoneModel(city: 'Bangkok', timezone: 'Asia/Bangkok', utcOffset: 7),
//   TimezoneModel(
//     city: 'Kuala Lumpur',
//     timezone: 'Asia/Kuala_Lumpur',
//     utcOffset: 8,
//   ),

//   // 🌍 Africa
//   TimezoneModel(city: 'Cairo', timezone: 'Africa/Cairo', utcOffset: 2),
//   TimezoneModel(city: 'Lagos', timezone: 'Africa/Lagos', utcOffset: 1),
//   TimezoneModel(city: 'Nairobi', timezone: 'Africa/Nairobi', utcOffset: 3),
//   TimezoneModel(
//     city: 'Cape Town',
//     timezone: 'Africa/Johannesburg',
//     utcOffset: 2,
//   ),
//   TimezoneModel(city: 'Algiers', timezone: 'Africa/Algiers', utcOffset: 1),

//   // 🌏 Oceania
//   TimezoneModel(city: 'Sydney', timezone: 'Australia/Sydney', utcOffset: 10),
//   TimezoneModel(
//     city: 'Melbourne',
//     timezone: 'Australia/Melbourne',
//     utcOffset: 10,
//   ),
//   TimezoneModel(city: 'Auckland', timezone: 'Pacific/Auckland', utcOffset: 12),
//   TimezoneModel(city: 'Fiji', timezone: 'Pacific/Fiji', utcOffset: 12),
//   TimezoneModel(
//     city: 'Port Moresby',
//     timezone: 'Pacific/Port_Moresby',
//     utcOffset: 10,
//   ),

//   // 🌎 South America
//   TimezoneModel(
//     city: 'São Paulo',
//     timezone: 'America/Sao_Paulo',
//     utcOffset: -3,
//   ),
//   TimezoneModel(
//     city: 'Buenos Aires',
//     timezone: 'America/Argentina/Buenos_Aires',
//     utcOffset: -3,
//   ),
//   TimezoneModel(city: 'Lima', timezone: 'America/Lima', utcOffset: -5),
//   TimezoneModel(city: 'Bogotá', timezone: 'America/Bogota', utcOffset: -5),
//   TimezoneModel(city: 'Santiago', timezone: 'America/Santiago', utcOffset: -4),
// ];
