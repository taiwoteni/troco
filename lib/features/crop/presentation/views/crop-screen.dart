import 'package:croppy/croppy.dart';
import 'package:flutter/material.dart';
import 'package:troco/core/app/color-manager.dart';

class CropScreen extends StatelessWidget {
  const CropScreen({
    super.key,
    required this.imageProvider,
    required this.initialData,
    this.heroTag,
    this.onCropped,
  });

  final ImageProvider imageProvider;
  final CroppableImageData? initialData;
  final Object? heroTag;
  final Future<CropImageResult> Function(CropImageResult)? onCropped;

  static Future<CropImageResult?> showCustomCropper(
  BuildContext context,
  ImageProvider imageProvider, {
  CroppableImageData? initialData,
  Object? heroTag,
  Future<CropImageResult> Function(CropImageResult)? onCropped,
}) async {
  // Before pushing the route, prepare the initial data. If it's null, populate
  // it with empty content. This is required for Hero animations.
  final _initialData = initialData ??
      await CroppableImageData.fromImageProvider(
        imageProvider,
      );

  if (context.mounted) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return CropScreen(
            imageProvider: imageProvider,
            initialData: _initialData,
            heroTag: heroTag,
            onCropped: onCropped,
          );
        },
      ),
    );
  }

  return null;
}

  @override
  Widget build(BuildContext context) {
    // Creates a croppable image controller
    return DefaultCupertinoCroppableImageController(
      imageProvider: imageProvider,
      initialData: initialData,
      postProcessFn: onCropped,
      builder: (context, controller) {
        // Used to animate the page with Hero animations. Can be omitted if
        // you don't want to use Hero animations.
        return CroppableImagePageAnimator(
          controller: controller,
          heroTag: heroTag,
          builder: (context, overlayOpacityAnimation) {
            return Scaffold(
              backgroundColor: ColorManager.background,
              appBar: AppBar(
                backgroundColor: ColorManager.background,
                actions: [
                  // The "Done" button
                  Builder(
                    builder: (context) => TextButton(
                      child: const Text('Done'),
                      onPressed: () async {
                        // Enable the Hero animations
                        CroppableImagePageAnimator.of(context)
                            ?.setHeroesEnabled(true);

                        // Crop the image
                        final result = await controller.crop();

                        if (context.mounted) {
                          Navigator.of(context).pop(result);
                        }
                      },
                    ),
                  ),
                ],
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  // Viewport is used to lay out the croppable image
                  child: AnimatedCroppableImageViewport(
                    controller: controller,
                    // We're using the default Material crop handles, but you
                    // can use your own if you want to.
                    cropHandlesBuilder: (context) => MaterialImageCropperHandles(
                      controller: controller,
                      gesturePadding: 16.0,
                    ),
                    overlayOpacityAnimation: overlayOpacityAnimation,
                    gesturePadding: 16.0,
                    heroTag: heroTag,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}