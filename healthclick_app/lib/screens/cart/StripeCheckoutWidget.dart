import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StripeCheckoutWidget extends StatefulWidget {
  final double amount;
  final String currency;
  final List<Map<String, dynamic>> items;
  final ScrollController scrollController;

  const StripeCheckoutWidget({
    Key? key,
    required this.amount,
    required this.currency,
    required this.items,
    required this.scrollController,
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
          content: Text('Por favor, preencha os dados do cartão.'),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.100.139:8000/api/stripe/create-checkout-session'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': (widget.amount * 100).toInt(),
          'currency': widget.currency,
        }),
      );

      final jsonResponse = jsonDecode(response.body);
      final clientSecret = jsonResponse['clientSecret'];

      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(email: 'cliente@exemplo.com'),
          ),
        ),
      );

      if (mounted) {
        Navigator.of(context).pop();
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
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: widget.scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[400],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Text(
                    'Adicionar Cartão',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Informações do Cartão',
                      style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                      color: isDark ? Colors.grey[800] : Colors.white,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CardField(
                      onCardChanged: (card) {
                        setState(() {
                          _card = card;
                        });
                      },
                      autofocus: true,
                      enablePostalCode:
                          false, // Desabilita o campo postal integrado
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('País ou Região', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: 'Mozambique',
                    items: const [
                      DropdownMenuItem(
                        value: 'Mozambique',
                        child: Text('Moçambique'),
                      ),
                      DropdownMenuItem(
                        value: 'United States',
                        child: Text('Estados Unidos'),
                      ),
                    ],
                    onChanged: (_) {},
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.white,
                    ),
                    dropdownColor: isDark ? Colors.grey[900] : null,
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Código Postal (ZIP)',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.white,
                      labelStyle:
                          TextStyle(color: isDark ? Colors.white70 : null),
                    ),
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: true,
                        onChanged: (_) {},
                        checkColor: Colors.white,
                        fillColor: MaterialStateProperty.all(
                          isDark ? Colors.blue : Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Salvar cartão para futuras compras',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _payWithCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Pagar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
