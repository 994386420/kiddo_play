import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization.dart';
import '../app_controllers.dart';
import '../sound/game_sound_controller.dart';

class FloatingSoundToggle extends ConsumerWidget {
  const FloatingSoundToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundEnabled = ref.watch(
      parentDataProvider.select((parentData) => parentData.soundEnabled),
    );

    return SafeArea(
      minimum: const EdgeInsets.only(right: 16, bottom: 20),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Tooltip(
          message: soundEnabled
              ? context.l10n.soundOffTooltip
              : context.l10n.soundOnTooltip,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () async {
                final parentData = ref.read(parentDataProvider);
                final soundController = ref.read(gameSoundControllerProvider);

                if (soundEnabled) {
                  await soundController.playClick();
                  await parentData.setSoundEnabled(false);
                } else {
                  await parentData.setSoundEnabled(true);
                  await soundController.playClick();
                }
              },
              child: Ink(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: soundEnabled
                        ? const [
                            Color(0xFF4FC3F7),
                            Color(0xFF1976D2),
                          ]
                        : const [
                            Color(0xFFBDBDBD),
                            Color(0xFF9E9E9E),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: soundEnabled
                        ? const Color(0xFF0D47A1)
                        : const Color(0xFF757575),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  soundEnabled
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
