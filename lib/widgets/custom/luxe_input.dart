import 'package:flutter/material.dart';
import 'package:flutter_client/config/theme.dart';

/// Luxe-styled text input field
class LuxeInput extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final int maxLines;
  final int minLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool enabled;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;

  const LuxeInput({
    Key? key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines = 1,
    this.validator,
    this.onChanged,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
  }) : super(key: key);

  @override
  State<LuxeInput> createState() => _LuxeInputState();
}

class _LuxeInputState extends State<LuxeInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  String? _errorText;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _validateInput(String value) {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: AppTheme.textTheme.labelLarge?.copyWith(
            color: _isFocused ? AppTheme.primaryColor : AppTheme.textColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacing2),
        
        // Input Container
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: _isFocused ? AppTheme.shadowMedium : AppTheme.shadowSmall,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: _obscureText && widget.obscureText,
            maxLines: _obscureText ? 1 : widget.maxLines,
            minLines: _obscureText ? 1 : widget.minLines,
            enabled: widget.enabled,
            textInputAction: widget.textInputAction,
            onChanged: (value) {
              _validateInput(value);
              widget.onChanged?.call(value);
            },
            onTap: widget.onTap,
            style: AppTheme.textTheme.bodyLarge?.copyWith(
              color: widget.enabled ? AppTheme.textColor : AppTheme.disabledColor,
            ),
            cursorColor: AppTheme.primaryColor,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textTertiaryColor,
              ),
              filled: true,
              fillColor: widget.enabled 
                ? AppTheme.surfaceColor 
                : AppTheme.backgroundColor.withOpacity(0.5),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing4,
                vertical: AppTheme.spacing3,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: const BorderSide(
                  color: AppTheme.borderColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: BorderSide(
                  color: _errorText != null ? AppTheme.errorColor : AppTheme.borderColor,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: const BorderSide(
                  color: AppTheme.errorColor,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: const BorderSide(
                  color: AppTheme.errorColor,
                  width: 2,
                ),
              ),
              prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _isFocused ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                  )
                : null,
              suffixIcon: widget.suffixIcon != null
                ? GestureDetector(
                    onTap: widget.onSuffixTap ?? (widget.obscureText ? _toggleObscure : null),
                    child: Icon(
                      widget.obscureText
                        ? (_obscureText ? Icons.visibility_off : Icons.visibility)
                        : widget.suffixIcon,
                      color: _isFocused ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                    ),
                  )
                : null,
              errorText: _errorText,
              errorStyle: AppTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.errorColor,
              ),
            ),
          ),
        ),
        
        // Error message
        if (_errorText != null) ...[
          const SizedBox(height: AppTheme.spacing2),
          Row(
            children: [
              Icon(
                Icons.info,
                size: 14,
                color: AppTheme.errorColor,
              ),
              const SizedBox(width: AppTheme.spacing1),
              Expanded(
                child: Text(
                  _errorText!,
                  style: AppTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.errorColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _toggleObscure() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}

/// Simple text input without label (for minimal forms)
class SimpleInput extends StatefulWidget {
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  const SimpleInput({
    Key? key,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  State<SimpleInput> createState() => _SimpleInputState();
}

class _SimpleInputState extends State<SimpleInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: _isFocused ? AppTheme.shadowMedium : AppTheme.shadowSmall,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        maxLines: widget.maxLines,
        onChanged: widget.onChanged,
        style: AppTheme.textTheme.bodyLarge,
        cursorColor: AppTheme.primaryColor,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTheme.textTheme.bodySmall,
          filled: true,
          fillColor: AppTheme.surfaceColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing4,
            vertical: AppTheme.spacing3,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: const BorderSide(color: AppTheme.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: const BorderSide(color: AppTheme.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: const BorderSide(
              color: AppTheme.primaryColor,
              width: 2,
            ),
          ),
          prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
          suffixIcon: widget.suffixIcon != null ? Icon(widget.suffixIcon) : null,
        ),
      ),
    );
  }
}
