import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tokens.dart';
import 'neu_surface.dart';

/// Neumorphic text input. Sunken state with focus ring.
///
/// States:
///   default → sunken, no border
///   focused → sunken + 2dp primary outline
///   error   → sunken + 2dp danger outline + helper text
///   disabled → flat, muted text
class NeuTextField extends StatefulWidget {
  const NeuTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.icon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final String? errorText;
  final IconData? icon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  @override
  State<NeuTextField> createState() => _NeuTextFieldState();
}

class _NeuTextFieldState extends State<NeuTextField> {
  late final FocusNode _focus = widget.focusNode ?? FocusNode();
  bool _focused = false;
  bool _ownFocus = false;

  @override
  void initState() {
    super.initState();
    _ownFocus = widget.focusNode == null;
    _focus.addListener(_onFocus);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    if (_ownFocus) _focus.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (mounted) setState(() => _focused = _focus.hasFocus);
  }

  Color _ringColor() {
    if (widget.errorText != null) return T.danger;
    if (_focused) return T.primary;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final disabled = !widget.enabled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!.toUpperCase(), style: T.label),
          const SizedBox(height: T.space2),
        ],
        AnimatedContainer(
          duration: T.motionFast,
          curve: T.easeOut,
          decoration: BoxDecoration(
            borderRadius: T.brMd,
            border: Border.all(color: _ringColor(), width: 2),
          ),
          padding: const EdgeInsets.all(2),
          child: NeuSurface(
            depth: disabled ? NeuDepth.flat : NeuDepth.sunken,
            borderRadius: T.brMd,
            size: NeuSize.sm,
            padding: const EdgeInsets.symmetric(
              horizontal: T.space4,
              vertical: T.space3,
            ),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon,
                      size: T.iconSm,
                      color: disabled ? T.inkDisabled : T.inkSoft),
                  const SizedBox(width: T.space3),
                ],
                Expanded(
                  child: TextField(
                    focusNode: _focus,
                    controller: widget.controller,
                    obscureText: widget.obscureText,
                    keyboardType: widget.keyboardType,
                    inputFormatters: widget.inputFormatters,
                    maxLines: widget.obscureText ? 1 : widget.maxLines,
                    minLines: widget.minLines,
                    maxLength: widget.maxLength,
                    enabled: widget.enabled,
                    autofocus: widget.autofocus,
                    textInputAction: widget.textInputAction,
                    onSubmitted: widget.onSubmitted,
                    onChanged: widget.onChanged,
                    cursorColor: T.primary,
                    style: T.body.copyWith(
                      color: disabled ? T.inkDisabled : T.ink,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: T.body.copyWith(color: T.inkMuted),
                      border: InputBorder.none,
                      isCollapsed: true,
                      counterText: '',
                    ),
                  ),
                ),
                if (widget.suffix != null) ...[
                  const SizedBox(width: T.space3),
                  widget.suffix!,
                ],
              ],
            ),
          ),
        ),
        if (widget.errorText != null || widget.helper != null) ...[
          const SizedBox(height: T.space2),
          Text(
            widget.errorText ?? widget.helper!,
            style: T.caption.copyWith(
              color: widget.errorText != null ? T.danger : T.inkMuted,
            ),
          ),
        ],
      ],
    );
  }
}
