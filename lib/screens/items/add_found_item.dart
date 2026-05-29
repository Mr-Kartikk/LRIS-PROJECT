import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:lris/providers/item_provider.dart';
import 'package:lris/utils/helpers.dart';
import 'package:lris/widgets/custom_textfield.dart';
import 'package:lris/widgets/custom_button.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddFoundItemScreen extends StatefulWidget {
  const AddFoundItemScreen({super.key});

  @override
  _AddFoundItemScreenState createState() => _AddFoundItemScreenState();
}

class _AddFoundItemScreenState extends State<AddFoundItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _currentLocationController = TextEditingController();
  final _brandController = TextEditingController();
  final _colorController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();

  DateTime? _foundDate;
  dynamic _image; // Changed from File? to dynamic to accept both File and XFile
  bool _isLoading = false;
  int? _selectedCategory;

  Future<void> _pickImage(ImageSource source) async {
    try {
      dynamic image; // Use dynamic to accept both File and XFile
      if (source == ImageSource.camera) {
        image = await Helpers.takePhoto();
      } else {
        image = await Helpers.pickImage();
      }

      if (image != null) {
        setState(() {
          _image = image;
        });
      }
    } catch (e) {
      Helpers.showToast('Failed to pick image: $e', isError: true);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera, color: Colors.blue),
            title: const Text('Take Photo'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.blue),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_foundDate == null) {
        Helpers.showToast('Please select found date', isError: true);
        return;
      }

      setState(() => _isLoading = true);

      final itemProvider = Provider.of<ItemProvider>(context, listen: false);

      final success = await itemProvider.createFoundItem(
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        currentLocation: _currentLocationController.text,
        foundDate: _foundDate!,
        brand: _brandController.text.isNotEmpty ? _brandController.text : null,
        color: _colorController.text.isNotEmpty ? _colorController.text : null,
        category: _selectedCategory,
        image: _image, // Now passing dynamic type
      );

      setState(() => _isLoading = false);

      if (success) {
        Helpers.showToast('Found item reported successfully!');
        Navigator.pop(context);
      } else {
        Helpers.showToast(
          itemProvider.error ?? 'Failed to report found item',
          isError: true,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _currentLocationController.dispose();
    _brandController.dispose();
    _colorController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Found Item'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Item Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _titleController,
                labelText: 'Item Title *',
                hintText: 'e.g., Wallet, Mobile Phone, Keys',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter item title';
                  }
                  if (value.length < 3) {
                    return 'Title must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description *',
                hintText: 'Describe the item in detail...',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  if (value.length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _locationController,
                labelText: 'Found Location *',
                hintText: 'e.g., Central Park, Main Street',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter found location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _currentLocationController,
                labelText: 'Current Location *',
                hintText: 'Where is the item currently kept?',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter current location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Text(
                'Found Date *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _foundDate = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _foundDate != null
                            ? Helpers.formatDate(_foundDate!)
                            : 'Select Date',
                        style: TextStyle(
                          fontSize: 16,
                          color: _foundDate != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.blue),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _brandController,
                      labelText: 'Brand (Optional)',
                      hintText: 'e.g., Samsung, Nike',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _colorController,
                      labelText: 'Color (Optional)',
                      hintText: 'e.g., Black, Red',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (itemProvider.categories.isNotEmpty) ...[
                const Text(
                  'Category',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: itemProvider.categories.map((category) {
                    final isSelected = _selectedCategory == category['id'];
                    return ChoiceChip(
                      label: Text(category['name']),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category['id'] : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              const Text(
                'Add Photo (Optional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildImagePreview(),
                ),
              ),
              const SizedBox(height: 30),

              CustomButton(
                text: 'Report Found Item',
                onPressed: _submitForm,
                backgroundColor: Colors.green,
                isLoading: _isLoading,
                fullWidth: true,
                icon: const Icon(Icons.check_circle, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_image == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
          Text('Tap to add photo'),
        ],
      );
    }

    if (kIsWeb) {
      // On web, show filename from XFile
      String filename = 'Image selected';
      if (_image is XFile) {
        filename = _image.name;
      }

      return Container(
        color: Colors.grey[300],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image, size: 50, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              filename,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
             Text(
              'Preview not available on web',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      );
    }

    // On mobile, show the actual image
    if (_image is File) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          _image as File,
          fit: BoxFit.cover,
        ),
      );
    }

    // Fallback
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Text('Invalid image format'),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tips for Reporting Found Items'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('• Be specific about found location'),
              Text('• Provide detailed description'),
              Text('• Include brand and color if known'),
              Text('• Add clear photos for identification'),
              Text('• Keep item safe until claimed'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}