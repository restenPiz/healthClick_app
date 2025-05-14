import 'package:flutter/material.dart';
import 'package:healthclick_app/models/CartProvider.dart';
import 'package:healthclick_app/screens/cart/StripeCheckoutWidget.dart';
import 'package:healthclick_app/screens/cart/BankTransferWidget.dart';

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
  final GlobalKey<BankTransferWidgetState> _bankKey =
      GlobalKey<BankTransferWidgetState>();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
              _buildHeader(),
              Divider(height: 30, color: dividerColor),
              _buildPaymentMethodSelector(isDarkMode, dividerColor),
              const SizedBox(height: 25),
            _buildOrderSummary(summaryBackgroundColor, subtitleColor),
            const SizedBox(height: 25),
              // Render Stripe ou Bank Transfer
              if (_isStripePayment)
                StripeCheckoutWidget(
                  amount: (widget.cart.totalAmount * 100).toDouble(),
                  currency: 'mzn',
                  items: widget.cart.items.entries.map((entry) {
                    return {
                      "name": entry.value.name,
                      "price": entry.value.price,
                      "quantity": entry.value.quantity,
                    };
                  }).toList(),
                  scrollController: ScrollController(),
                )
              else
                BankTransferWidget(
                  key: _bankKey,
                  cart: widget.cart,
                ),

              const SizedBox(height: 30),
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
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
          _buildPaymentOption(
            title: 'Cartão de Crédito/Débito',
            subtitle: 'Visa, Mastercard, Amex',
            icon: Icons.credit_card,
            iconColor: Colors.blue,
            isSelected: _isStripePayment,
            onTap: () => setState(() => _isStripePayment = true),
            isTopOption: true,
            isDarkMode: isDarkMode,
          ),
          // Divider(height: 1, thickness: 1, color: dividerColor),
          // _buildPaymentOption(
          //   title: 'Transferência Bancária',
          //   subtitle: 'BCI, BIM, Standard Bank',
          //   icon: Icons.account_balance,
          //   iconColor: Colors.green,
          //   isSelected: !_isStripePayment,
          //   onTap: () => setState(() => _isStripePayment = false),
          //   isTopOption: false,
          //   isDarkMode: isDarkMode,
          // ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(Color backgroundColor, Color subtitleColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: backgroundColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumo do Pedido',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: TextStyle(color: subtitleColor)),
              Text('${widget.cart.totalAmount.toStringAsFixed(2)} MZN',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Taxa de entrega', style: TextStyle(color: subtitleColor)),
              const Text('Grátis',
                  style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          Divider(height: 20, color: subtitleColor.withOpacity(0.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('${widget.cart.totalAmount.toStringAsFixed(2)} MZN',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green)),
            ],
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

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? selectedBackgroundColor : Colors.transparent,
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
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16)),
                  Text(subtitle,
                      style: TextStyle(
                          color: isDarkMode
                              ? Colors.grey.shade300
                              : Colors.grey.shade600)),
                ],
              ),
            ),
            Radio(
              value: isTopOption,
              groupValue: _isStripePayment,
              onChanged: (value) =>
                  setState(() => _isStripePayment = value as bool),
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      // child: ElevatedButton(
      //   onPressed: _isProcessing
      //       ? null
      //       : () async {
      //           if (_formKey.currentState!.validate()) {
      //             setState(() => _isProcessing = true);
      //             try {
      //               if (_isStripePayment) {
      //                 // Stripe já é processado diretamente no widget
      //                 Navigator.of(context)
      //                     .pop(); // Você pode mudar essa lógica se quiser feedback
      //               } else {
      //                 final isValid =
      //                     _bankKey.currentState?.validateAndSubmit() ?? false;
      //                 if (isValid) {
      //                   Navigator.of(context).pop();
      //                 }
      //               }
      //             } finally {
      //               if (mounted) setState(() => _isProcessing = false);
      //             }
      //           }
      //         },
      //   style: ElevatedButton.styleFrom(
      //     backgroundColor: Colors.green,
      //     shape:
      //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //   ),
      //   child: _isProcessing
      //       ? const CircularProgressIndicator(color: Colors.white)
      //       : const Text('Finalizar Pagamento', style: TextStyle(fontSize: 16)),
      // ),
    );
  }
}
