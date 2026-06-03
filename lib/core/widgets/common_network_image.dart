import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:viteezy/gen/assets.gen.dart';

class CommonNetworkImage extends StatelessWidget {
  const CommonNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  Widget _defaultPlaceholder() {
    return Assets.images.imgPlaceholder.image(
      width: width,
      height: height,
      fit: fit,
    );
  }

  Widget _defaultErrorWidget() {
    return Assets.images.imgPlaceholder.image(
      width: width,
      height: height,
      fit: fit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: imageUrl.isEmpty
          ? errorWidget ?? _defaultErrorWidget()
          : CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) =>
        placeholder ?? _defaultPlaceholder(),
        errorWidget: (context, url, error) =>
        errorWidget ?? _defaultErrorWidget(),
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
      ),
    );
  }
}