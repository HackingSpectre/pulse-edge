/// One feature vector — the input the anomaly detector sees, and the row
/// that gets stored in `feature_rows`.
class FeatureWindow {
  const FeatureWindow({
    required this.tsMs,
    required this.windowS,
    required this.hrMean,
    required this.hrStd,
    required this.hrMin,
    required this.hrMax,
    required this.rmssd,
    required this.pnn50,
    required this.spo2Mean,
    required this.tempMean,
    required this.tempSlope,
    required this.accelMean,
    required this.accelStd,
    required this.activity,
  });

  final int tsMs;
  final int windowS;
  final double hrMean;
  final double hrStd;
  final double hrMin;
  final double hrMax;
  final double rmssd;
  final double pnn50;
  final double? spo2Mean;
  final double tempMean;
  final double tempSlope;
  final double accelMean;
  final double accelStd;
  final int activity;

  /// Ordered numeric features for the model. Keep this in lock-step with
  /// the Python feature spec (ml/anomaly/feature_spec.json).
  List<double> toModelInput() => [
        hrMean,
        hrStd,
        hrMin,
        hrMax,
        rmssd,
        pnn50,
        spo2Mean ?? hrMean, // fall back so missing SpO₂ doesn't NaN-poison
        tempMean,
        tempSlope,
        accelMean,
        accelStd,
        activity.toDouble(),
      ];

  Map<String, Object?> toJson() => {
        'tsMs': tsMs,
        'windowS': windowS,
        'hrMean': hrMean,
        'hrStd': hrStd,
        'hrMin': hrMin,
        'hrMax': hrMax,
        'rmssd': rmssd,
        'pnn50': pnn50,
        'spo2Mean': spo2Mean,
        'tempMean': tempMean,
        'tempSlope': tempSlope,
        'accelMean': accelMean,
        'accelStd': accelStd,
        'activity': activity,
      };
}
