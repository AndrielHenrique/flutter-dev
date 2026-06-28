import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../../model/recebimento_model.dart';
import 'shared_widgets.dart';

// DialogErro
Future<void> mostrarDialogErro(BuildContext context, String msg) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: Colors.amber,
        size: 48,
      ),
      title: const Text(
        'ATENÇÃO',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(fontStyle: FontStyle.italic),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK, entendi'),
          ),
        ),
      ],
    ),
  );
}

// DialogConfirmarDelete
Future<bool> mostrarDialogConfirmarDelete(
  BuildContext context,
  RecebimentoModel rec,
) async {
  final bool? confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: Colors.amber,
        size: 48,
      ),
      title: const Text('Remover recebimento?', textAlign: TextAlign.center),
      content: Text(
        'AF ${rec.numAF} · ${rec.totalBarras} barras · ${rec.pesoTotal.toStringAsFixed(0)} kg',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.grey),
      ),
      actions: [
        _acoesDuplas(
          onCancelar: () => Navigator.pop(context, false),
          onConfirmar: () => Navigator.pop(context, true),
          labelConfirmar: 'Remover',
          corConfirmar: Colors.red,
        ),
      ],
    ),
  );
  return confirm == true;
}

// DialogEditarObs
/// Retorna a nova observação ou `null` se cancelado.
Future<String?> mostrarDialogEditarObs(
  BuildContext context,
  RecebimentoModel rec,
) async {
  final TextEditingController obsController = TextEditingController(
    text: rec.obs ?? '',
  );

  final bool? confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(
        'Editar AF ${rec.numAF}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rec.descricao, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          const Text(
            'Observação:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: obsController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Digite uma observação...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
      actions: [
        _acoesDuplas(
          onCancelar: () => Navigator.pop(context, false),
          onConfirmar: () => Navigator.pop(context, true),
          labelConfirmar: 'Salvar',
          corConfirmar: AppColors.primary,
        ),
      ],
    ),
  );

  if (confirm != true) return null;
  return obsController.text;
}

// DialogConfirmarRecebimento
Future<bool> mostrarDialogConfirmarRecebimento(
  BuildContext context, {
  required String numAF,
  required int totalBarras,
  required double pesoTotal,
}) async {
  final bool? confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.green,
        size: 48,
      ),
      title: const Text(
        'Confirmar Recebimento?',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Deseja realmente registrar esse recebimento?',
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ResumoItem('AF', numAF),
                ResumoItem('BARRAS', '$totalBarras'),
                ResumoItem('PESO', '${pesoTotal.toStringAsFixed(0)} kg'),
              ],
            ),
          ),
        ],
      ),
      actions: [
        _acoesDuplas(
          onCancelar: () => Navigator.pop(context, false),
          onConfirmar: () => Navigator.pop(context, true),
          labelConfirmar: '✓ Confirmar',
          corConfirmar: Colors.lightGreen,
        ),
      ],
    ),
  );
  return confirm == true;
}

// DialogConfirmarRemoverBarra
Future<bool> mostrarDialogConfirmarRemoverBarra(
  BuildContext context,
  int linha,
) async {
  final bool? confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Remover barra'),
      content: Text('Remover barra #$linha?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Remover', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  return confirm == true;
}

// Utilitário interno
Widget _acoesDuplas({
  required VoidCallback onCancelar,
  required VoidCallback onConfirmar,
  required String labelConfirmar,
  required Color corConfirmar,
}) {
  return Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: onCancelar,
          child: const Text('Cancelar'),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          onPressed: onConfirmar,
          style: ElevatedButton.styleFrom(
            backgroundColor: corConfirmar,
            foregroundColor: Colors.white,
          ),
          child: Text(labelConfirmar),
        ),
      ),
    ],
  );
}
