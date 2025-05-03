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
    final product = widget.product; 
    User? currentUser = FirebaseAuth.instance.currentUser;
    final cart = Provider.of<CartProvider>(context);
    
    // Get screen dimensions
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.04), // Responsive padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  title: const Text(
                    "Detalhes do Produto",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: screenSize.height * 0.4, // Responsive height
                  margin: EdgeInsets.symmetric(
                    vertical: screenSize.height * 0.01,
                    horizontal: screenSize.width * 0.02,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      product['image'],
                      fit: BoxFit.contain, // Changed to contain for better responsiveness
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, size: 60);
                      },
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                // Product name and category in flexible layout
                isSmallScreen
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.01),
                          CategoryWidget(category: product['category']),
                        ],
                      )
                    : Row(
                        children: [
                          // Nome do Produto
                          Expanded(
                            child: Text(
                              product['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 19,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          // Categoria do Produto
                          CategoryWidget(category: product['category']),
                        ],
                      ),
                SizedBox(height: screenSize.height * 0.01),
                Text(
                  product['description'],
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.01),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenSize.height * 0.01,
                  ),
                  child: Text(
                    '${product['price']} MZN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 18 : 20,
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.01),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _addToCart(product, context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: screenSize.height * 0.02,
                        ),
                      ),
                      child: Text(
                        'Add to Cart',
                        style: TextStyle(fontSize: isSmallScreen ? 15 : 17),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Extracted category widget for reusability
class CategoryWidget extends StatelessWidget {
  final String category;

  const CategoryWidget({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: isSmallScreen ? screenSize.width * 0.4 : 150,
        height: 24,
        color: Colors.blue,
        child: Center(
          child: Text(
            category,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}