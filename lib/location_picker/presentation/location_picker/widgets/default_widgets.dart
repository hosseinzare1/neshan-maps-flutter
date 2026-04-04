import 'package:flutter/material.dart';
import '../../../config/location_picker_builders.dart';

// ============ Shimmer Effect (reusable loading animation) ============

/// A shimmer effect widget for loading states.
class ShimmerEffect extends StatefulWidget {
  const ShimmerEffect({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.duration = const Duration(milliseconds: 1500),
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((v) => v.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A skeleton loader widget that shows a shimmer effect.
class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShimmerEffect(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// ============ Address Display ============

/// Default address display widget implementation.
///
/// Used when [LocationPickerUiConfig.addressDisplayBuilder] is null.
///
/// This widget is public so users can:
/// - Use it as reference implementation
/// - Wrap it with additional widgets
/// - Use it from their custom builder for certain states
///
/// Note: This widget will be automatically wrapped with [PointerInterceptor]
/// by the location picker. Custom implementations should not include
/// [PointerInterceptor] as it will be added automatically.
class DefaultAddressDisplay extends StatelessWidget {
  const DefaultAddressDisplay({super.key, required this.data});

  final AddressDisplayData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: data.isSearchEnabled ? data.openSearchScreen : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                // Leading icon with animation
                _buildLeadingIcon(context, colorScheme),
                const SizedBox(width: 16),

                // Address text with shimmer when loading
                Expanded(child: _buildAddressContent(context, theme)),

                // Trailing search icon with pulse animation
                if (data.isSearchEnabled) ...[
                  const SizedBox(width: 12),
                  _buildSearchIcon(context, colorScheme),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context, ColorScheme colorScheme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: data.isLoading
          ? SizedBox(
              key: const ValueKey('loading'),
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            )
          : data.hasError
          ? Icon(
              key: const ValueKey('error'),
              Icons.error_outline_rounded,
              color: colorScheme.error,
              size: 26,
            )
          : Icon(
              key: const ValueKey('success'),
              Icons.location_on_rounded,
              color: colorScheme.primary,
              size: 26,
            ),
    );
  }

  Widget _buildAddressContent(BuildContext context, ThemeData theme) {
    if (data.isLoading) {
      // Match the height of 2-line text (font size * line height * 2 lines + line spacing)
      return SizedBox(
        height: 44, // Approximately 2 lines of text with 1.4 line height
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SkeletonLoader(width: double.infinity, height: 14, borderRadius: 8),
            const SizedBox(height: 8),
            SkeletonLoader(width: 150, height: 14, borderRadius: 8),
          ],
        ),
      );
    }

    if (data.hasError) {
      return Text(
        'خطا در دریافت آدرس',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Text(
      data.formattedAddress ?? '',
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSearchIcon(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.search_rounded, size: 20, color: colorScheme.primary),
    );
  }
}

// ============ Accept Button ============

/// Default accept button widget implementation.
///
/// Used when [LocationPickerUiConfig.acceptButtonBuilder] is null.
///
/// This widget is public so users can:
/// - Use it as reference implementation
/// - Wrap it with additional widgets
/// - Use it from their custom builder
///
/// Note: This widget will be automatically wrapped with [PointerInterceptor]
/// by the location picker. Custom implementations should not include
/// [PointerInterceptor] as it will be added automatically.
class DefaultAcceptButton extends StatefulWidget {
  const DefaultAcceptButton({super.key, required this.data});

  final AcceptButtonData data;

  @override
  State<DefaultAcceptButton> createState() => _DefaultAcceptButtonState();
}

class _DefaultAcceptButtonState extends State<DefaultAcceptButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: widget.data.isEnabled ? 1.0 : 0.7,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: widget.data.isEnabled
                ? LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.data.isEnabled ? null : Colors.grey.shade300,
            boxShadow: widget.data.isEnabled
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.data.isEnabled ? widget.data.onPressed : null,
              onTapDown: widget.data.isEnabled
                  ? (_) => _scaleController.forward()
                  : null,
              onTapUp: widget.data.isEnabled
                  ? (_) => _scaleController.reverse()
                  : null,
              onTapCancel: widget.data.isEnabled
                  ? () => _scaleController.reverse()
                  : null,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: widget.data.isEnabled
                          ? Colors.white
                          : Colors.grey.shade500,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'تأیید مکان',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: widget.data.isEnabled
                            ? Colors.white
                            : Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============ Center Marker ============

/// Default center marker widget implementation.
///
/// Builds a center marker widget for location selection.
///
/// The marker is wrapped with [IgnorePointer] to allow map interactions
/// to pass through. An optional offset can be applied to adjust the marker
/// position (useful for icons where the point is at the bottom).
///
/// This marker stays fixed at the center while the map moves underneath,
/// allowing users to select a location by moving the map.
class DefaultCenterMarker extends StatelessWidget {
  const DefaultCenterMarker({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: Transform.translate(
          offset: const Offset(0, -34),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shadow/glow effect
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
              // Main marker icon
              Icon(
                Icons.location_on_rounded,
                color: colorScheme.primary,
                size: 68,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
