import 'package:flutter/material.dart';

class EstatisticaCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;

  const EstatisticaCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 6,
          ),
          child: Column(
            children: [
              Icon(icone),
              const SizedBox(height: 5),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}