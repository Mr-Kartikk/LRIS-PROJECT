import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class Helpers {
  // Date formatting
  static String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
    return DateFormat(format).format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return formatDate(date);
    }
  }

  // Show toast messages
  static void showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  // Validate phone number
  static bool isValidPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    return cleaned.length >= 10;
  }

  // Pick image from gallery - Returns dynamic (XFile on web, File on mobile)
  static Future<dynamic> pickImage() async {
    final picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        if (kIsWeb) {
          // On web, return the XFile directly
          return pickedFile;
        } else {
          // On mobile, convert to File
          return File(pickedFile.path);
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
    return null;
  }

  // Take photo with camera - Returns dynamic (XFile on web, File on mobile)
  static Future<dynamic> takePhoto() async {
    final picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        if (kIsWeb) {
          // On web, return the XFile directly
          return pickedFile;
        } else {
          // On mobile, convert to File
          return File(pickedFile.path);
        }
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
    return null;
  }

  // Get file size in readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  // Format phone number
  static String formatPhoneNumber(String phone) {
    if (phone.startsWith('+')) {
      return phone;
    }
    return '+91$phone';
  }
}