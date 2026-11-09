import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Whether decorative motion may play here.
///
/// Flourishes ask this before they move. It is false when the platform asks
/// for reduced motion (`MediaQuery.disableAnimations`), so a flourish then
/// shows its final, still state at once.
bool obMotionAllowed(BuildContext context) =>
    !MediaQuery.disableAnimationsOf(context);

/// An animation controller that plays a flourish once from 0 to 1.
///
/// It starts when the widget mounts and again whenever [replayKey] changes.
/// With reduced motion it sits at 1, so the flourish is simply there.
AnimationController useObFlourish({
  required Duration duration,
  Object? replayKey,
  bool play = true,
}) {
  final context = useContext();
  final allowed = obMotionAllowed(context);
  final controller = useAnimationController(
    duration: duration,
    initialValue: allowed && play ? 0 : 1,
  );
  useEffect(() {
    if (!allowed || !play) {
      controller.value = 1;
      return null;
    }
    controller.forward(from: 0);
    return null;
  }, [replayKey, allowed, play]);
  return controller;
}
