import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../model/af_item_model.dart';

class ItensPedidoList extends StatelessWidget {
  const ItensPedidoList({super.key, required this.itens});

  final List<AfItemModel> itens;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(),
          ...itens.asMap().entries.map(
            (e) => _ItemRow(index: e.key, item: e.value),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: const Text(
        'Itens do Pedido de Compra',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.index, required this.item});

  final int index;
  final AfItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _Numero(index: index),
          const SizedBox(width: 12),
          _Descricao(item: item),
          _Quantidades(item: item),
        ],
      ),
    );
  }
}

class _Numero extends StatelessWidget {
  const _Numero({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _Descricao extends StatelessWidget {
  const _Descricao({required this.item});
  final AfItemModel item;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.descricao,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            item.codigoMP,
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _Quantidades extends StatelessWidget {
  const _Quantidades({required this.item});
  final AfItemModel item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Qtd: ${item.quantidadePedida}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 2),
        Text(
          '${item.pesoUnitario.toStringAsFixed(1)} kg/un',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
