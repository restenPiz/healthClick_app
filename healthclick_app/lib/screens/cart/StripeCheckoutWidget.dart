import 'package:flutter/material.dart';
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

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController =
      TextEditingController(); // MM/YY
  final TextEditingController _cvcController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  String _selectedCountry = 'Mozambique';

  Future<void> _payWithCard() async {
    if (_emailController.text.isEmpty ||
        _cardNumberController.text.isEmpty ||
        _expiryController.text.isEmpty ||
        _cvcController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.100.139:8000/api/stripe/pay-direct'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': widget.amount.toInt(),
          'currency': widget.currency,
          'email': _emailController.text,
          'card_number': _cardNumberController.text,
          'exp': _expiryController.text,
          'cvc': _cvcController.text,
          'postal_code': _postalCodeController.text,
          'country': _selectedCountry,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode != 200 || jsonResponse['success'] != true) {
        throw Exception(jsonResponse['message'] ?? 'Erro no pagamento');
      }

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

        // Número do cartão
        TextFormField(
          controller: _cardNumberController,
          decoration: InputDecoration(
            labelText: 'Número do Cartão',
            hintText: '4242 4242 4242 4242',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: isDark ? Colors.grey.shade800 : Colors.white,
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),

        // Validade
        TextFormField(
          controller: _expiryController,
          decoration: InputDecoration(
            labelText: 'Validade (MM/AA)',
            hintText: '12/34',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: isDark ? Colors.grey.shade800 : Colors.white,
          ),
          keyboardType: TextInputType.datetime,
        ),
        const SizedBox(height: 12),

        // CVC
        TextFormField(
          controller: _cvcController,
          decoration: InputDecoration(
            labelText: 'CVC',
            hintText: '123',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: isDark ? Colors.grey.shade800 : Colors.white,
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        // País
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
            filled: true,
            fillColor: isDark ? Colors.grey.shade800 : Colors.white,
          ),
        ),
        const SizedBox(height: 12),

        // Código Postal
        TextFormField(
          controller: _postalCodeController,
          decoration: InputDecoration(
            labelText: 'Código Postal (ZIP)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: isDark ? Colors.grey.shade800 : Colors.white,
          ),
          keyboardType: TextInputType.number,
        ),
        // const SizedBox(height: 24),

        // // Botão de pagamento
        // SizedBox(
        //   width: double.infinity,
        //   height: 50,
        //   child: ElevatedButton(
        //     onPressed: _isProcessing ? null : _payWithCard,
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.green,
        //       foregroundColor: Colors.white,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(10),
        //       ),
        //       padding: const EdgeInsets.symmetric(vertical: 14),
        //       disabledBackgroundColor: Colors.grey,
        //     ),
        //     child: _isProcessing
        //         ? const SizedBox(
        //             height: 20,
        //             width: 20,
        //             child: CircularProgressIndicator(
        //               strokeWidth: 2,
        //               color: Colors.white,
        //             ),
        //           )
        //         : const Text(
        //             'Pagar',
        //             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        //           ),
        //   ),
        // ),
      ],
    );
  }
}
