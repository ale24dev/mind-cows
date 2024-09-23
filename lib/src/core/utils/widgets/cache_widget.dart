import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:my_app/resources/resources.dart';

class CacheWidget extends StatelessWidget {
  /// Widget to show images from the internet and keep them in the cache directory.
  ///
  /// Use **cached_network_image** library as base Widget and provide a default
  /// implementation with just two required params [imageUrl] and [size]
  const CacheWidget({
    required this.size, super.key,
    this.imageUrl,
    this.errorBackgroundColor,
    this.imageErrorPath = AppImages.noPhoto,
    this.boxDecoration = const BoxDecoration(),
    this.borderRadius,
    this.imageBuilder,
    this.placeholder,
    this.errorWidget,
    this.heroTag,
    this.color,
    this.height,
    this.width,
    this.alignment = Alignment.center,
    this.cacheKey,
    this.cacheManager,
    this.colorBlendMode,
    this.errorListener,
    this.fadeInCurve = Curves.easeIn,
    this.fadeInDuration = const Duration(milliseconds: 500),
    this.fadeOutCurve = Curves.easeOut,
    this.fadeOutDuration = const Duration(milliseconds: 1000),
    this.filterQuality = FilterQuality.low,
    this.fit,
    this.httpHeaders,
    this.imageRenderMethodForWeb = ImageRenderMethodForWeb.HtmlImage,
    this.matchTextDirection = false,
    this.maxHeightDiskCache,
    this.maxWidthDiskCache,
    this.memCacheHeight,
    this.memCacheWidth,
    this.placeholderFadeInDuration,
    this.progressIndicatorBuilder,
    this.repeat = ImageRepeat.noRepeat,
    this.useOldImageOnUrlChange = false,
  });

  /// The identifier for this particular hero. If the tag of this hero matches the
  /// tag of a hero on a PageRoute that we're navigating to or from, then a hero
  /// animation will be triggered
  final String? heroTag;

  /// The target image that is displayed.
  final String? imageUrl;

  /// A color background on default error image.
  final Color? errorBackgroundColor;

  /// Image path to asset to display when the target imageUrl failed loading
  /// and no errorWidget was provided
  final String imageErrorPath;

  /// Size of widget
  final Size size;

  /// BoxDecoration for default Container when [imageBuilder], [placeholder],
  /// or [errorWidget] was no provided
  final BoxDecoration boxDecoration;

  /// Image border radius
  final BorderRadius? borderRadius;

  /// Optional builder to further customize the display of the image
  final Widget Function(ImageProvider provider, Size size)? imageBuilder;

  /// Widget displayed while the target imageUrl failed loading.
  final Widget Function(String error)? errorWidget;

  /// Widget displayed while the target imageUrl is loading
  final Widget? placeholder;

  /// If non-null, this color is blended with each image pixel using [colorBlendMode].
  final Color? color;

  /// If non-null, require the image to have this height.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio. This may result in a sudden change if the size of the
  /// placeholder widget does not match that of the target image. The size is
  /// also affected by the scale factor.
  final double? height;

  /// If non-null, require the image to have this width.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio. This may result in a sudden change if the size of the
  /// placeholder widget does not match that of the target image. The size is
  /// also affected by the scale factor.
  final double? width;

  /// How to align the image within its bounds.
  ///
  /// The alignment aligns the given position in the image to the given position
  /// in the layout bounds. For example, a [Alignment] alignment of (-1.0,
  /// -1.0) aligns the image to the top-left corner of its layout bounds, while a
  /// [Alignment] alignment of (1.0, 1.0) aligns the bottom right of the
  /// image with the bottom right corner of its layout bounds. Similarly, an
  /// alignment of (0.0, 1.0) aligns the bottom middle of the image with the
  /// middle of the bottom edge of its layout bounds.
  ///
  /// If the [alignment] is [TextDirection]-dependent (i.e. if it is a
  /// [AlignmentDirectional]), then an ambient [Directionality] widget
  /// must be in scope.
  ///
  /// Defaults to [Alignment.center].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final Alignment alignment;

  final String? cacheKey;

  /// Option to use cacheManager with other settings
  final BaseCacheManager? cacheManager;

  /// Used to combine [color] with this image.
  ///
  /// The default is [BlendMode.srcIn]. In terms of the blend mode, [color] is
  /// the source and this image is the destination.
  ///
  /// See also:
  ///
  ///  * [BlendMode], which includes an illustration of the effect of each blend mode.
  final BlendMode? colorBlendMode;

  /// Listener to be called when images fails to load.
  final void Function(Object)? errorListener;

  /// The curve of the fade-in animation for the [imageUrl].
  final Curve fadeInCurve;

  /// The duration of the fade-in animation for the [imageUrl].
  final Duration fadeInDuration;

  /// The curve of the fade-out animation for the [placeholder].
  final Curve fadeOutCurve;

  /// The duration of the fade-out animation for the [placeholder].
  final Duration fadeOutDuration;

  /// Target the interpolation quality for image scaling.
  ///
  /// If not given a value, defaults to FilterQuality.low.
  final FilterQuality filterQuality;

  /// How to inscribe the image into the space allocated during layout.
  ///
  /// The default varies based on the other fields. See the discussion at
  /// [paintImage].
  final BoxFit? fit;

  /// Optional headers for the http request of the image url
  final Map<String, String>? httpHeaders;

  /// Render option for images on the web platform
  final ImageRenderMethodForWeb imageRenderMethodForWeb;

  /// Whether to paint the image in the direction of the [TextDirection].
  ///
  /// If this is true, then in [TextDirection.ltr] contexts, the image will be
  /// drawn with its origin in the top left (the "normal" painting direction for
  /// children); and in [TextDirection.rtl] contexts, the image will be drawn with
  /// a scaling factor of -1 in the horizontal direction so that the origin is
  /// in the top right.
  ///
  /// This is occasionally used with children in right-to-left environments, for
  /// children that were designed for left-to-right locales. Be careful, when
  /// using this, to not flip children with integral shadows, text, or other
  /// effects that will look incorrect when flipped.
  ///
  /// If this is true, there must be an ambient [Directionality] widget in
  /// scope.
  final bool matchTextDirection;

  /// Will resize the image and store the resized image in the disk cache.
  final int? maxHeightDiskCache;

  /// Will resize the image and store the resized image in the disk cache.
  final int? maxWidthDiskCache;

  /// Will resize the image in memory to have a certain height using [ResizeImage]
  final int? memCacheHeight;

  /// Will resize the image in memory to have a certain width using [ResizeImage]
  final int? memCacheWidth;

  /// The duration of the fade-in animation for the [placeholder].
  final Duration? placeholderFadeInDuration;

  /// Widget displayed while the target [imageUrl] is loading.
  final Widget Function(BuildContext, String, DownloadProgress)?
      progressIndicatorBuilder;

  /// How to paint any portions of the layout bounds not covered by the image.
  final ImageRepeat repeat;

  /// When set to true it will animate from the old image to the new image
  /// if the url changes.
  final bool useOldImageOnUrlChange;

  @override
  Widget build(BuildContext context) {
    return imageUrl == null
        ? Container(
            width: size.width,
            height: size.height,
            decoration: boxDecoration.copyWith(
              border: Border.all(color: Colors.grey),
              color: Colors.grey.withOpacity(0.5),
              borderRadius: borderRadius ?? BorderRadius.circular(16),
              image: DecorationImage(
                image: AssetImage(imageErrorPath),
                colorFilter: ColorFilter.mode(
                    errorBackgroundColor ?? Colors.transparent,
                    BlendMode.dstATop,),
                fit: BoxFit.cover,
              ),
            ),
          )
        : CachedNetworkImage(
            imageUrl: imageUrl!,
            imageBuilder: (_, img) => Hero(
              tag: heroTag ?? Random().nextDouble().toString(),
              child: Material(
                color: Colors.transparent,
                child: imageBuilder?.call(img, size) ??
                    Container(
                      width: size.width,
                      height: size.height,
                      decoration: boxDecoration.copyWith(
                        borderRadius: borderRadius ?? BorderRadius.circular(10),
                        image: DecorationImage(
                            image: img,
                            fit: fit,
                            colorFilter: color != null
                                ? ColorFilter.mode(color ?? Colors.transparent,
                                    colorBlendMode ?? BlendMode.srcIn,)
                                : null,),
                      ),
                    ),
              ),
            ),
            placeholder: (_, __) =>
                placeholder ??
                Container(
                  width: size.width,
                  height: size.height,
                  decoration: boxDecoration.copyWith(
                    border: Border.all(color: Colors.grey),
                    borderRadius: borderRadius ?? BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            errorWidget: (_, __, ___) {
              return errorWidget?.call(__) ??
                  Container(
                    width: size.width,
                    height: size.height,
                    decoration: boxDecoration.copyWith(
                      border: Border.all(color: Colors.grey),
                      color: Colors.grey.withOpacity(0.5),
                      borderRadius: borderRadius ?? BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(imageErrorPath),
                        colorFilter: ColorFilter.mode(
                            errorBackgroundColor ?? Colors.transparent,
                            BlendMode.dstATop,),
                        fit: fit,
                      ),
                    ),
                  );
            },
            color: color,
            height: height,
            width: width,
            alignment: alignment,
            cacheKey: cacheKey,
            cacheManager: cacheManager,
            colorBlendMode: colorBlendMode,
            errorListener: errorListener,
            fadeInCurve: fadeInCurve,
            fadeInDuration: fadeInDuration,
            fadeOutCurve: fadeOutCurve,
            fadeOutDuration: fadeOutDuration,
            filterQuality: filterQuality,
            fit: fit,
            httpHeaders: httpHeaders,
            imageRenderMethodForWeb: imageRenderMethodForWeb,
            key: key,
            matchTextDirection: matchTextDirection,
            maxHeightDiskCache: maxHeightDiskCache,
            maxWidthDiskCache: maxWidthDiskCache,
            memCacheHeight: memCacheHeight,
            memCacheWidth: memCacheWidth,
            placeholderFadeInDuration: placeholderFadeInDuration,
            progressIndicatorBuilder: progressIndicatorBuilder,
            repeat: repeat,
            useOldImageOnUrlChange: useOldImageOnUrlChange,
          );
  }
}
