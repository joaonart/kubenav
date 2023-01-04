import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:kubenav/repositories/app_repository.dart';
import 'package:kubenav/utils/constants.dart';
import 'package:kubenav/widgets/shared/app_bottom_sheet_widget.dart';

/// The [SettingsProxy] widget allows a user to specify a proxy for all
/// Kubernetes API requests.
class SettingsProxy extends StatefulWidget {
  const SettingsProxy({
    Key? key,
    required this.currentProxy,
  }) : super(key: key);

  final String currentProxy;

  @override
  State<SettingsProxy> createState() => _SettingsProxyState();
}

class _SettingsProxyState extends State<SettingsProxy> {
  final _proxyFormKey = GlobalKey<FormState>();
  final _proxyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _proxyController.text = widget.currentProxy;
  }

  @override
  void dispose() {
    _proxyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppRepository appRepository = Provider.of<AppRepository>(
      context,
      listen: false,
    );

    return AppBottomSheetWidget(
      title: 'Proxy',
      subtitle: 'A proxy for all Kubernetes requests',
      icon: Icons.http,
      closePressed: () {
        Navigator.pop(context);
      },
      actionText: 'Save',
      actionPressed: () {
        appRepository.setProxy(_proxyController.text);
        Navigator.pop(context);
      },
      actionIsLoading: false,
      child: Form(
        key: _proxyFormKey,
        child: ListView(
          shrinkWrap: false,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: Constants.spacingSmall,
              ),
              child: TextFormField(
                controller: _proxyController,
                keyboardType: TextInputType.url,
                autocorrect: false,
                enableSuggestions: false,
                maxLines: 1,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Proxy',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
