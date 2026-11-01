import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../models/business_profile.dart';

String tradeLabel(AppLocalizations l10n, UstaTrade t) => switch (t) {
      UstaTrade.elektrik => l10n.tradeElektrik,
      UstaTrade.elektrikLoyihachi => l10n.tradeElektrikLoyihachi,
      UstaTrade.santexnik => l10n.tradeSantexnik,
      UstaTrade.malyar => l10n.tradeMalyar,
      UstaTrade.oboy => l10n.tradeOboy,
      UstaTrade.laminat => l10n.tradeLaminat,
      UstaTrade.brigada => l10n.tradeBrigada,
      UstaTrade.plitkachi => l10n.tradePlitkachi,
      UstaTrade.shtukatur => l10n.tradeShtukatur,
      UstaTrade.gipsokartonchi => l10n.tradeGipsokartonchi,
      UstaTrade.eshikOyna => l10n.tradeEshikOyna,
      UstaTrade.isitishKonditsioner => l10n.tradeIsitishKonditsioner,
      UstaTrade.demontaj => l10n.tradeDemontaj,
    };

String statusLabel(AppLocalizations l10n, ModerationStatus s) => switch (s) {
      ModerationStatus.pending => l10n.businessStatusPending,
      ModerationStatus.approved => l10n.businessStatusApproved,
      ModerationStatus.rejected => l10n.businessStatusRejected,
    };

/// Digits only, at most 12 of them (under a trillion so'm). Without the cap a
/// longer number did not fit an int, `int.tryParse` gave null and the price
/// was saved as "not given" without a word.
final priceInputFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(12),
];
