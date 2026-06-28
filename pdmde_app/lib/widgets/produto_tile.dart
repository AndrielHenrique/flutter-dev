import 'package:flutter/material.dart';
import '../model/produto.dart';

class ProdutoTile extends StatelessWidget {
  final Produto produto;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProdutoTile({
    super.key,
    required this.produto,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.shopping_bag, color: Colors.blue),
        ),
        title: Text(
          produto.nome,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Preço: R\$ ${produto.preco.toStringAsFixed(2)} | Qtd: ${produto.quantidade}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
