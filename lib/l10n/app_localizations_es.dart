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
  String get commonDone => 'Listo';

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
  String get signupNameRequired => 'El nombre es obligatorio';

  @override
  String get signupEmailRequired => 'El correo es obligatorio';

  @override
  String get signupPasswordRequired => 'La contraseña es obligatoria';

  @override
  String get signupPasswordMinLength => 'Mínimo 6 caracteres';

  @override
  String get signupConfirmPasswordRequired =>
      'Por favor confirma tu contraseña';

  @override
  String get signupPasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String get signupShowPassword => 'Mostrar contraseña';

  @override
  String get signupHidePassword => 'Ocultar contraseña';

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
  String get forgotPasswordEmailRequired => 'El correo es obligatorio';

  @override
  String forgotPasswordSentMessage(String email) {
    return 'Enviamos un enlace a $email. Revisa tu bandeja de entrada y sigue las instrucciones.';
  }

  @override
  String get forgotPasswordBackToSignIn => 'Volver al inicio de sesión';

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
  String get emailVerificationNotVerified =>
      'Por favor verifica tu correo primero';

  @override
  String get emailVerificationSent =>
      'Correo de verificación enviado. Revisa tu bandeja.';

  @override
  String dashboardGreeting(String name) {
    return 'Hola, $name';
  }

  @override
  String get dashboardWelcomeBack => 'Bienvenido de vuelta,';

  @override
  String get dashboardTotalBalance => 'Balance total';

  @override
  String get dashboardToday => 'hoy';

  @override
  String get dashboardInvestedPortfolio => 'Portafolio invertido';

  @override
  String get dashboardCashToInvest => 'Efectivo para invertir';

  @override
  String get dashboardInvestedValue => 'Invertido';

  @override
  String get dashboardRecentActivity => 'Actividad reciente';

  @override
  String get dashboardSeeAll => 'Ver todo';

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
  String get commonToday => 'Hoy';

  @override
  String get commonYesterday => 'Ayer';

  @override
  String activityBought(String symbol) {
    return 'Comprado $symbol';
  }

  @override
  String activitySold(String symbol) {
    return 'Vendido $symbol';
  }

  @override
  String get activityDeposit => 'Depósito';

  @override
  String get activityWithdrawal => 'Retiro';

  @override
  String get activityUnknown => 'Desconocido';

  @override
  String get activityDetailQuantity => 'Cantidad';

  @override
  String get activityDetailPricePerUnit => 'Precio por unidad';

  @override
  String get activityDetailTotal => 'Total';

  @override
  String get activityDetailAmount => 'Monto';

  @override
  String get activityDetailDate => 'Fecha';

  @override
  String get activityDetailRealizedPnl => 'P&L realizado';

  @override
  String get activityDetailGain => 'Ganancia';

  @override
  String get activityDetailLoss => 'Pérdida';

  @override
  String get portfolioTitle => 'Portafolio';

  @override
  String get portfolioNoHoldings =>
      'Sin posiciones aún.\nCompra tu primer activo para empezar.';

  @override
  String get portfolioTotalInvested => 'Total invertido';

  @override
  String get portfolioTotalLabel => 'Total';

  @override
  String get portfolioReturn => 'Rendimiento';

  @override
  String get assetDetailPosition => 'Tu posición';

  @override
  String get assetDetailMarketValue => 'Valor de mercado';

  @override
  String get assetDetailShowAvgCost => 'Mi costo promedio';

  @override
  String get portfolioQuantity => 'Cant.';

  @override
  String get portfolioAvgCost => 'Costo prom.';

  @override
  String get portfolioCurrentPrice => 'Precio actual';

  @override
  String get portfolioAssetStock => 'Acción';

  @override
  String get portfolioAssetCash => 'Efectivo';

  @override
  String get portfolioAllocationTitle => 'Asignación';

  @override
  String get chartPortfolioValue => 'Valor del portafolio';

  @override
  String get chartNotEnoughData =>
      'Aún no hay datos suficientes para el gráfico.';

  @override
  String get chartRange1W => '1S';

  @override
  String get chartRange1M => '1M';

  @override
  String get chartRange3M => '3M';

  @override
  String get chartRange1Y => '1A';

  @override
  String get chartRangeAll => 'TODO';

  @override
  String get portfolioAssetCrypto => 'Cripto';

  @override
  String get portfolioAssetEtf => 'ETF';

  @override
  String get portfolioShares => 'acciones';

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
  String get goalCash => 'Efectivo';

  @override
  String get goalInvested => 'Invertido';

  @override
  String get goalDetailInvestmentsTitle => 'Inversiones hacia esta meta';

  @override
  String get goalDetailNoInvestments =>
      'Aún no hay inversiones asignadas a esta meta.';

  @override
  String get goalDetailCashTitle => 'Efectivo ahorrado';

  @override
  String goalDetailProjection(String date) {
    return 'A este ritmo, la alcanzarás cerca de $date';
  }

  @override
  String get goalDetailProjectionUnknown =>
      'Agrega fondos para ver una fecha estimada.';

  @override
  String get goalProjectionTitle => 'Proyección';

  @override
  String get goalOnTrack => 'En camino';

  @override
  String get goalBehind => 'Atrasado';

  @override
  String get goalInvestButton => 'Invertir hacia esta meta';

  @override
  String get buyAssignGoalLabel => '¿Asignar a una meta? (opcional)';

  @override
  String get buyNoGoalOption => 'Sin meta';

  @override
  String get goalFormTitle => 'Nueva meta';

  @override
  String get goalFormNameHint => 'Nombre de la meta';

  @override
  String get goalFormCategoryLabel => 'Categoría';

  @override
  String get categoryCar => 'Automóvil';

  @override
  String get categoryHome => 'Hogar';

  @override
  String get categoryVacation => 'Vacaciones';

  @override
  String get categoryEducation => 'Educación';

  @override
  String get categoryEmergency => 'Emergencia';

  @override
  String get categoryHealth => 'Salud';

  @override
  String get categoryOther => 'Otro';

  @override
  String get buyAssetTitle => 'Comprar activo';

  @override
  String get buySelectAsset => 'Selecciona un activo';

  @override
  String get buyPerShare => 'por acción';

  @override
  String get buyEnterQuantity => 'Ingresa cantidad';

  @override
  String get buyQuantityPositive => 'Debe ser mayor a 0';

  @override
  String get buyConfirmButton => 'Confirmar compra';

  @override
  String buyTitle(String symbol) {
    return 'Comprar $symbol';
  }

  @override
  String get buyInsufficientFunds =>
      'Saldo insuficiente. Deposita fondos para continuar.';

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
  String get sellAssetTitle => 'Vender activo';

  @override
  String get sellNoAssets => 'Aún no tienes activos';

  @override
  String get sellNoAssetsSubtitle =>
      'Compra tu primer activo para empezar a construir tu portafolio.';

  @override
  String get sellBuyFirstAsset => 'Comprar mi primer activo';

  @override
  String sellTitle(String symbol) {
    return 'Vender $symbol';
  }

  @override
  String get sellQuantityLabel => 'Cantidad';

  @override
  String sellSharesOwned(String quantity) {
    return '$quantity acciones en tu poder';
  }

  @override
  String get sellPricePerShare => 'Precio por acción (precio de mercado)';

  @override
  String get sellEnterQuantity => 'Ingresa la cantidad';

  @override
  String get sellQuantityPositive => 'Debe ser mayor que cero';

  @override
  String sellQuantityExceeds(String quantity) {
    return 'Solo tienes $quantity acciones';
  }

  @override
  String get sellEnterPrice => 'Ingresa el precio de venta';

  @override
  String get sellConfirm => 'Confirmar venta';

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
  String get topUpEnterAmount => 'Ingresar monto';

  @override
  String get topUpAmountRequired => 'Por favor ingresa un monto';

  @override
  String get topUpAmountInvalid => 'Por favor ingresa un monto válido';

  @override
  String get topUpConfirmButton => 'Confirmar depósito';

  @override
  String get topUpAmountHint => 'Monto';

  @override
  String get topUpButton => 'Agregar fondos';

  @override
  String get topUpSuccess => 'Fondos agregados exitosamente';

  @override
  String get withdrawTitle => 'Retirar';

  @override
  String get withdrawCash => 'Retirar efectivo';

  @override
  String get withdrawAvailableTo => 'Disponible para retirar';

  @override
  String get withdrawConfirmButton => 'Confirmar retiro';

  @override
  String get withdrawEnterAmount => 'Ingresa un monto';

  @override
  String get withdrawAmountPositive => 'El monto debe ser positivo';

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
  String get changePasswordErrorWrongPassword =>
      'La contraseña actual es incorrecta.';

  @override
  String get changePasswordErrorRecentLogin =>
      'Por favor cierra sesión y vuelve a iniciarla antes de cambiar tu contraseña.';

  @override
  String get changePasswordErrorFailed =>
      'No se pudo cambiar la contraseña. Intenta de nuevo.';

  @override
  String get deleteAccountTitle => 'Eliminar cuenta';

  @override
  String get deleteAccountWarning =>
      'Esta acción es permanente e irreversible. Todos tus datos serán eliminados.';

  @override
  String get deleteAccountConfirmTitle => 'Confirmar eliminación';

  @override
  String get deleteAccountConfirmPassword =>
      'Ingresa tu contraseña para confirmar';

  @override
  String get deleteAccountConfirmEmail => 'Escribe tu correo para confirmar';

  @override
  String get deleteAccountConfirmEmailText =>
      'Escribe tu correo para confirmar la eliminación.';

  @override
  String get deleteAccountConfirmPasswordText =>
      'Ingresa tu contraseña para confirmar la eliminación.';

  @override
  String get deleteAccountEmailMismatch =>
      'El correo no coincide. Intenta de nuevo.';

  @override
  String get deleteAccountEnterPassword => 'Por favor ingresa tu contraseña.';

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
  String get notificationsDescription =>
      'Recibirás notificaciones cuando:\n• Se procesa un depósito o retiro\n• Se confirma una orden de compra o venta\n• La fecha límite de una meta financiera se acerca (30 días)';

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

  @override
  String get helpReplyTime => 'Respondemos en menos de 24 horas';

  @override
  String get helpFaq1Q => '¿Cómo agrego dinero a mi cuenta?';

  @override
  String get helpFaq1A =>
      'Toca \"Depositar\" en la pantalla de inicio e ingresa el monto que deseas depositar. Los fondos se acreditarán en tu saldo de efectivo disponible.';

  @override
  String get helpFaq2Q => '¿Cómo compro un activo?';

  @override
  String get helpFaq2A =>
      'Toca \"Comprar\" en la pantalla de inicio, busca el activo por nombre o símbolo, ingresa la cantidad y confirma la compra.';

  @override
  String get helpFaq3Q => '¿Cómo establezco una meta financiera?';

  @override
  String get helpFaq3A =>
      'Ve a la pestaña de Metas y toca el botón \"+\". Ingresa un nombre, monto objetivo, categoría y fecha límite. Tus contribuciones contarán automáticamente hacia tus metas.';

  @override
  String get helpFaq4Q => '¿Puedo retirar mis fondos en cualquier momento?';

  @override
  String get helpFaq4A =>
      'Sí. Toca \"Retirar\" en la pantalla de inicio e ingresa el monto. Los retiros se procesan desde tu saldo de efectivo disponible.';

  @override
  String get helpFaq5Q => '¿Qué pasa si olvido mi contraseña?';

  @override
  String get helpFaq5A =>
      'En la pantalla de inicio de sesión, toca \"¿Olvidaste tu contraseña?\" e ingresa tu correo. Te enviaremos un enlace de restablecimiento en pocos minutos.';

  @override
  String get kycTitle => 'Verificación de identidad';

  @override
  String get kycIntroBody =>
      'Para comenzar a invertir, necesitamos verificar tu identidad. Es requerido por regulaciones financieras y toma aproximadamente 5 minutos.';

  @override
  String get kycStartButton => 'Iniciar verificación';

  @override
  String get kycRetryButton => 'Intentar de nuevo';

  @override
  String get kycCameraPermissionTitle => 'Acceso a la cámara requerido';

  @override
  String get kycCameraPermissionBody =>
      'El acceso a la cámara fue denegado. Habilítalo en Configuración para completar la verificación.';

  @override
  String get kycOpenSettings => 'Abrir Configuración';

  @override
  String get kycApprovedTitle => 'Verificado';

  @override
  String get kycApprovedBody =>
      'Tu identidad ha sido verificada. Ya puedes comprar y vender activos.';

  @override
  String get kycPendingTitle => 'En revisión';

  @override
  String get kycPendingBody =>
      'Tus documentos han sido enviados. Normalmente completamos la verificación en 24 horas.';

  @override
  String get kycRejectedTitle => 'Verificación fallida';

  @override
  String get kycRejectedBody =>
      'No pudimos verificar tu identidad. Por favor intenta de nuevo con una foto clara de tu documento de identidad.';

  @override
  String get kycBannerRequired =>
      'Verifica tu identidad para comenzar a operar. Toca aquí.';

  @override
  String get kycBannerPending =>
      'La verificación de identidad está en revisión. El trading se habilitará una vez aprobado.';

  @override
  String get kycSettingsLabel => 'Verificación de identidad';

  @override
  String get kycReqLegalName => 'Nombre legal completo';

  @override
  String get kycReqDob => 'Fecha de nacimiento';

  @override
  String get kycReqAddress => 'Dirección residencial';

  @override
  String get kycReqId => 'Documento de identidad oficial';

  @override
  String get kycReqTaxId => 'Número de identificación tributaria';

  @override
  String get brokerSettingsLabel => 'Cuenta de Inversión';

  @override
  String get brokerStatusPending => 'Pendiente';

  @override
  String get brokerStatusActive => 'Activa';

  @override
  String get brokerStatusRejected => 'Rechazada';

  @override
  String get brokerBannerPending =>
      'Tu cuenta de inversión está en revisión. El trading en vivo se habilitará una vez aprobada.';

  @override
  String get brokerBannerNotActive =>
      'Cuenta de inversión no configurada. El trading en papel está activo.';

  @override
  String get riskProfileSettingsLabel => 'Perfil de riesgo';

  @override
  String get riskProfileTitle => 'Perfil de riesgo';

  @override
  String riskProfileQuestionOf(int current, int total) {
    return '$current de $total';
  }

  @override
  String get riskProfileQ1 => '¿Cuál es tu horizonte de inversión?';

  @override
  String get riskProfileQ1A1 => 'Menos de 1 año';

  @override
  String get riskProfileQ1A2 => '1 a 3 años';

  @override
  String get riskProfileQ1A3 => '3 a 7 años';

  @override
  String get riskProfileQ1A4 => 'Más de 7 años';

  @override
  String get riskProfileQ2 => 'Si tu portafolio cayera un 20%, ¿qué harías?';

  @override
  String get riskProfileQ2A1 => 'Vendo todo';

  @override
  String get riskProfileQ2A2 => 'Vendo algunas posiciones';

  @override
  String get riskProfileQ2A3 => 'Mantengo y espero';

  @override
  String get riskProfileQ2A4 => 'Compro más';

  @override
  String get riskProfileQ3 => '¿Cómo describirías tu experiencia inversora?';

  @override
  String get riskProfileQ3A1 => 'Ninguna';

  @override
  String get riskProfileQ3A2 => 'Básica';

  @override
  String get riskProfileQ3A3 => 'Moderada';

  @override
  String get riskProfileQ3A4 => 'Avanzada';

  @override
  String get riskProfileQ4 => '¿Qué tan estables son tus ingresos?';

  @override
  String get riskProfileQ4A1 => 'Muy inestables';

  @override
  String get riskProfileQ4A2 => 'Inestables';

  @override
  String get riskProfileQ4A3 => 'Estables';

  @override
  String get riskProfileQ4A4 => 'Muy estables';

  @override
  String get riskProfileQ5 => '¿Cuál es tu objetivo principal de inversión?';

  @override
  String get riskProfileQ5A1 => 'Preservar el capital';

  @override
  String get riskProfileQ5A2 => 'Ingreso regular';

  @override
  String get riskProfileQ5A3 => 'Crecimiento moderado';

  @override
  String get riskProfileQ5A4 => 'Máximo crecimiento';

  @override
  String get riskProfileNext => 'Siguiente';

  @override
  String get riskProfileSubmit => 'Ver mi perfil';

  @override
  String get riskProfileConservative => 'Conservador';

  @override
  String get riskProfileModerate => 'Moderado';

  @override
  String get riskProfileAggressive => 'Agresivo';

  @override
  String get riskProfileConservativeDesc =>
      'Prefieres la estabilidad. Tu portafolio prioriza la preservación del capital con activos de bajo riesgo.';

  @override
  String get riskProfileModerateDesc =>
      'Buscas crecimiento equilibrado. Tu portafolio combina activos estables con oportunidades de crecimiento moderado.';

  @override
  String get riskProfileAggressiveDesc =>
      'Buscas el máximo crecimiento. Tu portafolio se enfoca en activos de alto rendimiento y toleras la volatilidad.';

  @override
  String get riskProfileRetake => 'Repetir cuestionario';

  @override
  String get riskProfileNotCompleted => 'No completado';

  @override
  String get riskProfileLoadError => 'No se pudo cargar el perfil de riesgo.';

  @override
  String get owlAiName => 'Owl AI';

  @override
  String get owlAiTagline => 'Recomendaciones de inversión para ti';

  @override
  String get owlAiPoweredAdvisor => 'Asesor con inteligencia artificial';

  @override
  String get owlAiAnalyzing => 'Analizando tu portafolio…';

  @override
  String get owlAiStrongBuy => 'Compra fuerte';

  @override
  String get owlAiModerateSignal => 'Moderado';

  @override
  String get owlAiSuggested => 'Sugerido:';

  @override
  String get owlAiBuyButton => 'COMPRAR →';

  @override
  String get owlAiRefresh => 'Actualizar análisis';

  @override
  String get owlAiUnavailable =>
      'El asesor IA no está disponible temporalmente.';

  @override
  String get owlAiErrorRetry =>
      'No se pudieron cargar las recomendaciones. Toca para reintentar.';

  @override
  String get owlAiRefreshing => 'Actualizando tus recomendaciones…';

  @override
  String get owlAiRefreshingSubtitle => 'Analizando tu portafolio y metas';

  @override
  String get owlAiAskNewRecs => 'Actualizar';

  @override
  String get owlHistoryButton => 'Historial';

  @override
  String get owlHistoryTitle => 'Historial del Búho';

  @override
  String get owlHistoryEmpty =>
      'Aún no hay sesiones. Pide recomendaciones al búho para empezar tu historial.';

  @override
  String owlHistorySessionBanner(String date) {
    return 'Sesión del $date';
  }

  @override
  String owlHistoryDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Hace $days días',
      one: 'Ayer',
      zero: 'Hoy',
    );
    return '$_temp0';
  }

  @override
  String owlHistoryContext(String portfolio, String cash) {
    return 'Portafolio $portfolio · Efectivo $cash';
  }

  @override
  String get owlAiCashAvailable => 'Disponible para invertir';

  @override
  String get portfolioActive => 'Portafolio activo';

  @override
  String get greetingMorning => 'Buenos días,';

  @override
  String get greetingAfternoon => 'Buenas tardes,';

  @override
  String get greetingEvening => 'Buenas noches,';

  @override
  String get alertsTitle => 'Alertas de precio';

  @override
  String get alertsSettingsLabel => 'Alertas de precio';

  @override
  String get alertsEmpty => 'Aún no tienes alertas de precio.';

  @override
  String get alertsEmptyHint =>
      'Crea una para recibir un aviso cuando un activo alcance tu precio objetivo.';

  @override
  String get alertsCreateTitle => 'Nueva alerta de precio';

  @override
  String get alertsAssetLabel => 'Activo';

  @override
  String get alertsConditionLabel => 'Condición';

  @override
  String get alertsSearchHint => 'Busca por símbolo o nombre';

  @override
  String get alertsSelectAssetFirst => 'Primero selecciona un activo';

  @override
  String alertsCurrentPrice(String price) {
    return 'Actual: $price';
  }

  @override
  String get alertsDirectionAbove => 'Sube hasta o por encima de';

  @override
  String get alertsDirectionBelow => 'Baja hasta o por debajo de';

  @override
  String get alertsTargetPriceHint => 'Precio objetivo (USD)';

  @override
  String get alertsCreateButton => 'Crear alerta';

  @override
  String get alertsCreated => 'Alerta creada';

  @override
  String get alertsDeleted => 'Alerta eliminada';

  @override
  String get alertsStatusActive => 'Activa';

  @override
  String get alertsStatusTriggered => 'Disparada';

  @override
  String alertsConditionAbove(String price) {
    return 'Por encima de $price';
  }

  @override
  String alertsConditionBelow(String price) {
    return 'Por debajo de $price';
  }

  @override
  String get alertsErrorAlreadyMet =>
      'El precio actual ya cumple este objetivo. Elige uno diferente.';

  @override
  String get alertsErrorLimit => 'Alcanzaste el máximo de 20 alertas activas.';

  @override
  String get alertsErrorDuplicate =>
      'Ya tienes una alerta idéntica para este activo.';

  @override
  String get alertsErrorUnknownSymbol => 'Activo desconocido.';

  @override
  String get alertsDeleteTooltip => 'Eliminar alerta';

  @override
  String get loginSessionTerminated =>
      'Tu sesión fue cerrada. Inicia sesión de nuevo.';

  @override
  String get authErrorUserNotFound => 'No existe una cuenta con este correo';

  @override
  String get authErrorInvalidCredentials => 'Correo o contraseña inválidos';

  @override
  String get authErrorInvalidEmail => 'Formato de correo inválido';

  @override
  String get authErrorUserDisabled => 'Esta cuenta ha sido deshabilitada';

  @override
  String get authErrorTooManyRequests =>
      'Demasiados intentos fallidos. Inténtalo más tarde';

  @override
  String get authErrorNetwork => 'Error de red. Verifica tu conexión';

  @override
  String get authErrorEmailInUse => 'Ya existe una cuenta con este correo';

  @override
  String get authErrorWeakPassword =>
      'La contraseña es muy débil. Usa al menos 6 caracteres';

  @override
  String get authErrorOperationNotAllowed =>
      'Las cuentas de correo/contraseña no están habilitadas';

  @override
  String get authErrorAccountExistsDifferentMethod =>
      'Ya existe una cuenta con este correo usando otro método de inicio de sesión';

  @override
  String get authErrorGoogleCancelled =>
      'Inicio de sesión con Google cancelado';

  @override
  String get authErrorWrongPassword => 'La contraseña es incorrecta';

  @override
  String get authErrorRequiresRecentLogin =>
      'Cierra sesión y vuelve a iniciarla primero';

  @override
  String get authErrorNoUser => 'No hay ningún usuario con sesión activa';

  @override
  String get authErrorVerificationEmailFailed =>
      'No se pudo enviar el correo de verificación. Inténtalo de nuevo';

  @override
  String get authErrorRefreshFailed =>
      'No se pudo actualizar el estado. Inténtalo de nuevo';

  @override
  String get authErrorDeletionFailed =>
      'No se pudo eliminar la cuenta. Inténtalo de nuevo';

  @override
  String get authErrorUnexpected =>
      'Ocurrió un error inesperado. Inténtalo de nuevo';

  @override
  String get goalFormTargetLabel => 'Monto objetivo';

  @override
  String get goalFormDateLabel => 'Fecha objetivo';

  @override
  String get goalFormCreateButton => 'Crear meta';

  @override
  String get goalFormNameRequired => 'Ingresa un nombre para la meta';

  @override
  String get goalFormTargetRequired => 'Ingresa un monto objetivo';

  @override
  String get goalFormTargetInvalid => 'El monto debe ser mayor que cero';

  @override
  String get goalFormDateRequired => 'Selecciona una fecha objetivo';

  @override
  String get goalFormCustomDate => 'Personalizada';

  @override
  String get goalFormCreateFailed =>
      'No se pudo crear la meta. Inténtalo de nuevo.';

  @override
  String goalPresetMonths(int months) {
    return '${months}M';
  }

  @override
  String goalPresetYears(int years) {
    return '${years}A';
  }

  @override
  String get withdrawMaxChip => 'MAX';

  @override
  String get currencyUSD => 'Dólar estadounidense';

  @override
  String get currencyEUR => 'Euro';

  @override
  String get currencyGBP => 'Libra esterlina';

  @override
  String get currencyCOP => 'Peso colombiano';

  @override
  String get currencyBRL => 'Real brasileño';

  @override
  String get currencyMXN => 'Peso mexicano';

  @override
  String get currencyCAD => 'Dólar canadiense';

  @override
  String get currencyARS => 'Peso argentino';

  @override
  String get currencyCLP => 'Peso chileno';

  @override
  String get currencyPEN => 'Sol peruano';

  @override
  String get currencyCHF => 'Franco suizo';

  @override
  String get currencyJPY => 'Yen japonés';

  @override
  String get currencyAUD => 'Dólar australiano';

  @override
  String get tradingSubtotal => 'Subtotal';

  @override
  String get tradingCommission => 'Comisión Investy';

  @override
  String get tradingFeeSec31 => 'Tasa SEC';

  @override
  String get tradingFeeFinraTaf => 'Tasa de actividad FINRA';

  @override
  String get tradingFeeFinraCat => 'Tasa CAT de FINRA';

  @override
  String get tradingFeeBrokerSpread => 'Comisión del bróker';

  @override
  String get tradingTotalToPay => 'Total a pagar';

  @override
  String get tradingYouReceive => 'Recibís';

  @override
  String get tradingQuoteUnavailable =>
      'No pudimos calcular el costo. Intentá de nuevo.';

  @override
  String tradingOrderTooSmall(String min) {
    return 'La orden mínima es $min';
  }

  @override
  String get tradingSellTooSmall =>
      'Esta venta no cubre sus comisiones. Vendé un poco más.';
}
