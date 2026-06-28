import 'package:flutter/material.dart';

import '../../dao/af_dao.dart';
import '../../dao/produto_dao.dart';
import '../../model/af_item_model.dart';
import '../../model/af_model.dart';
import '../../model/produto_model.dart';

class AfCadastroView extends StatefulWidget {
  const AfCadastroView({super.key, this.afParaEditar});

  final AfModel? afParaEditar;

  @override
  State<AfCadastroView> createState() => _AfCadastroViewState();
}

class _AfCadastroViewState extends State<AfCadastroView> {
  static const Color _primaryColor = Color(0xFF1E3A8A);
  static const Color _accentColor = Color(0xFF2771C2);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numAfController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _fornecedorController = TextEditingController();
  final TextEditingController _pesoTotalController = TextEditingController();

  final List<AfItemModel> _itens = [];
  bool _carregando = false;
  bool get _modoEdicao => widget.afParaEditar != null;

  @override
  void initState() {
    super.initState();
    if (widget.afParaEditar != null) {
      _numAfController.text = widget.afParaEditar!.numAF;
      _descricaoController.text = widget.afParaEditar!.descricao;
      _fornecedorController.text = widget.afParaEditar!.fornecedor;
      _pesoTotalController.text = widget.afParaEditar!.pesoTotal.toString();
      _itens.addAll(widget.afParaEditar!.itens);
    }
  }

  @override
  void dispose() {
    _numAfController.dispose();
    _descricaoController.dispose();
    _fornecedorController.dispose();
    _pesoTotalController.dispose();
    super.dispose();
  }

  String? _validarNumeroAf(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o número da AF.';
    }
    if (value.trim().length < 3) {
      return 'O número da AF deve ter pelo menos 3 caracteres.';
    }
    return null;
  }

  String? _validarDescricao(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe a descrição.';
    }
    return null;
  }

  String? _validarFornecedor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o fornecedor.';
    }
    return null;
  }

  String? _validarPeso(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o peso total.';
    }
    final peso = double.tryParse(value.replaceAll(',', '.'));
    if (peso == null || peso <= 0) {
      return 'Informe um peso válido maior que zero.';
    }
    return null;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final numeroAf = _numAfController.text.trim();
    final descricao = _descricaoController.text.trim();
    final fornecedor = _fornecedorController.text.trim();
    final peso =
        double.tryParse(_pesoTotalController.text.replaceAll(',', '.')) ?? 0.0;

    if (_itens.isEmpty) {
      _mostrarMensagem(
        tipo: _MensagemTipo.erro,
        titulo: 'Itens obrigatórios',
        mensagem: 'Adicione pelo menos um item para salvar a AF.',
      );
      return;
    }

    final itensInvalidos = _itens.where((item) {
      return item.codigoMP.trim().isEmpty ||
          item.descricao.trim().isEmpty ||
          item.quantidadePedida <= 0 ||
          item.pesoUnitario <= 0;
    }).toList();

    if (itensInvalidos.isNotEmpty) {
      _mostrarMensagem(
        tipo: _MensagemTipo.erro,
        titulo: 'Itens inválidos',
        mensagem: 'Preencha todos os campos dos itens com valores válidos.',
      );
      return;
    }

    setState(() => _carregando = true);

    final af = AfModel(
      id: widget.afParaEditar?.id,
      numAF: numeroAf,
      descricao: descricao,
      fornecedor: fornecedor,
      pesoTotal: peso,
      itens: _itens,
    );

    try {
      final existente = await AfDAO.buscarPorNumero(numeroAf);
      if (existente != null &&
          (!_modoEdicao || existente.id != widget.afParaEditar!.id)) {
        throw Exception('Já existe uma AF cadastrada com este número.');
      }

      if (_modoEdicao) {
        await AfDAO.atualizar(af.copyWith(id: widget.afParaEditar!.id));
      } else {
        await AfDAO.inserir(af);
      }

      await AfDAO.salvarViaApi(af, editar: _modoEdicao);

      for (final item in _itens) {
        final produto = ProdutoModel(
          codigo: item.codigoMP,
          descricao: item.descricao,
          fornecedor: fornecedor,
          saldoDisponivel: 0,
        );
        await ProdutoDAO.salvarViaApi(produto, editar: false);
      }

      if (!mounted) return;
      _mostrarMensagem(
        tipo: _MensagemTipo.sucesso,
        titulo: _modoEdicao ? 'AF atualizada' : 'AF cadastrada',
        mensagem: _modoEdicao
            ? 'A AF foi alterada com sucesso.'
            : 'A AF foi cadastrada com sucesso.',
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensagem(
        tipo: _MensagemTipo.erro,
        titulo: 'Não foi possível salvar',
        mensagem: e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _adicionarItem() {
    setState(() {
      _itens.add(
        const AfItemModel(
          codigoMP: '',
          descricao: '',
          quantidadePedida: 1,
          pesoUnitario: 0,
        ),
      );
    });
  }

  void _removerItem(int index) {
    setState(() => _itens.removeAt(index));
  }

  void _atualizarItem(int index, AfItemModel item) {
    setState(() => _itens[index] = item);
  }

  void _mostrarMensagem({
    required _MensagemTipo tipo,
    required String titulo,
    required String mensagem,
  }) {
    final color = tipo == _MensagemTipo.sucesso
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);
    final icon = tipo == _MensagemTipo.sucesso
        ? Icons.check_circle_outline
        : Icons.error_outline;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(mensagem),
                ],
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text(_modoEdicao ? 'Editar AF' : 'Cadastro de AF'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dados gerais da AF',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _numAfController,
                      decoration: const InputDecoration(
                        labelText: 'Número da AF',
                        prefixIcon: Icon(Icons.assignment_rounded),
                      ),
                      validator: _validarNumeroAf,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descricaoController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      validator: _validarDescricao,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _fornecedorController,
                      decoration: const InputDecoration(
                        labelText: 'Fornecedor',
                        prefixIcon: Icon(Icons.factory_outlined),
                      ),
                      validator: _validarFornecedor,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pesoTotalController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Peso total',
                        prefixIcon: Icon(Icons.monitor_weight_outlined),
                      ),
                      validator: _validarPeso,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Itens da AF',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _adicionarItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Adicionar item'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_itens.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F7FB),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text('Nenhum item adicionado ainda.'),
                      )
                    else
                      ...List.generate(_itens.length, (index) {
                        final item = _itens[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Item ${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () => _removerItem(index),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Color(0xFFDC2626),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: item.codigoMP,
                                decoration: const InputDecoration(
                                  labelText: 'Código MP',
                                ),
                                onChanged: (value) => _atualizarItem(
                                  index,
                                  AfItemModel(
                                    codigoMP: value,
                                    descricao: item.descricao,
                                    quantidadePedida: item.quantidadePedida,
                                    pesoUnitario: item.pesoUnitario,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: item.descricao,
                                decoration: const InputDecoration(
                                  labelText: 'Descrição',
                                ),
                                onChanged: (value) => _atualizarItem(
                                  index,
                                  AfItemModel(
                                    codigoMP: item.codigoMP,
                                    descricao: value,
                                    quantidadePedida: item.quantidadePedida,
                                    pesoUnitario: item.pesoUnitario,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: item.quantidadePedida
                                          .toString(),
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Quantidade pedida',
                                      ),
                                      onChanged: (value) => _atualizarItem(
                                        index,
                                        AfItemModel(
                                          codigoMP: item.codigoMP,
                                          descricao: item.descricao,
                                          quantidadePedida:
                                              int.tryParse(value) ?? 1,
                                          pesoUnitario: item.pesoUnitario,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: item.pesoUnitario
                                          .toString(),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      decoration: const InputDecoration(
                                        labelText: 'Peso unitário',
                                      ),
                                      onChanged: (value) => _atualizarItem(
                                        index,
                                        AfItemModel(
                                          codigoMP: item.codigoMP,
                                          descricao: item.descricao,
                                          quantidadePedida:
                                              item.quantidadePedida,
                                          pesoUnitario:
                                              double.tryParse(
                                                value.replaceAll(',', '.'),
                                              ) ??
                                              0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _carregando ? null : _salvar,
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _carregando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _carregando
                      ? 'Salvando...'
                      : (_modoEdicao ? 'Salvar alterações' : 'Salvar AF'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _MensagemTipo { sucesso, erro }
