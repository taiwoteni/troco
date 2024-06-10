import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';

class StackedImageListWidget extends ConsumerWidget {
  /// The Icon Size of the icons in the list
  final double iconSize;

  /// The list of images to be show.
  /// [ImageProvider<Object>] was used due to disparity in
  /// needs, wether File Image of Network Image.
  final List<ImageProvider<Object>> images;

  /// A Widget that displays a list of overlapped images like "instagram likes" images
  /// ![](https://i.stack.imgur.com/6JZa6.jpg)
  const StackedImageListWidget(
      {super.key, required this.images, this.iconSize = 35});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double borderSize = 2.25;
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.rtl,
      children: [
        ...List.generate(
          images.length,
          (index) => Align(
            widthFactor: 0.8,
            child: Container(
              width: iconSize - borderSize,
              height: iconSize - borderSize,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: ColorManager.tertiary,
                      width: borderSize,
                      strokeAlign: BorderSide.strokeAlignOutside),
                  image:
                      DecorationImage(fit: BoxFit.cover, image: images[index])),
            ),
          ),
        )
      ],
    );
  }
}
