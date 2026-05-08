import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization.dart';
import '../../app/route_args.dart';
import '../../app/router.dart';
import '../../core/app_controllers.dart';
import '../../core/widgets/kid_motion.dart';

enum _PinMode {
  verify,
  setupNew,
  setupConfirm,
  changeNew,
  changeConfirm,
}

class ParentPinPage extends ConsumerStatefulWidget {
  const ParentPinPage({
    required this.args,
    super.key,
  });

  final ParentPinRouteArgs args;

  @override
  ConsumerState<ParentPinPage> createState() => _ParentPinPageState();
}

class _ParentPinPageState extends ConsumerState<ParentPinPage> {
  static const _numpad = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', '⌫'],
  ];

  late _PinMode _mode;
  List<String> _digits = [];
  List<String> _firstEntry = [];
  bool _shake = false;
  String? _errorMessage;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    final parentData = ref.read(parentDataProvider);
    if (widget.args.changeMode) {
      _mode = _PinMode.changeNew;
    } else {
      _mode = parentData.isPinSet ? _PinMode.verify : _PinMode.setupNew;
    }
  }

  void _handleDigit(String key) {
    if (_success) return;

    if (key == '⌫') {
      setState(() {
        _digits = _digits.take(_digits.length - 1).toList();
        _errorMessage = null;
      });
      return;
    }

    if (_digits.length >= 4) return;

    final nextDigits = [..._digits, key];
    setState(() {
      _digits = nextDigits;
      _errorMessage = null;
    });

    if (nextDigits.length == 4) {
      Future<void>.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _handleComplete(nextDigits);
        }
      });
    }
  }

  Future<void> _handleComplete(List<String> entered) async {
    final pin = entered.join();
    final parentData = ref.read(parentDataProvider);

    switch (_mode) {
      case _PinMode.verify:
        if (parentData.verifyPin(pin)) {
          setState(() => _success = true);
          await Future<void>.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.parentDashboard,
            );
          }
        } else {
          _triggerError(context.l10n.parentPinErrorWrong);
        }
      case _PinMode.setupNew:
        setState(() {
          _firstEntry = entered;
          _digits = [];
          _mode = _PinMode.setupConfirm;
        });
      case _PinMode.setupConfirm:
        if (pin == _firstEntry.join()) {
          await parentData.setParentPin(pin);
          setState(() => _success = true);
          await Future<void>.delayed(const Duration(milliseconds: 600));
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.parentDashboard,
            );
          }
        } else {
          _triggerError(context.l10n.parentPinErrorMismatch);
          setState(() {
            _firstEntry = [];
            _mode = _PinMode.setupNew;
          });
        }
      case _PinMode.changeNew:
        setState(() {
          _firstEntry = entered;
          _digits = [];
          _mode = _PinMode.changeConfirm;
        });
      case _PinMode.changeConfirm:
        if (pin == _firstEntry.join()) {
          await parentData.setParentPin(pin);
          setState(() => _success = true);
          await Future<void>.delayed(const Duration(milliseconds: 600));
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.parentDashboard,
            );
          }
        } else {
          _triggerError(context.l10n.parentPinErrorMismatch);
          setState(() {
            _firstEntry = [];
            _mode = _PinMode.changeNew;
          });
        }
    }
  }

  void _triggerError(String message) {
    setState(() {
      _errorMessage = message;
      _shake = true;
      _digits = [];
    });

    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _shake = false);
      }
    });
  }

  String _title(BuildContext context) {
    final l10n = context.l10n;
    return switch (_mode) {
      _PinMode.verify => l10n.parentPinTitleVerify,
      _PinMode.setupNew => l10n.parentPinTitleSetup,
      _PinMode.setupConfirm => l10n.parentPinTitleConfirm,
      _PinMode.changeNew => l10n.parentPinTitleChange,
      _PinMode.changeConfirm => l10n.parentPinTitleChangeConfirm,
    };
  }

  String _subtitle(BuildContext context) {
    final l10n = context.l10n;
    return switch (_mode) {
      _PinMode.verify => l10n.parentPinSubtitleVerify,
      _PinMode.setupNew => l10n.parentPinSubtitleSetup,
      _PinMode.setupConfirm => l10n.parentPinSubtitleConfirm,
      _PinMode.changeNew => l10n.parentPinSubtitleChange,
      _PinMode.changeConfirm => l10n.parentPinSubtitleChangeConfirm,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final parentData = ref.watch(parentDataProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEDE7F6),
              Color(0xFFE3F2FD),
              Color(0xFFF3E5F5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: Column(
                  children: [
                    KidDelayedReveal(
                      child: Row(
                        children: [
                          Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: () => Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.home,
                              ),
                              child: Ink(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: const Color(0xFFCE93D8),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.chevron_left_rounded,
                                  color: Color(0xFF7B1FA2),
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _title(context),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4A148C),
                              ),
                            ),
                          ),
                          const SizedBox(width: 42),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    KidDelayedReveal(
                      delay: const Duration(milliseconds: 120),
                      beginScale: 0.7,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1),
                        duration: const Duration(milliseconds: 400),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: _success ? value : 1,
                            child: child,
                          );
                        },
                        child: Text(
                          _success ? '🔓' : '🔒',
                          style: const TextStyle(fontSize: 64),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    KidDelayedReveal(
                      delay: const Duration(milliseconds: 180),
                      child: Text(
                        _subtitle(context),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7B5BA6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    KidDelayedReveal(
                      delay: const Duration(milliseconds: 260),
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey(_shake),
                        tween: Tween(begin: 0, end: _shake ? 1 : 0),
                        duration: Duration(milliseconds: _shake ? 400 : 1),
                        builder: (context, value, child) {
                          final dx = _shake
                              ? (value * 6 - value * value * 6) *
                                  20 *
                                  (value < 0.5 ? -1 : 1)
                              : 0.0;
                          return Transform.translate(
                            offset: Offset(dx, 0),
                            child: child,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            final filled = _digits.length > index;
                            return Padding(
                              padding:
                                  EdgeInsets.only(right: index == 3 ? 0 : 20),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: filled
                                      ? const Color(0xFF7B1FA2)
                                      : const Color(0xFFE1BEE7),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFCE93D8),
                                    width: 2.5,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: _errorMessage == null
                          ? const SizedBox(height: 24)
                          : Padding(
                              key: ValueKey(_errorMessage),
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFE53935),
                                ),
                              ),
                            ),
                    ),
                    if (_success)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          l10n.parentPinSuccess,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    KidDelayedReveal(
                      delay: const Duration(milliseconds: 320),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _numpad.expand((row) => row).length,
                        padding: const EdgeInsets.only(top: 8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                        itemBuilder: (context, index) {
                          final value =
                              _numpad.expand((row) => row).toList()[index];
                          if (value.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final isDelete = value == '⌫';
                          return Material(
                            color: isDelete
                                ? const Color(0xFFFCE4EC)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _handleDigit(value),
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDelete
                                        ? const Color(0xFFF48FB1)
                                        : const Color(0xFFE1BEE7),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: isDelete
                                      ? const Icon(
                                          Icons.backspace_outlined,
                                          color: Color(0xFFC2185B),
                                        )
                                      : Text(
                                          value,
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF4A148C),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_mode == _PinMode.verify)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Text(
                          l10n.parentPinDefaultHint(
                              parentData.storedOrDefaultPin),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                    if (_mode == _PinMode.setupNew)
                      KidDelayedReveal(
                        delay: const Duration(milliseconds: 420),
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: const Color(0xFFCE93D8),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            l10n.parentPinSetupHint,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7B5BA6),
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
