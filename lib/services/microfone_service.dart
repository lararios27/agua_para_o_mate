import 'dart:async';

import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

class MicrofoneService {
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _subscription;

  Future<bool> solicitarPermissao() async {
    final status = await Permission.microphone.request();

    return status.isGranted;
  }

  Stream<double> iniciar() {
    _noiseMeter = NoiseMeter();

    final controller = StreamController<double>();

    _subscription = _noiseMeter!.noise.listen(
      (NoiseReading leitura) {
        final valor = leitura.meanDecibel;

        if (valor.isFinite && valor > 0) {
          controller.add(valor);
        }
      },
      onError: (erro) {
        controller.addError(erro);
      },
    );

    return controller.stream;
  }

  Future<void> parar() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> dispose() async {
    await parar();
  }
}