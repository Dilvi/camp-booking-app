import 'package:flutter/material.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/profile_model.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileModel profile;

  const EditProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  bool _isLoading = false;

  bool _nameTouched = false;
  bool _phoneTouched = false;
  bool _emailTouched = false;

  String? _nameError;
  String? _phoneError;
  String? _emailError;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController =
        TextEditingController(text: _stripPhonePrefix(widget.profile.phone));
    _emailController = TextEditingController(text: widget.profile.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _stripPhonePrefix(String phone) {
    if (phone.startsWith('+7')) {
      return phone.substring(2);
    }
    if (phone.startsWith('7')) {
      return phone.substring(1);
    }
    if (phone.startsWith('8') && phone.length == 11) {
      return phone.substring(1);
    }
    return phone;
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

  ({String firstName, String lastName}) _splitFullName(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return (firstName: '', lastName: '');
    }

    if (parts.length == 1) {
      return (firstName: parts.first, lastName: '');
    }

    return (
    firstName: parts.first,
    lastName: parts.sublist(1).join(' '),
    );
  }

  bool get _isEmailValid {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  bool get _isPhoneValid {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10;
  }

  void _validateName() {
    if (!_nameTouched) return;
    _nameError = _nameController.text.trim().isEmpty ? 'Введите имя' : null;
  }

  void _validatePhone() {
    if (!_phoneTouched) return;
    final value = _phoneController.text.trim();
    _phoneError =
    value.isEmpty || !_isPhoneValid ? 'Введите корректный номер телефона' : null;
  }

  void _validateEmail() {
    if (!_emailTouched) return;
    final value = _emailController.text.trim();
    _emailError = value.isEmpty || !_isEmailValid ? 'Введите корректный email' : null;
  }

  bool _validateForm() {
    _nameTouched = true;
    _phoneTouched = true;
    _emailTouched = true;

    _validateName();
    _validatePhone();
    _validateEmail();

    setState(() {});

    return _nameError == null && _phoneError == null && _emailError == null;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    _serverError = null;

    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final split = _splitFullName(_nameController.text);

      final updatedProfile = await ServiceLocator.profileApiService.updateProfile(
        firstName: split.firstName,
        lastName: split.lastName,
        email: _emailController.text.trim(),
        phone: _normalizePhone(_phoneController.text),
        avatarUrl: widget.profile.avatarUrl,
      );

      if (!mounted) return;
      Navigator.pop(context, updatedProfile);
    } on ApiException catch (e) {
      setState(() {
        _serverError = e.message;
      });
    } catch (_) {
      setState(() {
        _serverError = 'Не удалось сохранить изменения';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildError(String? text) {
    if (text == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: AppTextStyles.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = widget.profile.avatarUrl;

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
                  Row(
                    children: [
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
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Редактировать профиль',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 132,
                            height: 132,
                            child: avatarUrl != null && avatarUrl.isNotEmpty
                                ? Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFD9D9D9),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 52,
                                ),
                              ),
                            )
                                : Container(
                              color: const Color(0xFFD9D9D9),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 52,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF3D),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 34),
                  _AuthTextField(
                    controller: _nameController,
                    hintText: 'John Doe',
                    errorText: _nameError,
                    onChanged: (_) {
                      _nameTouched = true;
                      _validateName();
                      if (_serverError != null) _serverError = null;
                      setState(() {});
                    },
                  ),
                  _buildError(_nameError),
                  const SizedBox(height: 20),
                  _PhoneTextField(
                    controller: _phoneController,
                    hintText: '1234567890',
                    errorText: _phoneError,
                    onChanged: (_) {
                      _phoneTouched = true;
                      _validatePhone();
                      if (_serverError != null) _serverError = null;
                      setState(() {});
                    },
                  ),
                  _buildError(_phoneError),
                  const SizedBox(height: 20),
                  _AuthTextField(
                    controller: _emailController,
                    hintText: 'johndoe@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    onChanged: (_) {
                      _emailTouched = true;
                      _validateEmail();
                      if (_serverError != null) _serverError = null;
                      setState(() {});
                    },
                  ),
                  _buildError(_emailError),
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
                  const SizedBox(height: 320),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
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
                        'Сохранить',
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

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const _AuthTextField({
    required this.controller,
    required this.hintText,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.inputHint.copyWith(
          color: Colors.black87,
        ),
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
        hintStyle: AppTextStyles.inputHint.copyWith(
          color: Colors.black87,
        ),
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