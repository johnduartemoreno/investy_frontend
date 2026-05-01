// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Investy';

  @override
  String get navHome => 'Início';

  @override
  String get navGoals => 'Metas';

  @override
  String get navPortfolio => 'Portfólio';

  @override
  String get navSettings => 'Configurações';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonRetry => 'Tentar novamente';

  @override
  String get commonLoading => 'Carregando...';

  @override
  String get commonEmail => 'E-mail';

  @override
  String get commonPassword => 'Senha';

  @override
  String get commonName => 'Nome';

  @override
  String get commonError => 'Algo deu errado. Tente novamente.';

  @override
  String get commonLogOut => 'Sair';

  @override
  String get errorRequiredField => 'Este campo é obrigatório';

  @override
  String get errorInvalidEmail => 'Insira um e-mail válido';

  @override
  String get errorPasswordTooShort =>
      'A senha deve ter pelo menos 6 caracteres';

  @override
  String get errorPasswordMismatch => 'As senhas não coincidem';

  @override
  String get errorNetwork => 'Erro de rede. Verifique sua conexão.';

  @override
  String get loginTitle => 'Bem-vindo de volta!';

  @override
  String get loginSubtitle => 'Acesse seus investimentos com segurança.';

  @override
  String get loginRememberEmail => 'Lembrar e-mail';

  @override
  String get loginOrContinueWith => 'Ou continuar com';

  @override
  String get loginEmailHint => 'E-mail';

  @override
  String get loginPasswordHint => 'Senha';

  @override
  String get loginButton => 'Entrar';

  @override
  String get loginForgotPassword => 'Esqueceu a senha?';

  @override
  String get loginNoAccount => 'Não tem uma conta?';

  @override
  String get loginSignUp => 'Cadastre-se';

  @override
  String get loginWithGoogle => 'Continuar com Google';

  @override
  String get signupTitle => 'Criar conta';

  @override
  String get signupSubtitle => 'Comece a investir hoje';

  @override
  String get signupNameHint => 'Nome completo';

  @override
  String get signupEmailHint => 'E-mail';

  @override
  String get signupPasswordHint => 'Senha';

  @override
  String get signupConfirmPasswordHint => 'Confirmar senha';

  @override
  String get signupCurrencyLabel => 'Moeda de exibição';

  @override
  String get signupButton => 'Criar conta';

  @override
  String get signupHaveAccount => 'Já tem uma conta?';

  @override
  String get signupLogIn => 'Entrar';

  @override
  String get forgotPasswordTitle => 'Redefinir senha';

  @override
  String get forgotPasswordSubtitle =>
      'Insira seu e-mail e enviaremos um link de redefinição';

  @override
  String get forgotPasswordEmailHint => 'E-mail';

  @override
  String get forgotPasswordButton => 'Enviar link';

  @override
  String get forgotPasswordSuccess =>
      'Link enviado. Verifique sua caixa de entrada.';

  @override
  String get emailVerificationTitle => 'Verifique seu e-mail';

  @override
  String emailVerificationSubtitle(String email) {
    return 'Enviamos um link de verificação para $email. Verifique sua caixa de entrada.';
  }

  @override
  String get emailVerificationResend => 'Reenviar e-mail';

  @override
  String get emailVerificationLogout => 'Usar outra conta';

  @override
  String get emailVerificationNotVerified =>
      'Por favor, verifique seu e-mail primeiro';

  @override
  String get emailVerificationSent =>
      'E-mail de verificação enviado! Verifique sua caixa de entrada.';

  @override
  String dashboardGreeting(String name) {
    return 'Olá, $name';
  }

  @override
  String get dashboardWelcomeBack => 'Bem-vindo de volta,';

  @override
  String get dashboardTotalBalance => 'Saldo total';

  @override
  String get dashboardInvestedPortfolio => 'Portfólio investido';

  @override
  String get dashboardCashToInvest => 'Dinheiro para investir';

  @override
  String get dashboardInvestedValue => 'Investido';

  @override
  String get dashboardRecentActivity => 'Atividade recente';

  @override
  String get dashboardSeeAll => 'Ver tudo';

  @override
  String get dashboardNoActivity => 'Sem atividade recente';

  @override
  String get dashboardBuy => 'Comprar';

  @override
  String get dashboardSell => 'Vender';

  @override
  String get dashboardTopUp => 'Depositar';

  @override
  String get dashboardWithdraw => 'Sacar';

  @override
  String get dashboardAvailableCash => 'Dinheiro disponível';

  @override
  String get commonToday => 'Hoje';

  @override
  String get commonYesterday => 'Ontem';

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
  String get activityWithdrawal => 'Saque';

  @override
  String get activityUnknown => 'Desconhecido';

  @override
  String get portfolioTitle => 'Portfólio';

  @override
  String get portfolioNoHoldings =>
      'Sem posições ainda.\nCompre seu primeiro ativo para começar.';

  @override
  String get portfolioTotalInvested => 'Total investido';

  @override
  String get portfolioReturn => 'Retorno';

  @override
  String get portfolioQuantity => 'Qtd';

  @override
  String get portfolioAvgCost => 'Custo médio';

  @override
  String get portfolioCurrentPrice => 'Preço atual';

  @override
  String get portfolioAssetStock => 'Ação';

  @override
  String get portfolioAssetCrypto => 'Cripto';

  @override
  String get portfolioAssetEtf => 'ETF';

  @override
  String get portfolioShares => 'ações';

  @override
  String get goalsTitle => 'Metas';

  @override
  String get goalsNoGoals =>
      'Sem metas ainda.\nCrie uma para começar a poupar.';

  @override
  String get goalsAddButton => 'Adicionar meta';

  @override
  String goalProgress(int percent) {
    return '$percent% alcançado';
  }

  @override
  String get goalTarget => 'Meta';

  @override
  String get goalSaved => 'Poupado';

  @override
  String get goalDeadline => 'Prazo';

  @override
  String get goalCategory => 'Categoria';

  @override
  String get goalFormTitle => 'Nova meta';

  @override
  String get goalFormNameHint => 'Nome da meta';

  @override
  String get goalFormTargetHint => 'Valor alvo';

  @override
  String get goalFormDeadlineLabel => 'Prazo';

  @override
  String get goalFormCategoryLabel => 'Categoria';

  @override
  String get goalFormSaveButton => 'Salvar meta';

  @override
  String get goalFormSelectDate => 'Selecionar data';

  @override
  String get categoryCar => 'Carro';

  @override
  String get categoryHome => 'Casa';

  @override
  String get categoryVacation => 'Férias';

  @override
  String get categoryTravel => 'Viagem';

  @override
  String get categoryEducation => 'Educação';

  @override
  String get categoryEmergency => 'Emergência';

  @override
  String get categoryHealth => 'Saúde';

  @override
  String get categoryOther => 'Outro';

  @override
  String get buyAssetTitle => 'Comprar ativo';

  @override
  String get buySelectAsset => 'Selecione um ativo';

  @override
  String get buyPerShare => 'por ação';

  @override
  String get buyEnterQuantity => 'Insira a quantidade';

  @override
  String get buyQuantityPositive => 'Deve ser maior que 0';

  @override
  String get buyConfirmButton => 'Confirmar compra';

  @override
  String get buyEstimatedTotal => 'Total estimado';

  @override
  String buyTitle(String symbol) {
    return 'Comprar $symbol';
  }

  @override
  String get buyQuantityLabel => 'Quantidade';

  @override
  String get buyPriceLabel => 'Preço por unidade';

  @override
  String get buyTotalLabel => 'Total';

  @override
  String get buyButton => 'Comprar';

  @override
  String get buySuccess => 'Compra realizada com sucesso';

  @override
  String get sellAssetTitle => 'Vender ativo';

  @override
  String get sellNoAssets => 'Você ainda não tem ativos';

  @override
  String get sellNoAssetsSubtitle =>
      'Compre seu primeiro ativo para começar a construir seu portfólio.';

  @override
  String get sellBuyFirstAsset => 'Comprar meu primeiro ativo';

  @override
  String sellTitle(String symbol) {
    return 'Vender $symbol';
  }

  @override
  String get sellQuantityLabel => 'Quantidade';

  @override
  String get sellButton => 'Vender';

  @override
  String get sellSuccess => 'Venda realizada com sucesso';

  @override
  String sellMaxQuantity(String quantity) {
    return 'Máx: $quantity';
  }

  @override
  String get topUpTitle => 'Depositar';

  @override
  String get topUpEnterAmount => 'Inserir valor';

  @override
  String get topUpAmountRequired => 'Por favor insira um valor';

  @override
  String get topUpAmountInvalid => 'Por favor insira um valor válido';

  @override
  String get topUpConfirmButton => 'Confirmar depósito';

  @override
  String get topUpAmountHint => 'Valor';

  @override
  String get topUpButton => 'Adicionar fundos';

  @override
  String get topUpSuccess => 'Fundos adicionados com sucesso';

  @override
  String get withdrawTitle => 'Sacar';

  @override
  String get withdrawCash => 'Retirar dinheiro';

  @override
  String get withdrawAvailableTo => 'Disponível para saque';

  @override
  String get withdrawConfirmButton => 'Confirmar saque';

  @override
  String get withdrawEnterAmount => 'Insira um valor';

  @override
  String get withdrawAmountPositive => 'O valor deve ser positivo';

  @override
  String get withdrawAmountHint => 'Valor';

  @override
  String get withdrawButton => 'Sacar';

  @override
  String get withdrawSuccess => 'Saque realizado com sucesso';

  @override
  String get withdrawInsufficientFunds => 'Fundos insuficientes';

  @override
  String get assetSearchHint => 'Buscar ativos (ex. AAPL, BTC)';

  @override
  String get assetSearchEmpty => 'Nenhum ativo encontrado';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsCurrency => 'Moeda';

  @override
  String get settingsNotifications => 'Notificações';

  @override
  String get settingsPrivacySecurity => 'Privacidade e segurança';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsAbout => 'Sobre o Investy';

  @override
  String get settingsHelp => 'Ajuda e suporte';

  @override
  String get securityTitle => 'Privacidade e segurança';

  @override
  String get securityAccountSection => 'Segurança da conta';

  @override
  String get securityDangerSection => 'Zona de perigo';

  @override
  String get securityChangePassword => 'Alterar senha';

  @override
  String get securityChangePasswordSubtitle => 'Atualize sua senha de acesso';

  @override
  String get securityManagedByGoogle => 'Gerenciado pelo Google';

  @override
  String get securityDeleteAccount => 'Excluir conta';

  @override
  String get securityDeleteAccountSubtitle =>
      'Remove permanentemente sua conta e todos os dados';

  @override
  String get changePasswordTitle => 'Alterar senha';

  @override
  String get changePasswordCurrent => 'Senha atual';

  @override
  String get changePasswordNew => 'Nova senha';

  @override
  String get changePasswordConfirm => 'Confirmar nova senha';

  @override
  String get changePasswordButton => 'Atualizar senha';

  @override
  String get changePasswordSuccess => 'Senha atualizada com sucesso';

  @override
  String get changePasswordErrorWrongPassword =>
      'A senha atual está incorreta.';

  @override
  String get changePasswordErrorRecentLogin =>
      'Por favor saia e entre novamente antes de alterar sua senha.';

  @override
  String get changePasswordErrorFailed =>
      'Não foi possível alterar a senha. Tente novamente.';

  @override
  String get deleteAccountTitle => 'Excluir conta';

  @override
  String get deleteAccountWarning =>
      'Esta ação é permanente e irreversível. Todos os seus dados serão excluídos.';

  @override
  String get deleteAccountConfirmTitle => 'Confirmar exclusão';

  @override
  String get deleteAccountConfirmPassword => 'Insira sua senha para confirmar';

  @override
  String get deleteAccountConfirmEmail => 'Digite seu e-mail para confirmar';

  @override
  String get deleteAccountConfirmEmailText =>
      'Digite seu e-mail para confirmar a exclusão.';

  @override
  String get deleteAccountConfirmPasswordText =>
      'Insira sua senha para confirmar a exclusão.';

  @override
  String get deleteAccountEmailMismatch =>
      'O e-mail não confere. Tente novamente.';

  @override
  String get deleteAccountEnterPassword => 'Por favor insira sua senha.';

  @override
  String deleteAccountYourEmail(String email) {
    return 'Seu e-mail: $email';
  }

  @override
  String get deleteAccountButton => 'Excluir minha conta';

  @override
  String get notificationsTitle => 'Notificações';

  @override
  String get notificationsPush => 'Notificações push';

  @override
  String get notificationsPushSubtitle =>
      'Receba alertas de metas e transações';

  @override
  String get notificationsGoalReminders => 'Lembretes de metas';

  @override
  String get notificationsGoalRemindersSubtitle =>
      'Lembretes semanais de progresso das suas metas';

  @override
  String get notificationsEnable => 'Ativar notificações';

  @override
  String get notificationsDescription =>
      'Você será notificado quando:\n• Um depósito ou saque for processado\n• Uma ordem de compra ou venda for confirmada\n• O prazo de uma meta financeira se aproximar (30 dias)';

  @override
  String get appearanceTitle => 'Aparência';

  @override
  String get appearanceTheme => 'Tema';

  @override
  String get appearanceThemeSystem => 'Sistema';

  @override
  String get appearanceThemeLight => 'Claro';

  @override
  String get appearanceThemeDark => 'Escuro';

  @override
  String get appearanceLanguage => 'Idioma';

  @override
  String get languageEn => 'Inglês';

  @override
  String get languageEs => 'Espanhol';

  @override
  String get languagePt => 'Português (BR)';

  @override
  String get aboutTitle => 'Sobre o Investy';

  @override
  String get aboutVersion => 'Versão';

  @override
  String get aboutDescription =>
      'O Investy ajuda você a planejar e acompanhar seus investimentos em direção às suas metas.';

  @override
  String get aboutTerms => 'Termos de serviço';

  @override
  String get aboutPrivacy => 'Política de privacidade';

  @override
  String get helpTitle => 'Ajuda e suporte';

  @override
  String get helpFaq => 'Perguntas frequentes';

  @override
  String get helpContact => 'Falar com suporte';

  @override
  String get helpDocumentation => 'Documentação';

  @override
  String get helpReplyTime => 'Respondemos em até 24 horas';

  @override
  String get helpFaq1Q => 'Como adiciono dinheiro à minha conta?';

  @override
  String get helpFaq1A =>
      'Toque em \"Depositar\" na tela inicial e insira o valor que deseja depositar. Os fundos serão creditados no seu saldo de caixa disponível.';

  @override
  String get helpFaq2Q => 'Como compro um ativo?';

  @override
  String get helpFaq2A =>
      'Toque em \"Comprar\" na tela inicial, busque o ativo pelo nome ou símbolo, insira a quantidade e confirme a compra.';

  @override
  String get helpFaq3Q => 'Como defino uma meta financeira?';

  @override
  String get helpFaq3A =>
      'Navegue até a aba Metas e toque no botão \"+\". Insira um nome, valor alvo, categoria e prazo. Suas contribuições serão contadas automaticamente para suas metas.';

  @override
  String get helpFaq4Q => 'Posso sacar meus fundos a qualquer momento?';

  @override
  String get helpFaq4A =>
      'Sim. Toque em \"Sacar\" na tela inicial e insira o valor. Os saques são processados do seu saldo de caixa disponível.';

  @override
  String get helpFaq5Q => 'O que acontece se eu esquecer minha senha?';

  @override
  String get helpFaq5A =>
      'Na tela de login, toque em \"Esqueceu a senha?\" e insira seu e-mail. Enviaremos um link de redefinição em poucos minutos.';

  @override
  String get kycTitle => 'Verificação de identidade';

  @override
  String get kycIntroBody =>
      'Para começar a investir, precisamos verificar sua identidade. É exigido por regulamentações financeiras e leva cerca de 5 minutos.';

  @override
  String get kycStartButton => 'Iniciar verificação';

  @override
  String get kycRetryButton => 'Tentar novamente';

  @override
  String get kycCameraPermissionTitle => 'Acesso à câmera necessário';

  @override
  String get kycCameraPermissionBody =>
      'O acesso à câmera foi negado. Habilite nas Configurações para completar a verificação.';

  @override
  String get kycOpenSettings => 'Abrir Configurações';

  @override
  String get kycApprovedTitle => 'Verificado';

  @override
  String get kycApprovedBody =>
      'Sua identidade foi verificada. Agora você pode comprar e vender ativos.';

  @override
  String get kycPendingTitle => 'Em revisão';

  @override
  String get kycPendingBody =>
      'Seus documentos foram enviados. Normalmente concluímos a verificação em 24 horas.';

  @override
  String get kycRejectedTitle => 'Verificação falhou';

  @override
  String get kycRejectedBody =>
      'Não conseguimos verificar sua identidade. Por favor, tente novamente com uma foto clara do seu documento de identidade.';

  @override
  String get kycBannerRequired =>
      'Verifique sua identidade para começar a negociar. Toque aqui.';

  @override
  String get kycBannerPending =>
      'A verificação de identidade está em análise. A negociação será habilitada após aprovação.';

  @override
  String get kycSettingsLabel => 'Verificação de identidade';

  @override
  String get kycReqLegalName => 'Nome legal completo';

  @override
  String get kycReqDob => 'Data de nascimento';

  @override
  String get kycReqAddress => 'Endereço residencial';

  @override
  String get kycReqId => 'Documento de identidade oficial';

  @override
  String get kycReqTaxId => 'Número de identificação fiscal';

  @override
  String get brokerSettingsLabel => 'Conta de Investimento';

  @override
  String get brokerStatusPending => 'Pendente';

  @override
  String get brokerStatusActive => 'Ativa';

  @override
  String get brokerStatusRejected => 'Rejeitada';

  @override
  String get brokerBannerPending =>
      'Sua conta de investimento está em análise. O trading ao vivo será habilitado após a aprovação.';

  @override
  String get brokerBannerNotActive =>
      'Conta de investimento não configurada. O paper trading está ativo.';
}
