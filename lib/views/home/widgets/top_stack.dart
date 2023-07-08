import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/controllers/controllers.dart';
import 'package:impulse/views/shared/padded_body.dart';

class TopStack extends ConsumerStatefulWidget {
  const TopStack({
    super.key,
  });

  @override
  ConsumerState<TopStack> createState() => _TopStackState();
}

class _TopStackState extends ConsumerState<TopStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: $styles.times.med,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateProvider);
    final isConnected = connectionState == ConnectionState.connected;
    return SlideTransition(
      position:
          Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1)).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: $styles.curves.defaultCurve,
        ),
      ),
      child: AnimatedContainer(
        duration: $styles.times.fast,
        height: 30,
        width: MediaQuery.of(context).size.width,
        color: isConnected ? Colors.green : $styles.colors.iconColor3,
        child: PaddedBody(
          child: Row(
            children: [
              Icon(
                Icons.wifi_tethering,
                size: $styles.sizes.xSmallIconSize,
                color: $styles.colors.iconColor1,
              ),
              const SizedBox(width: 10),
              Text(
                isConnected ? "Connected" : "Waiting for Connection...",
                style: $styles.text.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
