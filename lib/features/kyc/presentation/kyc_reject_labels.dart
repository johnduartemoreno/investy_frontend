import '../../../l10n/app_localizations.dart';

/// Translates Sumsub's machine-readable `rejectLabels` into copy a person can
/// act on.
///
/// A rejection the user cannot understand is barely better than no rejection at
/// all: "UNSATISFACTORY_PHOTOS" tells them nothing about what to redo. Showing
/// the raw code would also violate the project rule that backend codes are
/// mapped to .arb keys and never rendered directly.
///
/// The set of labels is Sumsub's and open-ended, so an unknown one falls back
/// to a generic line rather than being dropped or shown raw — the user still
/// learns there was a problem with their documents.
class KycRejectLabels {
  const KycRejectLabels._();

  /// Maps labels to their translated line, de-duplicated and in a stable order.
  /// Returns an empty list when there is nothing specific to say, so the caller
  /// can omit the whole section instead of rendering an empty header.
  static List<String> describe(
    List<String> labels,
    AppLocalizations l10n,
  ) {
    final out = <String>[];
    var sawUnknown = false;

    for (final label in labels) {
      final text = _translate(label.toUpperCase(), l10n);
      if (text == null) {
        sawUnknown = true;
        continue;
      }
      if (!out.contains(text)) out.add(text);
    }

    // One generic line for any number of unrecognized labels — repeating it
    // per unknown code would just look broken.
    if (sawUnknown && out.isEmpty) {
      out.add(l10n.kycRejectLabelGeneric);
    }
    return out;
  }

  /// Returns null for a label we have no copy for.
  static String? _translate(String label, AppLocalizations l10n) {
    switch (label) {
      case 'UNSATISFACTORY_PHOTOS':
      case 'BAD_PHOTO_QUALITY':
      case 'LOW_QUALITY':
        return l10n.kycRejectLabelBadPhoto;
      case 'SCREENSHOTS':
      case 'BLACK_AND_WHITE':
        return l10n.kycRejectLabelScreenshot;
      case 'BAD_SELFIE':
      case 'SELFIE_WITH_PAPER':
      case 'UNSATISFACTORY_SELFIE':
        return l10n.kycRejectLabelSelfie;
      case 'DOCUMENT_MISSING':
      case 'INCOMPLETE_DOCUMENT':
      case 'DOCUMENT_PAGE_MISSING':
        return l10n.kycRejectLabelDocumentMissing;
      case 'EXPIRATION_DATE':
      case 'EXPIRED_DOCUMENT':
        return l10n.kycRejectLabelExpired;
      case 'REQUESTED_DATA_MISMATCH':
      case 'PROBLEMATIC_APPLICANT_DATA':
      case 'INCORRECT_SOCIAL_NUMBER':
        return l10n.kycRejectLabelDataMismatch;
      case 'GRAPHIC_EDITOR':
      case 'DOCUMENT_DAMAGED':
        return l10n.kycRejectLabelEdited;
      case 'UNSUITABLE_ENV':
      case 'BAD_AVATAR':
        return l10n.kycRejectLabelEnvironment;
      default:
        return null;
    }
  }
}
