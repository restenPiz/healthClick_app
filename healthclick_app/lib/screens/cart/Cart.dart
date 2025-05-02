import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:healthclick_app/models/CartProvider.dart';
import 'package:healthclick_app/utils/app_size.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  int _salesCount = 0; // Variável para contar as vendas

  Future<int?> buscarUserId(String firebaseUid) async {
    print("Buscando user_id para Firebase UID: $firebaseUid");
    final url = Uri.parse('https://cloudev.org/api/user-by-firebase/$firebaseUid');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("User ID encontrado: ${data['user_id']}");
      return data['user_id'];
    } else {
      print("Erro ao buscar user_id: ${response.body}");
      return null;
    }
  }

  Future<bool> _realizarPagamento(BuildContext context, String numero,
      String valor, CartProvider cart) async {
    final url = Uri.parse('https://cloudev.org/api/payment');
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    final payload = {
      "numero": numero,
      "valor": double.parse(valor),
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
          // Incrementar o contador de vendas quando a compra for bem-sucedida
          setState(() {
            _salesCount++;
          });
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

  Future<List<dynamic>> _fetchOrderHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final userId = await buscarUserId(user.uid);
      if (userId == null) {
        throw Exception('ID de usuário não encontrado no backend');
      }

      final url = Uri.parse('https://cloudev.org/api/sales/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final salesData = responseData['data'];

        // Para cada venda, buscar informações de entrega
        for (var sale in salesData) {
          final deliveryUrl = Uri.parse('https://cloudev.org/api/delivery/${sale['id']}');
          final deliveryResponse = await http.get(deliveryUrl);

          if (deliveryResponse.statusCode == 200) {
            final deliveryData = json.decode(deliveryResponse.body);
            sale['delivery'] = deliveryData['data'].isNotEmpty ? deliveryData['data'][0] : null;
          }
        }

        return salesData;
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
                          final hasDelivery = order['delivery'] != null;
                          final deliveryStatus = hasDelivery
                              ? order['delivery']['status']
                              : 'pendente';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(order['product']?['product_name'] ?? 'Produto'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Quantidade: ${order['quantity']}'),
                                  Text('Status: ${hasDelivery ? deliveryStatus : "Sem entrega"}'),
                                  const SizedBox(height: 8),
                                  if (!hasDelivery || deliveryStatus.toLowerCase() == 'pendente')
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _showDeliveryForm(context, order['id']);
                                        },
                                        child: const Text("Delivery"),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${double.parse(order['price'].toString()).toStringAsFixed(2)} MZN'),
                                  Text(
                                    DateTime.parse(order['sold_at'])
                                        .toString()
                                        .substring(0, 16),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar histórico: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeliveryForm(BuildContext context, int saleId) {
    final _addressController = TextEditingController();
    final _contactController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Informar Dados de Entrega"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: "Endereço de entrega",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: "Contacto",
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final address = _addressController.text.trim();
              final contact = _contactController.text.trim();

              if (address.isEmpty || contact.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preencha todos os campos')),
                );
                return;
              }

              final response = await http.post(
                Uri.parse("https://cloudev.org/api/deliveries"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "sale_id": saleId,
                  "delivery_address": address,
                  "contact": contact,
                }),
              );

              if (response.statusCode == 200 || response.statusCode == 201) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Pedido de entrega enviado com sucesso!")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erro ao enviar: ${response.body}")),
                );
              }
            },
            child: const Text("Confirmar Entrega"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carrinho de Compras"),
        actions: [
          IconButton(
            onPressed: () => _showOrderHistory(context),
            icon: Stack(
              children: [
                const Icon(Icons.receipt_long),
                if (_salesCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.red,
                      child: Text(
                        '$_salesCount',
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) {
                final cartItem = cart.items.values.toList()[i];
                final productId = cart.items.keys.toList()[i];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(cartItem.image),
                        radius: 30,
                      ),
                      title: Text(cartItem.name),
                      subtitle: Text(
                        'Total: ${(cartItem.price * cartItem.quantity).toStringAsFixed(2)} MZN',
                      ),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontSize: 20)),
                Chip(
                  label: Text(
                    '${cart.totalAmount.toStringAsFixed(2)} MZN',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: double.infinity,
              height: 50, 
                child: ElevatedButton(
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
                                if (numero.startsWith('258')) {
                                  numero = numero.substring(3);
                                }

                                if (numero.startsWith('0')) {
                                  numero = numero.substring(1);
                                }

                                if (numero.length != 9) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Por favor, digite um número válido com 9 dígitos')),
                                  );
                                  return;
                                }

                                final valor = cart.totalAmount.toStringAsFixed(2);

                                Navigator.of(ctx).pop(); // Fecha o modal

                                final pagamentoSucesso = await _realizarPagamento(
                                    context, numero, valor, cart);

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
                    padding:
                        const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Bordas arredondadas
                    ),
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text(
                    'Comprar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, // Texto em negrito
                      fontSize: 18,
                    ),
                  ),
                ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
