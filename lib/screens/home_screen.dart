import 'package:flutter/material.dart';

import '../data/post_repository.dart';
import '../models/post.dart';
import '../routes/app_routes.dart';
import '../widgets/state_views.dart';

// (1) status tampilan
enum ViewStatus { loading, success, error }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.simulateError = false});

  // ubah ke true (atau lewat constructor ini) untuk menguji error state
  final bool simulateError;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // (2) variabel state
  final _repository = PostRepository();
  ViewStatus _status = ViewStatus.loading;
  List<Post> _posts = [];
  String _errorMessage = '';

  // (3) ambil data saat layar pertama kali dibuka
  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  // (4) mengambil data + menangani error
  Future<void> _loadPosts() async {
    if (_status != ViewStatus.loading) {
      setState(() => _status = ViewStatus.loading);
    }
    try {
      final posts = await _repository.fetchPosts(simulateError: widget.simulateError);
      if (!mounted) return;
      setState(() {
        _posts = posts;
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
      appBar: AppBar(title: const Text('Home')),
      body: _buildContent(), // (5) isi layar tergantung status
    );
  }

  // (6) memilih tampilan: loading / error / empty / daftar data
  Widget _buildContent() {
    return switch (_status) {
      ViewStatus.loading => const LoadingView(),
      ViewStatus.error => ErrorView(message: _errorMessage, onRetry: _loadPosts),
      ViewStatus.success => _buildList(),
    };
  }

  Widget _buildList() {
    if (_posts.isEmpty) {
      return const EmptyView(message: 'Belum ada data.');
    }
    return ListView.builder(
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        // Boleh diganti dengan widget kartu buatan Praktikum 1
        return ListTile(
          title: Text(post.title),
          subtitle: Text(post.subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.detail,
            arguments: post,
          ),
        );
      },
    );
  }
}
