import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class StripeCheckoutWidget extends StatefulWidget {
final double amount;
  final String currency;
  final List<Map<String, dynamic>> items;

  const StripeCheckoutWidget({
    Key? key,
    required this.amount,
    required this.currency,
    required this.items,
  }) : super(key: key);

  @override
  State<StripeCheckoutWidget> createState() => _StripeCheckoutWidgetState();
}

class _StripeCheckoutWidgetState extends State<StripeCheckoutWidget> {
  bool _isProcessing = false;
  CardFieldInputDetails? _card;

  Future<void> _payWithCard() async {
    if (_card == null || !_card!.complete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, preencha os dados do cartão.')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 1. Criar PaymentIntent no backend
      final response = await http.post(
        Uri.parse('https://SEU_BACKEND_URL/api/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': (widget.amount * 100).toInt(), // centavos
          'currency': 'mzn', // ou 'usd', conforme necessário
        }),
      );

      final jsonResponse = jsonDecode(response.body);
      final clientSecret = jsonResponse['clientSecret'];

      // 2. Confirmação de pagamento
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              email: 'cliente@exemplo.com',
            ),
          ),
        ),
      );

      if (mounted) {
        Navigator.of(context).pop(); // fecha modal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Pagamento realizado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erro: $e')),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: _isProcessing
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add a card',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text('Card information'),
                  const SizedBox(height: 8),
                  CardField(
                    onCardChanged: (card) {
                      setState(() => _card = card);
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.all(10),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text('Country or region'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: 'Mozambique',
                    items: const [
                      DropdownMenuItem(
                          value: 'Mozambique', child: Text('Mozambique')),
                      DropdownMenuItem(
                          value: 'United States', child: Text('United States')),
                    ],
                    onChanged: (value) {},
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'ZIP',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)), 
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(value: true, onChanged: (_) {}),
                      const Expanded(
                        child:
                            Text('Save card for future HealthClick payments'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _payWithCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5469D4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Add', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
