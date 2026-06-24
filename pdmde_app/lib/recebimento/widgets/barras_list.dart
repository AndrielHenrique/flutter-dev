import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../model/af_item_model.dart';
import '../../../model/barra_model.dart';
import 'barra_row.dart';

class BarrasList extends StatelessWidget {
  const BarrasList({
    super.key,
    required this.itens,
    required this.barras,
    required this.totalRasuradas,
    required this.qtdPorItem,
    required this.onAdicionarBarra,
    required this.onAtualizarBarra,
    required this.onRemoverBarra,
  });

  final List<AfItemModel> itens;
  final List<BarraModel> barras;
  final int totalRasuradas;
  final int Function(String codigoMP) qtdPorItem;
  final void Function(AfItemModel) onAdicionarBarra;
  final void Function(int, BarraModel) onAtualizarBarra;
  final void Function(int) onRemoverBarra;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BotoesAdicionar(
          itens: itens,
          qtdPorItem: qtdPorItem,
          onAdicionar: onAdicionarBarra,
        ),
        if (barras.isNotEmpty) ...[
          const SizedBox(height: 12),
          _TabelaBarras(
            barras: barras,
            totalRasuradas: totalRasuradas,
            onAtualizar: onAtualizarBarra,
            onRemover: onRemoverBarra,
          ),
        ],
      ],
    );
  }
}

class _BotoesAdicionar extends StatelessWidget {
  const _BotoesAdicionar({
    required this.itens,
    required this.qtdPorItem,
    required this.onAdicionar,
  });

  final List<AfItemModel> itens;
  final int Function(String codigoMP) qtdPorItem;
  final void Function(AfItemModel) onAdicionar;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cabecalho(),
          ...itens.map((item) {
            // Contagem vem do controller (fonte única de verdade),
            // não recalculada aqui a partir de `barras`.
            final int qtd = qtdPorItem(item.codigoMP);
            final bool completo = qtd >= item.quantidadePedida;
            return _ItemBotao(
              item: item,
              qtdAdicionada: qtd,
              completo: completo,
              onAdicionar: () => onAdicionar(item),
            );
          }),
        ],
      ),
    );
  }

  Widget _cabecalho() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: const Text(
        'Adicionar Barra por Produto',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

class _ItemBotao extends StatelessWidget {
  const _ItemBotao({
    required this.item,
    required this.qtdAdicionada,
    required this.completo,
    required this.onAdicionar,
  });

  final AfItemModel item;
  final int qtdAdicionada;
  final bool completo;
  final VoidCallback onAdicionar;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.descricao,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$qtdAdicionada de ${item.quantidadePedida} barras adicionadas',
                  style: TextStyle(
                    fontSize: 11,
                    color: completo ? Colors.green : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: completo ? null : onAdicionar,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Barra', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: completo ? Colors.grey[300] : AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabelaBarras extends StatelessWidget {
  const _TabelaBarras({
    required this.barras,
    required this.totalRasuradas,
    required this.onAtualizar,
    required this.onRemover,
  });

  final List<BarraModel> barras;
  final int totalRasuradas;
  final void Function(int, BarraModel) onAtualizar;
  final void Function(int) onRemover;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _CabecalhoTabela(total: barras.length),
          _HeaderColunas(),
          ...barras.asMap().entries.map(
            (e) => BarraRow(
              index: e.key,
              barra: e.value,
              onAtualizar: (b) => onAtualizar(e.key, b),
              onRemover: () => onRemover(e.key),
            ),
          ),
          if (totalRasuradas > 0) _AlertaRasuradas(total: totalRasuradas),
        ],
      ),
    );
  }
}

class _CabecalhoTabela extends StatelessWidget {
  const _CabecalhoTabela({required this.total});
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'QTD: $total',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Expanded(
            child: Text(
              'Barras Registradas',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'ETAPA 2',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderColunas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: const Row(
        children: [
          SizedBox(width: 28, child: _ColTxt('#')),
          Expanded(flex: 3, child: _ColTxt('PRODUTO')),
          Expanded(flex: 2, child: _ColTxt('CORRIDA', center: true)),
          Expanded(flex: 2, child: _ColTxt('PESO (kg)', center: true)),
          Expanded(flex: 2, child: _ColTxt('Nr', center: true)),
          SizedBox(width: 36),
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
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }
}

class _AlertaRasuradas extends StatelessWidget {
  const _AlertaRasuradas({required this.total});
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        'Atencao: $total barra(s) rasurada(s) serao registradas com status 7.',
        style: const TextStyle(color: AppColors.warningText, fontSize: 13),
      ),
    );
  }
}
