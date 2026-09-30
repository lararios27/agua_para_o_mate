import 'package:flutter/material.dart';

class GraficoDecibeisPainter extends CustomPainter {
  final List<double> valores;
  final Color corLinha;
  final Color corGrade;

  GraficoDecibeisPainter({
    required this.valores,
    required this.corLinha,
    required this.corGrade,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (valores.isEmpty) {
      return;
    }

    const margemEsquerda = 8.0;
    const margemDireita = 8.0;
    const margemSuperior = 8.0;
    const margemInferior = 8.0;

    final larguraUtil =
        size.width - margemEsquerda - margemDireita;

    final alturaUtil =
        size.height - margemSuperior - margemInferior;

    final pinturaGrade = Paint()
      ..color = corGrade.withValues(alpha: 0.35)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = margemSuperior + (alturaUtil / 4) * i;

      canvas.drawLine(
        Offset(margemEsquerda, y),
        Offset(size.width - margemDireita, y),
        pinturaGrade,
      );
    }

    for (int i = 0; i <= 4; i++) {
      final x = margemEsquerda + (larguraUtil / 4) * i;

      canvas.drawLine(
        Offset(x, margemSuperior),
        Offset(x, size.height - margemInferior),
        pinturaGrade,
      );
    }

    double valorMinimo = valores.first;
    double valorMaximo = valores.first;

    for (final valor in valores) {
      if (valor < valorMinimo) {
        valorMinimo = valor;
      }

      if (valor > valorMaximo) {
        valorMaximo = valor;
      }
    }

    if (valorMaximo == valorMinimo) {
      valorMaximo += 1;
      valorMinimo -= 1;
    }

    final caminho = Path();

    for (int i = 0; i < valores.length; i++) {
      final x = valores.length == 1
          ? margemEsquerda + larguraUtil / 2
          : margemEsquerda +
              (i / (valores.length - 1)) * larguraUtil;

      final proporcao =
          (valores[i] - valorMinimo) /
          (valorMaximo - valorMinimo);

      final y = margemSuperior +
          alturaUtil -
          (proporcao * alturaUtil);

      if (i == 0) {
        caminho.moveTo(x, y);
      } else {
        caminho.lineTo(x, y);
      }
    }

    final pinturaLinha = Paint()
      ..color = corLinha
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(caminho, pinturaLinha);

    final pinturaPontos = Paint()
      ..color = corLinha
      ..style = PaintingStyle.fill;

    for (int i = 0; i < valores.length; i++) {
      final x = valores.length == 1
          ? margemEsquerda + larguraUtil / 2
          : margemEsquerda +
              (i / (valores.length - 1)) * larguraUtil;

      final proporcao =
          (valores[i] - valorMinimo) /
          (valorMaximo - valorMinimo);

      final y = margemSuperior +
          alturaUtil -
          (proporcao * alturaUtil);

      canvas.drawCircle(
        Offset(x, y),
        3,
        pinturaPontos,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant GraficoDecibeisPainter oldDelegate,
  ) {
    return oldDelegate.valores != valores ||
        oldDelegate.corLinha != corLinha ||
        oldDelegate.corGrade != corGrade;
  }
}