import 'package:flutter/material.dart';
import 'package:my_app/services/user_activity_service.dart';

class ActivityMessages extends StatefulWidget {
  const ActivityMessages({
    super.key,
    required this.child,
    required this.messengerKey,
    this.service,
  });
  final Widget child;
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final UserActivityService? service;
  @override
  State<ActivityMessages> createState() => _ActivityMessagesState();
}

class _ActivityMessagesState extends State<ActivityMessages> {
  late final _service = widget.service ?? UserActivityService.instance;
  int _lastRevision = -1;
  @override
  void initState() {
    super.initState();
    _service.addListener(_onChanged);
    _onChanged();
  }

  void _onChanged() {
    final message = _service.errorMessage;
    if (message == null || _lastRevision == _service.errorRevision) return;
    _lastRevision = _service.errorRevision;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  @override
  void dispose() {
    _service.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
