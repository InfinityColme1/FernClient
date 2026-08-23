import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/l10n/app_localizations.dart';

/// Qué parte de lo pendiente de revisar se enseña.
///
/// Revisar una importación de trescientos contenidos es dos trabajos distintos y
/// se hacen por separado: primero se despacha lo que los modelos ya han
/// propuesto, y después se mira a mano lo que nadie ha mirado todavía. Sin poder
/// separarlos, los dos se hacen a la vez y mal.
enum SuggestionFilter {
  /// Todo lo que hay pendiente de revisar.
  all,

  /// Sólo lo que tiene algo propuesto sin contestar.
  withSuggestions,

  /// Sólo lo que ningún modelo ha mirado nunca.
  ///
  /// No es «lo que no tiene sugerencias»: un contenido mirado al que no se le
  /// encontró nada ya está hecho, y volver a enseñarlo aquí es pedir que se
  /// revise dos veces lo mismo.
  neverRecognised;

  String label(AppLocalizations texts) => switch (this) {
        SuggestionFilter.all => texts.suggestionFilterAll,
        SuggestionFilter.withSuggestions => texts.suggestionFilterWith,
        SuggestionFilter.neverRecognised => texts.suggestionFilterNever,
      };

  /// Si este contenido entra con el filtro puesto.
  bool matches(MediaSummaryEntity media) => switch (this) {
        SuggestionFilter.all => true,
        SuggestionFilter.withSuggestions => media.hasPendingSuggestions,
        SuggestionFilter.neverRecognised => media.recognizedAt == null,
      };
}
