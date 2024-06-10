import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
          images.length,
          (index) => Align(
            widthFactor: 0.8,
            child: Container(
              width: iconSize,
              height: iconSize,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Image(
                image: images[index],
                fit: BoxFit.cover,
                width: iconSize,
                height: iconSize,
              ),
            ),
          ),
        )
      ],
    );
  }
}
