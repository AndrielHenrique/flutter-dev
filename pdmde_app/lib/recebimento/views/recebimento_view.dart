import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../../model/barra_model.dart';
import '../controllers/recebimento_controller.dart';
import '../widgets/dialogs.dart';
import '../widgets/shared_widgets.dart';

/// View (MVC) do fluxo de registro de recebimento.
///
/// Não contém lógica de negócio — toda operação é delegada ao
/// [RecebimentoController].
class RecebimentoView extends StatefulWidget {
  const RecebimentoView({super.key});

  @override
  State<RecebimentoView> createState() => _RecebimentoViewState();
}

class _RecebimentoViewState extends State<RecebimentoView> {
  late final RecebimentoController _ctrl;
  final TextEditingController _afController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl = RecebimentoController();
    _ctrl.addListener(_rebuild);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_rebuild);
    _ctrl.dispose();
    _afController.dispose();
    super.dispose();
  }

  void _rebuild() {
    // Sincroniza campo de texto quando o controller reseta
    if (!_ctrl.afEncontrada && _afController.text.isNotEmpty) {
      _afController.clear();
    }
    setState(() {});
  }

  // ──────────────────────────────────────────────
  // Ações
  // ──────────────────────────────────────────────

  Future<void> _onBuscarAF() async {
    await _ctrl.buscarAF(_afController.text.trim());
    if (_ctrl.erro != null && mounted) {
      await mostrarDialogErro(context, _ctrl.erro!);
    }
  }

  Future<void> _onAvancar() async {
    final String? erro = _ctrl.avancar();
    if (erro != null && mounted) await mostrarDialogErro(context, erro);
  }

  Future<void> _onRemoverBarra(int index) async {
    final bool confirmar = await mostrarDialogConfirmarRemoverBarra(
      context,
      _ctrl.barras[index].linha,
    );
    if (confirmar) await _ctrl.removerBarra(index);
  }

  Future<void> _onSalvar() async {
    final bool confirmar = await mostrarDialogConfirmarRecebimento(
      context,
      numAF: _ctrl.afSelecionada!.numAF,
      totalBarras: _ctrl.barras.length,
      pesoTotal: _ctrl.pesoTotal,
    );
    if (!confirmar) return;

    final bool ok = await _ctrl.salvar();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Recebimento registrado com sucesso!'
              : _ctrl.erro ?? 'Erro ao salvar.',
        ),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              _StepperBar(ctrl: _ctrl),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _ctrl.etapa == EtapaRecebimento.buscarAF
                      ? _Etapa1(
                          ctrl: _ctrl,
                          afController: _afController,
                          onBuscar: _onBuscarAF,
                        )
                      : _Etapa2(ctrl: _ctrl, onRemover: _onRemoverBarra),
                ),
              ),
              _Footer(ctrl: _ctrl, onAvancar: _onAvancar, onSalvar: _onSalvar),
            ],
          ),
        ),
        if (_ctrl.carregando) const LoadingOverlay(),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      title: Row(
        children: [
          const Expanded(
            child: Text(
              'Registrar Recebimento',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          _AfBadge(
            afEncontrada: _ctrl.afEncontrada,
            numAF: _ctrl.afSelecionada?.numAF,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _AfBadge
// ─────────────────────────────────────────────────────────────

class _AfBadge extends StatelessWidget {
  const _AfBadge({required this.afEncontrada, this.numAF});
  final bool afEncontrada;
  final String? numAF;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: afEncontrada ? AppColors.afFoundBg : Colors.blue[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        afEncontrada ? 'AF $numAF' : 'Sem AF',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: afEncontrada ? AppColors.afFoundText : Colors.grey[700],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _StepperBar
// ─────────────────────────────────────────────────────────────

class _StepperBar extends StatelessWidget {
  const _StepperBar({required this.ctrl});
  final RecebimentoController ctrl;

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
            ativo: ctrl.etapa == EtapaRecebimento.buscarAF,
            concluido: ctrl.etapa != EtapaRecebimento.buscarAF,
          ),
          Container(width: 1, height: 24, color: Colors.grey[300]),
          _StepItem(
            numero: 2,
            label: 'Barras',
            ativo: ctrl.etapa == EtapaRecebimento.inserirBarras,
            concluido: false,
          ),
          if (ctrl.etapa == EtapaRecebimento.inserirBarras) ...[
            Container(width: 1, height: 24, color: Colors.grey[300]),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AF · BARRAS · PESO',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                    Text(
                      '${ctrl.afSelecionada?.numAF ?? '—'}  ·  ${ctrl.barras.length}  ·  ${ctrl.pesoTotal.toStringAsFixed(0)} kg',
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
                concluido ? '✓' : '$numero',
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

// ─────────────────────────────────────────────────────────────
// _Etapa1
// ─────────────────────────────────────────────────────────────

class _Etapa1 extends StatelessWidget {
  const _Etapa1({
    required this.ctrl,
    required this.afController,
    required this.onBuscar,
  });

  final RecebimentoController ctrl;
  final TextEditingController afController;
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
          _cabecalho(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _campoBusca(context),
                const SizedBox(height: 12),
                if (!ctrl.afEncontrada) _dica(),
                if (ctrl.afEncontrada && ctrl.afSelecionada != null)
                  _cardAFEncontrada(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cabecalho() {
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

  Widget _campoBusca(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: afController,
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

  Widget _dica() {
    return Text(
      'Insira uma AF ou pedido de compra para visualizar os dados.',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
    );
  }

  Widget _cardAFEncontrada() {
    final af = ctrl.afSelecionada!;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue[300]!, width: 2),
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 66,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                af.numAF,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  af.descricao,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  af.fornecedor,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.afFoundBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${af.pesoTotal.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      color: AppColors.afFoundText,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _Etapa2
// ─────────────────────────────────────────────────────────────

class _Etapa2 extends StatelessWidget {
  const _Etapa2({required this.ctrl, required this.onRemover});

  final RecebimentoController ctrl;
  final Future<void> Function(int) onRemover;

  @override
  Widget build(BuildContext context) {
    final int rasuradas = ctrl.totalRasuradas;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _cabecalho(),
          _headerColunas(),
          ..._linhasBarras(context),
          _botaoAdicionar(),
          if (rasuradas > 0) _alertaRasuradas(rasuradas),
        ],
      ),
    );
  }

  Widget _cabecalho() {
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
            'QTD: ${ctrl.barras.length}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Expanded(
            child: Text(
              'Inserir Barras',
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

  Widget _headerColunas() {
    return Container(
      color: Colors.grey[100],
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: const Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'DESCRIÇÃO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'CORRIDA',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'PESO (kg)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Nº',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(width: 36),
        ],
      ),
    );
  }

  List<Widget> _linhasBarras(BuildContext context) {
    return ctrl.barras.asMap().entries.map((e) {
      final int index = e.key;
      final BarraModel barra = e.value;
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

            // Dropdown material
            Expanded(
              flex: 3,
              child: DropdownButtonHideUnderline(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButton<String>(
                    value: barra.codigoMP.isEmpty ? null : barra.codigoMP,
                    hint: const Text(
                      'Material',
                      style: TextStyle(fontSize: 11),
                    ),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, size: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    items: ctrl.produtos
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.codigo,
                            child: Text(
                              p.descricao,
                              style: const TextStyle(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (valor) async {
                      if (valor == null) return;
                      final produto = ctrl.produtos.firstWhere(
                        (p) => p.codigo == valor,
                      );
                      await ctrl.atualizarBarra(
                        index,
                        barra.copyWith(
                          codigoMP: produto.codigo,
                          descricao: produto.descricao,
                          fornecedor: produto.fornecedor,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Corrida
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: barra.corrida?.toString() ?? '',
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Corrida',
                  hintStyle: const TextStyle(fontSize: 11),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (v) => ctrl.atualizarBarra(
                  index,
                  barra.copyWith(corrida: int.tryParse(v)),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Peso
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: barra.pesoBarra == 0
                    ? ''
                    : barra.pesoBarra.toString(),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'kg',
                  hintStyle: const TextStyle(fontSize: 11),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: pesoAlerta ? Colors.red : Colors.grey[300]!,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (v) => ctrl.atualizarBarra(
                  index,
                  barra.copyWith(pesoBarra: double.tryParse(v) ?? 0),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Nº Barra
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: barra.numeroBarra,
                enabled: !rasurada,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Nº barra',
                  hintStyle: const TextStyle(fontSize: 11),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: rasurada ? Colors.red : Colors.grey[300]!,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (v) =>
                    ctrl.atualizarBarra(index, barra.copyWith(numeroBarra: v)),
              ),
            ),
            const SizedBox(width: 6),

            // Botão remover
            SizedBox(
              width: 36,
              height: 36,
              child: ElevatedButton(
                onPressed: () => onRemover(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text('✕', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _botaoAdicionar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: OutlinedButton.icon(
        onPressed: ctrl.adicionarBarra,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Barra'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(180, 52),
          side: const BorderSide(color: AppColors.primary, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _alertaRasuradas(int rasuradas) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        '⚠  $rasuradas barra(s) rasurada(s) serão registradas com status 7.',
        style: const TextStyle(color: AppColors.warningText, fontSize: 13),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _Footer
// ─────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer({
    required this.ctrl,
    required this.onAvancar,
    required this.onSalvar,
  });

  final RecebimentoController ctrl;
  final VoidCallback onAvancar;
  final VoidCallback onSalvar;

  bool get _naEtapa2 => ctrl.etapa == EtapaRecebimento.inserirBarras;

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
          SizedBox(
            width: 50,
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Icon(Icons.home),
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          const Spacer(),
          if (_naEtapa2) ...[
            OutlinedButton(
              onPressed: ctrl.voltar,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(120, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('← Voltar'),
            ),
            const SizedBox(width: 10),
          ],
          ElevatedButton(
            onPressed: _naEtapa2 ? onSalvar : onAvancar,
            style: ElevatedButton.styleFrom(
              backgroundColor: _naEtapa2
                  ? Colors.lightGreen
                  : AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: Size(_naEtapa2 ? 120 : 110, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _naEtapa2 ? '✓ Salvar' : 'Avançar →',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
