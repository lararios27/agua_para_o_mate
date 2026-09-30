import 'dart:async';

import 'package:flutter/material.dart';

import '../models/medicao.dart';
import '../services/microfone_service.dart';
import '../widgets/estatistica_card.dart';
import '../widgets/grafico_decibeis.dart';

class DecibelimetroPage extends StatefulWidget {
  final bool modoEscuro;
  final VoidCallback trocarTema;

  const DecibelimetroPage({
    super.key,
    required this.modoEscuro,
    required this.trocarTema,
  });

  @override
  State<DecibelimetroPage> createState() => _DecibelimetroPageState();
}

class _DecibelimetroPageState extends State<DecibelimetroPage> {
  final MicrofoneService microfoneService = MicrofoneService();

  StreamSubscription<double>? subscription;
  Timer? cronometro;

  int segundos = 0;
  double decibeis = 0;
  bool gravando = false;

  String distanciaSelecionada = '10 cm';

  final List<String> distancias = [
    '10 cm',
    '20 cm',
    '30 cm',
  ];

  final List<Medicao> medicoes = [];

  String formatarTempo(int totalSegundos) {
    final horas = (totalSegundos ~/ 3600)
        .toString()
        .padLeft(2, '0');

    final minutos = ((totalSegundos % 3600) ~/ 60)
        .toString()
        .padLeft(2, '0');

    final segundosRestantes = (totalSegundos % 60)
        .toString()
        .padLeft(2, '0');

    return '$horas:$minutos:$segundosRestantes';
  }

  double calcularMedia() {
    if (medicoes.isEmpty) {
      return 0;
    }

    double soma = 0;

    for (final medicao in medicoes) {
      soma += medicao.db;
    }

    return soma / medicoes.length;
  }

  double calcularMinimo() {
    if (medicoes.isEmpty) {
      return 0;
    }

    double minimo = medicoes.first.db;

    for (final medicao in medicoes) {
      if (medicao.db < minimo) {
        minimo = medicao.db;
      }
    }

    return minimo;
  }

  double calcularMaximo() {
    if (medicoes.isEmpty) {
      return 0;
    }

    double maximo = medicoes.first.db;

    for (final medicao in medicoes) {
      if (medicao.db > maximo) {
        maximo = medicao.db;
      }
    }

    return maximo;
  }

  Future<void> iniciar() async {
    final permissao =
        await microfoneService.solicitarPermissao();

    if (!permissao) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A permissão do microfone é necessária para iniciar.',
          ),
        ),
      );

      return;
    }

    await subscription?.cancel();
    cronometro?.cancel();

    if (!mounted) {
      return;
    }

    setState(() {
      segundos = 0;
      decibeis = 0;
      medicoes.clear();
      gravando = true;
    });

    subscription = microfoneService.iniciar().listen(
      (valor) {
        if (!mounted) {
          return;
        }

        setState(() {
          decibeis = valor;
        });
      },
      onError: (erro) {
        if (!mounted) {
          return;
        }

        parar();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao acessar o microfone: $erro',
            ),
          ),
        );
      },
    );

    cronometro = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          return;
        }

        setState(() {
          segundos++;

          if (segundos % 2 == 0 && decibeis > 0) {
            medicoes.add(
              Medicao(
                tempo: segundos,
                db: decibeis,
                distancia: distanciaSelecionada,
              ),
            );
          }
        });
      },
    );
  }

  Future<void> parar() async {
    await subscription?.cancel();
    subscription = null;

    cronometro?.cancel();
    cronometro = null;

    await microfoneService.parar();

    if (!mounted) {
      return;
    }

    setState(() {
      gravando = false;
    });
  }

  Future<void> limparRegistros() async {
    if (medicoes.isEmpty && segundos == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não há registros para apagar.'),
        ),
      );

      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Limpar registros?'),
          content: const Text(
            'Tem certeza de que deseja apagar todos os registros?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Apagar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) {
      return;
    }

    await subscription?.cancel();
    subscription = null;

    cronometro?.cancel();
    cronometro = null;

    await microfoneService.parar();

    setState(() {
      medicoes.clear();
      segundos = 0;
      decibeis = 0;
      gravando = false;
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    cronometro?.cancel();
    microfoneService.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = calcularMedia();
    final minimo = calcularMinimo();
    final maximo = calcularMaximo();

    final valoresGrafico = medicoes
        .map((medicao) => medicao.db)
        .toList();

    final textoDb = gravando && decibeis > 0
        ? '${decibeis.toStringAsFixed(1)} dB'
        : '-- dB';

    final textoMedia = medicoes.isNotEmpty
        ? '${media.toStringAsFixed(1)} dB'
        : '-- dB';

    final textoMinimo = medicoes.isNotEmpty
        ? '${minimo.toStringAsFixed(1)} dB'
        : '-- dB';

    final textoMaximo = medicoes.isNotEmpty
        ? '${maximo.toStringAsFixed(1)} dB'
        : '-- dB';

    final corGrafico =
        Theme.of(context).colorScheme.primary;

    final corGrade =
        Theme.of(context).dividerColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Decibelímetro'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: widget.modoEscuro
                ? 'Ativar tema claro'
                : 'Ativar tema escuro',
            icon: Icon(
              widget.modoEscuro
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.trocarTema,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            10,
          ),
          child: Column(
            children: [
              const Text(
                'Intensidade sonora atual',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                textoDb,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Tempo de medição',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              Text(
                formatarTempo(segundos),
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  EstatisticaCard(
                    titulo: 'Média',
                    valor: textoMedia,
                    icone: Icons.analytics_outlined,
                  ),
                  EstatisticaCard(
                    titulo: 'Mínimo',
                    valor: textoMinimo,
                    icone: Icons.arrow_downward,
                  ),
                  EstatisticaCard(
                    titulo: 'Máximo',
                    valor: textoMaximo,
                    icone: Icons.arrow_upward,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    12,
                    12,
                    12,
                    8,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gráfico de intensidade sonora',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      SizedBox(
                        height: 130,
                        width: double.infinity,
                        child: valoresGrafico.isEmpty
                            ? const Center(
                                child: Text(
                                  'O gráfico aparecerá após a primeira medição.',
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : CustomPaint(
                                painter:
                                    GraficoDecibeisPainter(
                                  valores: valoresGrafico,
                                  corLinha: corGrafico,
                                  corGrade: corGrade,
                                ),
                              ),
                      ),

                      const SizedBox(height: 4),

                      const Center(
                        child: Text(
                          'Tempo →',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: distanciaSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Distância do celular',
                  prefixIcon: Icon(Icons.straighten),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: distancias.map((distancia) {
                  return DropdownMenuItem<String>(
                    value: distancia,
                    child: Text(distancia),
                  );
                }).toList(),
                onChanged: gravando
                    ? null
                    : (valor) {
                        if (valor == null) {
                          return;
                        }

                        setState(() {
                          distanciaSelecionada = valor;
                        });
                      },
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                          gravando ? parar : iniciar,
                      icon: Icon(
                        gravando
                            ? Icons.stop
                            : Icons.mic,
                      ),
                      label: Text(
                        gravando
                            ? 'Parar'
                            : 'Iniciar',
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: limparRegistros,
                      icon: const Icon(
                        Icons.delete_outline,
                      ),
                      label: const Text('Limpar'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                'Registros a cada 2 segundos '
                '(${medicoes.length})',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Expanded(
                child: medicoes.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum registro ainda.',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: medicoes.length,
                        itemBuilder:
                            (context, index) {
                          final medicao =
                              medicoes[index];

                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  '${index + 1}',
                                ),
                              ),
                              title: Text(
                                'Tempo: '
                                '${formatarTempo(medicao.tempo)}',
                              ),
                              subtitle: Text(
                                'Intensidade: '
                                '${medicao.db.toStringAsFixed(1)} dB\n'
                                'Distância: '
                                '${medicao.distancia}',
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}