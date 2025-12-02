import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @mold.
  ///
  /// In en, this message translates to:
  /// **'Mold'**
  String get mold;

  /// No description provided for @molding.
  ///
  /// In en, this message translates to:
  /// **'Molding'**
  String get molding;

  /// No description provided for @tuft.
  ///
  /// In en, this message translates to:
  /// **'Tuft'**
  String get tuft;

  /// No description provided for @tufting.
  ///
  /// In en, this message translates to:
  /// **'Tufting'**
  String get tufting;

  /// No description provided for @blister.
  ///
  /// In en, this message translates to:
  /// **'Blister'**
  String get blister;

  /// No description provided for @blistering.
  ///
  /// In en, this message translates to:
  /// **'Blistering'**
  String get blistering;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @flexible.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get flexible;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get action;

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get systemSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @monitoring.
  ///
  /// In en, this message translates to:
  /// **'Monitoring'**
  String get monitoring;

  /// No description provided for @locationMa.
  ///
  /// In en, this message translates to:
  /// **'Location Management'**
  String get locationMa;

  /// No description provided for @monitoringDashboard.
  ///
  /// In en, this message translates to:
  /// **'Monitoring Dashboard'**
  String get monitoringDashboard;

  /// No description provided for @addDevice.
  ///
  /// In en, this message translates to:
  /// **'Add New Device'**
  String get addDevice;

  /// No description provided for @editDevice.
  ///
  /// In en, this message translates to:
  /// **'Edit Device'**
  String get editDevice;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @process.
  ///
  /// In en, this message translates to:
  /// **'Process'**
  String get process;

  /// No description provided for @moldcavity.
  ///
  /// In en, this message translates to:
  /// **'Mold Cavity'**
  String get moldcavity;

  /// No description provided for @moldca.
  ///
  /// In en, this message translates to:
  /// **'Mold Cav.'**
  String get moldca;

  /// No description provided for @actualcavity.
  ///
  /// In en, this message translates to:
  /// **'Actual Cavity'**
  String get actualcavity;

  /// No description provided for @actca.
  ///
  /// In en, this message translates to:
  /// **'Act. Cav.'**
  String get actca;

  /// No description provided for @capacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacity;

  /// No description provided for @efficiency.
  ///
  /// In en, this message translates to:
  /// **'Efficiency'**
  String get efficiency;

  /// No description provided for @effrequirement.
  ///
  /// In en, this message translates to:
  /// **'Eff.requirement'**
  String get effrequirement;

  /// No description provided for @currentcycle.
  ///
  /// In en, this message translates to:
  /// **'Current Cycle'**
  String get currentcycle;

  /// No description provided for @curcyc.
  ///
  /// In en, this message translates to:
  /// **'Cur. Cycle'**
  String get curcyc;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @upperlimit.
  ///
  /// In en, this message translates to:
  /// **'Upper Limit'**
  String get upperlimit;

  /// No description provided for @lowerlimit.
  ///
  /// In en, this message translates to:
  /// **'Lower Limit'**
  String get lowerlimit;

  /// No description provided for @rpm.
  ///
  /// In en, this message translates to:
  /// **'RPM'**
  String get rpm;

  /// No description provided for @brushesPerCycle.
  ///
  /// In en, this message translates to:
  /// **'Brushes/cycle'**
  String get brushesPerCycle;

  /// No description provided for @pcsMinute.
  ///
  /// In en, this message translates to:
  /// **'Pcs/minute'**
  String get pcsMinute;

  /// No description provided for @totallostpcs.
  ///
  /// In en, this message translates to:
  /// **'Total lost pcs'**
  String get totallostpcs;

  /// No description provided for @losttime.
  ///
  /// In en, this message translates to:
  /// **'Lost time'**
  String get losttime;

  /// No description provided for @shotcount.
  ///
  /// In en, this message translates to:
  /// **'Shot Count'**
  String get shotcount;

  /// No description provided for @totalrpm.
  ///
  /// In en, this message translates to:
  /// **'Total RPM'**
  String get totalrpm;

  /// No description provided for @totalcycle.
  ///
  /// In en, this message translates to:
  /// **'Total Cycle'**
  String get totalcycle;

  /// No description provided for @totalcount.
  ///
  /// In en, this message translates to:
  /// **'Total Count'**
  String get totalcount;

  /// No description provided for @nodata.
  ///
  /// In en, this message translates to:
  /// **'NO DATA'**
  String get nodata;

  /// No description provided for @addAction.
  ///
  /// In en, this message translates to:
  /// **'Add Action'**
  String get addAction;

  /// No description provided for @hourlyefficiency.
  ///
  /// In en, this message translates to:
  /// **'Hourly Efficiency'**
  String get hourlyefficiency;

  /// No description provided for @output.
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get output;

  /// No description provided for @towdayago.
  ///
  /// In en, this message translates to:
  /// **'2 day ago'**
  String get towdayago;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @fromdateline.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromdateline;

  /// No description provided for @todateline.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get todateline;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'SEARCH'**
  String get search;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'RESET'**
  String get reset;

  /// No description provided for @totaloutput.
  ///
  /// In en, this message translates to:
  /// **'Total Output'**
  String get totaloutput;

  /// No description provided for @averagecycle.
  ///
  /// In en, this message translates to:
  /// **'Average Cycle'**
  String get averagecycle;

  /// No description provided for @lossidletimereport.
  ///
  /// In en, this message translates to:
  /// **'Loss & Idle Time Report'**
  String get lossidletimereport;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @lostPcs.
  ///
  /// In en, this message translates to:
  /// **'Lost Pcs'**
  String get lostPcs;

  /// No description provided for @idleBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Idle/Breakdown(s)'**
  String get idleBreakdown;

  /// No description provided for @dateTime.
  ///
  /// In en, this message translates to:
  /// **'Date Time'**
  String get dateTime;

  /// No description provided for @averageOutput.
  ///
  /// In en, this message translates to:
  /// **'Average Output'**
  String get averageOutput;

  /// No description provided for @found.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get found;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'records'**
  String get records;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @pcs.
  ///
  /// In en, this message translates to:
  /// **'Pcs'**
  String get pcs;

  /// No description provided for @cycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get cycle;

  /// No description provided for @outputPcs.
  ///
  /// In en, this message translates to:
  /// **'Output (pcs)'**
  String get outputPcs;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'DATA NOT FOUND'**
  String get noDataFound;

  /// No description provided for @createnewaction.
  ///
  /// In en, this message translates to:
  /// **'Create new Action'**
  String get createnewaction;

  /// No description provided for @issueid.
  ///
  /// In en, this message translates to:
  /// **'Issue ID'**
  String get issueid;

  /// No description provided for @issuedescription.
  ///
  /// In en, this message translates to:
  /// **'Issue Description'**
  String get issuedescription;

  /// No description provided for @issuetype.
  ///
  /// In en, this message translates to:
  /// **'Issue Type'**
  String get issuetype;

  /// No description provided for @acteff.
  ///
  /// In en, this message translates to:
  /// **'Act. Eff.'**
  String get acteff;

  /// No description provided for @actcavity.
  ///
  /// In en, this message translates to:
  /// **'Act. Cavity'**
  String get actcavity;

  /// No description provided for @actcycle.
  ///
  /// In en, this message translates to:
  /// **'Act. Cycle'**
  String get actcycle;

  /// No description provided for @effrequired.
  ///
  /// In en, this message translates to:
  /// **'Eff. Req.'**
  String get effrequired;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @creator.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get creator;

  /// No description provided for @actionplans.
  ///
  /// In en, this message translates to:
  /// **'Action Plans'**
  String get actionplans;

  /// No description provided for @addplan.
  ///
  /// In en, this message translates to:
  /// **'Add Plan'**
  String get addplan;

  /// No description provided for @actionid.
  ///
  /// In en, this message translates to:
  /// **'Action ID'**
  String get actionid;

  /// No description provided for @plannedcompletiondate.
  ///
  /// In en, this message translates to:
  /// **'Planned completion date'**
  String get plannedcompletiondate;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @createaction.
  ///
  /// In en, this message translates to:
  /// **'Create Action'**
  String get createaction;

  /// No description provided for @example.
  ///
  /// In en, this message translates to:
  /// **'Example: John Doe'**
  String get example;

  /// No description provided for @emsdashboard.
  ///
  /// In en, this message translates to:
  /// **'EMS Dashboard'**
  String get emsdashboard;

  /// No description provided for @overall.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get overall;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @breakdown.
  ///
  /// In en, this message translates to:
  /// **'Breakdown'**
  String get breakdown;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @machineid.
  ///
  /// In en, this message translates to:
  /// **'Machine ID'**
  String get machineid;

  /// No description provided for @capacityhr.
  ///
  /// In en, this message translates to:
  /// **'Capacity/hr'**
  String get capacityhr;

  /// No description provided for @emsmonitoring.
  ///
  /// In en, this message translates to:
  /// **'EMS Monitoring'**
  String get emsmonitoring;

  /// No description provided for @machinedetails.
  ///
  /// In en, this message translates to:
  /// **'Machine Details'**
  String get machinedetails;

  /// No description provided for @efficiencyreport.
  ///
  /// In en, this message translates to:
  /// **'Efficiency Report'**
  String get efficiencyreport;

  /// No description provided for @outputreport.
  ///
  /// In en, this message translates to:
  /// **'Output Report'**
  String get outputreport;

  /// No description provided for @outputsummary.
  ///
  /// In en, this message translates to:
  /// **'Output Summary'**
  String get outputsummary;

  /// No description provided for @lostpcs.
  ///
  /// In en, this message translates to:
  /// **'Lost (pcs)'**
  String get lostpcs;

  /// No description provided for @allfamilies.
  ///
  /// In en, this message translates to:
  /// **'All Families'**
  String get allfamilies;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'SubTotal'**
  String get subtotal;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @dateshift.
  ///
  /// In en, this message translates to:
  /// **'Date Shift'**
  String get dateshift;

  /// No description provided for @nightshift.
  ///
  /// In en, this message translates to:
  /// **'Night Shift'**
  String get nightshift;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @sortoption.
  ///
  /// In en, this message translates to:
  /// **'Sort Options'**
  String get sortoption;

  /// No description provided for @selectfamily.
  ///
  /// In en, this message translates to:
  /// **'Select Family'**
  String get selectfamily;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @mgf.
  ///
  /// In en, this message translates to:
  /// **'Mgf.'**
  String get mgf;

  /// No description provided for @mgfdate.
  ///
  /// In en, this message translates to:
  /// **'Mgf. Date.'**
  String get mgfdate;

  /// No description provided for @cavities.
  ///
  /// In en, this message translates to:
  /// **'Cav.'**
  String get cavities;

  /// No description provided for @cap1h.
  ///
  /// In en, this message translates to:
  /// **'Cap.(1h)'**
  String get cap1h;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @hiscount.
  ///
  /// In en, this message translates to:
  /// **'His. Count'**
  String get hiscount;

  /// No description provided for @limit.
  ///
  /// In en, this message translates to:
  /// **'Limits'**
  String get limit;

  /// No description provided for @frecheckconnected.
  ///
  /// In en, this message translates to:
  /// **'Fre. Conn.(s)'**
  String get frecheckconnected;

  /// No description provided for @frechecklimit.
  ///
  /// In en, this message translates to:
  /// **'Fre. Limit(s)'**
  String get frechecklimit;

  /// No description provided for @efflimit.
  ///
  /// In en, this message translates to:
  /// **'Eff. Limit(s)'**
  String get efflimit;

  /// No description provided for @moldtype.
  ///
  /// In en, this message translates to:
  /// **'Mold Type'**
  String get moldtype;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// No description provided for @lower.
  ///
  /// In en, this message translates to:
  /// **'Lower'**
  String get lower;

  /// No description provided for @upper.
  ///
  /// In en, this message translates to:
  /// **'Upper'**
  String get upper;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @machineIDuniq.
  ///
  /// In en, this message translates to:
  /// **'Machine ID (unique)'**
  String get machineIDuniq;

  /// No description provided for @numberofca.
  ///
  /// In en, this message translates to:
  /// **'Number of Cavities'**
  String get numberofca;

  /// No description provided for @efficiencylimit.
  ///
  /// In en, this message translates to:
  /// **'Efficiency Limit (%)'**
  String get efficiencylimit;

  /// No description provided for @historycount.
  ///
  /// In en, this message translates to:
  /// **'History Count'**
  String get historycount;

  /// No description provided for @errorLoadData.
  ///
  /// In en, this message translates to:
  /// **'error load data: {error}'**
  String errorLoadData(Object error);

  /// No description provided for @loadingDevices.
  ///
  /// In en, this message translates to:
  /// **'Loading devices...'**
  String get loadingDevices;

  /// No description provided for @noDevicesFound.
  ///
  /// In en, this message translates to:
  /// **'No devices found in {category}'**
  String noDevicesFound(Object category);

  /// No description provided for @machineType.
  ///
  /// In en, this message translates to:
  /// **'Machine Type'**
  String get machineType;

  /// No description provided for @systemTypeHint.
  ///
  /// In en, this message translates to:
  /// **'--System Type--'**
  String get systemTypeHint;

  /// No description provided for @selectProcessHint.
  ///
  /// In en, this message translates to:
  /// **'--Select Process--'**
  String get selectProcessHint;

  /// No description provided for @manufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get manufacturer;

  /// No description provided for @lowerLimits.
  ///
  /// In en, this message translates to:
  /// **'Lower Limit (s)'**
  String get lowerLimits;

  /// No description provided for @targetLimits.
  ///
  /// In en, this message translates to:
  /// **'Target (s)'**
  String get targetLimits;

  /// No description provided for @upperLimits.
  ///
  /// In en, this message translates to:
  /// **'Upper Limit (s)'**
  String get upperLimits;

  /// No description provided for @freqChkConns.
  ///
  /// In en, this message translates to:
  /// **'Freq. Chk Conn. (s)'**
  String get freqChkConns;

  /// No description provided for @freqChkLims.
  ///
  /// In en, this message translates to:
  /// **'Freq. Chk. Lim. (s)'**
  String get freqChkLims;

  /// No description provided for @selectOption.
  ///
  /// In en, this message translates to:
  /// **'-- Select --'**
  String get selectOption;

  /// No description provided for @deviceAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Device added successfully!'**
  String get deviceAddedSuccess;

  /// No description provided for @deviceUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Device updated successfully!'**
  String get deviceUpdatedSuccess;

  /// No description provided for @failedError.
  ///
  /// In en, this message translates to:
  /// **'Failed: {message}'**
  String failedError(Object message);

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @updateDevice.
  ///
  /// In en, this message translates to:
  /// **'Update Device'**
  String get updateDevice;

  /// No description provided for @addD.
  ///
  /// In en, this message translates to:
  /// **'Add Device'**
  String get addD;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @deleteConfirmMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete device'**
  String get deleteConfirmMsg;

  /// No description provided for @deleteSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'{deviceId} deleted'**
  String deleteSuccessMsg(Object deviceId);

  /// No description provided for @deleteFailedMsg.
  ///
  /// In en, this message translates to:
  /// **'Delete device failed'**
  String get deleteFailedMsg;

  /// No description provided for @noIssuesFound.
  ///
  /// In en, this message translates to:
  /// **'No issues found'**
  String get noIssuesFound;

  /// No description provided for @noActionPlansAvailable.
  ///
  /// In en, this message translates to:
  /// **'No action plans available'**
  String get noActionPlansAvailable;

  /// No description provided for @issueType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get issueType;

  /// No description provided for @createdDate.
  ///
  /// In en, this message translates to:
  /// **'Created Date'**
  String get createdDate;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @approvalStatus.
  ///
  /// In en, this message translates to:
  /// **'Approval'**
  String get approvalStatus;

  /// No description provided for @actionPlan.
  ///
  /// In en, this message translates to:
  /// **'Action plan'**
  String get actionPlan;

  /// No description provided for @completeActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Action'**
  String get completeActionTitle;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @completeActionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Complete Action Successfully'**
  String get completeActionSuccess;

  /// No description provided for @completeActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to complete action'**
  String get completeActionFailed;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @locationManagement.
  ///
  /// In en, this message translates to:
  /// **'Location Management'**
  String get locationManagement;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get errorPrefix;

  /// No description provided for @deviceIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Device ID'**
  String get deviceIdLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @temperatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperatureLabel;

  /// No description provided for @humidityLabel.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidityLabel;

  /// No description provided for @pressureLabel.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get pressureLabel;

  /// No description provided for @totalCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Count (H)'**
  String get totalCountLabel;

  /// No description provided for @editLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Location'**
  String get editLocationTitle;

  /// No description provided for @locationNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Location Name'**
  String get locationNameLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @locationUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Location updated successfully'**
  String get locationUpdatedSuccess;

  /// No description provided for @deleteLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Location'**
  String get deleteLocationTitle;

  /// No description provided for @deleteConfirmMsgLoca.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete ?'**
  String get deleteConfirmMsgLoca;

  /// No description provided for @deleteIrreversible.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteIrreversible;

  /// No description provided for @locationDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Location deleted successfully'**
  String get locationDeletedSuccess;

  /// No description provided for @addNewLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Location'**
  String get addNewLocationTitle;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @locationAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Location added successfully'**
  String get locationAddedSuccess;

  /// No description provided for @noLocationsFound.
  ///
  /// In en, this message translates to:
  /// **'No locations found'**
  String get noLocationsFound;

  /// No description provided for @addFirstLocation.
  ///
  /// In en, this message translates to:
  /// **'Add First Location'**
  String get addFirstLocation;

  /// No description provided for @locationManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Management'**
  String get locationManagementTitle;

  /// No description provided for @locationsCount.
  ///
  /// In en, this message translates to:
  /// **'locations'**
  String get locationsCount;

  /// No description provided for @naValue.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get naValue;

  /// No description provided for @loadingLocations.
  ///
  /// In en, this message translates to:
  /// **'Loading locations...'**
  String get loadingLocations;

  /// No description provided for @errorLoadingLocations.
  ///
  /// In en, this message translates to:
  /// **'Error loading locations'**
  String get errorLoadingLocations;

  /// No description provided for @selectLocationHint.
  ///
  /// In en, this message translates to:
  /// **'--Select Location--'**
  String get selectLocationHint;

  /// No description provided for @frequencySeconds.
  ///
  /// In en, this message translates to:
  /// **'Frequency (seconds)'**
  String get frequencySeconds;

  /// No description provided for @frequencyCheckLimit.
  ///
  /// In en, this message translates to:
  /// **'Frequency Check Limit (s)'**
  String get frequencyCheckLimit;

  /// No description provided for @requiredFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get requiredFieldsError;

  /// No description provided for @addDeviceFailed.
  ///
  /// In en, this message translates to:
  /// **'Add device failed'**
  String get addDeviceFailed;

  /// No description provided for @deviceUpdatedError.
  ///
  /// In en, this message translates to:
  /// **'Device updated error'**
  String get deviceUpdatedError;

  /// No description provided for @updateDeviceFailed.
  ///
  /// In en, this message translates to:
  /// **'Update device failed'**
  String get updateDeviceFailed;

  /// No description provided for @dataFrequency.
  ///
  /// In en, this message translates to:
  /// **'Data Frequency'**
  String get dataFrequency;

  /// No description provided for @checkLimit.
  ///
  /// In en, this message translates to:
  /// **'Check Limit'**
  String get checkLimit;

  /// No description provided for @issue.
  ///
  /// In en, this message translates to:
  /// **'Issue'**
  String get issue;

  /// No description provided for @selectIssueType.
  ///
  /// In en, this message translates to:
  /// **'-- Select issue type --'**
  String get selectIssueType;

  /// No description provided for @enterActionPlan.
  ///
  /// In en, this message translates to:
  /// **'Enter detailed action plan...'**
  String get enterActionPlan;

  /// No description provided for @actual.
  ///
  /// In en, this message translates to:
  /// **'Actual'**
  String get actual;

  /// No description provided for @actionAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Action added successfully'**
  String get actionAddedSuccess;

  /// No description provided for @createActionError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create action'**
  String get createActionError;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or code...'**
  String get searchHint;

  /// No description provided for @searchHintt.
  ///
  /// In en, this message translates to:
  /// **'Search by device / issue / owner...'**
  String get searchHintt;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @resultsFound.
  ///
  /// In en, this message translates to:
  /// **'results found'**
  String get resultsFound;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @loadingInstructions.
  ///
  /// In en, this message translates to:
  /// **'Loading working instructions...'**
  String get loadingInstructions;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @noInstructionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No working instructions available'**
  String get noInstructionsAvailable;

  /// No description provided for @refreshButton.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshButton;

  /// No description provided for @noInstructionsFound.
  ///
  /// In en, this message translates to:
  /// **'No instructions found'**
  String get noInstructionsFound;

  /// No description provided for @adjustFiltersHint.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or search terms'**
  String get adjustFiltersHint;

  /// No description provided for @updatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updatedLabel;

  /// No description provided for @dailyInspectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Inspection'**
  String get dailyInspectionTitle;

  /// No description provided for @needToInspect.
  ///
  /// In en, this message translates to:
  /// **'Need to inspect'**
  String get needToInspect;

  /// No description provided for @maintenanceMachineTitle.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Machine'**
  String get maintenanceMachineTitle;

  /// No description provided for @scheduledToday.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Today'**
  String get scheduledToday;

  /// No description provided for @equipmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Equipments'**
  String get equipmentsTitle;

  /// No description provided for @overdueTitle.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdueTitle;

  /// No description provided for @listDailyInspection.
  ///
  /// In en, this message translates to:
  /// **'List Daily Inspection'**
  String get listDailyInspection;

  /// No description provided for @incomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get incomplete;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @activeFilters.
  ///
  /// In en, this message translates to:
  /// **'active'**
  String get activeFilters;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @filtered.
  ///
  /// In en, this message translates to:
  /// **'Filtered from tasks'**
  String get filtered;

  /// No description provided for @noTasksFound.
  ///
  /// In en, this message translates to:
  /// **'No tasks found'**
  String get noTasksFound;

  /// No description provided for @noTasksAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tasks available'**
  String get noTasksAvailable;

  /// No description provided for @noTasksInCategory.
  ///
  /// In en, this message translates to:
  /// **'No tasks in this category'**
  String get noTasksInCategory;

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorLoading;

  /// No description provided for @noInspectionsFound.
  ///
  /// In en, this message translates to:
  /// **'No inspections found'**
  String get noInspectionsFound;

  /// No description provided for @progressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressLabel;

  /// No description provided for @detail.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get detail;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @checklistForm.
  ///
  /// In en, this message translates to:
  /// **'Checklist Form'**
  String get checklistForm;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get step;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @failedloadvideo.
  ///
  /// In en, this message translates to:
  /// **'Failed to load video'**
  String get failedloadvideo;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @formSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Form has been submitted successfully!'**
  String get formSubmittedSuccess;

  /// No description provided for @formSubmissionFailed.
  ///
  /// In en, this message translates to:
  /// **'Form submission failed. Please try again.'**
  String get formSubmissionFailed;

  /// No description provided for @incompleteItemsCurrentStep.
  ///
  /// In en, this message translates to:
  /// **'Incomplete Items in Current Step'**
  String get incompleteItemsCurrentStep;

  /// No description provided for @formIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Form Incomplete'**
  String get formIncomplete;

  /// No description provided for @completeItemsBeforeNext.
  ///
  /// In en, this message translates to:
  /// **'Please complete the following items before proceeding to the next step:'**
  String get completeItemsBeforeNext;

  /// No description provided for @completeItemsBeforeSubmit.
  ///
  /// In en, this message translates to:
  /// **'The following items need to be completed before submission:'**
  String get completeItemsBeforeSubmit;

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @confirmCompleteSteps.
  ///
  /// In en, this message translates to:
  /// **'Have you completed all the steps above?'**
  String get confirmCompleteSteps;

  /// No description provided for @yesContinue.
  ///
  /// In en, this message translates to:
  /// **'Yes, continue'**
  String get yesContinue;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @formSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Form submitted successfully.'**
  String get formSubmitted;

  /// No description provided for @noFormAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Form Available'**
  String get noFormAvailable;

  /// No description provided for @noSavedForms.
  ///
  /// In en, this message translates to:
  /// **'There are no saved forms for this working instruction yet.'**
  String get noSavedForms;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @dateStart.
  ///
  /// In en, this message translates to:
  /// **'Date Start'**
  String get dateStart;

  /// No description provided for @overDueTask.
  ///
  /// In en, this message translates to:
  /// **'Task OverDue'**
  String get overDueTask;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Showing'**
  String get show;

  /// No description provided for @cavityLavel.
  ///
  /// In en, this message translates to:
  /// **'Cavity'**
  String get cavityLavel;

  /// No description provided for @listEquipment.
  ///
  /// In en, this message translates to:
  /// **'List Equipment'**
  String get listEquipment;

  /// No description provided for @masterPlan.
  ///
  /// In en, this message translates to:
  /// **'Master Plan'**
  String get masterPlan;

  /// No description provided for @currentCount.
  ///
  /// In en, this message translates to:
  /// **'Current Count'**
  String get currentCount;

  /// No description provided for @nextCount.
  ///
  /// In en, this message translates to:
  /// **'Next Count'**
  String get nextCount;

  /// No description provided for @estDate.
  ///
  /// In en, this message translates to:
  /// **'Est Date'**
  String get estDate;

  /// No description provided for @manufacturerDate.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer Date'**
  String get manufacturerDate;

  /// No description provided for @listInstructions.
  ///
  /// In en, this message translates to:
  /// **'List Instructions'**
  String get listInstructions;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @cmms.
  ///
  /// In en, this message translates to:
  /// **'CMMS'**
  String get cmms;

  /// No description provided for @languageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSection;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// No description provided for @vietnameseDisplay.
  ///
  /// In en, this message translates to:
  /// **'🇻🇳 Tiếng Việt'**
  String get vietnameseDisplay;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @englishDisplay.
  ///
  /// In en, this message translates to:
  /// **'🇺🇸 English'**
  String get englishDisplay;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get chinese;

  /// No description provided for @chineseDisplay.
  ///
  /// In en, this message translates to:
  /// **'🇨🇳 中文（简体）'**
  String get chineseDisplay;

  /// No description provided for @taiwanese.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get taiwanese;

  /// No description provided for @taiwaneseDisplay.
  ///
  /// In en, this message translates to:
  /// **'🇹🇼 中文（繁體）'**
  String get taiwaneseDisplay;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @receiveNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications on your device'**
  String get receiveNotifications;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmMessage;

  /// No description provided for @errorLogin.
  ///
  /// In en, this message translates to:
  /// **'You need to login'**
  String get errorLogin;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @otpCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'OTP Code'**
  String get otpCodeLabel;

  /// No description provided for @getOtp.
  ///
  /// In en, this message translates to:
  /// **'Get OTP'**
  String get getOtp;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @errorEmptyFields.
  ///
  /// In en, this message translates to:
  /// **'Please enter all required fields'**
  String get errorEmptyFields;

  /// No description provided for @errorUnableConnect.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to server'**
  String get errorUnableConnect;

  /// No description provided for @errorCannotOpenOtpApp.
  ///
  /// In en, this message translates to:
  /// **'Cannot open OTP application'**
  String get errorCannotOpenOtpApp;

  /// No description provided for @bottomButtonInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get bottomButtonInstructions;

  /// No description provided for @systemCoolingTower.
  ///
  /// In en, this message translates to:
  /// **'Cooling Tower'**
  String get systemCoolingTower;

  /// No description provided for @systemChiller.
  ///
  /// In en, this message translates to:
  /// **'Chiller'**
  String get systemChiller;

  /// No description provided for @systemVacuumTank.
  ///
  /// In en, this message translates to:
  /// **'Vacuum Tank'**
  String get systemVacuumTank;

  /// No description provided for @systemAirDryer.
  ///
  /// In en, this message translates to:
  /// **'Air Dryer'**
  String get systemAirDryer;

  /// No description provided for @systemCompressor.
  ///
  /// In en, this message translates to:
  /// **'Compressor'**
  String get systemCompressor;

  /// No description provided for @systemEndAirPressure.
  ///
  /// In en, this message translates to:
  /// **'End Air Pressure'**
  String get systemEndAirPressure;

  /// No description provided for @systemAirTank.
  ///
  /// In en, this message translates to:
  /// **'Air Tank'**
  String get systemAirTank;

  /// No description provided for @systemAirConditioner.
  ///
  /// In en, this message translates to:
  /// **'Air Conditioner'**
  String get systemAirConditioner;

  /// No description provided for @systemFactoryTemperature.
  ///
  /// In en, this message translates to:
  /// **'Factory Temperature'**
  String get systemFactoryTemperature;

  /// No description provided for @tabIssue.
  ///
  /// In en, this message translates to:
  /// **'Issue'**
  String get tabIssue;

  /// No description provided for @statusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get statusConnected;

  /// No description provided for @statusDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get statusDisconnected;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'A new update is available!'**
  String get updateAvailableTitle;

  /// No description provided for @updateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Update {version}'**
  String updateDialogTitle(Object version);

  /// No description provided for @updateDescription.
  ///
  /// In en, this message translates to:
  /// **'A new update is available!'**
  String get updateDescription;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get updateNow;

  /// No description provided for @downloadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloadingTitle;

  /// No description provided for @cmmsDescription.
  ///
  /// In en, this message translates to:
  /// **'Computerized Maintenance Management System'**
  String get cmmsDescription;

  /// No description provided for @emsDescription.
  ///
  /// In en, this message translates to:
  /// **'Equipment Management System'**
  String get emsDescription;

  /// No description provided for @fmcsDescription.
  ///
  /// In en, this message translates to:
  /// **'Facility Management Control System'**
  String get fmcsDescription;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {appVersion}'**
  String appVersion(Object appVersion);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
