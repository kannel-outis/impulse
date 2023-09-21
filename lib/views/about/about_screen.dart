import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/views/shared/impulse_ink_well.dart';
import 'package:impulse/views/shared/padded_body.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/about_tile.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(),
      body: PaddedBody(
        child: LayoutBuilder(builder: (context, contraints) {
          return Align(
            alignment: Alignment.center,
            child: Container(
              width: contraints.maxWidth,
              height: contraints.maxHeight,
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Image.asset(
                      isDark ? AssetsImage.logo_light : AssetsImage.logo_dark,
                      height: 100,
                      width: 100,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "IMPULSE",
                      style: $styles.text.h3,
                    ),
                    Text(
                      Configurations.versionNumber,
                      style: $styles.text.h4,
                    ),
                    const SizedBox(height: 50),
                    AboutTile(
                      imageUrl: AssetsImage.gmail,
                      imageUrlDark: AssetsImage.gmail,
                      isSvg: true,
                      tag: "enikuomehinoriade@gmail.com",
                      onTap: () {
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: 'enikuomehinoriade@gmail.com',
                        );
                        launchUrl(emailLaunchUri);
                      },
                    ),
                    const SizedBox(height: 15),
                    AboutTile(
                      imageUrl: AssetsImage.github_mark_white,
                      imageUrlDark: AssetsImage.github_mark,
                      tag: "@kannel-outis",
                      onTap: () {
                        launchUrl(
                          Uri.parse("https://github.com/kannel-outis"),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    AboutTile(
                      imageUrl: AssetsImage.x_light,
                      imageUrlDark: AssetsImage.x,
                      tag: "@Emirdilonx",
                      onTap: () {
                        launchUrl(
                          Uri.parse("https://twitter.com/Emirdilonx"),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                    const SizedBox(height: 50),
                    Text(
                      "Built with ❤️ and flutter",
                      style: $styles.text.bodySmallBold,
                    ),
                    const SizedBox(height: 30),
                    Tooltip(
                      message: "https://github.com/kannel-outis/impulse",
                      waitDuration: $styles.times.med,
                      child: ImpulseInkWell(
                        onTap: () {
                          launchUrl(
                            Uri.parse(
                                "https://github.com/kannel-outis/impulse"),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: Container(
                          padding:
                              ($styles.insets.sm, $styles.insets.xxs).insets,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular($styles.corners.sm),
                            color: Theme.of(context).highlightColor,
                          ),
                          child: Text(
                            "VIEW ON GITHUB",
                            style: $styles.text.bodySmallBold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
