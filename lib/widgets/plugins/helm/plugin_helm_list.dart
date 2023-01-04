import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:kubenav/models/plugins/helm.dart';
import 'package:kubenav/repositories/app_repository.dart';
import 'package:kubenav/repositories/clusters_repository.dart';
import 'package:kubenav/services/kubernetes_service.dart';
import 'package:kubenav/utils/constants.dart';
import 'package:kubenav/utils/custom_icons.dart';
import 'package:kubenav/utils/helpers.dart';
import 'package:kubenav/utils/navigate.dart';
import 'package:kubenav/utils/resources/general.dart';
import 'package:kubenav/utils/showmodal.dart';
import 'package:kubenav/widgets/plugins/helm/plugin_helm_details.dart';
import 'package:kubenav/widgets/shared/app_actions_header_widget.dart';
import 'package:kubenav/widgets/shared/app_bottom_navigation_bar_widget.dart';
import 'package:kubenav/widgets/shared/app_error_widget.dart';
import 'package:kubenav/widgets/shared/app_floating_action_buttons_widget.dart';
import 'package:kubenav/widgets/shared/app_namespaces_widget.dart';

/// The [PluginHelmList] can be used to view all Helm releases for the currently
/// active cluster and namespace. It shows a list of all Helm releases, with the
/// option to view the details of a release, by clicking on it. The user is then
/// redirected to the [PluginHelmDetails] widget.
///
/// The list of Helm releases only contains the latest version of each release,
/// if a user wants to view an older version, he has to go to the details page,
/// where he can select a specific version of a release.
class PluginHelmList extends StatefulWidget {
  const PluginHelmList({super.key});

  @override
  State<PluginHelmList> createState() => _PluginHelmListState();
}

class _PluginHelmListState extends State<PluginHelmList> {
  late Future<List<Release>> _futureFetchHelmReleases;

  /// [_fetchHelmReleases] fetches all Helm releases for the currently active
  /// cluster and namespace or all namespaces.
  Future<List<Release>> _fetchHelmReleases() async {
    ClustersRepository clustersRepository = Provider.of<ClustersRepository>(
      context,
      listen: false,
    );
    AppRepository appRepository = Provider.of<AppRepository>(
      context,
      listen: false,
    );

    final cluster = await clustersRepository.getClusterWithCredentials(
      clustersRepository.activeClusterId,
    );

    return await KubernetesService(
      cluster: cluster!,
      proxy: appRepository.settings.proxy,
      timeout: appRepository.settings.timeout,
    ).helmListCharts(cluster.namespace);
  }

  /// [buildItem] builds the widget for a single Helm release shown in the list
  /// of releases. When the user clicks on the release he will be redirected to
  /// the [PluginHelmDetails] screen.
  Widget buildItem(BuildContext context, Release release) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: Constants.spacingMiddle,
      ),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: Constants.sizeBorderBlurRadius,
            spreadRadius: Constants.sizeBorderSpreadRadius,
            offset: const Offset(0.0, 0.0),
          ),
        ],
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(Constants.sizeBorderRadius),
        ),
      ),
      child: InkWell(
        onTap: () {
          navigate(
            context,
            PluginHelmDetails(
              name: release.name!,
              namespace: release.namespace!,
              version: release.version!,
            ),
          );
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Characters(release.name ?? '')
                        .replaceAll(Characters(''), Characters('\u{200B}'))
                        .toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: primaryTextStyle(
                      context,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Characters('Namespace: ${release.namespace}')
                            .replaceAll(Characters(''), Characters('\u{200B}'))
                            .toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: secondaryTextStyle(
                          context,
                        ),
                      ),
                      Text(
                        Characters('Revision: ${release.version}')
                            .replaceAll(Characters(''), Characters('\u{200B}'))
                            .toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: secondaryTextStyle(
                          context,
                        ),
                      ),
                      Text(
                        Characters(
                                'Updated: ${formatTime(DateTime.parse(release.info?.lastDeployed ?? ''))}')
                            .replaceAll(Characters(''), Characters('\u{200B}'))
                            .toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: secondaryTextStyle(
                          context,
                        ),
                      ),
                      Text(
                        Characters('Status: ${release.info?.status}')
                            .replaceAll(Characters(''), Characters('\u{200B}'))
                            .toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: secondaryTextStyle(
                          context,
                        ),
                      ),
                      Text(
                        Characters('Chart: ${release.chart?.metadata?.version}')
                            .replaceAll(Characters(''), Characters('\u{200B}'))
                            .toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: secondaryTextStyle(
                          context,
                        ),
                      ),
                      Text(
                        Characters(
                                'App Version: ${release.chart?.metadata?.appVersion}')
                            .replaceAll(Characters(''), Characters('\u{200B}'))
                            .toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: secondaryTextStyle(
                          context,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _futureFetchHelmReleases = _fetchHelmReleases();
    });
  }

  @override
  Widget build(BuildContext context) {
    ClustersRepository clustersRepository = Provider.of<ClustersRepository>(
      context,
      listen: true,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(CustomIcons.namespaces),
            onPressed: () {
              showModal(context, const AppNamespacesWidget());
            },
          ),
        ],
        title: Column(
          children: [
            Text(
              Characters('Helm Charts')
                  .replaceAll(Characters(''), Characters('\u{200B}'))
                  .toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              Characters(clustersRepository
                              .getCluster(
                                clustersRepository.activeClusterId,
                              )!
                              .namespace ==
                          ''
                      ? 'All Namespaces'
                      : clustersRepository
                          .getCluster(
                            clustersRepository.activeClusterId,
                          )!
                          .namespace)
                  .replaceAll(Characters(''), Characters('\u{200B}'))
                  .toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBarWidget(),
      floatingActionButton: const AppFloatingActionButtonsWidget(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder(
              future: _futureFetchHelmReleases,
              builder: (
                BuildContext context,
                AsyncSnapshot<List<Release>> snapshot,
              ) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(Constants.spacingMiddle),
                          child: CircularProgressIndicator(
                            color: Constants.colorPrimary,
                          ),
                        ),
                      ],
                    );
                  default:
                    if (snapshot.hasError) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(Constants.spacingMiddle),
                              child: AppErrorWidget(
                                message: 'Could not load Helm charts',
                                details: snapshot.error.toString(),
                                icon: 'assets/plugins/image108x108/helm.png',
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return Wrap(
                      children: [
                        AppActionsHeaderWidget(
                          actions: [
                            AppActionsHeaderModel(
                              title: 'Refresh',
                              icon: Icons.refresh,
                              onTap: () {
                                setState(() {
                                  _futureFetchHelmReleases =
                                      _fetchHelmReleases();
                                });
                              },
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                            top: Constants.spacingMiddle,
                            bottom: Constants.spacingMiddle,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(
                              right: Constants.spacingMiddle,
                              left: Constants.spacingMiddle,
                            ),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return buildItem(
                                context,
                                snapshot.data![index],
                              );
                            },
                          ),
                        ),
                      ],
                    );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
