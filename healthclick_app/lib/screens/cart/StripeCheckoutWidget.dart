import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

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
  final TextEditingController _emailController = TextEditingController();

  // Inicialize o Stripe em main.dart com sua publishable key
  // Stripe.publishableKey = 'pk_test_your_publishable_key';

  Future<void> _makePayment() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, forneça um email')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 1. Criar setup de pagamento no servidor
      final paymentIntentResult = await _createPaymentIntent();
      if (paymentIntentResult == null)
        throw Exception('Falha ao criar payment intent');

      // 2. Configurar dados de faturamento
      final billingDetails = BillingDetails(
        email: _emailController.text,
      );

      // 3. Exibir sheet de pagamento Stripe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentResult['clientSecret'],
          merchantDisplayName: 'Seu Nome de Negócio',
          billingDetails: billingDetails,
          style: ThemeMode.system,
          // Customização:
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Colors.green,
            ),
          ),
        ),
      );

      // 4. Exibir folha de pagamento ao usuário
      await Stripe.instance.presentPaymentSheet();

      // 5. Confirmar pagamento com servidor
      await _confirmPayment(paymentIntentResult['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Pagamento realizado com sucesso!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (e is StripeException) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Erro: ${e.error.localizedMessage}')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Erro: $e')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<Map<String, dynamic>?> _createPaymentIntent() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.100.139:8000/api/stripe/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': (widget.amount * 100).toInt(), // converter para centavos
          'currency': widget.currency.toLowerCase(),
          'email': _emailController.text,
          'firebase_uid': userId,
          'items': widget.items,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode != 200 || jsonResponse['success'] != true) {
        throw Exception(
            jsonResponse['message'] ?? 'Erro ao criar payment intent');
      }

      return jsonResponse['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _confirmPayment(String paymentIntentId) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.100.139:8000/api/stripe/confirm-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'payment_intent_id': paymentIntentId,
          'firebase_uid': FirebaseAuth.instance.currentUser?.uid,
          'items': widget.items,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode != 200 || jsonResponse['success'] != true) {
        throw Exception(
            jsonResponse['message'] ?? 'Erro ao confirmar pagamento');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informações de Pagamento',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'seuemail@exemplo.com',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: isDark ? Colors.grey.shade800 : Colors.white,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _makePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              disabledBackgroundColor: Colors.grey,
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Pagar com Cartão',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }
}
