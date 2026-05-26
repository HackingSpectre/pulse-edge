import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';

class StepProfile extends ConsumerStatefulWidget {
  const StepProfile({super.key});

  @override
  ConsumerState<StepProfile> createState() => StepProfileState();
}

class StepProfileState extends ConsumerState<StepProfile> {
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  int _sex = 0;
  int _birthYear = DateTime.now().year - 25;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final name = _cleanName(_name.text);
    final username = _cleanUsername(_username.text);
    await ref
        .read(profileRepoProvider)
        .save(
          ProfilesCompanion(
            name: Value(name),
            username: Value(username),
            sex: Value(_sex),
            birthYear: Value(_birthYear),
            heightCm: Value(double.tryParse(_height.text)),
            weightKg: Value(double.tryParse(_weight.text)),
            createdAtMs: Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  String _cleanName(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'Friend' : trimmed;
  }

  String? _cleanUsername(String value) {
    final username = value.trim().replaceAll(RegExp(r'\s+'), '_');
    if (username.isEmpty) return null;
    return username.startsWith('@') ? username.substring(1) : username;
  }

  @override
  Widget build(BuildContext context) {
    final years = List<int>.generate(80, (i) => DateTime.now().year - 5 - i);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: T.space5),
          Text('A bit about you', style: T.h1),
          const SizedBox(height: T.space2),
          Text(
            'Used to seed your personal baseline. Stored only on this phone. '
            'we never sync it.',
            style: T.bodySoft,
          ),
          const SizedBox(height: T.space6),
          NeuTextField(
            controller: _name,
            label: 'Preferred name',
            hint: 'e.g. Adaeze',
            icon: Icons.person_rounded,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => save(),
          ),
          const SizedBox(height: T.space5),
          NeuTextField(
            controller: _username,
            label: 'Username',
            hint: 'optional',
            icon: Icons.alternate_email_rounded,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: T.space5),
          Text('Sex assigned at birth'.toUpperCase(), style: T.label),
          const SizedBox(height: T.space2),
          Wrap(
            spacing: T.space2,
            runSpacing: T.space2,
            children: [
              for (final entry in const [
                MapEntry(1, 'Male'),
                MapEntry(2, 'Female'),
                MapEntry(3, 'Other'),
                MapEntry(0, 'Prefer not to say'),
              ])
                NeuChip(
                  label: entry.value,
                  selected: _sex == entry.key,
                  onPressed: () => setState(() => _sex = entry.key),
                ),
            ],
          ),
          const SizedBox(height: T.space5),
          Text('Birth year'.toUpperCase(), style: T.label),
          const SizedBox(height: T.space2),
          NeuSurface(
            depth: NeuDepth.sunken,
            borderRadius: T.brMd,
            padding: const EdgeInsets.symmetric(
              horizontal: T.space4,
              vertical: T.space3,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _birthYear,
                isExpanded: true,
                style: T.body,
                dropdownColor: T.surfaceRaised,
                borderRadius: T.brMd,
                onChanged: (v) {
                  if (v != null) setState(() => _birthYear = v);
                },
                items: [
                  for (final y in years)
                    DropdownMenuItem(value: y, child: Text('$y')),
                ],
              ),
            ),
          ),
          const SizedBox(height: T.space5),
          Row(
            children: [
              Expanded(
                child: NeuTextField(
                  controller: _height,
                  label: 'Height (cm)',
                  hint: 'optional',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: T.space4),
              Expanded(
                child: NeuTextField(
                  controller: _weight,
                  label: 'Weight (kg)',
                  hint: 'optional',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          const SizedBox(height: T.space5),
        ],
      ),
    );
  }
}
