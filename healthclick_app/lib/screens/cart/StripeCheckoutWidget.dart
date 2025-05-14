import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:healthclick_app/models/CartProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

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
  static const String apiBaseUrl = 'http://192.168.100.139:8000/api';

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _makePayment() async {
    FocusScope.of(context).unfocus(); // Fechar o teclado

    if (_emailController.text.isEmpty || !_isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, forneça um email válido')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      print('🔍 Iniciando processo de pagamento');

      final paymentIntentResult = await _createPaymentIntent();

      if (paymentIntentResult == null) {
        throw Exception('Falha ao criar payment intent');
      }

      final billingDetails = BillingDetails(
        email: _emailController.text,
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentResult['clientSecret'],
          merchantDisplayName: 'HealthClick',
          billingDetails: billingDetails,
          style: ThemeMode.system,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      await _confirmPayment(paymentIntentResult['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Pagamento realizado com sucesso!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('❌ ERRO NO PAGAMENTO: $e');
      if (e is StripeException) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erro do Stripe: ${e.error.localizedMessage}'),
            ),
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
    final userId = FirebaseAuth.instance.currentUser?.uid;

    try {
      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/stripe/create-checkout-session'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'amount': (widget.amount * 100).toInt(),
              'currency': widget.currency.toLowerCase(),
              'email': _emailController.text,
              'firebase_uid': userId,
              'items': widget.items,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode != 200 || jsonResponse['success'] != true) {
        throw Exception(jsonResponse['message'] ?? 'Erro ao criar pagamento');
      }

      return jsonResponse['data'];
    } catch (e) {
      print('❌ Exceção ao criar payment intent: $e');
      rethrow;
    }
  }

  Future<void> _confirmPayment(String paymentIntentId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/stripe/confirm-payment'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'payment_intent_id': paymentIntentId,
              'firebase_uid': FirebaseAuth.instance.currentUser?.uid,
              'items': widget.items,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode != 200 || jsonResponse['success'] != true) {
        throw Exception(jsonResponse['message'] ?? 'Erro ao confirmar pagamento');
      }
      
      Provider.of<CartProvider>(context, listen: false).clear();

      setState(() {
        widget.items.clear();
      });
    } catch (e) {
      print('❌ Exceção ao confirmar pagamento: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
