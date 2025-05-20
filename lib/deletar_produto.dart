// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> deletarProdutoConfirmacao(
  BuildContext context,
  String produtoId,
  String nomeProduto,
  Function() onProdutoDeletado,
) async {
  final bool? confirmar = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja deletar o produto "$nomeProduto"?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Deletar'),
          ),
        ],
      );
    },
  );

  if (confirmar == true) {
    try {
      final Uri url = Uri.parse('https://desafio-dart.onrender.com/Produtos/$produtoId');
      final response = await http.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 200 OK ou 204 No Content são códigos de sucesso para DELETE
        onProdutoDeletado(); // Chama o callback para recarregar a lista

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produto "$nomeProduto" deletado com sucesso!')),
        );
      } else {
        // ignore: avoid_print
        print('Erro ao deletar produto: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao deletar produto: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Erro de conexão ao deletar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão ao deletar produto.')),
      );
    }
  }
}