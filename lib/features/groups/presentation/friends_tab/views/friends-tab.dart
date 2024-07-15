
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../collections_page/widgets/empty-screen.dart';

class FriendsTab extends ConsumerStatefulWidget {
  const FriendsTab({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FriendsTabState();
}

class _FriendsTabState extends ConsumerState<FriendsTab> {

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      child: EmptyScreen(
        label: "Add a friend",
      ),
    );
  }
}