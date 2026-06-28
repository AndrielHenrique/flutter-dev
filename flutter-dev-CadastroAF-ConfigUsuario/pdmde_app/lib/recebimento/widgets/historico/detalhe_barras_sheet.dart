import 'package:flutter/material.dart';
import 'package:pdmde/recebimento/widgets/shared_widgets.dart';
import '../../../constants/app_colors.dart';
import '../../../model/barra_model.dart';
import '../../../model/recebimento_model.dart';

class DetalheBarrasSheet extends StatelessWidget {
  const DetalheBarrasSheet({super.key, required this.rec});

  final RecebimentoModel rec;

  static void show(BuildContext context, RecebimentoModel rec) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DetalheBarrasSheet(rec: rec),
    );
  }

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
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          _Handle(),
          _Header(rec: rec),
          _Resumo(rec: rec, dataFormatada: _formatarData(rec.dataHora)),
          if (rec.obs != null && rec.obs!.isNotEmpty) _Obs(obs: rec.obs!),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.all(16),
              children: [
                _HeaderTabela(),
                ...rec.barras.asMap().entries.map(
                  (e) => _LinhaTabela(index: e.key, barra: e.value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.rec});
  final RecebimentoModel rec;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              rec.numAF,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.descricao,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  rec.fornecedor,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Resumo extends StatelessWidget {
  const _Resumo({required this.rec, required this.dataFormatada});
  final RecebimentoModel rec;
  final String dataFormatada;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ResumoItem('BARRAS', '${rec.totalBarras}'),
          Container(width: 1, height: 32, color: Colors.grey[300]),
          ResumoItem('PESO TOTAL', '${rec.pesoTotal.toStringAsFixed(0)} kg'),
          Container(width: 1, height: 32, color: Colors.grey[300]),
          ResumoItem('DATA', dataFormatada),
        ],
      ),
    );
  }
}

class _Obs extends StatelessWidget {
  const _Obs({required this.obs});
  final String obs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.amber[50],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'Obs: $obs',
        style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
      ),
    );
  }
}

class _HeaderTabela extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[300],
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: const Row(
        children: [
          SizedBox(width: 28, child: _ColTxt('#')),
          Expanded(flex: 3, child: _ColTxt('DESCRICAO')),
          Expanded(flex: 2, child: _ColTxt('CORRIDA', center: true)),
          Expanded(flex: 2, child: _ColTxt('PESO', center: true)),
          Expanded(flex: 2, child: _ColTxt('Nr BARRA', center: true)),
        ],
      ),
    );
  }
}

class _ColTxt extends StatelessWidget {
  const _ColTxt(this.label, {this.center = false});
  final String label;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 11,
        color: Colors.white,
      ),
    );
  }
}

class _LinhaTabela extends StatelessWidget {
  const _LinhaTabela({required this.index, required this.barra});
  final int index;
  final BarraModel barra;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: barra.isRasurada
          ? Colors.orange[50]
          : (index % 2 == 0 ? Colors.white : Colors.grey[50]),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${barra.linha}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(barra.descricao, style: const TextStyle(fontSize: 11)),
                if (barra.isRasurada)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    color: Colors.orange[100],
                    child: const Text(
                      'RASURADA',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${barra.corrida ?? ""}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${barra.pesoBarra.toStringAsFixed(1)} kg',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              barra.numeroBarra.isEmpty ? '' : barra.numeroBarra,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
