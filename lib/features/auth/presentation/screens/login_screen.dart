import 'package:flutter/material.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/token_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;

  String? _emailError;
  String? _passwordError;
  String? _serverError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isEmailValid {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  bool get _isPasswordValid {
    final password = _passwordController.text;
    return password.length >= 8;
  }

  void _validateEmail() {
    if (!_emailTouched) return;

    final email = _emailController.text.trim();
    if (email.isEmpty || !_isEmailValid) {
      _emailError = 'Введите корректный email';
    } else {
      _emailError = null;
    }
  }

  void _validatePassword() {
    if (!_passwordTouched) return;

    final password = _passwordController.text;
    if (password.isEmpty || !_isPasswordValid) {
      _passwordError = 'Введите корректный пароль';
    } else {
      _passwordError = null;
    }
  }

  bool _validateForm() {
    _emailTouched = true;
    _passwordTouched = true;

    _validateEmail();
    _validatePassword();

    setState(() {});

    return _emailError == null && _passwordError == null;
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    _serverError = null;

    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await ServiceLocator.authApiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      debugPrint('LOGIN TOKEN: $token');

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } on ApiException catch (e) {
      setState(() {
        _serverError = e.message;
      });
    } catch (_) {
      setState(() {
        _serverError = 'Не удалось выполнить вход';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    final token = await ServiceLocator.authApiService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    // СОХРАНЯЕМ
    await TokenStorage.saveToken(token);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  void _onEmailChanged(String value) {
    _emailTouched = true;
    _validateEmail();

    if (_serverError != null) {
      _serverError = null;
    }

    setState(() {});
  }

  void _onPasswordChanged(String value) {
    _passwordTouched = true;
    _validatePassword();

    if (_serverError != null) {
      _serverError = null;
    }

    setState(() {});
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
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Войти',
                    style: AppTextStyles.loginTitle,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Давай вернём тебя обратно.',
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: 28),
                  _AuthTextField(
                    controller: _emailController,
                    hintText: 'Введите email',
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    onChanged: _onEmailChanged,
                  ),
                  if (_emailError != null) ...[
                    const SizedBox(height: 6),
                    Text(_emailError!, style: AppTextStyles.error),
                  ],
                  const SizedBox(height: 14),
                  _AuthTextField(
                    controller: _passwordController,
                    hintText: 'Введите пароль',
                    obscureText: true,
                    errorText: _passwordError,
                    onChanged: _onPasswordChanged,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _passwordError != null
                            ? Text(
                          _passwordError!,
                          style: AppTextStyles.error,
                        )
                            : const SizedBox.shrink(),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Забыл пароль',
                          style: AppTextStyles.textButton,
                        ),
                      ),
                    ],
                  ),
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
                  const SizedBox(height: 28),
                  const _DividerWithText(text: 'Или войти через'),
                  const SizedBox(height: 22),
                  const Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          label: 'Яндекс ID',
                          assetPath: 'assets/icons/yandex_icon.png',
                        ),
                      ),
                      SizedBox(width: 18),
                      Expanded(
                        child: _SocialButton(
                          label: 'Вконтакте',
                          assetPath: 'assets/icons/vk_icon.png',
                        ),
                      ),
                    ],
                  ),

                  // вместо Spacer()
                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
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
                        'Войти',
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
                          'Еще нет аккаунта? ',
                          style: AppTextStyles.bottomText,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                          child: const Text(
                            'Зарегистрироваться',
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

class _DividerWithText extends StatelessWidget {
  final String text;

  const _DividerWithText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: Color(0xFFE3E3E3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            text,
            style: AppTextStyles.dividerText,
          ),
        ),
        const Expanded(
          child: Divider(
            color: Color(0xFFE3E3E3),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final String assetPath;

  const _SocialButton({
    required this.label,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetPath,
              width: 22,
              height: 22,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.socialButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}