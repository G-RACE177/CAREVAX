import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'theme.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? selectedRole;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }

  void signup() async {
    if (_formKey.currentState!.validate()) {
      if (selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Please select a role"),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kDefaultRadius),
            ),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Here you would also save user credentials securely
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      await saveUserRole(selectedRole!);

      // Navigate to login page after signup
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with gradient overlay
          Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/log.jpg'),
                fit: BoxFit.cover,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  kPrimaryColor.withOpacity(0.6),
                  kPrimaryVariant,
                ],
              ),
            ),
          ),

          // App logo and branding at the top
          Positioned(
            top: size.height * 0.05,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Icon(
                  Icons.health_and_safety,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  'CareVax',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Signup form card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: kDefaultPadding),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kLargeRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(kLargePadding),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Create Account',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign up to get started',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: kTextSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: kLargePadding),
                          
                          // Username field
                          TextFormField(
                            controller: username,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              hintText: 'Choose a username',
                              prefixIcon: Icon(Icons.person_outline, color: theme.colorScheme.primary),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a username';
                              }
                              if (value.length < 4) {
                                return 'Username must be at least 4 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: kDefaultPadding),
                          
                          // Password field
                          TextFormField(
                            controller: password,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Create a password',
                              prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: kTextSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: kDefaultPadding),
                          
                          // Confirm Password field
                          TextFormField(
                            controller: confirmPassword,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              hintText: 'Confirm your password',
                              prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                  color: kTextSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != password.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: kDefaultPadding),
                          
                          // Role selection
                          DropdownButtonFormField<String>(
                            value: selectedRole,
                            hint: const Text('Select your role'),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.assignment_ind_outlined, color: theme.colorScheme.primary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(kDefaultRadius),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                            items: ['Parent', 'VHT'].map((role) => 
                              DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              )
                            ).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedRole = value;
                              });
                            },
                          ),
                          
                          const SizedBox(height: kLargePadding),
                          
                          // Signup button
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : signup,
                              child: _isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'SIGN UP',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: kDefaultPadding),
                          
                          // Login link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account?',
                                style: TextStyle(color: kTextSecondary),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                                child: Text('Login'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
