import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/font-manager.dart';

import '../../../../core/app/routes-manager.dart';

class BlockScreen extends ConsumerStatefulWidget
{
    const BlockScreen({super.key});

    @override
    ConsumerState<ConsumerStatefulWidget> createState() => _BlockScreenState();
}

class _BlockScreenState extends ConsumerState<BlockScreen>
{

    @override
    Widget build(BuildContext context)
    {
        return Scaffold(
            backgroundColor: Colors.red,
            body: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                alignment: Alignment.center,
                child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        style: defaultStyle(),
                        children: [
                            const TextSpan(text: "Your account has been blocked.\n"),
                            TextSpan(
                                text: "Learn Why?", 
                                style: defaultStyle().copyWith(
                                    fontWeight: FontWeightManager.bold,
                                    decoration: TextDecoration.underline,
                                    decorationStyle: TextDecorationStyle.solid,
                                    decorationColor: Colors.white
                                ),
                                recognizer: TapGestureRecognizer()..onTap = ()
                                {
                                    Navigator.pushNamed(context, Routes.customerCareRoute);
                                }
                            )
                        ]
                    ))
            )

        );
    }

    TextStyle defaultStyle()
    {
        return const TextStyle(
            color: Colors.white,
            fontSize: FontSizeManager.regular,
            fontWeight: FontWeightManager.regular,
            fontFamily: 'lato'
        );
    }
}
