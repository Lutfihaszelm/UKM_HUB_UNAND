import 'package:flutter/material.dart';

import '../data/ukm_repository.dart';
import '../models/ukm.dart';
import '../widgets/state_views.dart';
import '../core/routing/app_routes.dart';

// (1) status tampilan
enum ViewStatus { loading, success, error }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // (2) variabel state
  final _repository = UkmRepository();
  ViewStatus _status = ViewStatus.loading;
  List<Ukm> _items = [];
  String _errorMessage = '';
  bool _simulateError = false; // ubah ke true untuk menguji error state

  // (3) ambil data saat layar pertama kali dibuka
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // (4) mengambil data + menangani error
  Future<void> _loadItems() async {
    if (_status != ViewStatus.loading) {
      setState(() => _status = ViewStatus.loading);
    }
    try {
      final items = await _repository.fetchUkms(simulateError: _simulateError);
      if (!mounted) return;
      setState(() {
        _items = items;
        _status = ViewStatus.success;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _status = ViewStatus.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UKM Hub')),
      body: _buildContent(), // (5) isi layar tergantung status
    );
  }

  // (6) memilih tampilan: loading / error / empty / daftar data
  Widget _buildContent() {
    return switch (_status) {
      ViewStatus.loading => const LoadingView(),
      ViewStatus.error => ErrorView(message: _errorMessage, onRetry: _loadItems),
      ViewStatus.success => _buildList(),
    };
  }

  Widget _buildList() {
    if (_items.isEmpty) {
      return const EmptyView(message: 'Belum ada data UKM.');
    }
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return ListTile(
          title: Text(item.name),
          subtitle: Text(item.category),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // (7) kirim item yang dipilih ke layar Detail
            Navigator.pushNamed(
              context,
              AppRoutes.detail,
              arguments: item,
            );
          },
        );
      },
    );
  }
}
