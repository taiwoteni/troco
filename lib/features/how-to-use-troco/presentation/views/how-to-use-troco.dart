import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../groups/presentation/collections_page/widgets/empty-screen.dart';

class HowToUseTroco extends ConsumerStatefulWidget {
  const HowToUseTroco({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HowToUseTrocoState();
}

class _HowToUseTrocoState extends ConsumerState<HowToUseTroco> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: SizedBox.expand(
        child: FutureBuilder<List<Widget>>(
          future: AssetManager.getLegalDisplay(
              type: 'how-to-use-troco', context: context),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: SizeManager.large * 1.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: snapshot.requireData,
                ),
              );
            }

            if (snapshot.hasError) {
              EmptyScreen(
                lottie: AssetManager.lottieFile(name: 'error'),
                label: "Couldn't Load How to use Troco",
              );
            }

            return EmptyScreen(
              lottie: AssetManager.lottieFile(name: 'loading'),
              label: 'Loading Loading To Use Troco',
            );
          },
        ),
      ),
    );
  }
}
