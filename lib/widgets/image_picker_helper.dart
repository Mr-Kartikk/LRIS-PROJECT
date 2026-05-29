import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

class ImageDisplayHelper {
  static Widget displayImage(dynamic image, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (image == null) {
      return Container();
    }

    // Handle File (mobile)
    if (image is File) {
      return Image.file(
        image,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.broken_image, size: 40),
            ),
          );
        },
      );
    }

    // Handle Uint8List (web alternative)
    if (image is Uint8List) {
      return Image.memory(
        image,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.broken_image, size: 40),
            ),
          );
        },
      );
    }

    // Handle network images
    if (image is String) {
      return Image.network(
        image,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.broken_image, size: 40),
            ),
          );
        },
      );
    }

    return Container();
  }
}