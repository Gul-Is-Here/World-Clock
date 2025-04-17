import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/timezone_model.dart';
import 'package:get/get.dart';
import '../controllers/clock_controller.dart';

class TimezoneCard extends StatefulWidget {
  final TimezoneModel timezone;
  final VoidCallback onDelete;
  final VoidCallback? onSetAlarm;
  final VoidCallback? onShare;
  final bool isCurrentLocation;

  const TimezoneCard({
    required this.timezone,
    required this.onDelete,
    this.onSetAlarm,
    this.onShare,
    this.isCurrentLocation = false,
    super.key,
  });

  @override
  State<TimezoneCard> createState() => _TimezoneCardState();
}

class _TimezoneCardState extends State<TimezoneCard> {
  final ClockController _controller = Get.find();

  bool _isExpanded = false;
  late DateTime _localTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateLocalTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _updateLocalTime());
    });
  }

  void _updateLocalTime() {
    _localTime = DateTime.now().toUtc().add(
      Duration(hours: widget.timezone.utcOffset.toInt()),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDayTime = _localTime.hour >= 6 && _localTime.hour <= 18;
    final isLight = theme.brightness == Brightness.light;

    final timeColor =
        isDayTime
            ? (isLight ? colorScheme.primary : colorScheme.secondary)
            : (isLight ? colorScheme.secondary : colorScheme.primary);

    final bgColor = theme.cardColor.withOpacity(0.95);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Container(
          color: bgColor,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (widget.isCurrentLocation)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.my_location,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: timeColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDayTime ? Icons.wb_sunny : Icons.nightlight_round,
                          color: timeColor,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                    itemBuilder:
                        (context) => [
                          if (widget.onSetAlarm != null)
                            const PopupMenuItem(
                              value: 'alarm',
                              child: Text('Set Alarm'),
                            ),
                          if (widget.onShare != null)
                            const PopupMenuItem(
                              value: 'share',
                              child: Text('Share Location'),
                            ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        widget.onDelete();
                      } else if (value == 'alarm' &&
                          widget.onSetAlarm != null) {
                        widget.onSetAlarm!();
                      } else if (value == 'share' && widget.onShare != null) {
                        widget.onShare!();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.timezone.city,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'UTC ${widget.timezone.utcOffset >= 0 ? '+' : ''}${widget.timezone.utcOffset}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                DateFormat('hh:mm:ss a').format(_localTime),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: timeColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEE, MMM d, yyyy').format(_localTime),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (widget.onSetAlarm != null)
                      _buildActionButton(
                        icon: Icons.alarm,
                        label: 'Alarm',
                        onTap: widget.onSetAlarm,
                      ),
                    if (widget.onShare != null)
                      _buildActionButton(
                        icon: Icons.share,
                        label: 'Share',
                        onTap: widget.onShare,
                      ),
                    _buildActionButton(
                      icon: Icons.compare_arrows,
                      label: 'Compare',
                      onTap: _showComparisonDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showComparisonDialog() {
    final selected = widget.timezone;
    final others =
        _controller.selectedTimezones.where((tz) => tz != selected).toList();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time Comparison',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected.city,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'UTC ${selected.utcOffset >= 0 ? '+' : ''}${selected.utcOffset}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('hh:mm a').format(selected.currentTime),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...others.map((tz) {
                final diff = tz.utcOffset - selected.utcOffset;
                final sign = diff >= 0 ? '+' : '';
                final isDayTime =
                    tz.currentTime.hour >= 6 && tz.currentTime.hour <= 18;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              isDayTime
                                  ? Colors.orange.shade100
                                  : Colors.indigo.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDayTime ? Icons.wb_sunny : Icons.nightlight_round,
                          color:
                              isDayTime
                                  ? Colors.orange.shade600
                                  : Colors.indigo.shade600,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tz.city,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${sign}${diff} hrs vs ${selected.city}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat('hh:mm a').format(tz.currentTime),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'UTC ${tz.utcOffset >= 0 ? '+' : ''}${tz.utcOffset}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.labelSmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
