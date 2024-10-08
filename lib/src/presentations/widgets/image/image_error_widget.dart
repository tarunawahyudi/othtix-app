import 'package:othtix_app/src/presentations/extensions/extensions.dart';
import 'package:flutter/material.dart';

class ImageErrorWidget extends StatelessWidget {
  const ImageErrorWidget({
    super.key,
    this.small = false,
    this.text = 'Image error',
  });

  final bool small;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.broken_image_outlined,
          color: context.theme.disabledColor,
          size: small ? 32 : 52,
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: small
              ? context.textTheme.bodySmall?.copyWith(
                  color: context.theme.disabledColor,
                )
              : context.textTheme.bodyMedium?.copyWith(
                  color: context.theme.disabledColor,
                ),
        ),
      ],
    );
  }
}
