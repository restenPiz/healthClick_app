import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:healthclick_app/models/CartProvider.dart';
import 'package:healthclick_app/screens/cart/StripeCheckoutWidget.dart';
import 'package:healthclick_app/screens/cart/BankTransferWidget.dart';
import 'package:healthclick_app/screens/cart/StripePaymentSection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final CartProvider cart;

  const PaymentMethodsScreen({
    Key? key,
    required this.cart,
  }) : super(key: key);

  @override
  _PaymentMethodsScreenState createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  bool _isStripePayment = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),

              const Divider(height: 30),

              // Payment Method Selection
              _buildPaymentMethodSelector(),

              const SizedBox(height: 25),

              // Display fields based on selection
              if (_isStripePayment)
                const StripePaymentSection()
              else
                BankTransferWidget(cart: widget.cart),

              const SizedBox(height: 30),

              // Order Summary
              _buildOrderSummary(),

              const SizedBox(height: 20),

              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Método de Pagamento',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Stripe Option
          _buildPaymentOption(
            title: 'Cartão de Crédito/Débito',
            subtitle: 'Visa, Mastercard, Amex',
            icon: Icons.credit_card,
            iconColor: Colors.blue,
            isSelected: _isStripePayment,
            onTap: () {
              setState(() {
                _isStripePayment = true;
              });
            },
            isTopOption: true,
          ),

          Divider(height: 1, thickness: 1, color: Colors.grey.shade300),

          // Bank Transfer Option
          _buildPaymentOption(
            title: 'Transferência Bancária',
            subtitle: 'BCI, BIM, Standard Bank',
            icon: Icons.account_balance,
            iconColor: Colors.green,
            isSelected: !_isStripePayment,
            onTap: () {
              setState(() {
                _isStripePayment = false;
              });
            },
            isTopOption: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isTopOption,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.green.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: isTopOption ? const Radius.circular(12) : Radius.zero,
            topRight: isTopOption ? const Radius.circular(12) : Radius.zero,
            bottomLeft: !isTopOption ? const Radius.circular(12) : Radius.zero,
            bottomRight: !isTopOption ? const Radius.circular(12) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Radio(
              value: isTopOption,
              groupValue: _isStripePayment,
              onChanged: (value) {
                setState(() {
                  _isStripePayment = value as bool;
                });
              },
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo do Pedido',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                '${widget.cart.totalAmount.toStringAsFixed(2)} MZN',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Taxa de entrega',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                'Grátis',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                '${widget.cart.totalAmount.toStringAsFixed(2)} MZN',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            if (_isStripePayment) {
              Navigator.of(context).pop();
              // Show Stripe checkout widget
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StripeCheckoutWidget(
                    amount: (widget.cart.totalAmount * 100)
                        .toDouble(), // Convert to cents
                    currency: 'mzn',
                    items: widget.cart.items.entries.map((entry) {
                      return {
                        "name": entry.value.name,
                        "price": entry.value.price,
                        "quantity": entry.value.quantity,
                      };
                    }).toList(),
                  ),
                ),
              );
              // widget.cart.clear();
            } else {
              // Bank transfer is handled in BankTransferWidget
              final bankTransferState = BankTransferWidget.of(context);
              if (bankTransferState != null) {
                if (bankTransferState.validateAndSubmit()) {
                  Navigator.of(context).pop();
                }
              }
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          _isStripePayment ? 'Pagar com Cartão' : 'Enviar Pagamento',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
