import 'package:flutter/material.dart';
import 'package:pdmde/recebimento/controllers/recebimento_controller.dart';
import '../../../constants/app_colors.dart';

class FooterRecebimento extends StatelessWidget {
  const FooterRecebimento({
    super.key,
    required this.etapa,
    required this.onVoltar,
    required this.onAvancar,
    required this.onHome,
  });

  final EtapaRecebimento etapa;
  final VoidCallback onVoltar;
  final VoidCallback onAvancar;
  final VoidCallback onHome;

  bool get _naEtapa2 => etapa == EtapaRecebimento.inserirBarras;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _BotaoHome(onPressed: onHome),
          const SizedBox(width: 10),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          const Spacer(),
          if (_naEtapa2) ...[
            _BotaoVoltar(onPressed: onVoltar),
            const SizedBox(width: 10),
          ],
          _BotaoAvancar(naEtapa2: _naEtapa2, onPressed: onAvancar),
        ],
      ),
    );
  }
}

class _BotaoHome extends StatelessWidget {
  const _BotaoHome({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Icon(Icons.home),
      ),
    );
  }
}

class _BotaoVoltar extends StatelessWidget {
  const _BotaoVoltar({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(120, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('Voltar'),
    );
  }
}

class _BotaoAvancar extends StatelessWidget {
  const _BotaoAvancar({required this.naEtapa2, required this.onPressed});
  final bool naEtapa2;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: naEtapa2 ? Colors.lightGreen : AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: Size(naEtapa2 ? 120 : 110, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        naEtapa2 ? 'Salvar' : 'Avancar',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
