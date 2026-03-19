import 'package:flutter/material.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_exception.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isCurrentObscured = true;
  bool _isNewObscured = true;
  bool _isLoading = false;

  bool _currentTouched = false;
  bool _newTouched = false;

  String? _currentPasswordError;
  String? _newPasswordError;
  String? _serverError;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _validateCurrentPassword() {
    if (!_currentTouched) return;

    final value = _currentPasswordController.text;
    if (value.isEmpty || value.length < 8) {
      _currentPasswordError = 'Введите корректный текущий пароль';
    } else {
      _currentPasswordError = null;
    }
  }

  void _validateNewPassword() {
    if (!_newTouched) return;

    final value = _newPasswordController.text;
    if (value.isEmpty || value.length < 8) {
      _newPasswordError = 'Новый пароль должен быть не менее 8 символов';
    } else if (value == _currentPasswordController.text) {
      _newPasswordError = 'Новый пароль должен отличаться от текущего';
    } else {
      _newPasswordError = null;
    }
  }

  bool _validateForm() {
    _currentTouched = true;
    _newTouched = true;

    _validateCurrentPassword();
    _validateNewPassword();

    setState(() {});

    return _currentPasswordError == null && _newPasswordError == null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    _serverError = null;

    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final message = await ServiceLocator.profileApiService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;

      Navigator.pop(context, message);
    } on ApiException catch (e) {
      setState(() {
        _serverError = e.message;
      });
    } catch (_) {
      setState(() {
        _serverError = 'Не удалось изменить пароль';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                  const Center(
                    child: Text(
                      'Сменить пароль',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  _PasswordField(
                    controller: _currentPasswordController,
                    hintText: 'Введите текущий пароль',
                    obscureText: _isCurrentObscured,
                    onToggleObscure: () {
                      setState(() {
                        _isCurrentObscured = !_isCurrentObscured;
                      });
                    },
                    errorText: _currentPasswordError,
                    onChanged: (_) {
                      _currentTouched = true;
                      _validateCurrentPassword();
                      _validateNewPassword();
                      if (_serverError != null) {
                        _serverError = null;
                      }
                      setState(() {});
                    },
                  ),
                  if (_currentPasswordError != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _currentPasswordError!,
                      style: AppTextStyles.error,
                    ),
                  ],
                  const SizedBox(height: 18),
                  _PasswordField(
                    controller: _newPasswordController,
                    hintText: 'Введите новый пароль',
                    obscureText: _isNewObscured,
                    onToggleObscure: () {
                      setState(() {
                        _isNewObscured = !_isNewObscured;
                      });
                    },
                    errorText: _newPasswordError,
                    onChanged: (_) {
                      _newTouched = true;
                      _validateNewPassword();
                      if (_serverError != null) {
                        _serverError = null;
                      }
                      setState(() {});
                    },
                  ),
                  if (_newPasswordError != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _newPasswordError!,
                      style: AppTextStyles.error,
                    ),
                  ],
                  if (_serverError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _serverError!,
                      style: const TextStyle(
                        color: Color(0xFFE53935),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 280),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
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
                        'Сменить пароль',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final VoidCallback onToggleObscure;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _PasswordField({
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.onToggleObscure,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: TextInputType.visiblePassword,
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
        suffixIcon: IconButton(
          onPressed: onToggleObscure,
          icon: Icon(
            obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.black87,
          ),
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