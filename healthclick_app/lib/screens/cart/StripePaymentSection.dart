import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class StripePaymentSection extends StatelessWidget {
  const StripePaymentSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informações do Pagamento',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Será redirecionado para uma página segura para completar o pagamento com cartão.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/b/ba/Stripe_Logo%2C_revised_2016.svg/2560px-Stripe_Logo%2C_revised_2016.svg.png',
                    height: 30,
                  ),
                  const SizedBox(width: 15),
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/2560px-Visa_Inc._logo.svg.png',
                    height: 25,
                  ),
                  const SizedBox(width: 15),
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png',
                    height: 30,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
