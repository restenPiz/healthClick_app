// import 'package:flutter/material.dart';
// import 'package:healthclick_app/models/CartProvider.dart';
// import 'package:provider/provider.dart';

// class Cart extends StatefulWidget {
//   const Cart({super.key});

//   @override
//   State<Cart> createState() => _CartState();
// }

// class _CartState extends State<Cart> {
//   @override
//   Widget build(BuildContext context) {
//     // Obtendo o estado do carrinho do CartProvider
//     final cart = Provider.of<CartProvider>(context);

//     return Scaffold(
//       // appBar: AppBar(
//       //   title: const Text('Carrinho de Compras'),
//       //   backgroundColor: Colors.green,
//       // ),
//       body: cart.items.isEmpty
//           ? Container(
//             child: Column(
//               children: [
//                 const SizedBox(
//                     height: 35,
//                   ),
//                 ListTile(
//                   leading: IconButton(
//                     icon: const Icon(Icons.arrow_back),
//                     onPressed: () {
//                       Navigator.pop(context); 
//                     },
//                   ),
//                   title: const Text(
//                     "Ola Mauro Peniel",
//                     style:
//                         TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
//                   ),
//                 ),
//                 const SizedBox(height: 450,),
//                 const Center(
//                   child: Text('O seu carrinho esta vazio',style: TextStyle(fontSize: 20),),
//                 )
//               ],
//             ),
//           )
//           : SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     ListTile(
//                       leading: IconButton(
//                         icon: const Icon(Icons.arrow_back),
//                         onPressed: () {
//                           Navigator.pop(context); // Voltar para a tela anterior
//                         },
//                       ),
//                       title: const Text(
//                         "Ola Mauro Peniel",
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 17),
//                       ),
//                     ),
//                     const SizedBox(height: 30,),
//                     ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: cart.items.length,
//                       itemBuilder: (context, index) {
//                         return Card(
//                           elevation: 2,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           margin: const EdgeInsets.only(bottom: 10),
//                           child: ListTile(
//                             leading: Image.asset(cart.items[index].image),
//                             title: Text(cart.items[index].name, style:
//                                   const TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             subtitle: Text(
//                                 'Preço: ${cart.items[index].price.toString()} MZN', 
//                                 ),
//                             trailing: IconButton(
//                               icon: const Icon(Icons.remove_circle),
//                               onPressed: () {
//                                 // Remover item do carrinho
//                                 cart.removeItem(cart.items[index]);
//                               },
//                             ),
//                           ),
//                         );
//                       },
//                     ),

//                     // Exibindo o total
//                     const SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Total: ${cart.totalPrice} MZN',
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         ElevatedButton(
//                           onPressed: () {
//                             showDialog(
//                               context: context,
//                               builder: (context) => AlertDialog(
//                                 title: const Text('Finalizar Compra'),
//                                 content:
//                                     const Text('Deseja finalizar sua compra?'),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () {
//                                       Navigator.of(context).pop();
//                                     },
//                                     child: const Text('Cancelar'),
//                                   ),
//                                   TextButton(
//                                     onPressed: () {
//                                       // Finalizar a compra aqui
//                                       Navigator.of(context).pop();
//                                       // Pode redirecionar para uma página de sucesso ou limpar o carrinho
//                                       cart.clearCart();
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(const SnackBar(
//                                               content:
//                                                   Text('Compra finalizada')));
//                                     },
//                                     child: const Text('Finalizar'),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                           child: const Text('Finalizar Compra',style: TextStyle(fontSize: 18),),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                                 vertical: 12, horizontal: 20),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:healthclick_app/models/CartProvider.dart';
import 'package:provider/provider.dart';

class Cart extends StatelessWidget {
  const Cart({super.key});

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
                        onPressed: () {
                          // Implementar a lógica de checkout (pagamento)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Funcionalidade de pagamento em desenvolvimento.'),
                              duration: Duration(seconds: 2),
                            ),
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
