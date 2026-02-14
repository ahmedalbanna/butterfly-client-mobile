import 'package:flutter/material.dart';
import 'package:flutter_client/config/theme.dart';

/// Custom AppBar matching LuxeFinds web design
class LuxeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final bool showDivider;
  final VoidCallback? onLeadingPressed;

  const LuxeAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
    this.showDivider = true,
    this.onLeadingPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.backgroundColor,
        border: showDivider
          ? Border(
              bottom: BorderSide(
                color: AppTheme.borderColor,
                width: 0.5,
              ),
            )
          : null,
        boxShadow: elevation > 0 ? AppTheme.shadowSmall : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing4,
            vertical: AppTheme.spacing3,
          ),
          child: Row(
            mainAxisAlignment: centerTitle 
              ? MainAxisAlignment.spaceBetween 
              : MainAxisAlignment.start,
            children: [
              // Leading
              if (leading != null)
                GestureDetector(
                  onTap: onLeadingPressed ?? () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacing2),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                        color: AppTheme.borderColor,
                        width: 0.5,
                      ),
                    ),
                    child: leading,
                  ),
                )
              else
                const SizedBox(width: 40),

              // Title
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: AppTheme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // Actions
              if (actions != null && actions!.isNotEmpty)
                Row(
                  children: [
                    ...List.generate(
                      actions!.length,
                      (index) => Padding(
                        padding: EdgeInsets.only(
                          left: index > 0 ? AppTheme.spacing2 : 0,
                        ),
                        child: actions![index],
                      ),
                    ),
                  ],
                )
              else
                const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Simple back button for AppBar
class BackButton extends StatelessWidget {
  final Color? color;
  final VoidCallback? onPressed;

  const BackButton({
    Key? key,
    this.color,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () => Navigator.pop(context),
      child: Icon(
        Icons.arrow_back,
        color: color ?? AppTheme.textColor,
        size: 24,
      ),
    );
  }
}

/// App bar action button
class AppBarAction extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? badge;
  final Color? color;

  const AppBarAction({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.badge,
    this.color,
  }) : super(key: key);

  @override
  State<AppBarAction> createState() => _AppBarActionState();
}

class _AppBarActionState extends State<AppBarAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 1, end: 1.1)
                .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacing2),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: AppTheme.borderColor,
                  width: 0.5,
                ),
              ),
              child: Icon(
                widget.icon,
                color: widget.color ?? AppTheme.primaryColor,
                size: 20,
              ),
            ),
          ),
          // Badge
          if (widget.badge != null)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  widget.badge!,
                  style: AppTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.backgroundColor,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
