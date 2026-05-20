/// Barrel for all reusable neumorphic widgets.
///
/// Components in this folder are the only entry points app-screen code is
/// allowed to use for primary UI. Hand-rolling Material widgets (ElevatedButton,
/// Card, ListTile, Switch) anywhere outside this folder breaks the design
/// system and should be flagged in code review.
library;

export 'neu_bottom_nav.dart';
export 'neu_button.dart';
export 'neu_chip.dart';
export 'neu_empty_state.dart';
export 'neu_list_tile.dart';
export 'neu_pin_keypad.dart';
export 'neu_progress.dart';
export 'neu_scaffold.dart';
export 'neu_surface.dart';
export 'neu_switch.dart';
export 'neu_text_field.dart';
