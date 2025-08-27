import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:healthclick_app/models/CartProvider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class BankTransferWidget extends StatefulWidget {
  final CartProvider cart;

  const BankTransferWidget({
    super.key,
    required this.cart,
  });

  @override
  BankTransferWidgetState createState() => BankTransferWidgetState();

  static BankTransferWidgetState? of(BuildContext context) {
    return context.findAncestorStateOfType<BankTransferWidgetState>();
  }
}

class BankTransferWidgetState extends State<BankTransferWidget> {
  final TextEditingController _contaController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _comprovativoImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _valorController.text = widget.cart.totalAmount.toString();
  }

  @override
  void dispose() {
    _contaController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _selecionarComprovativo() async {
    final XFile? selectedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (selectedImage != null) {
      setState(() {
        _comprovativoImage = File(selectedImage.path);
      });
    }
  }

  Future<bool> _realizarPagamentoBancario() async {
    final context = this.context;
    final url = Uri.parse(
        'http://192.168.100.139:8000/api/stripe/create-checkout-session');
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    var request = http.MultipartRequest('POST', url);
    request.fields['conta_bancaria'] = _contaController.text;
    request.fields['valor'] = _valorController.text;
    request.fields['firebase_uid'] = userId ?? '';
    request.fields['payment_type'] = 'banco';
    request.fields['items'] = json.encode(widget.cart.items.entries
        .map((entry) => {
              "name": entry.value.name,
              "price": entry.value.price,
              "quantity": entry.value.quantity,
            })
        .toList());

    request.files.add(await http.MultipartFile.fromPath(
      'comprovativo',
      _comprovativoImage!.path,
      filename: 'comprovativo_${DateTime.now().millisecondsSinceEpoch}.jpg',
    ));

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pagamento registrado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          widget.cart.clear();
          return true;
        } else {
          String message = responseData['message'] ?? 'Erro desconhecido';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Falha: $message'),
              backgroundColor: Colors.orange,
            ),
          );
          return false;
        }
      } else {
        Map<String, dynamic> errorData = {};
        try {
          errorData = json.decode(response.body);
        } catch (_) {}

        String errorMessage = errorData['message'] ?? response.body;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro (${response.statusCode}): $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  bool validateAndSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_comprovativoImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione um comprovativo.'),
            backgroundColor: Colors.orange,
          ),
        );
        return false;
      }

      _realizarPagamentoBancario();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações Bancárias',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildBankInfoCard(isDark),
          const SizedBox(height: 20),
          _buildBankAccountField(),
          const SizedBox(height: 15),
          _buildAmountField(),
          const SizedBox(height: 20),
          _buildAttachProofButton(),
          if (_comprovativoImage != null) _buildSelectedFileIndicator(),
        ],
      ),
    );
  }

  Widget _buildBankInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey.shade300,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dados da Conta para Transferência:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 10),
          Text('Banco: BCI'),
          Text('Titular: HealthClick Inc.'),
          Text('NIB: 0008 0000 1234 5678 9012 3'),
          Text('IBAN: MZ59 0008 0000 1234 5678 9012 3'),
        ],
      ),
    );
  }

  Widget _buildBankAccountField() {
    return TextFormField(
      controller: _contaController,
      decoration: const InputDecoration(
        labelText: 'Sua Conta Bancária',
        border: OutlineInputBorder(),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _valorController,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Valor (MZN)',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildAttachProofButton() {
    return ElevatedButton.icon(
      onPressed: _selecionarComprovativo,
      icon: const Icon(Icons.upload_file),
      label: const Text('Anexar Comprovativo'),
    );
  }

  Widget _buildSelectedFileIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        'Comprovativo selecionado: ${_comprovativoImage?.path.split('/').last}',
        style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
      ),
    );
  }
}
