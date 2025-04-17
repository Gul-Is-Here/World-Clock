import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:world_clock_app/controllers/clock_controller.dart';
import 'package:world_clock_app/controllers/theme_controller.dart';
import 'package:world_clock_app/models/timezone_model.dart';

import 'package:world_clock_app/widgets/timezone_card.dart';

import '../utils/theme_service.dart';
import 'search_page.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ClockController controller = Get.put(ClockController());
  final ThemeService themeService = Get.find();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'World Clock',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  theme.brightness == Brightness.dark
                      ? [Colors.grey.shade900, Colors.black]
                      : [Colors.blue.shade800, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => Get.to(() => SearchPage()),
          ),
          Obx(
            () => IconButton(
              icon: Icon(
                themeService.isDarkMode.value
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color: Colors.white,
              ),
              onPressed: () => themeService.toggleTheme(),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                theme.brightness == Brightness.dark
                    ? [Colors.black, Colors.grey.shade900]
                    : [Colors.blue.shade50, Colors.blue.shade100],
          ),
        ),
        child: Obx(() {
          if (controller.selectedTimezones.isEmpty) {
            return _buildEmptyState(theme);
          }
          return _buildTimezoneList();
        }),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
        child: const Icon(Icons.add),
        onPressed: () => _showCitySelectorBottomSheet(context),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.public,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No cities added',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first city',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTimezoneList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView(
        children: [
          const SizedBox(height: 16),
          ...controller.selectedTimezones.map((tz) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TimezoneCard(
                timezone: tz,
                onDelete: () => controller.removeTimezone(tz),
              ),
            );
          }).toList(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showCitySelectorBottomSheet(BuildContext context) async {
    final theme = Theme.of(context);
    TimezoneModel? selected = await showModalBottomSheet<TimezoneModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder:
                (_, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: theme.dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Text(
                        'Select a City',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: controller.availableTimezones.length,
                          itemBuilder: (context, index) {
                            final tz = controller.availableTimezones[index];
                            final isSelected = controller.selectedTimezones
                                .contains(tz);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary
                                      .withOpacity(0.1),
                                  child: Icon(
                                    Icons.location_on,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                title: Text(
                                  tz.city,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  'UTC ${tz.utcOffset >= 0 ? '+' : ''}${tz.utcOffset}',
                                  style: theme.textTheme.bodySmall,
                                ),
                                trailing:
                                    isSelected
                                        ? Icon(
                                          Icons.check_circle,
                                          color: Colors.green.shade400,
                                        )
                                        : null,
                                onTap: () => Navigator.pop(context, tz),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );

    if (selected != null) {
      controller.addTimezone(selected);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${selected.city} to your cities'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
