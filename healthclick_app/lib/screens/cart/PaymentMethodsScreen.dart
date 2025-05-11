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
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    // Obtém as cores do tema atual
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final cardColor = isDarkMode ? Theme.of(context).cardColor : Colors.white;
    final dividerColor =
        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
    final subtitleColor =
        isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600;
    final shadowColor = isDarkMode ? Colors.black54 : Colors.black26;
    final summaryBackgroundColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -5),
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

              Divider(height: 30, color: dividerColor),

              // Payment Method Selection
              _buildPaymentMethodSelector(isDarkMode, dividerColor),

              const SizedBox(height: 25),

              // Display fields based on selection
              if (_isStripePayment)
                const StripePaymentSection()
              else
                BankTransferWidget(cart: widget.cart),

              const SizedBox(height: 30),

              // Order Summary
              _buildOrderSummary(summaryBackgroundColor, subtitleColor),

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

  Widget _buildPaymentMethodSelector(bool isDarkMode, Color dividerColor) {
    final borderColor =
        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
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
            isDarkMode: isDarkMode,
          ),

          Divider(height: 1, thickness: 1, color: dividerColor),

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
            isDarkMode: isDarkMode,
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
    required bool isDarkMode,
  }) {
    final selectedBackgroundColor = isDarkMode
        ? Colors.green.withOpacity(0.2)
        : Colors.green.withOpacity(0.1);

    final transparentColor = Colors.transparent;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? selectedBackgroundColor : transparentColor,
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
                      color: isDarkMode
                          ? Colors.grey.shade300
                          : Colors.grey.shade600,
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

  Widget _buildOrderSummary(Color backgroundColor, Color subtitleColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
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
                  color: subtitleColor,
                ),
              ),
              Text(
                '${widget.cart.totalAmount.toStringAsFixed(2)} MZN',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Taxa de entrega',
                style: TextStyle(color: subtitleColor),
              ),
              const Text(
                'Grátis',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Divider(height: 20, color: subtitleColor.withOpacity(0.5)),
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
        onPressed: _isProcessing
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _isProcessing = true;
                  });

                  try {
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
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isProcessing = false;
                      });
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
          disabledBackgroundColor:
              Theme.of(context).primaryColor.withOpacity(0.5),
        ),
        child: _isProcessing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isStripePayment ? 'Processando...' : 'Enviando...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Text(
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
