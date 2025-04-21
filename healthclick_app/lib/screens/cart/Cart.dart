
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:healthclick_app/models/CartProvider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Cart extends StatelessWidget {
  const Cart({super.key});

  Future<bool> _realizarPagamento(BuildContext context, String numero,
    String valor, CartProvider cart) async {
  final url = Uri.parse('http://192.168.100.139:8000/api/payment');
  
  // Construir payload
  final payload = {
    "numero": numero,
    "valor": double.parse(valor),
    "user_id": 1,
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
                    content: const Text(
                        'Deseja remover todos os itens do carrinho?'),
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
