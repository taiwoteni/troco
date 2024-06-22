import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/features/auth/domain/entities/client.dart';
import 'package:troco/features/profile/presentation/view-profile/widgets/profile-body-widget.dart';
import 'package:troco/features/profile/presentation/view-profile/widgets/profile-header-widget.dart';

class ViewProfileScreen extends ConsumerStatefulWidget {
  final Client client;
  const ViewProfileScreen({super.key, required this.client});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewProfileScreenState();
}

class _ViewProfileScreenState extends ConsumerState<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            ProfileHeader(client: widget.client),
            ProfileBody(client: widget.client),
          ],
        ),
      ),
    );
  }
}
