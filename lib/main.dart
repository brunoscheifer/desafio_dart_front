import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'adicionar_produto.dart';
import 'deletar_produto.dart';
import 'editar_produto.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Adicione o construtor com a key

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minha Loja de Produtos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ListaProdutos(),
    );
  }
}

class ListaProdutos extends StatefulWidget {
  const ListaProdutos({super.key}); // Adicione o construtor com a key

  @override
  @visibleForTesting
  // ignore: library_private_types_in_public_api
  _ListaProdutosState createState() => _ListaProdutosState();
}

class _ListaProdutosState extends State<ListaProdutos> {
  List<dynamic> produtos = [];

  @override
  void initState() {
    super.initState();
    _fetchProdutos();
  }

  Future<void> _fetchProdutos() async {
    final response = await http.get(Uri.parse('https://desafio-dart.onrender.com/Produtos'));
    if (response.statusCode == 200) {
      try {
        setState(() {
          produtos = jsonDecode(response.body);
        });
      } catch (e) {
        // ignore: avoid_print
        print('Erro ao decodificar JSON (GET): $e');
      }
    } else {
      // ignore: avoid_print
      print('Erro ao buscar produtos: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Produtos'),
      ),
      body: produtos.isEmpty
          ? const Center(child: Text('Nenhum produto encontrado.'))
          : ListView.builder(
              itemCount: produtos.length,
              itemBuilder: (context, index) {
                final produto = produtos[index];
                return ListTile(
                  title: Text(produto['nome'] ?? 'Nome não disponível'),
                  subtitle: Text(
                    'ID: ${produto['id'] ?? 'Não Disponivel'} '
                    'Preço: ${produto['preco']?.toString() ?? 'Preço não disponível'} '
                    'Quantidade: ${produto['quantidade'] ?? 'Quantidade não Disponvel'}'
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ícone de Edição
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: Colors.blue,
                        onPressed: () {
                          mostrarFormularioEditarProduto(
                            context,
                            produto, // Passa o produto completo
                            _fetchProdutos,
                          );
                        },
                      ),
                      // Ícone de Deletar
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () {
                          deletarProdutoConfirmacao(
                            context,
                            // *** MUDANÇA AQUI: de 'mongoId' para '_id' ***
                            produto['_id'].toString(), // Use o '_id' retornado pelo backend
                            produto['nome'] ?? 'produto desconhecido',
                            _fetchProdutos,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          mostrarFormularioAdicionarProduto(context, _fetchProdutos);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
