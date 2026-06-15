import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../models/episode_model.dart';
import '../../providers/episode_provider.dart';
import '../../providers/watch_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/error_display.dart';
import '../../widgets/server_button.dart';

class WatchScreen extends ConsumerStatefulWidget {
  final String episodeId;

  const WatchScreen({super.key, required this.episodeId});

  @override
  ConsumerState<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends ConsumerState<WatchScreen> {
  WebViewController? _webViewController;
  bool _isWebViewLoading = true;
  bool _webViewError = false;

  @override
  void initState() {
    super.initState();
    _loadEpisode();
  }

  Future<void> _loadEpisode() async {
    final rtdb = ref.read(rtdbServiceProvider);
    final episode = await rtdb.getEpisode(widget.episodeId);
    if (episode != null && mounted) {
      ref.read(watchProvider.notifier).setEpisode(episode);
      _initWebView(episode);
    }
  }

  void _initWebView(EpisodeModel episode) {
    if (episode.servers.isEmpty) {
      setState(() => _webViewError = true);
      return;
    }

    final url = episode.servers[0];

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isWebViewLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isWebViewLoading = false);
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() => _webViewError = true);
              ref.read(watchProvider.notifier).markError();
            }
          },
        ),
      );

    _loadIframe(_webViewController!, url);

    if (mounted) setState(() => _webViewController = _webViewController);
  }

  void _loadIframe(WebViewController controller, String url) {
    setState(() {
      _isWebViewLoading = true;
      _webViewError = false;
    });

    final htmlContent = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          * { margin: 0; padding: 0; box-sizing: border-box; }
          body { background: #000; overflow: hidden; }
          iframe {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            border: none;
          }
        </style>
      </head>
      <body>
        <iframe src="$url" allowfullscreen allow="autoplay"></iframe>
      </body>
      </html>
    ''';

    controller.loadHtmlString(htmlContent);
    ref.read(watchProvider.notifier).retry();
  }

  void _switchServer(int index) {
    final state = ref.read(watchProvider);
    if (state.episode == null) return;

    ref.read(watchProvider.notifier).switchServer(index);
    final url = state.episode!.servers[index];
    if (_webViewController != null) {
      _loadIframe(_webViewController!, url);
    }
  }

  void _tryNextServer() {
    ref.read(watchProvider.notifier).tryNextServer();
    final state = ref.read(watchProvider);
    if (state.currentServerUrl != null && _webViewController != null) {
      _loadIframe(_webViewController!, state.currentServerUrl!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchState = ref.watch(watchProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildPlayerSection(watchState),
          if (watchState.episode != null) ...[
            _buildEpisodeInfo(watchState.episode!),
            _buildServerSelector(watchState),
            if (watchState.error != null) _buildErrorBanner(watchState),
            _buildNextEpisodeButton(watchState.episode!),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerSection(WatchState watchState) {
    return Container(
      color: Colors.black,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            if (_webViewController != null)
              WebViewWidget(controller: _webViewController!)
            else
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            if (_isWebViewLoading && !_webViewError)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            if (_webViewError || watchState.error != null)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                    const SizedBox(height: 8),
                    const Text(
                      'Server failed',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _tryNextServer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Try Next Server'),
                    ),
                  ],
                ),
              ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEpisodeInfo(EpisodeModel episode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Episode ${episode.episodeNumber}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            episode.title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerSelector(WatchState watchState) {
    if (watchState.episode == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Servers',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(watchState.episode!.servers.length, (i) {
              return ServerButton(
                label: 'Server ${i + 1}',
                isSelected: watchState.selectedServerIndex == i,
                onTap: _isWebViewLoading ? null : () => _switchServer(i),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(WatchState watchState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber, color: AppColors.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                watchState.error!,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: _tryNextServer,
              child: const Text(
                'Retry',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextEpisodeButton(EpisodeModel currentEpisode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: () async {
            final episodes = await ref.read(rtdbServiceProvider).getEpisodes(currentEpisode.animeId);
            final currentIndex = episodes.indexWhere((e) => e.id == widget.episodeId);
            if (currentIndex >= 0 && currentIndex < episodes.length - 1) {
              final nextEp = episodes[currentIndex + 1];
              if (mounted) {
                context.pushReplacement('/watch/${nextEp.id}');
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('No more episodes'),
                    backgroundColor: AppColors.textSecondary,
                  ),
                );
              }
            }
          },
          icon: const Icon(Icons.skip_next, color: AppColors.textPrimary),
          label: const Text(
            'Next Episode',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
