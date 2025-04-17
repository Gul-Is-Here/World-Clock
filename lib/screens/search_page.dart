import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:world_clock_app/controllers/clock_controller.dart';
import 'package:world_clock_app/models/timezone_model.dart';

class SearchPage extends StatelessWidget {
  final ClockController controller = Get.find();

  SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Search Cities',
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredCities =
        widget.controller.availableTimezones
            .where((tz) => tz.city.toLowerCase().contains(filter.toLowerCase()))
            .toList();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              theme.brightness == Brightness.dark
                  ? [Colors.black, Colors.grey.shade900]
                  : [const Color(0xFFe0f7fa), const Color(0xFFf5f5f5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 90),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              borderRadius: BorderRadius.circular(12),
              elevation: 4,
              shadowColor: Colors.black12,
              child: TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search cities...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => filter = value),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                filteredCities.isEmpty
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No cities found',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try a different name',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredCities.length,
                      itemBuilder: (context, index) {
                        final tz = filteredCities[index];
                        final isSelected = widget.controller.selectedTimezones
                            .contains(tz);

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? theme.colorScheme.secondary.withOpacity(
                                      0.1,
                                    )
                                    : theme.cardColor.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(16),
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.black12,
                            //     blurRadius: 6,
                            //     offset: const Offset(0, 3),
                            //   ),
                            // ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
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
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'UTC ${tz.utcOffset >= 0 ? '+' : ''}${tz.utcOffset}',
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child:
                                  isSelected
                                      ? Icon(
                                        Icons.check_circle,
                                        color: theme.colorScheme.secondary,
                                        key: const ValueKey('check'),
                                      )
                                      : const Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.blue,
                                        key: ValueKey('add'),
                                      ),
                            ),
                            onTap: () {
                              if (!isSelected) {
                                widget.controller.addTimezone(tz);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Added ${tz.city} to your cities',
                                    ),
                                    backgroundColor: Colors.green.shade600,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
