import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../../model/barra_model.dart';
import '../../../model/recebimento_model.dart';
import '../controllers/historico_controller.dart';
import '../widgets/dialogs.dart';
import '../widgets/shared_widgets.dart';

/// View (MVC) do histórico de recebimentos.
///
/// Não contém lógica de negócio — toda operação é delegada ao
/// [HistoricoController].
class HistoricoView extends StatefulWidget {
  const HistoricoView({super.key});

  @override
  State<HistoricoView> createState() => _HistoricoViewState();
}

class _HistoricoViewState extends State<HistoricoView> {
  late final HistoricoController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = HistoricoController();
    _ctrl.addListener(_rebuild);
    _ctrl.carregar();
  }

  @override
  void dispose() {
    _ctrl.removeListener(_rebuild);
    _ctrl.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  // ──────────────────────────────────────────────
  // Ações — coordenam controller + feedback de UI
  // ──────────────────────────────────────────────

  Future<void> _onDeletar(RecebimentoModel rec) async {
    final bool confirmar = await mostrarDialogConfirmarDelete(context, rec);
    if (!confirmar) return;

    final bool ok = await _ctrl.deletar(rec);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Recebimento removido.' : _ctrl.erro ?? 'Erro.'),
        backgroundColor: ok ? Colors.red : Colors.orange,
      ),
    );
  }

  Future<void> _onEditar(RecebimentoModel rec) async {
    final String? novaObs = await mostrarDialogEditarObs(context, rec);
    if (novaObs == null || rec.id == null) return;

    final bool ok = await _ctrl.atualizarObs(rec, novaObs);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Recebimento atualizado.' : _ctrl.erro ?? 'Erro.'),
        backgroundColor: ok ? Colors.green : Colors.orange,
      ),
    );
  }

  void _onVerDetalhes(RecebimentoModel rec) => _mostrarDetalhes(rec);

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
          body: _buildBody(),
          floatingActionButton: _buildFab(),
        ),
        if (_ctrl.carregando) const LoadingOverlay(),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      title: const Text(
        'Histórico de Recebimentos',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          onPressed: _ctrl.carregar,
          icon: const Icon(Icons.refresh),
          tooltip: 'Atualizar',
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_ctrl.recebimentos.isEmpty && !_ctrl.carregando) {
      return _buildEstadoVazio();
    }
    return _buildLista();
  }

  Widget _buildEstadoVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhum recebimento registrado.',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLista() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: _ctrl.recebimentos.length,
      itemBuilder: (_, index) => _RecebimentoCard(
        rec: _ctrl.recebimentos[index],
        onVer: _onVerDetalhes,
        onEditar: _onEditar,
        onDeletar: _onDeletar,
      ),
    );
  }

  FloatingActionButton _buildFab() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.pushNamed(
        context,
        '/recebimento',
      ).then((_) => _ctrl.carregar()),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Novo Recebimento'),
    );
  }

  // ──────────────────────────────────────────────
  // Bottom Sheet de detalhes
  // ──────────────────────────────────────────────

  void _mostrarDetalhes(RecebimentoModel rec) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _DetalhesSheet(rec: rec),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _RecebimentoCard
// ─────────────────────────────────────────────────────────────

class _RecebimentoCard extends StatelessWidget {
  const _RecebimentoCard({
    required this.rec,
    required this.onVer,
    required this.onEditar,
    required this.onDeletar,
  });

  final RecebimentoModel rec;
  final void Function(RecebimentoModel) onVer;
  final Future<void> Function(RecebimentoModel) onEditar;
  final Future<void> Function(RecebimentoModel) onDeletar;

  int get _rasuradas => rec.barras.where((b) => b.isRasurada).length;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () => onVer(rec),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            _CardHeader(rec: rec),
            _CardBody(rec: rec, rasuradas: _rasuradas),
            _CardAcoes(
              onVer: () => onVer(rec),
              onEditar: () => onEditar(rec),
              onDeletar: () => onDeletar(rec),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.rec});
  final RecebimentoModel rec;

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
          _afBadge(),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              rec.fornecedor,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            DateFormatter.formatarDataHora(rec.dataHora),
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _afBadge() => Container(
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
  );
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.rec, required this.rasuradas});
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
              '📝 ${rec.obs}',
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

class _CardAcoes extends StatelessWidget {
  const _CardAcoes({
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
          Expanded(
            child: TextButton.icon(
              onPressed: onVer,
              icon: const Icon(Icons.visibility_outlined, size: 16),
              label: const Text('Ver', style: TextStyle(fontSize: 13)),
            ),
          ),
          const DividerV(),
          Expanded(
            child: TextButton.icon(
              onPressed: onEditar,
              icon: const Icon(
                Icons.edit_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              label: const Text(
                'Editar',
                style: TextStyle(fontSize: 13, color: AppColors.primary),
              ),
            ),
          ),
          const DividerV(),
          Expanded(
            child: TextButton.icon(
              onPressed: onDeletar,
              icon: const Icon(
                Icons.delete_outline,
                size: 16,
                color: Colors.red,
              ),
              label: const Text(
                'Remover',
                style: TextStyle(fontSize: 13, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _DetalhesSheet — Bottom sheet de detalhes de um recebimento
// ─────────────────────────────────────────────────────────────

class _DetalhesSheet extends StatelessWidget {
  const _DetalhesSheet({required this.rec});
  final RecebimentoModel rec;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          _handle(),
          _sheetHeader(),
          _sheetResumo(),
          if (rec.obs != null && rec.obs!.isNotEmpty) _sheetObs(),
          Expanded(child: _tabelaBarras(controller)),
        ],
      ),
    );
  }

  Widget _handle() => Container(
    margin: const EdgeInsets.only(top: 12, bottom: 8),
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(2),
    ),
  );

  Widget _sheetHeader() => Container(
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

  Widget _sheetResumo() => Container(
    color: Colors.grey[50],
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ResumoItem('BARRAS', '${rec.totalBarras}'),
        Container(width: 1, height: 32, color: Colors.grey[300]),
        ResumoItem('PESO TOTAL', '${rec.pesoTotal.toStringAsFixed(0)} kg'),
        Container(width: 1, height: 32, color: Colors.grey[300]),
        ResumoItem('DATA', DateFormatter.formatarDataHora(rec.dataHora)),
      ],
    ),
  );

  Widget _sheetObs() => Container(
    width: double.infinity,
    color: Colors.amber[50],
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Text(
      '📝 ${rec.obs}',
      style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
    ),
  );

  Widget _tabelaBarras(ScrollController controller) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(16),
      children: [
        _headerTabela(),
        ...rec.barras.asMap().entries.map((e) => _linhaTabela(e.key, e.value)),
      ],
    );
  }

  Widget _headerTabela() => Container(
    color: Colors.blue[300],
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    child: const Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            '#',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            'DESCRIÇÃO',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'CORRIDA',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'PESO',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Nº BARRA',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _linhaTabela(int i, BarraModel b) {
    return Container(
      color: b.isRasurada
          ? Colors.orange[50]
          : (i % 2 == 0 ? Colors.white : Colors.grey[50]),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${b.linha}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.descricao, style: const TextStyle(fontSize: 11)),
                if (b.isRasurada)
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
              '${b.corrida ?? '—'}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${b.pesoBarra.toStringAsFixed(1)} kg',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              b.numeroBarra.isEmpty ? '—' : b.numeroBarra,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
