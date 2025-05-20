// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> mostrarFormularioEditarProduto(
  BuildContext context,
  Map<String, dynamic> produtoAtual,
  Function() onProdutoAtualizado,
) async {
  TextEditingController idController =
      TextEditingController(text: produtoAtual['id']?.toString() ?? '');
  TextEditingController nomeController =
      TextEditingController(text: produtoAtual['nome'] ?? '');
  TextEditingController precoController =
      TextEditingController(text: produtoAtual['preco']?.toString() ?? '');
  TextEditingController quantidadeController =
      TextEditingController(text: produtoAtual['quantidade']?.toString() ?? '');

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) { // Renomeado para dialogContext para evitar conflito
      return AlertDialog(
        title: const Text('Editar Produto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: idController,
                decoration: const InputDecoration(labelText: 'ID Customizado'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: precoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Preço'),
              ),
              TextField(
                controller: quantidadeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantidade'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Usa dialogContext aqui
            },
          ),
          TextButton(
            child: const Text('Salvar Alterações'),
            onPressed: () {
              // Alterado de 'mongoId' para '_id' para corresponder ao backend
              final String? mongoIdParaAtualizar = produtoAtual['_id']?.toString();

              if (mongoIdParaAtualizar == null || mongoIdParaAtualizar.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar( // Usa dialogContext aqui
                  const SnackBar(content: Text('Erro: ID do produto inválido (_id do Mongo ausente).')),
                );
                Navigator.of(dialogContext).pop(); // Fecha o diálogo mesmo com erro de ID
                return;
              }

              // Chama a função de atualização e AGUARDA ela finalizar
              // O Navigator.of(context).pop() DEVE VIR DEPOIS, dentro da função 'atualizarProduto'
              atualizarProduto(
                dialogContext, // Passa o dialogContext
                mongoIdParaAtualizar, // Agora contém o _id real
                idController.text,
                nomeController.text,
                precoController.text,
                quantidadeController.text,
                onProdutoAtualizado,
              );
              // REMOVIDO: Navigator.of(context).pop(); // Esta linha causava o erro "deactivated widget's ancestor"
            },
          ),
        ],
      );
    },
  );
}

Future<void> atualizarProduto(
  BuildContext context, // Este é o BuildContext do diálogo
  String mongoId, // Este parâmetro agora receberá o valor de '_id'
  String idCustom,
  String nome,
  String preco,
  String quantidade,
  Function() onProdutoAtualizado,
) async {
  final Uri url = Uri.parse('https://desafio-dart.onrender.com/Produtos/$mongoId');

  final Map<String, dynamic> dadosAtualizados = {
    'id': int.tryParse(idCustom) ?? 0,
    'nome': nome,
    'preco': double.tryParse(preco) ?? 0.0,
    'quantidade': int.tryParse(quantidade) ?? 0,
  };

  try {
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dadosAtualizados),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto "$nome" atualizado com sucesso!')),
      );
      onProdutoAtualizado(); // Chama o callback para recarregar a lista
      Navigator.of(context).pop(); // Fecha o diálogo APÓS exibir a SnackBar de sucesso
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar produto: ${response.statusCode}')),
      );
      print('Erro ao atualizar produto: ${response.statusCode}');
      Navigator.of(context).pop(); // Fecha o diálogo APÓS exibir a SnackBar de erro
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erro de conexão ao atualizar produto.')),
    );
    print('Erro de conexão ao atualizar: $e');
    Navigator.of(context).pop(); // Fecha o diálogo APÓS exibir a SnackBar de erro de conexão
  }
}