import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';

import '../../../domain/entities/group.dart';

class ViewGroupScreen extends ConsumerStatefulWidget {
  final Group group;
  const ViewGroupScreen({super.key, required this.group});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewGroupScreenState();
}

class _ViewGroupScreenState extends ConsumerState<ViewGroupScreen> {
  late Group group;

  @override
  void initState() {
    group = widget.group;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      
    );
  }
}
