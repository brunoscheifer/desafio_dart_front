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
    builder: (BuildContext dialogContext) {
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
              Navigator.of(dialogContext).pop();
            },
          ),
          TextButton(
            child: const Text('Salvar Alterações'),
            onPressed: () {
              final String? mongoIdParaAtualizar = produtoAtual['_id']?.toString();

              if (mongoIdParaAtualizar == null || mongoIdParaAtualizar.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Erro: ID do produto inválido (_id do Mongo ausente).')),
                );
                Navigator.of(dialogContext).pop();
                return;
              }

              atualizarProduto(
                dialogContext,
                mongoIdParaAtualizar,
                idController.text,
                nomeController.text,
                precoController.text,
                quantidadeController.text,
                onProdutoAtualizado,
              );
            },
          ),
        ],
      );
    },
  );
}

Future<void> atualizarProduto(
  BuildContext context,
  String mongoId,
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
      onProdutoAtualizado();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar produto: ${response.statusCode}')),
      );
      print('Erro ao atualizar produto: ${response.statusCode}');
      Navigator.of(context).pop();
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erro de conexão ao atualizar produto.')),
    );
    print('Erro de conexão ao atualizar: $e');
    Navigator.of(context).pop();
  }
}