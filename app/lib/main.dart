import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pembayaran PBB',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> tagihan = [];  // Untuk menyimpan daftar tagihan

  @override
  void initState() {
    super.initState();
    fetchTagihan();  // Ambil data saat app dimulai
  }

  Future<void> fetchTagihan() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/tagihan'));
      if (response.statusCode == 200) {
        setState(() {
          tagihan = json.decode(response.body);
        });
      } else {
        // Handle error, misalnya tampilkan pesan
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat tagihan')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> bayarTagihan(int id) async {
    try {
      final response = await http.post(Uri.parse('http://localhost:3000/bayar/$id'));
      if (response.statusCode == 200) {
        fetchTagihan();  // Refresh daftar tagihan
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pembayaran berhasil')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membayar')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran PBB & Retribusi'),
      ),
      body: tagihan.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: tagihan.length,
              itemBuilder: (context, index) {
                final item = tagihan[index];
                return ListTile(
                  title: Text('${item['jenis']} - Rp ${item['jumlah']}'),
                  subtitle: Text('Status: ${item['status']}'),
                  trailing: item['status'] == 'belum bayar'
                      ? ElevatedButton(
                          onPressed: () => bayarTagihan(item['id']),
                          child: Text('Bayar'),
                        )
                      : null,
                );
              },
            ),
    );
  }
}
