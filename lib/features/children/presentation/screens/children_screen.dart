import 'package:flutter/material.dart';
import '../../../../app/router.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/models/child_model.dart';

class ChildrenScreen extends StatefulWidget {
  const ChildrenScreen({super.key});

  @override
  State<ChildrenScreen> createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends State<ChildrenScreen> {
  bool _isLoading = true;
  String? _error;
  List<ChildModel> _children = [];

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final children = await ServiceLocator.childrenApiService.getChildren();

      if (!mounted) return;
      setState(() {
        _children = children;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openCreateChild() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.addChild,
    );

    if (!mounted) return;

    if (result is ChildModel) {
      setState(() {
        _children.add(result);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ребёнок успешно добавлен')),
      );
    }
  }

  Future<void> _openEditChild(ChildModel child) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.editChild,
      arguments: child,
    );

    if (!mounted) return;

    if (result is ChildModel) {
      setState(() {
        final index = _children.indexWhere((e) => e.id == result.id);
        if (index != -1) {
          _children[index] = result;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профиль ребёнка обновлён')),
      );
    }
  }

  Future<void> _deleteChild(ChildModel child) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeleteChildSheet(childName: child.fullName),
    );

    if (confirmed != true) return;

    try {
      await ServiceLocator.childrenApiService.deleteChild(child.id);

      if (!mounted) return;
      setState(() {
        _children.removeWhere((e) => e.id == child.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ребёнок удалён')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось удалить ребёнка')),
      );
    }
  }

  void _showChildActions(ChildModel child) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChildActionsSheet(
        onEdit: () {
          Navigator.pop(context);
          _openEditChild(child);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteChild(child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasChildren = _children.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/splash_tents.png',
                fit: BoxFit.cover,
                height: 220,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Row(
                    children: [
                      _CircleButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Дети',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      _CircleButton(
                        icon: Icons.add,
                        onTap: _openCreateChild,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadChildren,
                    child: _buildBody(hasChildren),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool hasChildren) {
    if (_isLoading) {
      return const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(top: 120),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_error != null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              _error!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadChildren,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (!hasChildren) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 180,
          child: _EmptyChildrenState(onAddTap: _openCreateChild),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 180),
      itemCount: _children.length,
      itemBuilder: (context, index) {
        final child = _children[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: _ChildTile(
            child: child,
            onMoreTap: () => _showChildActions(child),
          ),
        );
      },
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
          child: Icon(
            icon,
            size: 18,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class _ChildTile extends StatelessWidget {
  final ChildModel child;
  final VoidCallback onMoreTap;

  const _ChildTile({
    required this.child,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Row(
        children: [
          _ChildAvatar(photoUrl: child.photoUrl),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              child.fullName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          IconButton(
            onPressed: onMoreTap,
            icon: const Icon(Icons.more_vert),
          ),
        ],
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
        width: 46,
        height: 46,
        child: photoUrl != null && photoUrl!.isNotEmpty
            ? Image.network(
          photoUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFD9D9D9),
            alignment: Alignment.center,
            child: const Icon(Icons.person, color: Colors.white),
          ),
        )
            : Container(
          color: const Color(0xFFD9D9D9),
          alignment: Alignment.center,
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ),
    );
  }
}

class _EmptyChildrenState extends StatelessWidget {
  final VoidCallback onAddTap;

  const _EmptyChildrenState({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF17A34A)),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icons/children_empty_icon.png',
                  width: 44,
                  height: 44,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.group_add_outlined,
                    size: 48,
                    color: Color(0xFF17A34A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Добавить ребёнка',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Добавить профиль своего ребёнка.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF7A7A7A),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 188,
              height: 48,
              child: ElevatedButton(
                onPressed: onAddTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF3D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Добавить',
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
    );
  }
}

class _ChildActionsSheet extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ChildActionsSheet({
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: _CircleButton(
                icon: Icons.close,
                onTap: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Center(
                child: Text(
                  'Редактировать',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              onTap: onEdit,
            ),
            const Divider(),
            ListTile(
              title: const Center(
                child: Text(
                  'Удалить',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteChildSheet extends StatelessWidget {
  final String childName;

  const _DeleteChildSheet({required this.childName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Удалить профиль ребёнка',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Удалить профиль ребёнка и данные о лагере?\nДействие необратимо.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF7A7A7A),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4CAF3D),
                      side: const BorderSide(color: Color(0xFF4CAF3D)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Text(
                      'Отмена',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF3D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Text(
                      'Да',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}