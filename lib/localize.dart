import 'dart:async';

import 'package:dingdrink/catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter_localizations/flutter_localizations.dart';
String globalLanguage="fr";
String appLanguage="fr";
BuildContext globalLocContext;

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    //globalLocContext = context;
    //globalLanguage = AppLocalizations.of(context).locale.languageCode;
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      'updateApp': 'Veuillez d\'abord installer la dernière version de l\'application DingDrink sur https://it-cs.be/dingdrink/install',
      'updateAppTitle': 'Mise à jour nécessaire',
      // catalog texts
      'mapSelectionTitle': 'Choix de la carte',
      'selectMapDetail': 'Tapez sur la première icone pour sélectionner une carte',
      'catalogTitle': 'Carte',
      'firstLetters': 'Tapez les premières lettres du lieu',
      'selectMap': 'Sélectionnez la carte des consommations avec l\'icone ici à droite',
      //cart
      'enterTable': 'Indiquez votre table',
      'enterName': 'Et votre nom',
      'totalPrice': 'A payer',
      'backToCatalog': '<-Retour à la carte',
      'doOrder': 'Passer commande',
      //order
      'alert1': 'Merci pour votre commande',
      'alert2' : 'Votre commande N° ',
      'alert3' : ' a été transmise et vous serez averti dès qu\'elle sera prête',
      'alert4' : 'Désolé',
      'alert5' : 'Les commandes ne sont pas possibles pour l\'instant'

    },
    'nl': {
      'updateApp': 'Gelieve eerst de alerlaatste versie van de app DingDrink te installeren op https://it-cs.be/dingdrink/install',
      'updateAppTitle': 'update vereist ',
      // catalog texts
      'mapSelectionTitle': 'Kies de Kaart',
      'selectMapDetail': 'Tap op het eerste icoontje om een kaart te selecteren',
      'catalogTitle': 'Kaart',
      'firstLetters': 'Tijp de eerste letters van de plaats',
      'selectMap': 'Selecteer de kaart met het icoontje hier rechts',
      //cart
      'enterTable': 'Tijp de tafel naam',
      'enterName': 'en uw nom',
      'totalPrice': 'Te betalen',
      'backToCatalog': '<-Terug naar de kaart',
      'doOrder': 'Bestellen',
      //order
      'alert1': 'Bedankt voor uw bestelling',
      'alert2' : 'Uw bestelling N° ',
      'alert3' : '  is doorgestuurd. U wordt op de hoogte gebracht zodra deze klaar is',
      'alert4' : 'Sorry',
      'alert5' : 'Bestellingen zijn momenteel niet mogelijk.'


    },
  };

  String localized(myVariable){
    return _localizedValues[locale.languageCode][myVariable];
  }
 /* String get catalogTitle {
    return _localizedValues[locale.languageCode]['catalogTitle'];
  }
  String get selectMap {
    return _localizedValues[locale.languageCode]['selectMap'];
  }
  String get alert1 {
    return _localizedValues[locale.languageCode]['alert1'];
  }
  String get alert2 {
    return _localizedValues[locale.languageCode]['alert2'];
  }  String get alert3 {
    return _localizedValues[locale.languageCode]['alert3'];
  }
 */

}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['fr', 'nl'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of AppLocalizations.
    appLanguage = locale.languageCode;
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

