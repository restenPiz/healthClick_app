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
    Key? key,
    required this.cart,
  }) : super(key: key);

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
    final url = Uri.parse('https://cloudev.org/api/bank-payment');
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    // Criar um request multipart
    var request = http.MultipartRequest('POST', url);

    // Adicionar campos de texto
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

    // Adicionar o arquivo comprovativo
    request.files.add(await http.MultipartFile.fromPath(
        'comprovativo', _comprovativoImage!.path,
        filename: 'comprovativo_${DateTime.now().millisecondsSinceEpoch}.jpg'));

    try {
      // Mostrar indicador de carregamento
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Fechar o indicador de carregamento
      Navigator.of(context).pop();

      print('Status code: ${response.statusCode}');
      print('Resposta completa: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Pagamento bancário registrado com sucesso! Aguardando confirmação.'),
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
        } catch (e) {
          // Se não for um JSON válido, usa o corpo como está
        }

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
      // Fechar o indicador de carregamento se ainda estiver aberto
      Navigator.of(context, rootNavigator: true).pop();

      print('Exceção: $e');
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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações Bancárias',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildBankInfoCard(),
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

  Widget _buildBankInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dados da Conta para Transferência:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          const Text('Banco: BCI'),
          const Text('Titular: HealthClick Inc.'),
          const Text('NIB: 0008 0000 1234 5678 9012 3'),
          const Text('IBAN: MZ59 0008 0000 1234 5678 9012 3'),
        ],
      ),
    );
  }

  Widget _buildBankAccountField() {
    return TextFormField(
      controller: _contaController,
      decoration: InputDecoration(
        labelText: 'Conta Bancária (Sua)',
        hintText: 'Ex: BCI / BIM / Standard Bank',
        prefixIcon: const Icon(Icons.account_balance),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, informe sua conta bancária';
        }
        return null;
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _valorController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Valor',
        hintText: 'Valor da transferência',
        prefixIcon: const Icon(Icons.monetization_on),
        suffixText: 'MZN',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, informe o valor';
        }
        return null;
      },
    );
  }

  Widget _buildAttachProofButton() {
    return ElevatedButton.icon(
      onPressed: _selecionarComprovativo,
      icon: const Icon(Icons.upload_file),
      label: Text(
        _comprovativoImage == null
            ? 'Anexar Comprovativo de Pagamento'
            : 'Comprovativo Selecionado',
        style: const TextStyle(fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.green,
        backgroundColor: Colors.green.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.green),
        ),
      ),
    );
  }

  Widget _buildSelectedFileIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Arquivo: ${_comprovativoImage!.path.split('/').last}',
              style: const TextStyle(color: Colors.green),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
