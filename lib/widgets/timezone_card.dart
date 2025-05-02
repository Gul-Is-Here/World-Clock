import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../models/timezone_model.dart';
import '../controllers/clock_controller.dart';

class TimezoneCard extends StatefulWidget {
  final TimezoneModel timezone;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final VoidCallback? onSetAlarm;
  final VoidCallback? onShare;
  final bool isCurrentLocation;
  final bool isPrimary;

  const TimezoneCard({
    required this.timezone,
    required this.onDelete,
    this.onTap,
    this.onSetAlarm,
    this.onShare,
    this.isCurrentLocation = false,
    this.isPrimary = false,
    super.key,
  });

  @override
  State<TimezoneCard> createState() => _TimezoneCardState();
}

class _TimezoneCardState extends State<TimezoneCard> {
  final ClockController _controller = Get.find();
  late Timer _timer;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      setState(() => _isExpanded = !_isExpanded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final colorScheme = theme.colorScheme;
    final localTime = _controller.getLocalTime(widget.timezone);
    final isDayTime = widget.timezone.isDaytime;

    // Colors for light/dark themes
    final bgColor =
        isLight
            ? isDayTime
                ? colorScheme.primaryContainer
                : colorScheme.secondaryContainer
            : isDayTime
            ? colorScheme.primaryContainer
            : colorScheme.secondaryContainer;

    final textColor =
        isLight
            ? isDayTime
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSecondaryContainer
            : Colors.white;

    final secondaryTextColor =
        isLight
            ? isDayTime
                ? colorScheme.onPrimaryContainer.withOpacity(0.8)
                : colorScheme.onSecondaryContainer.withOpacity(0.8)
            : Colors.white.withOpacity(0.8);

    final iconColor =
        isLight
            ? isDayTime
                ? colorScheme.primary
                : colorScheme.secondary
            : Colors.white;

    final buttonBgColor =
        isLight
            ? isDayTime
                ? colorScheme.primary.withOpacity(0.1)
                : colorScheme.secondary.withOpacity(0.1)
            : Colors.white.withOpacity(0.1);

    return Card(
      elevation: _isExpanded ? 8 : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _handleTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: bgColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isLight ? 0.05 : 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderRow(theme, isDayTime, iconColor),
                const SizedBox(height: 12),
                _buildLocationInfo(theme, textColor, secondaryTextColor),
                const SizedBox(height: 16),
                _buildTimeDisplay(
                  theme,
                  localTime,
                  textColor,
                  secondaryTextColor,
                ),
                const SizedBox(height: 4),
                _buildDateDisplay(theme, localTime, secondaryTextColor),
                if (_isExpanded && widget.onTap == null)
                  _buildExpandedContent(
                    theme,
                    buttonBgColor,
                    iconColor,
                    textColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(ThemeData theme, bool isDayTime, Color iconColor) {
    final isLight = theme.brightness == Brightness.light;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Location Indicator and Day/Night Icon
        Row(
          children: [
            if (widget.isCurrentLocation)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(isLight ? 0.1 : 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.my_location, size: 16, color: Colors.red),
              ),
            if (widget.isCurrentLocation) const SizedBox(width: 8),
            if (widget.isPrimary)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(isLight ? 0.1 : 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.star, size: 16, color: Colors.amber),
              ),
            if (widget.isPrimary) const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(isLight ? 0.2 : 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDayTime ? Icons.wb_sunny : Icons.nightlight_round,
                color: iconColor,
                size: 20,
              ),
            ),
          ],
        ),

        // More Options Menu
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: iconColor.withOpacity(0.8)),
          itemBuilder:
              (context) => [
                if (widget.onSetAlarm != null)
                  PopupMenuItem(
                    value: 'alarm',
                    child: ListTile(
                      leading: Icon(Icons.alarm, color: theme.iconTheme.color),
                      title: Text(
                        'Set Alarm',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),
                if (widget.onShare != null)
                  PopupMenuItem(
                    value: 'share',
                    child: ListTile(
                      leading: Icon(Icons.share, color: theme.iconTheme.color),
                      title: Text(
                        'Share Location',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),

                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text(
                      'Delete',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
          onSelected: (value) {
            switch (value) {
              case 'delete':
                widget.onDelete();
                break;
              case 'alarm':
                widget.onSetAlarm?.call();
                break;
              case 'share':
                widget.onShare?.call();
                break;
              case 'set_primary':
                // _controller.setAsPrimaryTimezone(widget.timezone);
                break;
            }
          },
        ),
      ],
    );
  }

  Widget _buildLocationInfo(
    ThemeData theme,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.timezone.city,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              widget.timezone.country,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: secondaryTextColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.timezone.formattedUtcOffset(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeDisplay(
    ThemeData theme,
    DateTime localTime,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          DateFormat('HH:mm').format(localTime),
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: textColor,
            height: 0.9,
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            DateFormat('ss').format(localTime),
            style: theme.textTheme.titleMedium?.copyWith(
              color: secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateDisplay(
    ThemeData theme,
    DateTime localTime,
    Color secondaryTextColor,
  ) {
    return Text(
      widget.timezone.formattedFullDate(),
      style: theme.textTheme.bodyMedium?.copyWith(color: secondaryTextColor),
    );
  }

  Widget _buildExpandedContent(
    ThemeData theme,
    Color buttonBgColor,
    Color iconColor,
    Color textColor,
  ) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Divider(height: 1, color: textColor.withOpacity(0.2)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (widget.onSetAlarm != null)
              _buildActionButton(
                icon: Icons.alarm,
                label: 'Alarm',
                onTap: widget.onSetAlarm,
                bgColor: buttonBgColor,
                iconColor: iconColor,
                textColor: textColor,
              ),
            if (widget.onShare != null)
              _buildActionButton(
                icon: Icons.share,
                label: 'Share',
                onTap: widget.onShare,
                bgColor: buttonBgColor,
                iconColor: iconColor,
                textColor: textColor,
              ),
            _buildActionButton(
              icon: Icons.compare_arrows,
              label: 'Compare',
              onTap: _showComparisonDialog,
              bgColor: buttonBgColor,
              iconColor: iconColor,
              textColor: textColor,
            ),
            _buildActionButton(
              icon: Icons.info_outline,
              label: 'Details',
              onTap: _showTimezoneDetails,
              bgColor: buttonBgColor,
              iconColor: iconColor,
              textColor: textColor,
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showComparisonDialog() {
    final selected = widget.timezone;
    final others =
        _controller.selectedTimezones.where((tz) => tz != selected).toList();

    if (others.isEmpty) {
      Get.snackbar(
        'No other timezones',
        'Add more timezones to compare',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        colorText: Theme.of(context).colorScheme.onPrimaryContainer,
      );
      return;
    }

    Get.dialog(
      Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Time Comparison',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildComparisonItem(selected, null, true),
                    const SizedBox(height: 16),
                    ...others.map((tz) => _buildComparisonItem(tz, selected)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonItem(
    TimezoneModel tz,
    TimezoneModel? reference, [
    bool isReference = false,
  ]) {
    final theme = Theme.of(context);
    final isDayTime = tz.isDaytime;
    final timeDifference =
        reference != null ? tz.timeDifferenceFrom(reference) : '';

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            isReference
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Day/Night Indicator
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  isDayTime ? Colors.orange.shade100 : Colors.indigo.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDayTime ? Icons.wb_sunny : Icons.nightlight_round,
              color:
                  isDayTime ? Colors.orange.shade600 : Colors.indigo.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),

          // Location Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tz.city,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color:
                        isReference
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (reference != null)
                  Text(
                    '$timeDifference from ${reference.city}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          isReference
                              ? theme.colorScheme.onPrimaryContainer
                                  .withOpacity(0.8)
                              : theme.colorScheme.onSurfaceVariant.withOpacity(
                                0.7,
                              ),
                    ),
                  ),
              ],
            ),
          ),

          // Time Display
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tz.formattedTime(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color:
                      isReference
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                tz.formattedUtcOffset(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      isReference
                          ? theme.colorScheme.onPrimaryContainer.withOpacity(
                            0.8,
                          )
                          : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTimezoneDetails() {
    final tz = widget.timezone;
    final theme = Theme.of(context);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 6,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Text(
              'Timezone Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow(Icons.location_city, 'City', tz.city),
            _buildDetailRow(Icons.public, 'Timezone', tz.timezone),
            _buildDetailRow(Icons.flag, 'Country', tz.country),
            _buildDetailRow(
              Icons.access_time,
              'UTC Offset',
              tz.formattedUtcOffset(),
            ),
            _buildDetailRow(
              Icons.timelapse,
              'Local Time',
              tz.formattedTimeWithSeconds(),
            ),
            _buildDetailRow(
              Icons.calendar_today,
              'Date',
              tz.formattedFullDate(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Get.back(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required Color bgColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: bgColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: iconColor),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
