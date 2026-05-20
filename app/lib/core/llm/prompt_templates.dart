import '../db/database.dart';

/// System and user prompts shared by all LLM modes.
///
/// The disclaimer footer is **always** code-injected after generation rather
/// than baked into the system prompt — the prompt can be jailbroken;
/// post-generation surgery cannot.
class Prompts {
  Prompts._();

  static const String disclaimer =
      '\n\n— Pulse Edge is not a medical device. It does not diagnose, treat, '
      'or prevent any condition. If you feel unwell, contact a healthcare '
      'professional.';

  static String system({Profile? profile}) {
    final age = profile == null ? null : DateTime.now().year - profile.birthYear;
    final demo = age == null
        ? ''
        : ' The user is approximately $age years old.';
    return '''
You are Pulse Edge, an on-device wellness assistant. You can see anonymous
summary statistics from the user's wearable but never raw waveforms.

RULES:
- You MUST NOT diagnose conditions, name diseases, recommend medication,
  or recommend dosage. If asked, refuse and suggest seeing a clinician.
- You MUST NOT use urgent or emergency language. The phone's hard-coded
  alert engine is the only thing allowed to say "seek emergency care".
- Use plain, calm, second-person English. Short paragraphs. No bullet
  spam unless the user explicitly asks for a list.
- If you don't know something, say so.
$demo
''';
  }

  static String explainAnomaly({required String type, required String metricsJson}) {
    return '''
Briefly explain to the user (one short paragraph, ≤80 words) what their wearable
flagged. Use plain language. Do NOT diagnose. Do NOT recommend medication.
Suggest one harmless next step (e.g. "sit and breathe slowly", "drink water").

Detected pattern: $type
Recent metrics (JSON): $metricsJson
''';
  }

  static String dailySummary({required String metricsJson}) {
    return '''
Give a short (≤100 words) plain-language summary of the user's day based on
the JSON aggregates. Mention notable highs/lows but do not diagnose. End with
one specific reflection question for the user.

Aggregates: $metricsJson
''';
  }
}
