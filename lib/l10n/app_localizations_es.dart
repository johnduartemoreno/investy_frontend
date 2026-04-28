// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Investy';

  @override
  String get navHome => 'Inicio';

  @override
  String get navGoals => 'Metas';

  @override
  String get navPortfolio => 'Portafolio';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonLoading => 'Cargando...';

  @override
  String get commonEmail => 'Correo';

  @override
  String get commonPassword => 'Contraseña';

  @override
  String get commonName => 'Nombre';

  @override
  String get commonError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get commonLogOut => 'Cerrar sesión';

  @override
  String get errorRequiredField => 'Este campo es obligatorio';

  @override
  String get errorInvalidEmail => 'Ingresa un correo válido';

  @override
  String get errorPasswordTooShort =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get errorPasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String get errorNetwork => 'Error de red. Revisa tu conexión.';

  @override
  String get loginTitle => '¡Bienvenido de nuevo!';

  @override
  String get loginSubtitle => 'Accede a tus inversiones de forma segura.';

  @override
  String get loginRememberEmail => 'Recordar correo';

  @override
  String get loginOrContinueWith => 'O continuar con';

  @override
  String get loginEmailHint => 'Correo';

  @override
  String get loginPasswordHint => 'Contraseña';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get loginForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginNoAccount => '¿No tienes cuenta?';

  @override
  String get loginSignUp => 'Regístrate';

  @override
  String get loginWithGoogle => 'Continuar con Google';

  @override
  String get signupTitle => 'Crear cuenta';

  @override
  String get signupSubtitle => 'Empieza a invertir hoy';

  @override
  String get signupNameHint => 'Nombre completo';

  @override
  String get signupEmailHint => 'Correo';

  @override
  String get signupPasswordHint => 'Contraseña';

  @override
  String get signupConfirmPasswordHint => 'Confirmar contraseña';

  @override
  String get signupCurrencyLabel => 'Moneda de visualización';

  @override
  String get signupButton => 'Crear cuenta';

  @override
  String get signupHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get signupLogIn => 'Inicia sesión';

  @override
  String get forgotPasswordTitle => 'Restablecer contraseña';

  @override
  String get forgotPasswordSubtitle =>
      'Ingresa tu correo y te enviaremos un enlace de restablecimiento';

  @override
  String get forgotPasswordEmailHint => 'Correo';

  @override
  String get forgotPasswordButton => 'Enviar enlace';

  @override
  String get forgotPasswordSuccess =>
      'Enlace enviado. Revisa tu bandeja de entrada.';

  @override
  String get emailVerificationTitle => 'Verifica tu correo';

  @override
  String emailVerificationSubtitle(String email) {
    return 'Enviamos un enlace de verificación a $email. Revisa tu bandeja.';
  }

  @override
  String get emailVerificationResend => 'Reenviar correo';

  @override
  String get emailVerificationLogout => 'Usar otra cuenta';

  @override
  String dashboardGreeting(String name) {
    return 'Hola, $name';
  }

  @override
  String get dashboardTotalBalance => 'Balance total';

  @override
  String get dashboardInvestedValue => 'Invertido';

  @override
  String get dashboardRecentActivity => 'Actividad reciente';

  @override
  String get dashboardNoActivity => 'Sin actividad reciente';

  @override
  String get dashboardBuy => 'Comprar';

  @override
  String get dashboardSell => 'Vender';

  @override
  String get dashboardTopUp => 'Depositar';

  @override
  String get dashboardWithdraw => 'Retirar';

  @override
  String get dashboardAvailableCash => 'Efectivo disponible';

  @override
  String get portfolioTitle => 'Portafolio';

  @override
  String get portfolioNoHoldings =>
      'Sin posiciones aún.\nCompra tu primer activo para empezar.';

  @override
  String get portfolioTotalInvested => 'Total invertido';

  @override
  String get portfolioReturn => 'Rendimiento';

  @override
  String get portfolioQuantity => 'Cant.';

  @override
  String get portfolioAvgCost => 'Costo prom.';

  @override
  String get portfolioCurrentPrice => 'Precio actual';

  @override
  String get goalsTitle => 'Metas';

  @override
  String get goalsNoGoals => 'Sin metas aún.\nCrea una para empezar a ahorrar.';

  @override
  String get goalsAddButton => 'Agregar meta';

  @override
  String goalProgress(int percent) {
    return '$percent% alcanzado';
  }

  @override
  String get goalTarget => 'Meta';

  @override
  String get goalSaved => 'Ahorrado';

  @override
  String get goalDeadline => 'Fecha límite';

  @override
  String get goalCategory => 'Categoría';

  @override
  String get goalFormTitle => 'Nueva meta';

  @override
  String get goalFormNameHint => 'Nombre de la meta';

  @override
  String get goalFormTargetHint => 'Monto objetivo';

  @override
  String get goalFormDeadlineLabel => 'Fecha límite';

  @override
  String get goalFormCategoryLabel => 'Categoría';

  @override
  String get goalFormSaveButton => 'Guardar meta';

  @override
  String get goalFormSelectDate => 'Seleccionar fecha';

  @override
  String get categoryCar => 'Automóvil';

  @override
  String get categoryHome => 'Hogar';

  @override
  String get categoryVacation => 'Vacaciones';

  @override
  String get categoryTravel => 'Viaje';

  @override
  String get categoryEducation => 'Educación';

  @override
  String get categoryEmergency => 'Emergencia';

  @override
  String get categoryHealth => 'Salud';

  @override
  String get categoryOther => 'Otro';

  @override
  String buyTitle(String symbol) {
    return 'Comprar $symbol';
  }

  @override
  String get buyQuantityLabel => 'Cantidad';

  @override
  String get buyPriceLabel => 'Precio por unidad';

  @override
  String get buyTotalLabel => 'Total';

  @override
  String get buyButton => 'Comprar';

  @override
  String get buySuccess => 'Compra exitosa';

  @override
  String sellTitle(String symbol) {
    return 'Vender $symbol';
  }

  @override
  String get sellQuantityLabel => 'Cantidad';

  @override
  String get sellButton => 'Vender';

  @override
  String get sellSuccess => 'Venta exitosa';

  @override
  String sellMaxQuantity(String quantity) {
    return 'Máx: $quantity';
  }

  @override
  String get topUpTitle => 'Depositar';

  @override
  String get topUpAmountHint => 'Monto';

  @override
  String get topUpButton => 'Agregar fondos';

  @override
  String get topUpSuccess => 'Fondos agregados exitosamente';

  @override
  String get withdrawTitle => 'Retirar';

  @override
  String get withdrawAmountHint => 'Monto';

  @override
  String get withdrawButton => 'Retirar';

  @override
  String get withdrawSuccess => 'Retiro exitoso';

  @override
  String get withdrawInsufficientFunds => 'Fondos insuficientes';

  @override
  String get assetSearchHint => 'Buscar activos (ej. AAPL, BTC)';

  @override
  String get assetSearchEmpty => 'No se encontraron activos';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsCurrency => 'Moneda';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsPrivacySecurity => 'Privacidad y seguridad';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsAbout => 'Acerca de Investy';

  @override
  String get settingsHelp => 'Ayuda y soporte';

  @override
  String get securityTitle => 'Privacidad y seguridad';

  @override
  String get securityAccountSection => 'Seguridad de cuenta';

  @override
  String get securityDangerSection => 'Zona de peligro';

  @override
  String get securityChangePassword => 'Cambiar contraseña';

  @override
  String get securityChangePasswordSubtitle =>
      'Actualiza tu contraseña de acceso';

  @override
  String get securityManagedByGoogle => 'Administrado por Google';

  @override
  String get securityDeleteAccount => 'Eliminar cuenta';

  @override
  String get securityDeleteAccountSubtitle =>
      'Elimina permanentemente tu cuenta y todos tus datos';

  @override
  String get changePasswordTitle => 'Cambiar contraseña';

  @override
  String get changePasswordCurrent => 'Contraseña actual';

  @override
  String get changePasswordNew => 'Nueva contraseña';

  @override
  String get changePasswordConfirm => 'Confirmar nueva contraseña';

  @override
  String get changePasswordButton => 'Actualizar contraseña';

  @override
  String get changePasswordSuccess => 'Contraseña actualizada exitosamente';

  @override
  String get deleteAccountTitle => 'Eliminar cuenta';

  @override
  String get deleteAccountWarning =>
      'Esta acción es permanente e irreversible. Todos tus datos serán eliminados.';

  @override
  String get deleteAccountConfirmPassword =>
      'Ingresa tu contraseña para confirmar';

  @override
  String get deleteAccountConfirmEmail => 'Escribe tu correo para confirmar';

  @override
  String deleteAccountYourEmail(String email) {
    return 'Tu correo: $email';
  }

  @override
  String get deleteAccountButton => 'Eliminar mi cuenta';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsPush => 'Notificaciones push';

  @override
  String get notificationsPushSubtitle =>
      'Recibe alertas de metas y transacciones';

  @override
  String get notificationsGoalReminders => 'Recordatorios de metas';

  @override
  String get notificationsGoalRemindersSubtitle =>
      'Recordatorios semanales de progreso de tus metas';

  @override
  String get notificationsEnable => 'Activar notificaciones';

  @override
  String get appearanceTitle => 'Apariencia';

  @override
  String get appearanceTheme => 'Tema';

  @override
  String get appearanceThemeSystem => 'Sistema';

  @override
  String get appearanceThemeLight => 'Claro';

  @override
  String get appearanceThemeDark => 'Oscuro';

  @override
  String get appearanceLanguage => 'Idioma';

  @override
  String get languageEn => 'Inglés';

  @override
  String get languageEs => 'Español';

  @override
  String get languagePt => 'Portugués (BR)';

  @override
  String get aboutTitle => 'Acerca de Investy';

  @override
  String get aboutVersion => 'Versión';

  @override
  String get aboutDescription =>
      'Investy te ayuda a planificar y rastrear tus inversiones hacia tus metas.';

  @override
  String get aboutTerms => 'Términos de servicio';

  @override
  String get aboutPrivacy => 'Política de privacidad';

  @override
  String get helpTitle => 'Ayuda y soporte';

  @override
  String get helpFaq => 'Preguntas frecuentes';

  @override
  String get helpContact => 'Contactar soporte';

  @override
  String get helpDocumentation => 'Documentación';
}
