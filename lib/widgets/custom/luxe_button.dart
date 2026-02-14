import 'package:flutter/material.dart';
import 'package:luxefinds_client/config/theme.dart';

/// Primary styled button with LuxeFinds design system
class LuxeButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final Size? size;
  final bool isLoading;
  final IconData? icon;
  final MainAxisAlignment iconAlignment;

  const LuxeButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.iconAlignment = MainAxisAlignment.center,
  }) : super(key: key);

  @override
  State<LuxeButton> createState() => _LuxeButtonState();
}

class _LuxeButtonState extends State<LuxeButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = widget.size as Size? ?? ButtonSize.medium;
    final isDisabled = widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : _onTapDown,
      onTapUp: isDisabled ? null : _onTapUp,
      onTapCancel: isDisabled ? null : _controller.reverse,
      onTap: isDisabled ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: _buildButton(buttonSize, isDisabled),
      ),
    );
  }

  Widget _buildButton(Size size, bool isDisabled) {
    final padding = _getPadding(size);
    final fontSize = _getFontSize(size);

    switch (widget.variant) {
      case ButtonVariant.primary:
        return Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDisabled ? AppTheme.disabledColor : AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: isDisabled ? AppTheme.shadowNone : AppTheme.shadowMedium,
          ),
          child: _buildButtonContent(fontSize, AppTheme.backgroundColor, isDisabled),
        );

      case ButtonVariant.secondary:
        return Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDisabled ? AppTheme.disabledColor : AppTheme.surfaceLighter,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: isDisabled ? AppTheme.borderColor : AppTheme.primaryColor,
              width: 1.5,
            ),
            boxShadow: isDisabled ? AppTheme.shadowNone : AppTheme.shadowSmall,
          ),
          child: _buildButtonContent(fontSize, AppTheme.primaryColor, isDisabled),
        );

      case ButtonVariant.outline:
        return Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: isDisabled ? AppTheme.disabledColor : AppTheme.primaryColor,
              width: 1.5,
            ),
          ),
          child: _buildButtonContent(
            fontSize,
            isDisabled ? AppTheme.disabledColor : AppTheme.primaryColor,
            isDisabled,
          ),
        );

      case ButtonVariant.ghost:
        return Container(
          padding: padding,
          child: _buildButtonContent(fontSize, AppTheme.primaryColor, isDisabled),
        );
    }
  }

  Widget _buildButtonContent(double fontSize, Color textColor, bool isDisabled) {
    if (widget.isLoading) {
      return SizedBox(
        height: fontSize + 4,
        width: fontSize + 4,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: widget.iconAlignment,
        children: [
          Icon(widget.icon, color: textColor, size: fontSize + 2),
          const SizedBox(width: AppTheme.spacing3),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
              fontFamily: AppTheme.primaryFont,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.label,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: textColor,
        fontFamily: AppTheme.primaryFont,
      ),
    );
  }

  EdgeInsets _getPadding(Size size) {
    switch (size.width.toInt()) {
      case 32: // small
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case 48: // large
        return const EdgeInsets.symmetric(horizontal: 40, vertical: 16);
      default: // medium
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 12);
    }
  }

  double _getFontSize(Size size) {
    switch (size.width.toInt()) {
      case 32: // small
        return 12;
      case 48: // large
        return 16;
      default: // medium
        return 14;
    }
  }
}

enum ButtonVariant { primary, secondary, outline, ghost }

class ButtonSize {
  static const Size small = Size(32, 32);
  static const Size medium = Size(40, 40);
  static const Size large = Size(48, 48);
}
