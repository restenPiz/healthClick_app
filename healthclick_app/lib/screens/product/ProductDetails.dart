import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthclick_app/models/CartProvider.dart';
import 'package:provider/provider.dart';

class ProductDetails extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetails({super.key, required this.product});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int _currentIndex = 1;

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

void _addToCart(Map<String, dynamic> product, BuildContext context) {
    try {
      // Imprimir dados para depuração
      print('Dados do produto: $product');

      // Verificar e obter valores com segurança
      final String productId = product['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final String name = product['name']?.toString() ?? 'Produto';
      final double price =
          product['price'] is num ? (product['price'] as num).toDouble() : 0.0;
      final String image = product['image']?.toString() ?? '';

      // Registrar valores para depuração
      print('ID usado: $productId');
      print('Nome usado: $name');
      print('Preço usado: $price');
      print('Imagem usada: $image');

      // Adicionar ao carrinho
      final cart = Provider.of<CartProvider>(context, listen: false);
      cart.addItem(productId, name, price, image);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Produto adicionado ao carrinho!'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'DESFAZER',
            onPressed: () {
              cart.removeSingleItem(productId);
            },
          ),
        ),
      );
    } catch (e) {
      print('Erro ao adicionar ao carrinho: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao adicionar ao carrinho: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final product = widget.product; // ✅ Correto: dentro do build()
    User? currentUser = FirebaseAuth.instance.currentUser;
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10,),
              ListTile(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: const Text(
                  "Detalhes do Produto",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 400,
                margin: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    product['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  // Nome do Produto
                  Expanded(
                    child: Text(
                      product['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                      overflow: TextOverflow.ellipsis, // Truncar o texto se necessário
                      maxLines: 1, // Limitar a 1 linha
                    ),
                  ),
                  
                  // Categoria do Produto
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 150,
                      height: 24,
                      color: Colors.blue,
                      child: Center(
                        child: Text(
                          product['category'],
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                product['description'],
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: Text(
                  '${product['price']} MZN',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _addToCart(product, context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
