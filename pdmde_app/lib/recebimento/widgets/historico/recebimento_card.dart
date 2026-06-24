import 'package:flutter/material.dart';
import 'package:pdmde/recebimento/widgets/shared_widgets.dart';
import '../../../constants/app_colors.dart';
import '../../../model/recebimento_model.dart';

class RecebimentoCard extends StatelessWidget {
  const RecebimentoCard({
    super.key,
    required this.rec,
    required this.onVer,
    required this.onEditar,
    required this.onDeletar,
  });

  final RecebimentoModel rec;
  final VoidCallback onVer;
  final VoidCallback onEditar;
  final VoidCallback onDeletar;

  String _formatarData(String iso) {
    try {
      final DateTime dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final int rasuradas = rec.barras.where((b) => b.isRasurada).length;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: onVer,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            _Header(rec: rec, dataFormatada: _formatarData(rec.dataHora)),
            _Corpo(rec: rec, rasuradas: rasuradas),
            _Acoes(onVer: onVer, onEditar: onEditar, onDeletar: onDeletar),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.rec, required this.dataFormatada});
  final RecebimentoModel rec;
  final String dataFormatada;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'AF ${rec.numAF}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              rec.fornecedor,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            dataFormatada,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _Corpo extends StatelessWidget {
  const _Corpo({required this.rec, required this.rasuradas});
  final RecebimentoModel rec;
  final int rasuradas;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rec.descricao,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              InfoChip(Icons.layers_outlined, '${rec.totalBarras} barras'),
              const SizedBox(width: 8),
              InfoChip(
                Icons.scale_outlined,
                '${rec.pesoTotal.toStringAsFixed(0)} kg',
              ),
              if (rasuradas > 0) ...[
                const SizedBox(width: 8),
                InfoChip(
                  Icons.warning_amber_outlined,
                  '$rasuradas rasurada(s)',
                  color: Colors.orange,
                ),
              ],
            ],
          ),
          if (rec.obs != null && rec.obs!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Obs: ${rec.obs}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Acoes extends StatelessWidget {
  const _Acoes({
    required this.onVer,
    required this.onEditar,
    required this.onDeletar,
  });

  final VoidCallback onVer;
  final VoidCallback onEditar;
  final VoidCallback onDeletar;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          _Acao(
            icon: Icons.visibility_outlined,
            label: 'Ver',
            onPressed: onVer,
          ),
          const DividerV(),
          _Acao(
            icon: Icons.edit_outlined,
            label: 'Editar',
            onPressed: onEditar,
            color: AppColors.primary,
          ),
          const DividerV(),
          _Acao(
            icon: Icons.delete_outline,
            label: 'Remover',
            onPressed: onDeletar,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

class _Acao extends StatelessWidget {
  const _Acao({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: color),
        label: Text(label, style: TextStyle(fontSize: 13, color: color)),
      ),
    );
  }
}
