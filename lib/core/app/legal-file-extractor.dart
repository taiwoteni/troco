import 'package:clipboard/clipboard.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalFileExtractor {
  static TextSpan decodeString(
      {required final String source, required final TextStyle style}) {
    // Regular expression to split between <link> and </link>
    final linkRegex = RegExp(r"<(link|image|i|bold)>(.*?)<\/\1>");

    final linkStyle = TextStyle(
        color: ColorManager.accentColor,
        decoration: TextDecoration.underline,
        decorationColor: ColorManager.accentColor);

    List<InlineSpan> spans = [];
    int currentIndex = 0;

    // Match all <link> tags
    for (final match in linkRegex.allMatches(source)) {
      // Add the text before the <link> tag
      if (currentIndex < match.start) {
        spans.add(TextSpan(text: source.substring(currentIndex, match.start)));
      }

      // Add the text inside the <link> or <image> tag with a specific style
      String? tagName = match.group(1); // Tag name (link or image)
      String? content = match.group(2); // Content inside the tag

      if (tagName == 'link') {
        spans.add(
          TextSpan(
              text: content, // Text inside <link>
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  final uri = Uri.parse(content ?? '');

                  canLaunchUrl(uri).then(
                    (value) {
                      // If the url can be launched, open it
                      if (value) {
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                        return;
                      }

                      // If not, copy it
                      FlutterClipboard.copy(content ?? '');
                    },
                  );
                }),
        );
      } else if (tagName == 'bold') {
        spans.add(
          TextSpan(
              text: content, // Text inside <link>
              style: linkStyle.copyWith(
                  decoration: TextDecoration.none,
                  fontWeight: FontWeightManager.extrabold),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  final uri = Uri.parse(content ?? '');

                  canLaunchUrl(uri).then(
                    (value) {
                      // If the url can be launched, open it
                      if (value) {
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                        return;
                      }

                      // If not, copy it
                      FlutterClipboard.copy(content ?? '');
                    },
                  );
                }),
        );
      } else if (tagName == 'i') {
        spans.add(
          TextSpan(
              text: content, // Text inside <link>
              style: linkStyle.copyWith(
                  decoration: TextDecoration.none,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeightManager.semibold),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  final uri = Uri.parse(content ?? '');

                  canLaunchUrl(uri).then(
                    (value) {
                      // If the url can be launched, open it
                      if (value) {
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                        return;
                      }

                      // If not, copy it
                      FlutterClipboard.copy(content ?? '');
                    },
                  );
                }),
        );
      } else {
        spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              alignment: Alignment.centerLeft,
              constraints:
                  BoxConstraints(maxHeight: 350, minWidth: 140, maxWidth: 300),
              child: Image.asset(
                'assets/images/${content ?? 'nike-shoe-sample.jpeg'}',
                width: double.maxFinite,
                fit: BoxFit.fitWidth,
              ),
            )));
      }

      currentIndex = match.end;
    }

    // Add the remaining text after the last <link> tag
    if (currentIndex < source.length) {
      spans.add(TextSpan(text: source.substring(currentIndex)));
    }

    // Return a parent TextSpan containing all the parts
    return TextSpan(
      style: style,
      children: spans,
    );
  }
}
