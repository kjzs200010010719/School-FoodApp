import 'package:flutter/material.dart';
import 'package:my_app/data/food_catalog_repository.dart';
import 'package:my_app/services/member_api.dart';

class CatalogGate extends StatefulWidget {
  const CatalogGate({
    super.key,
    required this.child,
    this.repository,
    this.onLoaded,
  });
  final Widget child;
  final FoodCatalogRepository? repository;
  final Future<void> Function()? onLoaded;

  @override
  State<CatalogGate> createState() => _CatalogGateState();
}

class _CatalogGateState extends State<CatalogGate> {
  late final _repository = widget.repository ?? FoodCatalogRepository.instance;
  late Future<void> _loading;
  @override
  void initState() {
    super.initState();
    _loading = _load();
  }

  Future<void> _load() async {
    if (!_repository.useCloud) return;
    await _repository.load();
    await widget.onLoaded?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!_repository.useCloud) return widget.child;
    return FutureBuilder<void>(
      future: _loading,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          return widget.child;
        }
        return Scaffold(
          appBar: AppBar(title: const Text('膳解人意')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: snapshot.hasError
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off, size: 40),
                        const SizedBox(height: 16),
                        Text(
                          snapshot.error is MemberApiException
                              ? (snapshot.error as MemberApiException).message
                              : '商品載入失敗，請稍後再試',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        IconButton(
                          tooltip: '重新載入商品',
                          icon: const Icon(Icons.refresh),
                          onPressed: () => setState(() {
                            _loading = _load();
                          }),
                        ),
                      ],
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}
