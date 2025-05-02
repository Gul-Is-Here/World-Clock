import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:world_clock_app/controllers/clock_controller.dart';
import 'package:world_clock_app/models/timezone_model.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class SearchPage extends StatelessWidget {
  final ClockController controller = Get.find();

  SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Search Cities',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isDark
                      ? [Colors.grey.shade900, Colors.black]
                      : [Colors.blue.shade800, const Color.fromARGB(255, 30, 229, 110)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: _SearchContent(controller: controller),
    );
  }
}

class _SearchContent extends StatefulWidget {
  final ClockController controller;

  const _SearchContent({required this.controller});

  @override
  State<_SearchContent> createState() => _SearchContentState();
}

class _SearchContentState extends State<_SearchContent> {
  String filter = '';
  final searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredCities =
        widget.controller.availableTimezones
            .where((tz) => tz.city.toLowerCase().contains(filter.toLowerCase()))
            .toList();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDark
                  ? [Colors.grey.shade900, Colors.black]
                  : [Colors.blue.shade50, const Color.fromARGB(255, 187, 251, 211)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 90),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Material(
              borderRadius: BorderRadius.circular(16),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: searchController,
                  focusNode: _searchFocusNode,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search by city name...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor.withOpacity(0.7),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    filled: true,
                    fillColor: theme.cardColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon:
                        filter.isNotEmpty
                            ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: theme.hintColor,
                              ),
                              onPressed: () {
                                searchController.clear();
                                setState(() => filter = '');
                              },
                            )
                            : null,
                  ),
                  style: theme.textTheme.bodyLarge,
                  onChanged: (value) => setState(() => filter = value),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                filteredCities.isEmpty
                    ? _buildEmptyState(theme)
                    : AnimationLimiter(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredCities.length,
                        itemBuilder: (context, index) {
                          final tz = filteredCities[index];
                          RxBool isSelected =
                              widget.controller.selectedTimezones
                                  .contains(tz)
                                  .obs;

                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: _buildCityCard(theme, tz),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.travel_explore_rounded,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No cities found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for a different city',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCityCard(ThemeData theme, TimezoneModel tz) {
    return Obx(() {
      final isSelected = widget.controller.selectedTimezones.contains(tz);

      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleCitySelection(tz, isSelected, context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tz.city,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tz.country} • UTC ${tz.utcOffset >= 0 ? '+' : ''}${tz.utcOffset}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                  child:
                      isSelected
                          ? Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green.shade500,
                            key: const ValueKey('selected'),
                          )
                          : Icon(
                            Icons.add_circle_outline_rounded,
                            color: theme.colorScheme.primary,
                            key: const ValueKey('unselected'),
                          ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _handleCitySelection(
    TimezoneModel tz,
    bool isSelected,
    BuildContext context,
  ) {
    if (!isSelected) {
      widget.controller.addTimezone(tz);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${tz.city} to your cities'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () => widget.controller.removeTimezone(tz),
          ),
        ),
      );
    }
  }
}
