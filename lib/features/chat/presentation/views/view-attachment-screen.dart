import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/chat.dart';

class ViewAttachmentScreen extends ConsumerStatefulWidget {
  final Chat chat;
  const ViewAttachmentScreen({super.key, required this.chat});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ViewAttachmentScreenState();
}

class _ViewAttachmentScreenState extends ConsumerState<ViewAttachmentScreen> {

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}