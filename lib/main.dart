import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Adicione a importação do http
import 'dart:convert'; // Adicione a importação do dart:convert
import 'adicionar_produto.dart';

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
      setState(() {
        produtos = jsonDecode(response.body);
      });
    } else {
      // ignore: avoid_print
      print('Erro ao buscar produtos: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Produtos'),
      ),
      body: produtos.isEmpty
          ? Center(child: Text('Nenhum produto encontrado.'))
          : ListView.builder(
              itemCount: produtos.length,
              itemBuilder: (context, index) {
                final produto = produtos[index];
                return ListTile(
                  title: Text(produto['nome'] ?? 'Nome não disponível'),
                  subtitle: Text('Id: ${produto['id'] ?? 'Id não Disponivel'} Preço: ${produto['preco']?.toString() ?? 'Preço não disponível'} Quantidade: ${produto['quantidade'] ?? 'Quantidade não Disponvel'}'),
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
