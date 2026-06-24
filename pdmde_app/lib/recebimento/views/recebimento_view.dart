import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdmde/constants/app_colors.dart';
import 'package:pdmde/recebimento/controllers/recebimento_controller.dart';
import 'package:pdmde/recebimento/widgets/barras_list.dart';
import 'package:pdmde/recebimento/widgets/dialogs.dart';
import 'package:pdmde/recebimento/widgets/etapa1_buscar_af.dart';
import 'package:pdmde/recebimento/widgets/footer_recebimento.dart';
import 'package:pdmde/recebimento/widgets/shared_widgets.dart';
import 'package:pdmde/recebimento/widgets/stepper_recebimento.dart';

class RecebimentoView extends StatefulWidget {
  const RecebimentoView({super.key});

  @override
  State<RecebimentoView> createState() => _RecebimentoViewState();
}

class _RecebimentoViewState extends State<RecebimentoView> {
  final TextEditingController _afController = TextEditingController();
  late final RecebimentoController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = RecebimentoController();
  }

  @override
  void dispose() {
    _afController.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _buscarAF() async {
    await _ctrl.buscarAF(_afController.text.trim());
    if (_ctrl.erro != null && mounted) {
      await mostrarDialogErro(context, _ctrl.erro!);
    }
  }

  Future<void> _avancar() async {
    // Captura a etapa ANTES de chamar avancar(), porque é o único jeito
    // de diferenciar "acabei de transicionar de etapa 1 para etapa 2"
    // (não deve salvar ainda) de "já estava na etapa 2 e quero salvar"
    // (deve seguir para o dialog de confirmação). Comparar a etapa
    // DEPOIS de avancar() não funciona: ela é a mesma (inserirBarras)
    // nos dois casos.
    final EtapaRecebimento etapaAntes = _ctrl.etapa;

    final String? erro = _ctrl.avancar();
    if (erro != null && mounted) {
      await mostrarDialogErro(context, erro);
      return;
    }

    // Se estávamos na etapa 1 e avancar() validou com sucesso,
    // a transição para a etapa 2 já foi feita só mostra a tela,
    // não salva nada ainda.
    if (etapaAntes == EtapaRecebimento.buscarAF) return;

    // Se chegou aqui, já estávamos na etapa 2 e a validação de
    // barras passou segue para confirmar e salvar.
    final bool confirmar = await mostrarDialogConfirmarRecebimento(
      context,
      numAF: _ctrl.afSelecionada!.numAF,
      totalBarras: _ctrl.barras.length,
      pesoTotal: _ctrl.pesoTotal,
    );
    if (!confirmar) return;

    final bool ok = await _ctrl.salvar();
    if (mounted) {
      if (ok) {
        _afController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recebimento registrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await mostrarDialogErro(context, _ctrl.erro ?? 'Erro ao salvar.');
      }
    }
  }

  Future<void> _removerBarra(int index) async {
    final bool confirm = await mostrarDialogConfirmarRemoverBarra(
      context,
      _ctrl.barras[index].linha,
    );
    if (confirm) await _ctrl.removerBarra(index);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecebimentoController>.value(
      value: _ctrl,
      child: Consumer<RecebimentoController>(
        builder: (context, ctrl, _) {
          return Stack(
            children: [
              Scaffold(
                backgroundColor: AppColors.background,
                appBar: _buildAppBar(ctrl),
                body: Column(
                  children: [
                    StepperRecebimento(
                      etapa: ctrl.etapa,
                      numAF: ctrl.afSelecionada?.numAF,
                      totalBarras: ctrl.barras.length,
                      pesoTotal: ctrl.pesoTotal,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: ctrl.etapa == EtapaRecebimento.buscarAF
                            ? Etapa1BuscarAf(
                                controller: _afController,
                                afEncontrada: ctrl.afEncontrada,
                                af: ctrl.afSelecionada,
                                onBuscar: _buscarAF,
                              )
                            : BarrasList(
                                itens: ctrl.afSelecionada!.itens,
                                barras: ctrl.barras,
                                totalRasuradas: ctrl.totalRasuradas,
                                qtdPorItem: ctrl.qtdBarrasPorItem,
                                onAdicionarBarra: ctrl.adicionarBarra,
                                onAtualizarBarra: ctrl.atualizarBarra,
                                onRemoverBarra: _removerBarra,
                              ),
                      ),
                    ),
                    FooterRecebimento(
                      etapa: ctrl.etapa,
                      onVoltar: ctrl.voltar,
                      onAvancar: _avancar,
                      onHome: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              if (ctrl.carregando) const LoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(RecebimentoController ctrl) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: ctrl.afEncontrada ? AppColors.successBg : Colors.blue[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              ctrl.afEncontrada ? 'AF ${ctrl.afSelecionada!.numAF}' : 'Sem AF',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: ctrl.afEncontrada
                    ? AppColors.successText
                    : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
