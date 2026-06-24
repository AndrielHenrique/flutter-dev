import 'package:flutter/material.dart';
import 'package:pdmde/constants/app_colors.dart';
import 'package:pdmde/recebimento/controllers/historico_controller.dart';
import 'package:pdmde/recebimento/widgets/dialogs.dart';
import 'package:pdmde/recebimento/widgets/shared_widgets.dart';
import 'package:provider/provider.dart';
import '../widgets/historico/recebimento_card.dart';
import '../widgets/historico/detalhe_barras_sheet.dart';

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
    _ctrl = HistoricoController()..carregar();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _deletar(dynamic rec) async {
    final bool confirm = await mostrarDialogConfirmarDelete(context, rec);
    if (!confirm) return;

    final bool ok = await _ctrl.deletar(rec);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? 'Recebimento removido.' : _ctrl.erro ?? 'Erro ao remover.',
          ),
          backgroundColor: ok ? Colors.red : Colors.orange,
        ),
      );
    }
  }

  Future<void> _editar(dynamic rec) async {
    final String? novaObs = await mostrarDialogEditarObs(context, rec);
    if (novaObs == null) return;

    final bool ok = await _ctrl.atualizarObs(rec, novaObs);
    if (mounted && !ok) {
      await mostrarDialogErro(context, _ctrl.erro ?? 'Erro ao atualizar.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HistoricoController>.value(
      value: _ctrl,
      child: Consumer<HistoricoController>(
        builder: (context, ctrl, _) {
          return Stack(
            children: [
              Scaffold(
                backgroundColor: AppColors.background,
                appBar: AppBar(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  title: const Text(
                    'Historico de Recebimentos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    IconButton(
                      onPressed: ctrl.carregar,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                body: ctrl.recebimentos.isEmpty && !ctrl.carregando
                    ? _Vazio()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        separatorBuilder: (_, i) => const SizedBox(height: 10),
                        itemCount: ctrl.recebimentos.length,
                        itemBuilder: (_, i) {
                          final rec = ctrl.recebimentos[i];
                          return RecebimentoCard(
                            rec: rec,
                            onVer: () => DetalheBarrasSheet.show(context, rec),
                            onEditar: () => _editar(rec),
                            onDeletar: () => _deletar(rec),
                          );
                        },
                      ),
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/recebimento',
                  ).then((_) => ctrl.carregar()),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: const Text('Novo Recebimento'),
                ),
              ),
              if (ctrl.carregando) const LoadingOverlay(),
            ],
          );
        },
      ),
    );
  }
}

class _Vazio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}
