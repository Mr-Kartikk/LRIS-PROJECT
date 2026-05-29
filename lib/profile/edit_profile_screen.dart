import 'package:flutter/material.dart';
import 'package:lris/providers/auth_provider.dart';
import 'package:lris/utils/helpers.dart';
import 'package:lris/widgets/custom_button.dart';
import 'package:lris/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _fullNameController = TextEditingController(text: authProvider.user?.fullName ?? '');
    _emailController = TextEditingController(text: authProvider.user?.email ?? '');
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateProfile({
        'full_name': _fullNameController.text,
        'email': _emailController.text,
      });

      setState(() => _isLoading = false);

      if (authProvider.error == null) {
        Helpers.showToast('Profile updated successfully');
        Navigator.pop(context);
      } else {
        Helpers.showToast(authProvider.error!, isError: true);
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue[100],
                  child: Icon(
                    Icons.person,
                    size: 70,
                    color: Colors.blue,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              CustomTextField(
                controller: _fullNameController,
                labelText: 'Full Name *',
                hintText: 'Enter your full name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'your@email.com',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!Helpers.isValidEmail(value)) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              CustomButton(
                text: 'Save Changes',
                onPressed: _updateProfile,
                isLoading: _isLoading,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}