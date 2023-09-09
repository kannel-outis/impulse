import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/views/shared/impulse_ink_well.dart';
import 'package:impulse/views/shared/padded_body.dart';

class WhyDialog extends StatelessWidget {
  const WhyDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        height: 250,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular($styles.corners.md),
        ),
        child: Column(
          children: [
            Container(
              height: 80,
              width: double.infinity,
              padding: ($styles.insets.sm, $styles.insets.sm).insets,
              alignment: Alignment.center,
              child: Text(
                "These are likely to fix it",
                textAlign: TextAlign.center,
                style: $styles.text.h3.copyWith(
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Expanded(
              child: PaddedBody(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "1. ",
                          style: $styles.text.body,
                        ),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            Text(
                              "Set up a ",
                              style: $styles.text.body,
                            ),
                            ImpulseInkWell(
                              onTap: isDeskTop
                                  ? null
                                  : () {
                                      AppSettings.openHotspotSettings(
                                          asAnotherTask: true);
                                    },
                              child: Container(
                                padding: ($styles.insets.xs, $styles.insets.xxs)
                                    .insets,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).highlightColor,
                                ),
                                child: Text(
                                  "Hotspot",
                                  style: $styles.text.bodyBold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          "2. ",
                          style: $styles.text.body,
                        ),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            ImpulseInkWell(
                              onTap: isDeskTop
                                  ? null
                                  : () {
                                      AppSettings.openWIFISettings(
                                          asAnotherTask: true);
                                    },
                              child: Container(
                                padding: ($styles.insets.xs, $styles.insets.xxs)
                                    .insets,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).highlightColor,
                                ),
                                child: Text(
                                  "Connect",
                                  style: $styles.text.bodyBold,
                                ),
                              ),
                            ),
                            Text(
                              " to a hostspot through wifi",
                              style: $styles.text.body,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "Tip: Both sender and receiver must be on thesame network.",
                      textAlign: TextAlign.center,
                      style: $styles.text.bodySmallBold,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
