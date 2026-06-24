import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import 'package:pdmde/recebimento/controllers/recebimento_controller.dart';

class StepperRecebimento extends StatelessWidget {
  const StepperRecebimento({
    super.key,
    required this.etapa,
    required this.numAF,
    required this.totalBarras,
    required this.pesoTotal,
  });

  final EtapaRecebimento etapa;
  final String? numAF;
  final int totalBarras;
  final double pesoTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          _StepItem(
            numero: 1,
            label: 'Buscar AF',
            ativo: etapa == EtapaRecebimento.buscarAF,
            concluido: etapa == EtapaRecebimento.inserirBarras,
          ),
          Container(width: 1, height: 24, color: Colors.grey[300]),
          _StepItem(
            numero: 2,
            label: 'Barras',
            ativo: etapa == EtapaRecebimento.inserirBarras,
            concluido: false,
          ),
          if (etapa == EtapaRecebimento.inserirBarras) ...[
            Container(width: 1, height: 24, color: Colors.grey[300]),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AF / BARRAS / PESO',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                    Text(
                      '${numAF ?? ""} / $totalBarras / ${pesoTotal.toStringAsFixed(0)} kg',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.numero,
    required this.label,
    required this.ativo,
    required this.concluido,
  });

  final int numero;
  final String label;
  final bool ativo;
  final bool concluido;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: concluido
                  ? Colors.green
                  : (ativo ? AppColors.primary : Colors.blue[50]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                concluido ? 'V' : '$numero',
                style: TextStyle(
                  color: concluido || ativo ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: ativo ? FontWeight.w600 : FontWeight.normal,
              color: concluido
                  ? Colors.green
                  : (ativo ? Colors.black87 : Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
