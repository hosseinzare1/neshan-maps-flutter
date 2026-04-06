import 'package:flutter/widgets.dart';

/// Wraps [child] for correct pointer handling over platform views.
///
/// On **web**, the implementation is swapped for one that uses
/// `pointer_interceptor` (see [map_pointer_interceptor_web.dart]). On all other
/// platforms this is a no-op wrapper so the package graph stays compatible
/// with every Flutter target (including Android) for static platform tagging.
class MapPointerInterceptor extends StatelessWidget {
  /// Creates a [MapPointerInterceptor].
  const MapPointerInterceptor({
    super.key,
    required this.child,
    this.intercepting = true,
  });

  /// The subtree to wrap.
  final Widget child;

  /// When `false`, passes [child] through without interception where supported.
  final bool intercepting;

  @override
  Widget build(BuildContext context) => child;
}
