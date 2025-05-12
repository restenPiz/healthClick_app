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
  CardFieldInputDetails? _cardDetails;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  String _selectedCountry = 'Mozambique';

  Future<void> _payWithCard() async {
    if (_cardDetails == null || !_cardDetails!.complete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha os dados do cartão')),
      );
      return;
    }

    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira o e-mail')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.100.139:8000/api/stripe/create-checkout-session'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': widget.amount.toInt(),
          'currency': widget.currency,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao criar sessão de pagamento: ${response.body}');
      }

      final jsonResponse = jsonDecode(response.body);
      final clientSecret = jsonResponse['clientSecret'];

      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              email: 'cliente@exemplo.com',
              address: Address(
                city: 'Beira',
                country: 'MZ', // Código ISO do país
                line1: 'Rua de exemplo',
                line2: 'Bairro Central',
                state: 'Sofala',
                postalCode: '2100',
              ),
            ),
          ),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Pagamento realizado com sucesso!')),
        );
        Navigator.of(context).pop();
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informações do Cartão',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Campo do cartão
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          child: CardField(
            onCardChanged: (details) {
              setState(() => _cardDetails = details);
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              filled: true,
              fillColor: isDark ? Colors.grey.shade800 : Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintStyle: TextStyle(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ),
          ),
        ),

        // Campo de email
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'E-mail',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: isDark ? Colors.grey.shade800 : Colors.white,
            labelStyle: TextStyle(color: isDark ? Colors.white70 : null),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        const SizedBox(height: 16),

        // País
        Text('País ou Região', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCountry,
          items: const [
            DropdownMenuItem(value: 'Mozambique', child: Text('Moçambique')),
            DropdownMenuItem(value: 'US', child: Text('Estados Unidos')),
          ],
          onChanged: (value) {
            setState(() => _selectedCountry = value!);
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            filled: true,
            fillColor: isDark ? Colors.grey.shade800 : Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        // Código Postal
        TextFormField(
          controller: _postalCodeController,
          decoration: InputDecoration(
            labelText: 'Código Postal (ZIP)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: isDark ? Colors.grey.shade800 : Colors.white,
            labelStyle: TextStyle(color: isDark ? Colors.white70 : null),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          keyboardType: TextInputType.number,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        const SizedBox(height: 24),

        // Botão de pagamento
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _payWithCard,
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
                    'Pagar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }
}
