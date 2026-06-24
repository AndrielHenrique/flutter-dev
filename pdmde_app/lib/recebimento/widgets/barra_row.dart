import 'package:flutter/material.dart';
import '../../../model/barra_model.dart';

class BarraRow extends StatelessWidget {
  const BarraRow({
    super.key,
    required this.index,
    required this.barra,
    required this.onAtualizar,
    required this.onRemover,
  });

  final int index;
  final BarraModel barra;
  final void Function(BarraModel) onAtualizar;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    final bool rasurada = barra.isRasurada;
    final bool pesoAlerta = barra.pesoBarra > 0 && barra.pesoBarra < 475;

    return Container(
      color: rasurada
          ? Colors.orange[50]
          : (index % 2 == 0 ? Colors.white : const Color(0xFFF8FAFD)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#${barra.linha}',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              barra.descricao,
              style: const TextStyle(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: _CampoTexto(
              valorInicial: barra.corrida?.toString() ?? '',
              hint: 'Corrida',
              teclado: TextInputType.number,
              bordaVermelha: false,
              onChanged: (v) =>
                  onAtualizar(barra.copyWith(corrida: int.tryParse(v))),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: _CampoTexto(
              valorInicial: barra.pesoBarra == 0
                  ? ''
                  : barra.pesoBarra.toString(),
              hint: 'kg',
              teclado: TextInputType.number,
              bordaVermelha: pesoAlerta,
              onChanged: (v) => onAtualizar(
                barra.copyWith(pesoBarra: double.tryParse(v) ?? 0),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: _CampoTexto(
              valorInicial: barra.numeroBarra,
              hint: 'Nr',
              teclado: TextInputType.text,
              bordaVermelha: rasurada,
              habilitado: !rasurada,
              onChanged: (v) => onAtualizar(barra.copyWith(numeroBarra: v)),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 36,
            height: 36,
            child: ElevatedButton(
              onPressed: onRemover,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                'X',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  const _CampoTexto({
    required this.valorInicial,
    required this.hint,
    required this.teclado,
    required this.bordaVermelha,
    required this.onChanged,
    this.habilitado = true,
  });

  final String valorInicial;
  final String hint;
  final TextInputType teclado;
  final bool bordaVermelha;
  final bool habilitado;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: valorInicial,
      keyboardType: teclado,
      textAlign: TextAlign.center,
      enabled: habilitado,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 11),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: bordaVermelha ? Colors.red : Colors.grey[300]!,
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
      onChanged: onChanged,
    );
  }
}
