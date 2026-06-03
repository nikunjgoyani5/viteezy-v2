import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:viteezy/core/utils/exports.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  int _loadingProgress = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments;
    final String? url = arguments?['url'];
    final String title = arguments?['title'] ?? '';

    if (url == null || url.isEmpty) {
      _errorMessage = 'No URL provided';
      _isLoading = false;
      return;
    }

    // Initialize WebViewController
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _loadingProgress = 0;
              _errorMessage = null;
            });
          },
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress;
              _isLoading = progress < 100;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _loadingProgress = 100;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _loadingProgress = 0;
              _errorMessage = error.description.isNotEmpty
                  ? error.description
                  : 'Failed to load page. Please try again.';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments;
    final String title = arguments?['title'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.surfaceColor,
      appBar: CommonAppbar(
        title: title,
        showBackButton: true,
      ),
      body: _errorMessage != null
          ? _buildErrorView()
          : Column(
              children: [
                // Linear Progress Indicator
                if (_isLoading)
                  LinearProgressIndicator(
                    value: _loadingProgress / 100,
                    backgroundColor: AppColors.grayE3E3DC,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    minHeight: 3.0,
                  ),
                // WebView
                Expanded(
                  child: WebViewWidget(controller: _webViewController),
                ),
              ],
            ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: AppColors.gray949391,
            ),
            Gap(16.h),
            Text(
              'Unable to load page',
              style: TextStyles.bold(20.sp, fontColor: AppColors.black1414141),
              textAlign: TextAlign.center,
            ),
            Gap(8.h),
            Text(
              _errorMessage ?? 'Something went wrong. Please try again.',
              style: TextStyles.regular(14.sp, fontColor: AppColors.gray949391),
              textAlign: TextAlign.center,
            ),
            Gap(24.h),
            ElevatedButton(
              onPressed: () {
                final arguments = Get.arguments;
                final String? url = arguments?['url'];
                if (url != null && url.isNotEmpty) {
                  setState(() {
                    _errorMessage = null;
                    _isLoading = true;
                  });
                  _webViewController.reload();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.surfaceColor,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Retry',
                style: TextStyles.semiBold(16.sp, fontColor: AppColors.surfaceColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

