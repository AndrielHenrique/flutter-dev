import 'package:flutter/material.dart';

import '../../dao/af_dao.dart';
import '../../model/af_model.dart';
import 'af_cadastro_view.dart';

class AfListaView extends StatefulWidget {
  const AfListaView({super.key});

  @override
  State<AfListaView> createState() => _AfListaViewState();
}

class _AfListaViewState extends State<AfListaView> {
  static const Color _primaryColor = Color(0xFF1E3A8A);
  static const Color _accentColor = Color(0xFF2771C2);

  List<AfModel> _afs = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    final afs = await AfDAO.carregarTodos();
    if (!mounted) return;
    setState(() {
      _afs = afs;
      _carregando = false;
    });
  }

  Future<void> _abrirCadastro({AfModel? af}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AfCadastroView(afParaEditar: af)),
    );

    if (resultado == true) {
      await _carregar();
    }
  }

  Future<void> _confirmarExclusao(AfModel af) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir AF'),
        content: Text('Deseja realmente excluir a AF ${af.numAF}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await AfDAO.deletar(af);
    await _carregar();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('AF ${af.numAF} excluída com sucesso.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF16A34A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('AFs cadastradas'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirCadastro(),
        backgroundColor: _accentColor,
        icon: const Icon(Icons.add),
        label: const Text('Nova AF'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _afs.isEmpty
          ? Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
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
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 48,
                      color: _primaryColor,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Nenhuma AF cadastrada',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text('Use o botão abaixo para adicionar uma nova AF.'),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _afs.length,
              itemBuilder: (context, index) {
                final af = _afs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: _accentColor,
                      child: const Icon(Icons.assignment, color: Colors.white),
                    ),
                    title: Text(
                      af.numAF,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${af.descricao}\nFornecedor: ${af.fornecedor}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _confirmarExclusao(af),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () => _abrirCadastro(af: af),
                  ),
                );
              },
            ),
    );
  }
}
