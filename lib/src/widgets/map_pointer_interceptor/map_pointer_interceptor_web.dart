import 'package:flutter/widgets.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

/// Web implementation: prevents the map (e.g. [HtmlElementView]) from swallowing taps.
class MapPointerInterceptor extends StatelessWidget {
  /// Creates a [MapPointerInterceptor].
  const MapPointerInterceptor({
    super.key,
    required this.child,
    this.intercepting = true,
  });

  /// The subtree to wrap.
  final Widget child;

  /// Passed through to [PointerInterceptor].
  final bool intercepting;

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(intercepting: intercepting, child: child);
  }
}
