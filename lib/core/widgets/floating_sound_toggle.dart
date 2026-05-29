import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization.dart';
import '../app_controllers.dart';
import '../sound/game_sound_controller.dart';
import 'figma_game_icons.dart';

class FloatingSoundToggle extends ConsumerWidget {
  const FloatingSoundToggle({
    this.accentColor = const Color(0xFF4FC3F7),
    this.borderColor = const Color(0xFF0D47A1),
    super.key,
  });

  final Color accentColor;
  final Color borderColor;

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
                        ? [
                            accentColor,
                            borderColor,
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
                    color: soundEnabled ? borderColor : const Color(0xFF757575),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (soundEnabled ? borderColor : Colors.black)
                          .withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: FigmaSpeakerIcon(
                    size: 20,
                    color: Colors.white,
                    muted: !soundEnabled,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
