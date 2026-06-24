import 'package:app/ui/utils/app_text.dart';
import 'package:flutter/material.dart';

class AppFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final Widget? loading;
  final Widget? error;

  const AppFutureBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.loading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading ?? const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return error ?? Center(child: AppText(txt: 'Something went wrong'));
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        return builder(context, snapshot.data as T);
      },
    );
  }
}
