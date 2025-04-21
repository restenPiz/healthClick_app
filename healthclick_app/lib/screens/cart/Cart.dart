
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:healthclick_app/models/CartProvider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
class Cart extends StatelessWidget {
  const Cart({super.key});

  Future<int?> buscarUserId(String firebaseUid) async {
    print("Buscando user_id para Firebase UID: $firebaseUid"); // Log para depuração
    final url = Uri.parse('http://192.168.100.139:8000/api/user-by-firebase/$firebaseUid');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("User ID encontrado: ${data['user_id']}"); // Log do ID encontrado
      return data['user_id'];
    } else {
      print("Erro ao buscar user_id: ${response.body}");
      return null;
    }
  }

  Future<bool> _realizarPagamento(BuildContext context, String numero,
    String valor, CartProvider cart) async {
    final url = Uri.parse('http://192.168.100.139:8000/api/payment');
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    final payload = {
      "numero": numero,
      "valor": double.parse(valor),
      // "user_id": userId,
       "firebase_uid": userId,
      "items": cart.items.entries
          .map((entry) => {
                "name": entry.value.name,
                "price": entry.value.price,
                "quantity": entry.value.quantity,
              })
          .toList(),
    };
    
    print('Payload enviado: ${json.encode(payload)}');

    try {
      // Mostrar indicador de carregamento
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );
      
      // Fechar o indicador de carregamento
      Navigator.of(context).pop();
      
      print('Status code: ${response.statusCode}');
      print('Resposta completa: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pagamento realizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          return true;
        } else {
          String message = responseData['message'] ?? 'Erro desconhecido';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Falha: $message'),
              backgroundColor: Colors.orange,
            ),
          );
          return false;
        }
      } else {
        Map<String, dynamic> errorData = {};
        try {
          errorData = json.decode(response.body);
        } catch (e) {
          // Se não for um JSON válido, usa o corpo como está
        }
        
        String errorMessage = errorData['message'] ?? response.body;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ($response.statusCode): $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      // Fechar o indicador de carregamento se ainda estiver aberto
      Navigator.of(context, rootNavigator: true).pop();
      
      print('Exceção: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  //*Method to fetch Sales
  Future<List<dynamic>> _fetchOrderHistory() async {
  try {
    // Obter o UID do usuário atual do Firebase
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }
    
    // Obter o user_id correspondente no backend usando a API
    final userId = await buscarUserId(user.uid);
    if (userId == null) {
      throw Exception('ID de usuário não encontrado no backend');
    }
    
    // Buscar o histórico de vendas
    final url = Uri.parse('http://192.168.100.139:8000/api/sales/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['data'];
    } else {
      throw Exception('Erro ao buscar histórico: ${response.statusCode}');
    }
  } catch (e) {
    print('Erro ao buscar histórico de compras: $e');
    return [];
  }
}



void _showOrderHistory(BuildContext context) async {
  showDialog(
    context: context,
    builder: (ctx) => const Center(
      child: CircularProgressIndicator(),
    ),
  );
  
  try {
    final orders = await _fetchOrderHistory();
    
    // Fechar o indicador de carregamento
    Navigator.of(context).pop();
    
    // Mostrar o histórico
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Histórico de Compras',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: orders.isEmpty
                ? const Center(child: Text('Nenhuma compra encontrada'))
                : ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (ctx, i) {
                      final order = orders[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(order['product_name'] ?? 'Produto'),
                          subtitle: Text('Quantidade: ${order['quantity']}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${double.parse(order['price'].toString()).toStringAsFixed(2)} MZN'),
                              Text(
                                DateTime.parse(order['sold_at']).toString().substring(0, 16),
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  } catch (e) {
    // Fechar o indicador de carregamento se ainda estiver aberto
    Navigator.of(context, rootNavigator: true).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao carregar histórico: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Carrinho'),
        actions: [
          if (cart.itemCount > 0)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Tem certeza?'),
                    content: const Text('Deseja remover todos os itens do carrinho?'),
                    actions: [
                      TextButton(
                        child: const Text('Não'),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                      TextButton(
                        child: const Text('Sim'),
                        onPressed: () {
                          cart.clear();
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () {
               _showOrderHistory(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text('Seu carrinho está vazio!'))
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final cartItem = cart.items.values.toList()[i];
                      final productId = cart.items.keys.toList()[i];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(cartItem.image),
                              radius: 30,
                            ),
                            title: Text(cartItem.name),
                            subtitle: Text(
                                'Total: ${(cartItem.price * cartItem.quantity).toStringAsFixed(2)} MZN'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    cart.removeSingleItem(productId);
                                  },
                                ),
                                Text('${cartItem.quantity}'),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    cart.addItem(
                                      productId,
                                      cartItem.name,
                                      cartItem.price,
                                      cartItem.image,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    cart.removeItem(productId);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (cart.items.isNotEmpty)
            Card(
              margin: const EdgeInsets.all(15),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(fontSize: 20),
                        ),
                        Chip(
                          label: Text(
                            '${cart.totalAmount.toStringAsFixed(2)} MZN',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // onPressed: () {
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     const SnackBar(
                        //       content: Text(
                        //           'Funcionalidade de pagamento em desenvolvimento.'),
                        //       duration: Duration(seconds: 2),
                        //     ),
                        //   );
                        // },
                        onPressed: () async {
                          final numeroController = TextEditingController();

                          showDialog(
                            context: context,
                            builder: (ctx) {
                              return AlertDialog(
                                title: const Text('Finalizar Compra'),
                                content: TextField(
                                  controller: numeroController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Digite o número (ex: 84xxxxxxx)',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancelar'),
                                    onPressed: () => Navigator.of(ctx).pop(),
                                  ),
                                  TextButton(
                                    child: const Text('Pagar'),
                                    onPressed: () async {
                                      var numero = numeroController.text.trim();
                                      
                                      // Garantir o formato correto do número
                                      // Remover o prefixo '258' se já estiver presente
                                      if (numero.startsWith('258')) {
                                        numero = numero.substring(3);
                                      }
                                      
                                      // Remover o '0' inicial se estiver presente
                                      if (numero.startsWith('0')) {
                                        numero = numero.substring(1);
                                      }
                                      
                                      // Verificar se o número tem 9 dígitos (formato moçambicano)
                                      if (numero.length != 9) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Por favor, digite um número válido com 9 dígitos')),
                                        );
                                        return;
                                      }
                                      
                                      final valor = cart.totalAmount.toStringAsFixed(2);

                                      Navigator.of(ctx).pop(); // Fecha o modal
                                      
                                      // Aguardar resultado do pagamento
                                      final pagamentoSucesso = await _realizarPagamento(
                                          context, numero, valor, cart);
                                          
                                      // Só limpe o carrinho se o pagamento for bem-sucedido
                                      if (pagamentoSucesso) {
                                        cart.clear();
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text('FINALIZAR COMPRA'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}