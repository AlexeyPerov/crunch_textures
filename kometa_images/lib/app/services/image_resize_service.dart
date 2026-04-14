import 'dart:io';

import 'package:image/image.dart' as image_utils;
import 'package:path/path.dart' as path_utils;

enum ResizeMode { createResizedCopy, resizeThisFile, resizeThisFileAndBackup }

enum ResizeType { nearest, linear, cubic, centerWithAlpha }

extension ResizeTypeToString on ResizeType {
  String toShortString() {
    return toString().split('.').last;
  }
}

class ImageResizeRequest {
  final String sourcePath;
  final int width;
  final int height;
  final ResizeType resizeType;
  final ResizeMode resizeMode;

  const ImageResizeRequest({
    required this.sourcePath,
    required this.width,
    required this.height,
    required this.resizeType,
    required this.resizeMode,
  });
}

class ImageResizeResult {
  final bool success;
  final String sourcePath;
  final String? outputPath;
  final String? backupPath;
  final String? error;

  const ImageResizeResult({
    required this.success,
    required this.sourcePath,
    this.outputPath,
    this.backupPath,
    this.error,
  });
}

class ImageResizeService {
  Future<ImageResizeResult> resize(ImageResizeRequest request) async {
    final sourcePath = request.sourcePath;
    final sourceFile = File(sourcePath);
    final extension = path_utils.extension(sourcePath).toLowerCase();
    final pathNoExtension = path_utils.withoutExtension(sourcePath);
    final destination = pathNoExtension +
        "_autoresize_" +
        request.width.toString() +
        "x" +
        request.height.toString() +
        "_" +
        request.resizeType.toShortString() +
        extension;

    try {
      final sourceBytes = await sourceFile.readAsBytes();
      final decodedImage = image_utils.decodeImage(sourceBytes);

      if (decodedImage == null) {
        return ImageResizeResult(
          success: false,
          sourcePath: sourcePath,
          error: "Unable to decode image bytes",
        );
      }

      image_utils.Image resizedImage;

      switch (request.resizeType) {
        case ResizeType.nearest:
          resizedImage = image_utils.copyResize(
            decodedImage,
            width: request.width,
            height: request.height,
            interpolation: image_utils.Interpolation.nearest,
          );
          break;
        case ResizeType.linear:
          resizedImage = image_utils.copyResize(
            decodedImage,
            width: request.width,
            height: request.height,
            interpolation: image_utils.Interpolation.linear,
          );
          break;
        case ResizeType.cubic:
          resizedImage = image_utils.copyResize(
            decodedImage,
            width: request.width,
            height: request.height,
            interpolation: image_utils.Interpolation.cubic,
          );
          break;
        case ResizeType.centerWithAlpha:
          final tempImage = image_utils.Image(request.width, request.height);
          final blankImage =
              image_utils.fill(tempImage, image_utils.getColor(0, 0, 0, 0));
          resizedImage = image_utils.copyInto(
            blankImage,
            decodedImage,
            blend: false,
            center: true,
          );
          break;
      }

      final resultingBytes = _encodeByExtension(resizedImage, extension);

      if (request.resizeMode == ResizeMode.resizeThisFileAndBackup) {
        final backupPath = pathNoExtension + "_original" + extension;
        await File(backupPath).writeAsBytes(sourceBytes);
        await sourceFile.writeAsBytes(resultingBytes);

        return ImageResizeResult(
          success: true,
          sourcePath: sourcePath,
          outputPath: sourcePath,
          backupPath: backupPath,
        );
      }

      if (request.resizeMode == ResizeMode.resizeThisFile) {
        await sourceFile.writeAsBytes(resultingBytes);
        return ImageResizeResult(
          success: true,
          sourcePath: sourcePath,
          outputPath: sourcePath,
        );
      }

      await File(destination).writeAsBytes(resultingBytes);
      return ImageResizeResult(
        success: true,
        sourcePath: sourcePath,
        outputPath: destination,
      );
    } catch (e) {
      return ImageResizeResult(
        success: false,
        sourcePath: sourcePath,
        error: e.toString(),
      );
    }
  }

  List<int> _encodeByExtension(image_utils.Image image, String extension) {
    if (extension == ".jpg" || extension == ".jpeg") {
      return image_utils.encodeJpg(image);
    }
    if (extension == ".tga") {
      return image_utils.encodeTga(image);
    }
    return image_utils.encodePng(image);
  }
}
