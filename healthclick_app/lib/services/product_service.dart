import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  final String baseUrl;

  ProductService({required this.baseUrl});

  // Função para buscar os produtos
  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await http.get(Uri.parse('http://cloudev.org/api/products'));

    if (response.statusCode == 200) {
      // Se a resposta for bem-sucedida, parse o JSON
      List<dynamic> data = json.decode(response.body);
      return data.map((product) {
        return {
          "name": product['product_name'], // Nome do produto
          "price": product['product_price'], // Preço do produto
          "description": product['product_description'], // Descrição do produto
          "image": product[
              'product_file'], // Imagem do produto (URL ou caminho do arquivo)
          "quantity": product['quantity'], // Quantidade do produto
        };
      }).toList();
    } else {
      // Se a resposta falhar, lança um erro
      throw Exception('Falha ao carregar produtos');
    }
  }
}
