import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../dao/af_dao.dart';
import '../../../dao/barra_dao.dart';
import '../../../dao/recebimento_dao.dart';
import '../../../http/dio_client.dart';
import '../../../model/af_item_model.dart';
import '../../../model/af_model.dart';
import '../../../model/barra_model.dart';
import '../../../model/recebimento_model.dart';
import '../../../model/produto_model.dart';

/// Enumeração das etapas do fluxo de recebimento.
enum EtapaRecebimento { buscarAF, inserirBarras }

/// Controller MVC para [RecebimentoView].
///
/// Responsabilidades:
///  - Buscar AF (SQLite → API).
///  - Gerenciar a lista de barras em andamento.
///  - Salvar o recebimento final.
///  - Expor estado reativo sem depender de widgets.
class RecebimentoController extends ChangeNotifier {
  RecebimentoController() {
    _dio = DioClient.getInstance();
    _init();
  }

  late final Dio _dio;

  // ── Estado público ──────────────────────────────
  EtapaRecebimento etapa = EtapaRecebimento.buscarAF;
  bool carregando = false;
  String? erro;

  AfModel? afSelecionada;
  List<ProdutoModel> produtos = [];
  List<BarraModel> barras = [];

  bool get afEncontrada => afSelecionada != null;

  double get pesoTotal => barras.fold(0.0, (s, b) => s + b.pesoBarra);
  int get totalRasuradas => barras.where((b) => b.isRasurada).length;

  /// Quantas barras já foram adicionadas para um item específico do pedido.
  /// Usado pela tela para desabilitar o botão "+ Barra" quando
  /// `quantidadePedida` for atingida.
  int qtdBarrasPorItem(String codigoMP) =>
      barras.where((b) => b.codigoMP == codigoMP).length;

  // Init

  Future<void> _init() async {
    AfDAO.seedInicial();
    await _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    try {
      final response = await _dio.get('/produtos');
      produtos = (response.data as List)
          .map((p) => ProdutoModel.fromApiMap(p as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } on DioException catch (_) {
      // Produtos ficam vazios , não bloqueia o fluxo.
    }
  }

  // Buscar AF

  Future<void> buscarAF(String numAF) async {
    if (numAF.isEmpty) {
      erro = 'Informe o número da AF antes de buscar.';
      notifyListeners();
      return;
    }

    _setCarregando(true);
    erro = null;
    afSelecionada = null;
    barras = [];

    try {
      AfModel? af = await AfDAO.buscarPorNumero(numAF);

      // Itens do pedido são persistidos no SQLite junto com a AF
      // (coluna itensJson), uma vez que a AF foi salva localmente com
      // seus itens, não é mais necessário buscar a API de novo só por isso.
      if (af == null) {
        final response = await _dio.get('/af/$numAF');
        af = AfModel.fromApiMap(response.data as Map<String, dynamic>);
        await AfDAO.inserir(af);
      }

      List<BarraModel> lista = await BarraDAO.carregarPorAF(numAF);

      if (lista.isEmpty) {
        final response = await _dio.get('/af/$numAF/barras');
        final List<BarraModel> barrasApi = (response.data as List)
            .map((b) => BarraModel.fromApiMap(b as Map<String, dynamic>))
            .toList();
        for (final b in barrasApi) {
          await BarraDAO.inserir(b);
        }
        lista = await BarraDAO.carregarPorAF(numAF);
      }

      afSelecionada = af;
      barras = lista;
    } on DioException catch (e) {
      erro = e.response?.statusCode == 404
          ? 'AF "$numAF" não encontrada.'
          : 'Erro no servidor. Tente novamente.';
    } finally {
      _setCarregando(false);
    }
  }

  // Navegação entre etapas

  /// Retorna mensagem de erro se a validação falhar, `null` se ok.
  String? avancar() {
    if (etapa == EtapaRecebimento.buscarAF) {
      if (!afEncontrada) return 'Busque e selecione uma AF antes de avançar.';
      etapa = EtapaRecebimento.inserirBarras;
      notifyListeners();
      return null;
    }
    return _validarBarras();
  }

  void voltar() {
    if (etapa == EtapaRecebimento.inserirBarras) {
      etapa = EtapaRecebimento.buscarAF;
      notifyListeners();
    }
  }

  String? _validarBarras() {
    if (barras.isEmpty) return 'Adicione ao menos uma barra antes de salvar.';
    if (barras.any((b) => b.codigoMP.isEmpty)) {
      return 'Selecione o material em todas as barras.';
    }
    if (barras.any((b) => b.corrida == null)) {
      return 'Preencha a corrida em todas as barras.';
    }
    if (barras.any((b) => b.pesoBarra <= 0)) {
      return 'Preencha o peso em todas as barras.';
    }
    if (barras.any((b) => b.pesoBarra > 0 && b.pesoBarra < 475)) {
      return 'Existe barra com peso abaixo do mínimo permitido (475 kg).';
    }
    if (barras.any((b) => b.numeroBarra.isEmpty && !b.isRasurada)) {
      return 'Preencha o número de todas as barras (ou marque como rasurada).';
    }
    return null;
  }

  // CRUD barras

  /// Adiciona uma barra vinculada ao [item] do pedido que o usuário
  /// clicou. A barra nasce com o material do item já preenchido,
  /// nunca com dados de outro item ou vazios.
  Future<void> adicionarBarra(AfItemModel item) async {
    // Defesa em profundidade: mesmo que o botão devesse estar
    // desabilitado ao atingir a quantidade pedida, o controller
    // nunca deve permitir passar disso.
    if (qtdBarrasPorItem(item.codigoMP) >= item.quantidadePedida) return;

    final BarraModel nova = BarraModel(
      numAF: afSelecionada!.numAF,
      linha: barras.length + 1,
      codigoMP: item.codigoMP,
      descricao: item.descricao,
      fornecedor: afSelecionada!.fornecedor,
      pesoBarra: 0,
      numeroBarra: '',
      isRasurada: false,
    );
    final int id = await BarraDAO.inserir(nova);
    barras.add(nova.copyWith(id: id));
    notifyListeners();
  }

  Future<void> removerBarra(int index) async {
    final BarraModel barra = barras[index];
    if (barra.id != null) await BarraDAO.deletar(barra.id!);
    barras.removeAt(index);
    notifyListeners();
  }

  Future<void> atualizarBarra(int index, BarraModel atualizada) async {
    if (atualizada.id != null) await BarraDAO.atualizar(atualizada);
    barras[index] = atualizada;
    notifyListeners();
  }

  // Salvar recebimento

  /// Retorna `true` se salvo com sucesso.
  Future<bool> salvar() async {
    _setCarregando(true);
    try {
      for (final BarraModel barra in barras) {
        try {
          await _dio.put('/barras/${barra.id}', data: barra.toMap());
        } on DioException catch (_) {
          // Continua mesmo se API falhar , já está no SQLite.
        }
      }

      await RecebimentoDAO.inserir(
        RecebimentoModel(
          numAF: afSelecionada!.numAF,
          descricao: afSelecionada!.descricao,
          fornecedor: afSelecionada!.fornecedor,
          totalBarras: barras.length,
          pesoTotal: pesoTotal,
          dataHora: DateTime.now().toIso8601String(),
          barras: barras,
        ),
      );

      _resetar();
      return true;
    } catch (_) {
      erro = 'Erro ao salvar. Tente novamente.';
      notifyListeners();
      return false;
    } finally {
      _setCarregando(false);
    }
  }

  // Internos

  void _resetar() {
    etapa = EtapaRecebimento.buscarAF;
    afSelecionada = null;
    barras = [];
    erro = null;
    notifyListeners();
  }

  void _setCarregando(bool valor) {
    carregando = valor;
    notifyListeners();
  }
}
