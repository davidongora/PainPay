// update_wrapper.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pain_pay/services/update_service.dart';
import 'package:provider/provider.dart';

class UpdateWrapper extends StatefulWidget {
  final Widget child;

  const UpdateWrapper({
    super.key,
    required this.child,
  });

  @override
  State<UpdateWrapper> createState() => _UpdateWrapperState();
}

class _UpdateWrapperState extends State<UpdateWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkForUpdates();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkForUpdates();
    }
  }

  Future<void> _checkForUpdates() async {
    await Provider.of<UpdateService>(context, listen: false)
        .checkForUpdate(context);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
