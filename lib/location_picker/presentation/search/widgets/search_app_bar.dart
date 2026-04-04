import 'package:flutter/material.dart';

/// A custom AppBar widget for the search screen.
///
/// This widget provides a search input field with an animated clear button.
/// It includes:
/// - Back button
/// - Search text field with RTL support
/// - Animated clear button that appears when text is entered
class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a [SearchAppBar] instance.
  ///
  /// [controller] - The text editing controller for the search field.
  /// [onChanged] - Callback when the search text changes.
  /// [onClear] - Callback when the clear button is pressed.
  const SearchAppBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? theme.colorScheme.surface : Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : Colors.black87,
            size: 26,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      titleSpacing: 16,
      title: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(24),
          ),
          child: TextField(
            controller: controller,
            autofocus: true,
            textDirection: TextDirection.rtl,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'جستجوی مکان، خیابان، منطقه...',
              hintTextDirection: TextDirection.rtl,
              hintStyle: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                size: 24,
              ),
              suffixIcon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: controller.text.isNotEmpty
                    ? IconButton(
                        key: const ValueKey('clear'),
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDark ? Colors.white70 : Colors.black54,
                          size: 20,
                        ),
                        onPressed: onClear,
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
