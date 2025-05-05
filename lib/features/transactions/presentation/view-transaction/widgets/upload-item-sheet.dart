import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/api/data/model/response-model.dart';
import 'package:troco/core/api/utilities/concurrent/concurrent-future.dart';
import 'package:troco/core/app/file-manager.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/features/transactions/data/models/virtual-document.dart';
import 'package:troco/features/transactions/domain/entities/virtual-service.dart';
import 'package:troco/features/transactions/domain/repository/transaction-repo.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/current-transacton-provider.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/virtual-documents-notifier.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/enter-document-link-sheet.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/select-(other)-document-type-sheet.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/select-upload-item-type-sheet.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/virtual-document-widget.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/writeup-sheet.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/others/drag-handle.dart';
import '../../../../../core/components/others/spacer.dart';

class UploadVirtualDocumentsSheet extends ConsumerStatefulWidget {
  final VirtualService virtualService;
  const UploadVirtualDocumentsSheet({super.key, required this.virtualService});

  @override
  ConsumerState createState() => _UploadVirtualDocumentSheetState();

  static Future<bool?> bottomSheet(
      {required BuildContext context, required VirtualService virtualService}) {
    return showModalBottomSheet<bool?>(
        context: context,
        backgroundColor: ColorManager.background,
        isDismissible: false,
        isScrollControlled: true,
        enableDrag: true,
        builder: (context) => UploadVirtualDocumentsSheet(
              virtualService: virtualService,
            ));
  }
}

class _UploadVirtualDocumentSheetState
    extends ConsumerState<UploadVirtualDocumentsSheet> {
  bool loading = false;
  bool link = false;
  bool error = false;
  int uploadedDocuments = 0;
  final buttonKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      (timeStamp) {
        ref.watch(virtualDocumentsProvider.notifier).clear();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
      decoration: BoxDecoration(
          color: ColorManager.background,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SizeManager.extralarge))),
      child: SingleChildScrollView(
        child: Column(
          children: [
            extraLargeSpacer(),
            const DragHandle(),
            largeSpacer(),
            title(),
            largeSpacer(),
            documentsList(),
            largeSpacer(),
            addDocumentWidget(),
            extraLargeSpacer(),
            button(),
            extraLargeSpacer(),
          ],
        ),
      ),
    );
  }

  Future<void> showPopupMenu() async {
    final inkWellBox = context.findRenderObject() as RenderBox;
    final offset = inkWellBox.localToGlobal(Offset.zero);
    final size = inkWellBox.size;

    final rect = RelativeRect.fromLTRB(
        offset.dx, offset.dy + size.height, offset.dx + size.width, offset.dy);

    // final result =
    await showMenu<String?>(context: context, position: rect, items: const [
      PopupMenuItem<String>(
        value: "Edit",
        child: Text("Edit"),
      ),
      PopupMenuItem<String>(
        value: "Delete",
        child: Text("Delete"),
      ),
    ]);
  }

  Widget documentsList() {
    return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return VirtualDocumentWidget(
            key: ObjectKey(ref.watch(virtualDocumentsProvider)[index]),
            document: ref.watch(virtualDocumentsProvider)[index],
            uploaded: loading ? uploadedDocuments > index : null,
          );
        },
        separatorBuilder: (context, index) {
          return mediumSpacer();
        },
        itemCount: ref.watch(virtualDocumentsProvider).length);
  }

  Widget addDocumentWidget() {
    return InkWell(
      onTap: addDocument,
      highlightColor: ColorManager.accentColor.withOpacity(0.3),
      borderRadius: BorderRadius.circular(SizeManager.regular),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SizeManager.large),
        child: DottedBorder(
            color: ColorManager.accentColor,
            strokeWidth: 2,
            borderType: BorderType.RRect,
            dashPattern: const [5, 6],
            radius: const Radius.circular(SizeManager.regular),
            child: Container(
              width: double.maxFinite,
              height: 60,
              alignment: Alignment.center,
              child: Text(
                "Add Virtual Document",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: ColorManager.accentColor,
                    fontFamily: 'lato',
                    fontWeight: FontWeightManager.bold,
                    fontSize: FontSizeManager.large * 0.6),
              ),
            )),
      ),
    );
  }

  Future<void> addDocument() async {
    final isLink =
        await SelectUploadItemTypeSheet.bottomSheet(context: context);
    if (isLink == null) {
      return;
    }

    /// If the user selected link as his/her option
    if (isLink) {
      final link = await EnterDocumentLinkSheet.bottomSheet(context: context);

      if (link == null) {
        return;
      }

      final document = VirtualDocument(value: link);
      ref.read(virtualDocumentsProvider.notifier).add(document: document);
      setState(() {});
      return;
    }

    // If other was what was selected, then we get the other document;
    /// [isWriteUp] will return true if the user selected write-up document over a file
    final isWriteUp =
        await SelectOtherDocumentTypeSheet.bottomSheet(context: context);

    if (isWriteUp == null) {
      return;
    }

    if (isWriteUp) {
      final writeUpDocument = await WriteUpSheet.bottomSheet(context: context);

      if (writeUpDocument == null) {
        return;
      }

      final document = VirtualDocument(value: writeUpDocument.path);
      ref.read(virtualDocumentsProvider.notifier).add(document: document);
      setState(() {});
      return;
    }

    final filePaths =
        await FileManager.pickDocuments(header: "Select Documents");
    if (filePaths == null) {
      return;
    }

    final documents = filePaths
        .map(
          (e) => VirtualDocument(value: e.path),
        )
        .toList();
    ref.read(virtualDocumentsProvider.notifier).addAll(documents: documents);
    setState(() {});
  }

  Widget button() {
    return CustomButton(
        label: "Upload",
        buttonKey: buttonKey,
        usesProvider: true,
        onPressed: uploadWork);
  }

  Widget title() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(vertical: SizeManager.small),
          alignment: Alignment.center,
          child: Text(
            "Upload Item",
            style: TextStyle(
                color: ColorManager.primary,
                fontWeight: FontWeightManager.bold,
                fontFamily: "Lato",
                fontSize: FontSizeManager.large * 0.9),
          ),
        ),
        Positioned(
          width: SizeManager.extralarge * 1.1,
          height: SizeManager.extralarge * 1.1,
          right: SizeManager.regular,
          child: IconButton(
              onPressed: () => Navigator.pop(context),
              style: ButtonStyle(
                  shape: const MaterialStatePropertyAll(CircleBorder()),
                  backgroundColor: MaterialStatePropertyAll(
                      ColorManager.accentColor.withOpacity(0.2))),
              icon: Icon(
                Icons.close_rounded,
                color: ColorManager.accentColor,
                size: IconSizeManager.small,
              )),
        )
      ],
    );
  }

  List<VirtualDocument> documentsToUpload() {
    return ref.read(virtualDocumentsProvider).where(
      (document) {
        // we want to only upload the documents that have not been uploaded
        final index = ref.read(virtualDocumentsProvider).indexOf(document) + 1;

        return uploadedDocuments < index;
      },
    ).toList();
  }

  Future<void> uploadWork() async {
    setState(() {
      loading = true;
      error = false;
    });
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));
    if (documentsToUpload().isEmpty) {
      SnackbarManager.showErrorSnackbar(
          context: context, message: "Empty Documents");
      context.pop();
      return;
    }
    final concurrentFuture = ConcurrentFuture<HttpResponseModel>(
            futures: TransactionRepo.uploadVirtualDocuments(
                transaction: ref.watch(currentTransactionProvider),
                taskId: widget.virtualService.id,
                documents: documentsToUpload()))
        .onProgress((progress) {
      debugPrint('Item ${uploadedDocuments + 1} is uploaded');
      setState(() => uploadedDocuments += 1);
    }).onError(() {
      setState(() {
        loading = false;
        error = true;
      });
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    }).onCompleted(
      (result) {
        final data = result;
        debugPrint("Result are : ${data.length} in number");

        SnackbarManager.showBasicSnackbar(
            context: context, message: "Uploaded documents successfully");
        context.pop(result: true);
      },
    );
    await concurrentFuture.runAsStream();
  }
}
