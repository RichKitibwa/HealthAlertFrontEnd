// Resolve LocationResult errors to localized messages for display in the UI.

import 'location_utils.dart';
import '../../l10n/app_localizations.dart';

/// Returns a localized message for the given [result] using [l10n].
/// Use this when displaying location errors to the user (e.g. SnackBar, dialog).
String localizedLocationErrorMessage(LocationResult result, AppLocalizations l10n) {
  if (result.success || result.errorCode == null) {
    return result.error ?? l10n.locationUnknownError;
  }
  switch (result.errorCode!) {
    case LocationErrorCode.locationServicesDisabled:
      return l10n.locationServicesDisabled;
    case LocationErrorCode.locationPermissionDenied:
      return l10n.locationPermissionDenied;
    case LocationErrorCode.locationPermissionDeniedForever:
      return l10n.locationPermissionDeniedForever;
    case LocationErrorCode.locationTimeout:
      return l10n.locationRequestTimeout;
    case LocationErrorCode.locationUnknown:
    default:
      return result.error ?? l10n.locationUnknownError;
  }
}
