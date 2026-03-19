import 'package:flutter/material.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_exception.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  bool _firstNameTouched = false;
  bool _lastNameTouched = false;
  bool _phoneTouched = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;

  String? _firstNameError;
  String? _lastNameError;
  String? _phoneError;
  String? _emailError;
  String? _passwordError;
  String? _serverError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isEmailValid {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  bool get _isPasswordValid => _passwordController.text.length >= 8;

  bool get _isPhoneValid {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10;
  }

  void _validateFirstName() {
    if (!_firstNameTouched) return;
    final value = _firstNameController.text.trim();
    _firstNameError = value.isEmpty ? 'Введите имя' : null;
  }

  void _validateLastName() {
    if (!_lastNameTouched) return;
    final value = _lastNameController.text.trim();
    _lastNameError = value.isEmpty ? 'Введите фамилию' : null;
  }

  void _validatePhone() {
    if (!_phoneTouched) return;
    final value = _phoneController.text.trim();
    _phoneError = value.isEmpty || !_isPhoneValid ? 'Введите корректный номер телефона' : null;
  }

  void _validateEmail() {
    if (!_emailTouched) return;
    final value = _emailController.text.trim();
    _emailError = value.isEmpty || !_isEmailValid ? 'Введите корректный email' : null;
  }

  void _validatePassword() {
    if (!_passwordTouched) return;
    final value = _passwordController.text;
    _passwordError = value.isEmpty || !_isPasswordValid ? 'Пароль должен быть не менее 8 символов' : null;
  }

  bool _validateForm() {
    _firstNameTouched = true;
    _lastNameTouched = true;
    _phoneTouched = true;
    _emailTouched = true;
    _passwordTouched = true;

    _validateFirstName();
    _validateLastName();
    _validatePhone();
    _validateEmail();
    _validatePassword();

    setState(() {});

    return _firstNameError == null &&
        _lastNameError == null &&
        _phoneError == null &&
        _emailError == null &&
        _passwordError == null;
  }

  String _normalizePhone(String rawPhone) {
    final digits = rawPhone.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('7')) {
      return '+$digits';
    }

    if (digits.startsWith('8') && digits.length == 11) {
      return '+7${digits.substring(1)}';
    }

    return '+7$digits';
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    _serverError = null;

    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await ServiceLocator.authApiService.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _normalizePhone(_phoneController.text),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      debugPrint('REGISTER SUCCESS: $userData');

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } on ApiException catch (e) {
      setState(() {
        _serverError = e.message;
      });
    } catch (_) {
      setState(() {
        _serverError = 'Не удалось выполнить регистрацию';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearServerError() {
    if (_serverError != null) {
      _serverError = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TopHeaderImage(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F1F1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Регистрация',
                    style: AppTextStyles.loginTitle,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Привет! Укажи свои данные',
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: 28),
                  _AuthTextField(
                    controller: _firstNameController,
                    hintText: 'Введи своё имя',
                    errorText: _firstNameError,
                    onChanged: (_) {
                      _firstNameTouched = true;
                      _validateFirstName();
                      _clearServerError();
                      setState(() {});
                    },
                  ),
                  if (_firstNameError != null) ...[
                    const SizedBox(height: 6),
                    Text(_firstNameError!, style: AppTextStyles.error),
                  ],
                  const SizedBox(height: 14),
                  _AuthTextField(
                    controller: _lastNameController,
                    hintText: 'Введи свою фамилию',
                    errorText: _lastNameError,
                    onChanged: (_) {
                      _lastNameTouched = true;
                      _validateLastName();
                      _clearServerError();
                      setState(() {});
                    },
                  ),
                  if (_lastNameError != null) ...[
                    const SizedBox(height: 6),
                    Text(_lastNameError!, style: AppTextStyles.error),
                  ],
                  const SizedBox(height: 14),
                  _PhoneTextField(
                    controller: _phoneController,
                    hintText: '1234567890',
                    errorText: _phoneError,
                    onChanged: (_) {
                      _phoneTouched = true;
                      _validatePhone();
                      _clearServerError();
                      setState(() {});
                    },
                  ),
                  if (_phoneError != null) ...[
                    const SizedBox(height: 6),
                    Text(_phoneError!, style: AppTextStyles.error),
                  ],
                  const SizedBox(height: 14),
                  _AuthTextField(
                    controller: _emailController,
                    hintText: 'Введи свой email',
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    onChanged: (_) {
                      _emailTouched = true;
                      _validateEmail();
                      _clearServerError();
                      setState(() {});
                    },
                  ),
                  if (_emailError != null) ...[
                    const SizedBox(height: 6),
                    Text(_emailError!, style: AppTextStyles.error),
                  ],
                  const SizedBox(height: 14),
                  _AuthTextField(
                    controller: _passwordController,
                    hintText: 'Введи пароль',
                    obscureText: true,
                    errorText: _passwordError,
                    onChanged: (_) {
                      _passwordTouched = true;
                      _validatePassword();
                      _clearServerError();
                      setState(() {});
                    },
                  ),
                  if (_passwordError != null) ...[
                    const SizedBox(height: 6),
                    Text(_passwordError!, style: AppTextStyles.error),
                  ],
                  if (_serverError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _serverError!,
                      style: const TextStyle(
                        color: Color(0xFFE53935),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF3D),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFA5D6A7),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Зарегистрироваться',
                        style: AppTextStyles.primaryButton,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        const Text(
                          'Уже есть аккаунт? ',
                          style: AppTextStyles.bottomText,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            );
                          },
                          child: const Text(
                            'Войти',
                            style: AppTextStyles.bottomLink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopHeaderImage extends StatelessWidget {
  const _TopHeaderImage();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/auth_header.png',
      width: double.infinity,
      height: 92,
      fit: BoxFit.cover,
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String? errorText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const _AuthTextField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.inputHint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: hasError ? const Color(0xFFE53935) : const Color(0xFFE7E7E7),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: hasError ? const Color(0xFFE53935) : const Color(0xFFD9D9D9),
            width: 1,
          ),
        ),
      ),
    );
  }
}

class _PhoneTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _PhoneTextField({
    required this.controller,
    required this.hintText,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.inputHint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 16, right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+7',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: Colors.black,
              ),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: hasError ? const Color(0xFFE53935) : const Color(0xFFE7E7E7),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: hasError ? const Color(0xFFE53935) : const Color(0xFFD9D9D9),
            width: 1,
          ),
        ),
      ),
    );
  }
}