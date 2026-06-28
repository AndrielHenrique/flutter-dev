import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../model/af_model.dart';
import 'af_card.dart';
import 'itens_pedido_list.dart';

class Etapa1BuscarAf extends StatelessWidget {
  const Etapa1BuscarAf({
    super.key,
    required this.controller,
    required this.afEncontrada,
    required this.af,
    required this.onBuscar,
  });

  final TextEditingController controller;
  final bool afEncontrada;
  final AfModel? af;
  final VoidCallback onBuscar;

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
          _Cabecalho(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _CampoBusca(controller: controller, onBuscar: onBuscar),
                const SizedBox(height: 12),
                if (!afEncontrada) _Dica(),
                if (afEncontrada && af != null) ...[
                  AfCard(af: af!),
                  const SizedBox(height: 16),
                  ItensPedidoList(itens: af!.itens),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 44,
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Buscar por AF / Pedido de Compra',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'ETAPA 1',
              style: TextStyle(
                color: Colors.white,
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

class _CampoBusca extends StatelessWidget {
  const _CampoBusca({required this.controller, required this.onBuscar});

  final TextEditingController controller;
  final VoidCallback onBuscar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'ex: 261544',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            onSubmitted: (_) => onBuscar(),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 52,
          width: 110,
          child: ElevatedButton.icon(
            onPressed: onBuscar,
            icon: const Icon(Icons.search),
            label: const Text('Buscar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Dica extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Insira o numero da AF para visualizar os dados.',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
    );
  }
}
