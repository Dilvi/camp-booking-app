import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/child_model.dart';

class ChildFormScreen extends StatefulWidget {
  final ChildModel? child;

  const ChildFormScreen({
    super.key,
    this.child,
  });

  @override
  State<ChildFormScreen> createState() => _ChildFormScreenState();
}

class _ChildFormScreenState extends State<ChildFormScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _birthDateController;

  bool _isLoading = false;
  String? _serverError;

  String _gender = 'male';
  String? _selectedHobby;
  String? _selectedAllergy;

  final List<String> _hobbies = [
    'reading',
    'dance',
    'sport',
    'drawing',
    'swimming',
  ];

  final List<String> _allergies = [
    'nuts',
    'chestnuts',
    'eggs',
    'fish',
    'corn',
    'milk',
  ];

  bool get _isEdit => widget.child != null;

  @override
  void initState() {
    super.initState();
    final child = widget.child;
    _firstNameController = TextEditingController(text: child?.firstName ?? '');
    _lastNameController = TextEditingController(text: child?.lastName ?? '');
    _birthDateController = TextEditingController(
      text: _formatBirthDateForUi(child?.birthDate ?? ''),
    );
    _gender = child?.gender.isNotEmpty == true ? child!.gender : 'male';
    _selectedHobby = child?.hobby.isNotEmpty == true ? child!.hobby : null;
    _selectedAllergy = child?.allergy.isNotEmpty == true ? child!.allergy : null;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  String _formatBirthDateForUi(String value) {
    if (value.length == 10 && value.contains('-')) {
      final parts = value.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
    }
    return value;
  }

  String _formatBirthDateForApi(String value) {
    final parts = value.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return value;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDate: DateTime(2015, 1, 1),
    );

    if (picked == null) return;

    setState(() {
      _birthDateController.text =
      '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    });
  }

  String _genderLabel(String value) {
    switch (value) {
      case 'male':
        return 'Мужской';
      case 'female':
        return 'Женский';
      default:
        return value;
    }
  }

  String _hobbyLabel(String value) {
    switch (value) {
      case 'reading':
        return 'Чтение';
      case 'dance':
        return 'Танцы';
      case 'sport':
        return 'Спорт';
      case 'drawing':
        return 'Рисование';
      case 'swimming':
        return 'Плавание';
      default:
        return value;
    }
  }

  String _allergyLabel(String value) {
    switch (value) {
      case 'nuts':
        return 'Арахис';
      case 'chestnuts':
        return 'Каштаны';
      case 'eggs':
        return 'Яйца';
      case 'fish':
        return 'Рыба';
      case 'corn':
        return 'Кукуруза';
      case 'milk':
        return 'Молоко';
      default:
        return value;
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    _serverError = null;

    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _birthDateController.text.trim().isEmpty ||
        _selectedHobby == null ||
        _selectedAllergy == null) {
      setState(() {
        _serverError = 'Заполните все поля';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final child = _isEdit
          ? await ServiceLocator.childrenApiService.updateChild(
        childId: widget.child!.id,
        photoUrl: widget.child!.photoUrl,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        birthDate: _formatBirthDateForApi(_birthDateController.text.trim()),
        gender: _gender,
        hobby: _selectedHobby!,
        allergy: _selectedAllergy!,
      )
          : await ServiceLocator.childrenApiService.createChild(
        photoUrl: widget.child?.photoUrl ?? 'https://example.com/photo.jpg',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        birthDate: _formatBirthDateForApi(_birthDateController.text.trim()),
        gender: _gender,
        hobby: _selectedHobby!,
        allergy: _selectedAllergy!,
      );

      if (!mounted) return;
      Navigator.pop(context, child);
    } on ApiException catch (e) {
      setState(() {
        _serverError = e.message;
      });
    } catch (_) {
      setState(() {
        _serverError = 'Не удалось сохранить данные ребёнка';
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
    final title = _isEdit ? 'Редактировать профиль' : 'Добавить ребенка';
    final buttonText = _isEdit ? 'Сохранить' : 'Добавить ребенка';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CircleButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
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
                  _ChildAvatar(photoUrl: widget.child?.photoUrl),
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
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 34),
            Row(
              children: [
                Expanded(
                  child: _LabeledTextField(
                    label: 'Имя',
                    controller: _firstNameController,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _LabeledTextField(
                    label: 'Фамилия',
                    controller: _lastNameController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _LabeledDateField(
              label: 'Дата рождения',
              controller: _birthDateController,
              onTap: _pickDate,
            ),
            const SizedBox(height: 20),
            const Text(
              'Пол',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            _DropdownBox<String>(
              value: _gender,
              items: const ['male', 'female'],
              itemLabel: _genderLabel,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _gender = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Хобби',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            _ChipContainer(
              children: _hobbies
                  .map(
                    (hobby) => _SelectableChip(
                  label: _hobbyLabel(hobby),
                  selected: _selectedHobby == hobby,
                  onTap: () {
                    setState(() {
                      _selectedHobby = hobby;
                    });
                  },
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Аллергия',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            _ChipContainer(
              children: _allergies
                  .map(
                    (allergy) => _SelectableChip(
                  label: _allergyLabel(allergy),
                  selected: _selectedAllergy == allergy,
                  onTap: () {
                    setState(() {
                      _selectedAllergy = allergy;
                    });
                  },
                ),
              )
                  .toList(),
            ),
            if (_serverError != null) ...[
              const SizedBox(height: 14),
              Text(
                _serverError!,
                style: const TextStyle(
                  color: Color(0xFFE53935),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 34),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF3D),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFA5D6A7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
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
                    : Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F1F1),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}

class _ChildAvatar extends StatelessWidget {
  final String? photoUrl;

  const _ChildAvatar({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 132,
        height: 132,
        child: photoUrl != null && photoUrl!.isNotEmpty
            ? Image.network(
          photoUrl!,
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
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _LabeledTextField({
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE7E7E7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
            ),
          ),
        ),
      ],
    );
  }
}

class _LabeledDateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;

  const _LabeledDateField({
    required this.label,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            suffixIcon: const Icon(Icons.calendar_today_outlined),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE7E7E7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownBox<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T value) itemLabel;
  final ValueChanged<T?> onChanged;

  const _DropdownBox({
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ChipContainer extends StatelessWidget {
  final List<Widget> children;

  const _ChipContainer({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 12,
        children: children,
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF5FFF4) : const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? const Color(0xFF4CAF3D) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: selected ? const Color(0xFF2F7D2D) : const Color(0xFF333333),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}