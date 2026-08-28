import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/recognition/data/services/recognition_engine.dart';
import 'package:Fern/features/recognition/data/services/sidecar_failure.dart';
import 'package:Fern/features/recognition/data/services/sidecar_provisioner.dart';
import 'package:Fern/features/recognition/presentation/widgets/confirm_gpu_dialog.dart';
import 'package:Fern/features/recognition/presentation/widgets/sidecar_activity_text.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Con qué se instala el entorno desde cero.
enum _InstallTarget { cpu, gpu }

/// Cómo se cuenta en pantalla cada paso de la instalación.
extension SidecarSetupStageLabels on SidecarSetupStage {
  String label(AppLocalizations texts) => switch (this) {
        SidecarSetupStage.notInstalled => texts.sidecarNotInstalled,
        SidecarSetupStage.downloadingUv => texts.sidecarDownloadingUv,
        SidecarSetupStage.installingPython => texts.sidecarInstallingPython,
        SidecarSetupStage.creatingVenv => texts.sidecarCreatingVenv,
        SidecarSetupStage.detectingHardware => texts.sidecarDetectingHardware,
        SidecarSetupStage.installingTorch => texts.sidecarInstallingTorch,
        SidecarSetupStage.installingUltralytics =>
          texts.sidecarInstallingUltralytics,
        SidecarSetupStage.cleaning => texts.sidecarCleaning,
        SidecarSetupStage.verifying => texts.sidecarVerifying,
        SidecarSetupStage.ready => texts.sidecarReady,
        SidecarSetupStage.error => texts.sidecarError,
      };
}

/// El entorno con el que FeRN entrena y reconoce: en qué estado está y el botón
/// de instalarlo.
///
/// Se instala cuando el usuario lo pide, nunca por su cuenta: es una descarga
/// grande y hay que decir cuánto ocupa antes de empezar.
class SidecarSetupPanel extends StatefulWidget {
  const SidecarSetupPanel({super.key});

  @override
  State<SidecarSetupPanel> createState() => _SidecarSetupPanelState();
}

class _SidecarSetupPanelState extends State<SidecarSetupPanel> {
  final _engine = getIt<RecognitionEngine>();

  Map<String, dynamic>? _info;
  bool _showLog = false;

  @override
  void initState() {
    super.initState();
    _refreshInfo();
  }

  /// Si el entorno ya está montado, se le pregunta con qué va a calcular: es lo
  /// que dice si va a ir por tarjeta gráfica o por procesador.
  ///
  /// Y se le suelta en cuanto contesta: preguntar arranca el proceso de Python,
  /// que tiene abiertos los ficheros de su propio entorno. Dejarlo vivo por si
  /// acaso es lo que impedía después reinstalar o cambiar a la tarjeta gráfica.
  Future<void> _refreshInfo() async {
    if (!_engine.isReady) return;

    try {
      final info = await _engine.environmentInfo();
      if (mounted) setState(() => _info = info);
    } on Object {
      return;
    } finally {
      await _engine.stop();
    }
  }

  Future<void> _install() async {
    await _engine.install();
    await _refreshInfo();
  }

  Future<void> _switchAcceleration({required bool withCuda}) async {
    await _engine.switchAcceleration(withCuda: withCuda);
    await _refreshInfo();
  }

  /// Instalar de cero, eligiendo con qué. La versión de tarjeta gráfica avisa
  /// antes de empezar: son varios gigas más.
  Future<void> _onInstallSelected(_InstallTarget target) async {
    if (target == _InstallTarget.cpu) return _install();

    final confirmed = await askForGpuInstall(context);
    if (confirmed != true) return;

    await _engine.install(withCuda: true);
    await _refreshInfo();
  }

  Future<void> _askAndEnableGpu() async {
    final confirmed = await askForGpuInstall(context);
    if (confirmed != true) return;

    await _switchAcceleration(withCuda: true);
  }

  Future<void> _reset() async {
    await _engine.reset();
    if (mounted) setState(() => _info = null);
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final provisioner = _engine.provisioner;

    if (provisioner == null) {
      return _description(context, texts.sidecarUnsupportedPlatform);
    }

    return StreamBuilder<SidecarSetupState>(
      stream: provisioner.changes,
      initialData: provisioner.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const SidecarSetupState();
        // El estado en memoria arranca en "sin instalar" aunque el entorno ya
        // estuviera montado de una sesión anterior: el disco manda.
        final stage = state.stage == SidecarSetupStage.notInstalled &&
                provisioner.isReady
            ? SidecarSetupStage.ready
            : state.stage;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(context, texts.sidecarTitle),
            _description(context, texts.sidecarDescription),
            const SizedBox(height: AppSpacing.l),
            _statusRow(context, texts, stage),
            if (stage.isWorking) ...[
              const SizedBox(height: AppSpacing.s),
              // El porcentaje va encima y a la derecha de la barra, que es donde
              // se busca.
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  texts.sidecarPercent((state.overallProgress * 100).round()),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: context.colors.gray),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              LinearProgressIndicator(value: state.overallProgress),
              const SizedBox(height: AppSpacing.s),
              const SidecarActivityText(),
              if (state.total != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: _description(
                    context,
                    texts.sidecarDownloaded(
                      _megabytes(state.received),
                      _megabytes(state.total!),
                    ),
                  ),
                ),
            ],
            if (state.failure case final failure?
                when stage == SidecarSetupStage.error) ...[
              const SizedBox(height: AppSpacing.m),
              _failureCard(context, texts, failure),
            ],
            if (_info != null) ...[
              const SizedBox(height: AppSpacing.m),
              _description(context, _environmentSummary()),
            ],
            const SizedBox(height: AppSpacing.l),
            Wrap(
              spacing: AppSpacing.m,
              runSpacing: AppSpacing.s,
              children: [
                // Instalar es un desplegable y no un botón: quien ya sabe que
                // quiere tarjeta gráfica no tiene por qué instalar primero la
                // versión de procesador y cambiarla después.
                FernPopupMenu<_InstallTarget>(
                  options: [
                    FernMenuOption(
                      value: _InstallTarget.cpu,
                      label: texts.sidecarInstallCpu,
                      icon: Symbols.memory,
                    ),
                    FernMenuOption(
                      value: _InstallTarget.gpu,
                      label: texts.sidecarInstallGpu,
                      icon: Symbols.bolt,
                    ),
                  ],
                  onSelected: _onInstallSelected,
                  builder: (context, toggle) => FernPillButton(
                    label: stage == SidecarSetupStage.ready
                        ? texts.sidecarReinstall
                        : texts.sidecarInstall,
                    icon: Symbols.download,
                    backgroundColor: context.colors.primary,
                    foregroundColor: context.colors.black,
                    onPressed: stage.isWorking ? null : toggle,
                  ),
                ),
                // Y con el entorno ya montado se puede cambiar de motor sin
                // rehacerlo, en los dos sentidos.
                if (stage == SidecarSetupStage.ready && _isOnCpu)
                  FernPillButton(
                    label: texts.sidecarEnableGpu,
                    icon: Symbols.bolt,
                    backgroundColor: context.colors.secondary,
                    foregroundColor: context.colors.black,
                    onPressed: stage.isWorking ? null : _askAndEnableGpu,
                  ),
                if (stage == SidecarSetupStage.ready && _isOnGpu)
                  FernPillButton(
                    label: texts.sidecarEnableCpu,
                    icon: Symbols.memory,
                    backgroundColor: context.colors.secondary,
                    foregroundColor: context.colors.black,
                    onPressed: stage.isWorking
                        ? null
                        : () => _switchAcceleration(withCuda: false),
                  ),
                FernPillButton(
                  label: texts.sidecarUninstall,
                  icon: Symbols.delete,
                  backgroundColor: context.colors.error,
                  foregroundColor: context.colors.white,
                  onPressed: stage.isWorking ? null : _reset,
                ),
              ],
            ),
            if (state.log.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.m),
              TextButton(
                onPressed: () => setState(() => _showLog = !_showLog),
                child: Text(
                  _showLog ? texts.sidecarHideLog : texts.sidecarShowLog,
                ),
              ),
              if (_showLog)
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    maxHeight: AppSizes.sidecarLogHeight,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: context.colors.lightgray,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      state.log.join('\n'),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  /// Qué ha pasado y qué puede hacer el usuario, en su idioma y sin jerga.
  ///
  /// El detalle técnico no se enseña aquí: se queda en el registro plegable, que
  /// es donde sirve cuando hay que contar el fallo, y no en la cara de quien
  /// sólo quería instalar el reconocimiento.
  Widget _failureCard(
    BuildContext context,
    AppLocalizations texts,
    SidecarFailure failure,
  ) {
    final (what, how) = switch (failure.kind) {
      SidecarFailureKind.filesInUse => (
          texts.sidecarFailureInUse,
          texts.sidecarFailureInUseHint,
        ),
      SidecarFailureKind.notEnoughSpace => (
          texts.sidecarFailureSpace,
          texts.sidecarFailureSpaceHint,
        ),
      SidecarFailureKind.network => (
          texts.sidecarFailureNetwork,
          texts.sidecarFailureNetworkHint,
        ),
      SidecarFailureKind.blocked => (
          texts.sidecarFailureBlocked,
          texts.sidecarFailureBlockedHint,
        ),
      SidecarFailureKind.missingPiece => (
          texts.sidecarFailureMissing,
          texts.sidecarFailureMissingHint,
        ),
      SidecarFailureKind.unknown => (
          texts.sidecarFailureUnknown,
          texts.sidecarFailureUnknownHint,
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: context.colors.error.withValues(alpha: sidecarFailureTint),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(what, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            how,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: context.colors.gray),
          ),
        ],
      ),
    );
  }

  /// Con qué está calculando ahora mismo el entorno instalado.
  ///
  /// En los Mac con Apple Silicon devuelve `mps`, así que no sale ninguno de los
  /// dos botones: ya viene acelerado y no hay nada que descargar.
  bool get _isOnCpu => _info?['device'] == 'cpu';

  bool get _isOnGpu => (_info?['device'] as String?)?.startsWith('cuda') ?? false;

  String _environmentSummary() {
    final info = _info;
    if (info == null) return '';

    final parts = <String>[
      if (info['python'] != null) 'Python ${info['python']}',
      if (info['torch'] != null) 'torch ${info['torch']}',
      if (info['ultralytics'] != null) 'ultralytics ${info['ultralytics']}',
      if (info['device_name'] != null)
        '${info['device_name']} (${info['device']})',
    ];

    return parts.join(' · ');
  }

  String _megabytes(int bytes) => (bytes / (1024 * 1024)).toStringAsFixed(1);

  Widget _statusRow(
    BuildContext context,
    AppLocalizations texts,
    SidecarSetupStage stage,
  ) {
    final (icon, color) = switch (stage) {
      SidecarSetupStage.ready => (Symbols.check_circle, context.colors.terciary),
      SidecarSetupStage.error => (Symbols.error, context.colors.error),
      _ => (Symbols.info, context.colors.gray),
    };

    return Row(
      children: [
        Icon(icon, size: AppSizes.iconMedium, color: color),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Text(
            stage.label(texts),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _title(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _description(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(color: context.colors.gray),
    );
  }
}
