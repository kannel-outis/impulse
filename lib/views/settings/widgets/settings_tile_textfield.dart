import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:impulse/app/app.dart';

class SettingsTileTextField extends StatelessWidget {
  const SettingsTileTextField({
    super.key,
    required TextEditingController portNumberTextController,
  }) : _portNumberTextController = portNumberTextController;

  final TextEditingController _portNumberTextController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: MediaQuery.of(context).size.width,
      // color: Colors.black,
      child: LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          height: 70,
          width: constraints.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Port Number",
                    style: $styles.text.bodyBold.copyWith(height: 1.2),
                  ),
                  SizedBox(
                    width: constraints.maxWidth - 90,
                    child: Text(
                      "Will only be used when connected as a receiver",
                      maxLines: 5,
                      style: $styles.text.bodySmall.copyWith(
                        height: 1.2,
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withOpacity(.5),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 80.scale,
                height: 60,
                child: TextField(
                  controller: _portNumberTextController,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  cursorColor: Theme.of(context).colorScheme.tertiary,
                  style: $styles.text.body.copyWith(letterSpacing: 2),

                  // cursorHeight: 15,
                  maxLength: 5,
                  maxLines: 1,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 20.scale,
                      horizontal: $styles.insets.xs,
                    ),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.tertiary.withOpacity(.1),
                    focusColor: Theme.of(context).colorScheme.tertiary,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                  onSubmitted: (value) {
                    Configurations.instance
                        .setReceiverPortNumber(int.parse(value));
                  },
                  onChanged: (value) {
                    if (value.length == 5) {
                      Configurations.instance
                          .setReceiverPortNumber(int.parse(value));
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
