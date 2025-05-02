import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:world_clock_app/controllers/clock_controller.dart';
import 'package:world_clock_app/controllers/theme_controller.dart';
import 'package:world_clock_app/models/timezone_model.dart';
import 'package:world_clock_app/widgets/timezone_card.dart';
import '../utils/theme_service.dart';
import 'search_page.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

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
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            'World Clock',
            key: ValueKey<bool>(themeService.isDarkMode.value),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  theme.brightness == Brightness.dark
                      ? [Colors.grey.shade900, Colors.black]
                      : [
                        const Color.fromARGB(255, 100, 142, 190),
                        const Color.fromARGB(255, 30, 229, 53),
                      ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed:
                () => Get.to(
                  () => SearchPage(),
                  transition: Transition.rightToLeftWithFade,
                  duration: const Duration(milliseconds: 500),
                ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              controller.refreshTime();
            },
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
          if (controller.isLoading.value) {
            return _buildLoadingState(theme);
          }
          if (controller.selectedTimezones.isEmpty) {
            return _buildEmptyState(theme, context);
          }
          return _buildTimezoneList(theme, context);
        }),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'sort',
            mini: true,
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            child: const Icon(Icons.sort),
            onPressed: () => _showSortOptions(context),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'add',
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            child: const Icon(Icons.add),
            onPressed: () => _showCitySelectorBottomSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCube(
            color: theme.colorScheme.primary,
            size: 50.0,
            duration: const Duration(milliseconds: 1200),
          ),
          const SizedBox(height: 20),
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 500),
            child: Text(
              'Loading time data...',
              style: theme.textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedRotation(
            duration: const Duration(seconds: 10),
            turns: 1,
            child: Icon(
              Icons.public,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Text(
              'No cities added',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 500),
            child: Text(
              'Tap + to add your first city',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedButton(
            onPressed: () => _showCitySelectorBottomSheet(context),
            child: const Text('Add Popular Cities'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimezoneList(ThemeData theme, BuildContext context) {
    return Column(
      children: [
        _buildCurrentDateTime(theme),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: RefreshIndicator(
              onRefresh: () async {
                await controller.refreshTime();
              },
              displacement: 40,
              color: theme.colorScheme.primary,
              backgroundColor: theme.cardColor,
              child: AnimationLimiter(
                child: ListView(
                  children: [
                    // const SizedBox(height: 16),
                    ...controller.selectedTimezones.map((tz) {
                      return AnimationConfiguration.staggeredList(
                        position: controller.selectedTimezones.indexOf(tz),
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: TimezoneCard(
                                timezone: tz,
                                onDelete: () => controller.removeTimezone(tz),
                                onTap: () => _showTimezoneDetails(context, tz),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    // const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentDateTime(ThemeData theme) {
    return Obx(() {
      final now = controller.currentTime.value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                DateFormat('EEEE, MMMM d').format(now),
                key: ValueKey<String>(DateFormat('EEEE, MMMM d').format(now)),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Text(
                DateFormat.jm().format(now),
                key: ValueKey<String>(DateFormat.jm().format(now)),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showSortOptions(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder:
          (context) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sort Cities By',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                AnimationLimiter(
                  child: Column(
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder:
                          (widget) => SlideAnimation(
                            horizontalOffset: 50.0,
                            child: FadeInAnimation(child: widget),
                          ),
                      children: [
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: const Text('Time Difference'),
                          onTap: () {
                            controller.sortTimezonesByTimeDifference();
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.sort_by_alpha),
                          title: const Text('Alphabetical'),
                          onTap: () {
                            controller.sortTimezonesAlphabetically();
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: const Text('Region'),
                          onTap: () {
                            controller.sortTimezonesByRegion();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showTimezoneDetails(BuildContext context, TimezoneModel timezone) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => AnimatedPadding(
            padding: MediaQuery.of(context).viewInsets,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.3,
              maxChildSize: 0.7,
              builder:
                  (_, scrollController) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: theme.dividerColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            timezone.city,
                            key: ValueKey<String>(timezone.city),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            timezone.country,
                            key: ValueKey<String>(timezone.country),
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(() {
                          final localTime = controller.getLocalTime(timezone);
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Column(
                              key: ValueKey<DateTime>(localTime),
                              children: [
                                Text(
                                  DateFormat.jm().format(localTime),
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  DateFormat('EEEE, MMMM d').format(localTime),
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'UTC ${timezone.utcOffset >= 0 ? '+' : ''}${timezone.utcOffset}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const Spacer(),
                      ],
                    ),
                  ),
            ),
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
          (context) => AnimatedPadding(
            padding: MediaQuery.of(context).viewInsets,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: DraggableScrollableSheet(
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
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: theme.dividerColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            'Select a City',
                            key: ValueKey<bool>(themeService.isDarkMode.value),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search cities...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged:
                                  (query) => controller.filterTimezones(query),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => Expanded(
                            child: AnimationLimiter(
                              child: ListView.builder(
                                controller: scrollController,
                                itemCount: controller.filteredTimezones.length,
                                itemBuilder: (context, index) {
                                  final tz =
                                      controller.filteredTimezones[index];
                                  final isSelected = controller
                                      .selectedTimezones
                                      .contains(tz);
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 375),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: Card(
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 8,
                                                ),
                                            leading: CircleAvatar(
                                              backgroundColor: theme
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.1),
                                              child: Icon(
                                                Icons.location_on,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                            ),
                                            title: Text(
                                              tz.city,
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                            subtitle: Text(
                                              '${tz.country} • UTC ${tz.utcOffset >= 0 ? '+' : ''}${tz.utcOffset}',
                                              style: theme.textTheme.bodySmall,
                                            ),
                                            trailing:
                                                isSelected
                                                    ? Icon(
                                                      Icons.check_circle,
                                                      color:
                                                          Colors.green.shade400,
                                                    )
                                                    : null,
                                            onTap:
                                                () =>
                                                    Navigator.pop(context, tz),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => controller.removeTimezone(selected),
          ),
        ),
      );
    }
  }
}

class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const AnimatedButton({
    required this.onPressed,
    required this.child,
    super.key,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ElevatedButton(onPressed: widget.onPressed, child: widget.child),
      ),
    );
  }
}
