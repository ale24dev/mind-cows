import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mind_cows/l10n/l10n.dart';
import 'package:mind_cows/src/core/ui/colors.dart';
import 'package:mind_cows/src/core/utils/widgets/bottom_snackbar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

/// Adds extensions to num  to make creating durations more succint:
///
/// ```
/// 200.ms // equivalent to Duration(milliseconds: 200)
/// 3.seconds // equivalent to Duration(milliseconds: 3000)
/// 1.5.days // equivalent to Duration(hours: 36)
/// ```
extension NumDurationX on num {
  Duration get microseconds => Duration(microseconds: round());
  Duration get ms => (this * 1000).microseconds;
  Duration get milliseconds => (this * 1000).microseconds;
  Duration get seconds => (this * 1000 * 1000).microseconds;
  Duration get minutes => (this * 1000 * 1000 * 60).microseconds;
  Duration get hours => (this * 1000 * 1000 * 60 * 60).microseconds;
  Duration get days => (this * 1000 * 1000 * 60 * 60 * 24).microseconds;
}

extension TextStyleX on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);

  TextStyle color(Color color) => copyWith(color: color);
}

extension BuildContextX on BuildContext {
  void genericMessage({String? message, Widget? widget}) {
    if (mounted) {
      showTopSnackBar(
        Overlay.of(this),
        BottomSnackbar(message: message, widget: widget),
      );
    }
  }
}
