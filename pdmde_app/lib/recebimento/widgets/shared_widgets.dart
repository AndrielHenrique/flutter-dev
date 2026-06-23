import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

// ResumoItem: label + valor em coluna (usado em confirmação e
// detalhes do recebimento)

class ResumoItem extends StatelessWidget {
  const ResumoItem(this.label, this.valor, {super.key});

  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }
}

// InfoChip: ícone + label colorido (usado nas cards do histórico)

class InfoChip extends StatelessWidget {
  const InfoChip(this.icon, this.label, {this.color, super.key});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: c),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: c)),
        ],
      ),
    );
  }
}

// LoadingOverlay: sobreposição de carregamento

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.overlay,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

// DividerV: separador vertical (usado em footers e cards)

class DividerV extends StatelessWidget {
  const DividerV({this.height = 32, super.key});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: height, color: Colors.grey[200]);
  }
}
