import 'package:flutter/material.dart';

import '../theme/tokens.dart';

enum AlertSeverity {
  low(0, 'Low', T.info),
  medium(1, 'Medium', T.warning),
  high(2, 'High', T.danger);

  const AlertSeverity(this.code, this.label, this.color);
  final int code;
  final String label;
  final Color color;

  static AlertSeverity fromCode(int code) =>
      AlertSeverity.values.firstWhere((s) => s.code == code, orElse: () => AlertSeverity.low);
}

/// Stable identifier for the kind of physiological signal that fired.
enum AlertType {
  tachycardia('tachycardia', 'Elevated heart rate'),
  bradycardia('bradycardia', 'Low heart rate'),
  hypoxia('hypoxia', 'Low oxygen saturation'),
  hyperthermia('hyperthermia', 'High skin temperature'),
  hypothermia('hypothermia', 'Low skin temperature'),
  fall('fall', 'Possible fall detected'),
  modelAnomaly('model', 'Pattern anomaly detected');

  const AlertType(this.id, this.label);
  final String id;
  final String label;

  static AlertType fromId(String id) =>
      AlertType.values.firstWhere((t) => t.id == id, orElse: () => AlertType.modelAnomaly);
}
