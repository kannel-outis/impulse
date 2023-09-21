import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse/app/app.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  int counter = 0;

  // @override
  // void reassemble() {
  //   super.reassemble();
  //   if (isAndroid) {
  //     result = null;
  //     controller?.pauseCamera();
  //   } else {
  //     controller?.resumeCamera();
  //   }
  // }

  double get torchBoxSize => 70.0;
  double get overlayCutSize => 300.0;
  double get margin => 100.0;

  double get dy {
    /* 
    *because alignment starts from the center with (0,0), the remainingHeight would be screenheight/2
    *we calculate the alignment by finding the percentage the cutsize occupies in our remainingHeight
    *which would be cutSize/2
    *for better accuracy, it would be (cutSize/2) + torchBoxSize/2
  */

    return ((overlayCutSize * .5) + (torchBoxSize * .5) + margin) /
        (MediaQuery.of(context).size.height * .5);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          formatsAllowed: const [BarcodeFormat.qrcode],
          overlay: QrScannerOverlayShape(
            borderColor: Theme.of(context).colorScheme.primary,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: overlayCutSize,
          ),
        ),
        Align(
          alignment: Alignment(0, dy),
          child: InkWell(
            onTap: () {
              controller?.toggleFlash();
            },
            child: Container(
              height: torchBoxSize,
              width: torchBoxSize * 2,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background.withOpacity(.8),
                borderRadius: BorderRadius.circular($styles.corners.md),
              ),
              child: const Center(
                child: Icon(
                  Icons.light_mode,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Text(result?.code ?? ""),
        ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      counter++;
      setState(() {
        result = scanData;
      });

      if (result != null) {
        final data = jsonDecode(result!.code ?? "{}") as Map<String, dynamic>;
        if (data.containsKey("ip") || data.containsKey("port")) {
          //Apparantely, go_router has a problem with ports :(
          controller.pauseCamera().then((value) async {
            final result = await context.pushNamed<bool>(
              "scan_dialog",
              queryParameters: {
                "data": jsonEncode({
                  "ip": data["ip"] as String,
                  "port": int.tryParse(data["port"].toString()),
                })
              },
            );
            if (result == false || result == null) {
              controller.resumeCamera();
              this.result = null;
              setState(() {});
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
