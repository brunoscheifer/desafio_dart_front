// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void mostrarFormularioAdicionarProduto(
  BuildContext context,
  Function() onProdutoAdicionado,
) {
  TextEditingController idController = TextEditingController();
  TextEditingController nomeController = TextEditingController();
  TextEditingController precoController = TextEditingController();
  TextEditingController quantidadeController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Adicionar Novo Produto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: idController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Id'),
              ),
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: precoController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Salvar'),
            onPressed: () {
              adicionarNovoProduto(
                idController.text,
                nomeController.text,
                precoController.text,
                quantidadeController.text,
                onProdutoAdicionado, // Recebe a função de callback
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> adicionarNovoProduto(String id, String nome, String preco, String quantidade, Function() onProdutoAdicionado) async {
  final Uri url = Uri.parse('https://desafio-dart.onrender.com/Produtos');
  final Map<String, dynamic> novoProduto = {
    'id': int.tryParse(id) ?? 0,
    'nome': nome,
    'preco': double.tryParse(preco) ?? 0.0,
    'quantidade': int.tryParse(quantidade) ?? 0,
  };

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(novoProduto),
    );

    if (response.statusCode == 201) {
      // Produto criado com sucesso, chama a função de callback para recarregar a lista
      onProdutoAdicionado();
    } else {
      print('Erro ao adicionar produto: ${response.statusCode}');
      // Exiba uma mensagem de erro para o usuário (pode ser feito na tela principal)
    }
  } catch (e) {
    print('Erro de conexão: $e');
    // Exiba uma mensagem de erro de conexão
  }
}