import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_client/config/theme.dart';

/// Stylized card widget matching LuxeFinds design system
class LuxeCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final double? elevation;
  final VoidCallback? onTap;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final double borderRadius;

  const LuxeCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.spacing4),
    this.backgroundColor,
    this.elevation,
    this.onTap,
    this.border,
    this.boxShadow,
    this.borderRadius = AppTheme.radiusLarge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(
          color: AppTheme.borderColor,
          width: 0.5,
        ),
        boxShadow: boxShadow ?? AppTheme.shadowSmall,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: _buildHoverEffect(card),
      );
    }

    return card;
  }

  Widget _buildHoverEffect(Widget card) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: card,
    );
  }
}

/// Product card with image, title, and price
class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double price;
  final String? category;
  final VoidCallback onTap;
  final bool isLiked;
  final VoidCallback? onLikeToggle;

  const ProductCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.category,
    required this.onTap,
    this.isLiked = false,
    this.onLikeToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: AppTheme.borderColor,
            width: 0.5,
          ),
          boxShadow: AppTheme.shadowSmall,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppTheme.radiusLarge),
                      topRight: Radius.circular(AppTheme.radiusLarge),
                    ),
                  ),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.backgroundColor,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: AppTheme.textSecondaryColor,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
                // Like Button
                if (onLikeToggle != null)
                  Positioned(
                    top: AppTheme.spacing3,
                    right: AppTheme.spacing3,
                    child: GestureDetector(
                      onTap: onLikeToggle,
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.spacing2),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          backdropFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        ),
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? AppTheme.errorColor : AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category != null)
                    Text(
                      category!.toUpperCase(),
                      style: AppTheme.textTheme.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: AppTheme.spacing2),
                  Text(
                    title,
                    style: AppTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacing3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: AppTheme.textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section container with title and optional action
class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? action;
  final EdgeInsets padding;

  const SectionCard({
    Key? key,
    required this.title,
    required this.children,
    this.action,
    this.padding = const EdgeInsets.all(AppTheme.spacing4),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTheme.textTheme.headlineSmall,
            ),
            if (action != null) action!,
          ],
        ),
        const SizedBox(height: AppTheme.spacing4),
        ...children,
      ],
    );
  }
}
