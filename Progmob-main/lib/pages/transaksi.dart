import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../transaksi/addTransaksiDialog.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({Key? key}) : super(key: key);

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final _storage = GetStorage();
  final _dio = Dio();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api/tabungan/489';

  List<dynamic> transaksiList = [];

  @override
  void initState() {
    super.initState();
    fetchTransaksi();
  }

  Future<void> fetchTransaksi() async {
    try {
      final token = _storage.read('token');
      if (token == null) {
        print('Authorization token not found');
        return;
      }

      final response = await _dio.get(
        _apiUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print(
          'Response data: ${response.data}'); // Debugging: Print the response data

      setState(() {
        transaksiList = response.data['data']['tabungan'] ?? [];
      });
    } on DioError catch (e) {
      print(
          'Failed to fetch transaksi: ${e.response?.statusCode} ${e.response?.data}');
      if (e.response != null) {
        print('Error data: ${e.response?.data}');
      } else {
        print('Error message: ${e.message}');
      }
      // Tampilkan pesan kesalahan kepada pengguna
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Failed to fetch transactions: ${e.response?.data['message'] ?? e.message}')),
      );
    } catch (e) {
      print('Unexpected error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    }
  }

  void _showAddTransaksiDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddTransaksiDialog(
          onTransaksiAdded: ()async{
            await fetchTransaksi();
            Navigator.pop(context);
          });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'List Transaksi',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Expanded(
            child: transaksiList.isEmpty
                ? Center(child: Text('Belum ada Transaksi yang dilakukan'))
                : ListView.builder(
                    itemCount: transaksiList.length,
                    itemBuilder: (context, index) {
                      final transaksi = transaksiList[index];
                      return ListTile(
                        title: Text('Transaction ID: ${transaksi['id']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Transaction Date: ${transaksi['trx_tanggal']}'),
                            Text('Nominal: ${transaksi['trx_nominal']}'),
                          ],
                        ),
                        );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransaksiDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
