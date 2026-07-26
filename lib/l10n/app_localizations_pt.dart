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
  String get commonDone => 'Concluído';

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
  String get signupNameRequired => 'O nome é obrigatório';

  @override
  String get signupEmailRequired => 'O e-mail é obrigatório';

  @override
  String get signupPasswordRequired => 'A senha é obrigatória';

  @override
  String get signupPasswordMinLength => 'Mínimo 6 caracteres';

  @override
  String get signupConfirmPasswordRequired => 'Por favor, confirme sua senha';

  @override
  String get signupPasswordMismatch => 'As senhas não coincidem';

  @override
  String get signupShowPassword => 'Mostrar senha';

  @override
  String get signupHidePassword => 'Ocultar senha';

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
  String get forgotPasswordEmailRequired => 'O e-mail é obrigatório';

  @override
  String forgotPasswordSentMessage(String email) {
    return 'Enviamos um link para $email. Verifique sua caixa de entrada e siga as instruções.';
  }

  @override
  String get forgotPasswordBackToSignIn => 'Voltar para entrar';

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
  String get dashboardToday => 'hoje';

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
  String get activityDetailQuantity => 'Quantidade';

  @override
  String get activityDetailPricePerUnit => 'Preço por unidade';

  @override
  String get activityDetailTotal => 'Total';

  @override
  String get activityDetailAmount => 'Valor';

  @override
  String get activityDetailDate => 'Data';

  @override
  String get activityDetailRealizedPnl => 'P&L realizado';

  @override
  String get activityDetailGain => 'Ganho';

  @override
  String get activityDetailLoss => 'Perda';

  @override
  String get portfolioTitle => 'Portfólio';

  @override
  String get portfolioNoHoldings =>
      'Sem posições ainda.\nCompre seu primeiro ativo para começar.';

  @override
  String get portfolioTotalInvested => 'Total investido';

  @override
  String get portfolioTotalLabel => 'Total';

  @override
  String get portfolioReturn => 'Retorno';

  @override
  String get assetDetailPosition => 'Sua posição';

  @override
  String get assetDetailMarketValue => 'Valor de mercado';

  @override
  String get assetDetailShowAvgCost => 'Meu custo médio';

  @override
  String get portfolioQuantity => 'Qtd';

  @override
  String get portfolioAvgCost => 'Custo médio';

  @override
  String get portfolioCurrentPrice => 'Preço atual';

  @override
  String get portfolioAssetStock => 'Ação';

  @override
  String get portfolioAssetCash => 'Dinheiro';

  @override
  String get portfolioAllocationTitle => 'Alocação';

  @override
  String get chartPortfolioValue => 'Valor da carteira';

  @override
  String get chartNotEnoughData =>
      'Ainda não há dados suficientes para o gráfico.';

  @override
  String get chartRange1W => '1S';

  @override
  String get chartRange1M => '1M';

  @override
  String get chartRange3M => '3M';

  @override
  String get chartRange1Y => '1A';

  @override
  String get chartRangeAll => 'TUDO';

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
  String get goalCash => 'Em caixa';

  @override
  String get goalInvested => 'Investido';

  @override
  String get goalDetailInvestmentsTitle => 'Investimentos para esta meta';

  @override
  String get goalDetailNoInvestments =>
      'Ainda não há investimentos atribuídos a esta meta.';

  @override
  String get goalDetailCashTitle => 'Dinheiro guardado';

  @override
  String goalDetailProjection(String date) {
    return 'Neste ritmo, você alcançará por volta de $date';
  }

  @override
  String get goalDetailProjectionUnknown =>
      'Adicione fundos para ver uma data estimada.';

  @override
  String get goalProjectionTitle => 'Projeção';

  @override
  String get goalOnTrack => 'No caminho';

  @override
  String get goalBehind => 'Atrasado';

  @override
  String get goalInvestButton => 'Investir para esta meta';

  @override
  String get buyAssignGoalLabel => 'Atribuir a uma meta? (opcional)';

  @override
  String get buyNoGoalOption => 'Sem meta';

  @override
  String get goalFormTitle => 'Nova meta';

  @override
  String get goalFormNameHint => 'Nome da meta';

  @override
  String get goalFormCategoryLabel => 'Categoria';

  @override
  String get categoryCar => 'Carro';

  @override
  String get categoryHome => 'Casa';

  @override
  String get categoryVacation => 'Férias';

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
  String buyTitle(String symbol) {
    return 'Comprar $symbol';
  }

  @override
  String get buyInsufficientFunds =>
      'Saldo insuficiente. Deposite fundos para continuar.';

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
  String sellSharesOwned(String quantity) {
    return '$quantity ações em sua posse';
  }

  @override
  String get sellPricePerShare => 'Preço por ação (preço de mercado)';

  @override
  String get sellEnterQuantity => 'Insira a quantidade';

  @override
  String get sellQuantityPositive => 'Deve ser maior que zero';

  @override
  String sellQuantityExceeds(String quantity) {
    return 'Você só tem $quantity ações';
  }

  @override
  String get sellEnterPrice => 'Insira o preço de venda';

  @override
  String get sellConfirm => 'Confirmar venda';

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
  String get withdrawCash => 'Sacar dinheiro';

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

  @override
  String get riskProfileSettingsLabel => 'Perfil de risco';

  @override
  String get riskProfileTitle => 'Perfil de risco';

  @override
  String riskProfileQuestionOf(int current, int total) {
    return '$current de $total';
  }

  @override
  String get riskProfileQ1 => 'Qual é o seu horizonte de investimento?';

  @override
  String get riskProfileQ1A1 => 'Menos de 1 ano';

  @override
  String get riskProfileQ1A2 => '1 a 3 anos';

  @override
  String get riskProfileQ1A3 => '3 a 7 anos';

  @override
  String get riskProfileQ1A4 => 'Mais de 7 anos';

  @override
  String get riskProfileQ2 => 'Se sua carteira caísse 20%, o que você faria?';

  @override
  String get riskProfileQ2A1 => 'Venderia tudo';

  @override
  String get riskProfileQ2A2 => 'Venderia algumas posições';

  @override
  String get riskProfileQ2A3 => 'Manteria e esperaria';

  @override
  String get riskProfileQ2A4 => 'Compraria mais';

  @override
  String get riskProfileQ3 =>
      'Como você descreveria sua experiência em investimentos?';

  @override
  String get riskProfileQ3A1 => 'Nenhuma';

  @override
  String get riskProfileQ3A2 => 'Básica';

  @override
  String get riskProfileQ3A3 => 'Moderada';

  @override
  String get riskProfileQ3A4 => 'Avançada';

  @override
  String get riskProfileQ4 => 'Quão estável é sua renda?';

  @override
  String get riskProfileQ4A1 => 'Muito instável';

  @override
  String get riskProfileQ4A2 => 'Instável';

  @override
  String get riskProfileQ4A3 => 'Estável';

  @override
  String get riskProfileQ4A4 => 'Muito estável';

  @override
  String get riskProfileQ5 =>
      'Qual é o seu principal objetivo de investimento?';

  @override
  String get riskProfileQ5A1 => 'Preservar o capital';

  @override
  String get riskProfileQ5A2 => 'Renda regular';

  @override
  String get riskProfileQ5A3 => 'Crescimento moderado';

  @override
  String get riskProfileQ5A4 => 'Máximo crescimento';

  @override
  String get riskProfileNext => 'Próximo';

  @override
  String get riskProfileSubmit => 'Ver meu perfil';

  @override
  String get riskProfileConservative => 'Conservador';

  @override
  String get riskProfileModerate => 'Moderado';

  @override
  String get riskProfileAggressive => 'Agressivo';

  @override
  String get riskProfileConservativeDesc =>
      'Você prefere estabilidade. Sua carteira prioriza a preservação de capital com ativos de baixo risco.';

  @override
  String get riskProfileModerateDesc =>
      'Você busca crescimento equilibrado. Sua carteira combina ativos estáveis com oportunidades de crescimento moderado.';

  @override
  String get riskProfileAggressiveDesc =>
      'Você busca o máximo crescimento. Sua carteira foca em ativos de alto crescimento e tolera a volatilidade.';

  @override
  String get riskProfileRetake => 'Refazer questionário';

  @override
  String get riskProfileNotCompleted => 'Não concluído';

  @override
  String get riskProfileLoadError =>
      'Não foi possível carregar o perfil de risco.';

  @override
  String get owlAiName => 'Owl AI';

  @override
  String get owlAiTagline => 'Recomendações de investimento para você';

  @override
  String get owlAiPoweredAdvisor => 'Assessor com inteligência artificial';

  @override
  String get owlAiAnalyzing => 'Analisando sua carteira…';

  @override
  String get owlAiStrongBuy => 'Compra forte';

  @override
  String get owlAiModerateSignal => 'Moderado';

  @override
  String get owlAiSuggested => 'Sugerido:';

  @override
  String get owlAiBuyButton => 'COMPRAR →';

  @override
  String get owlAiRefresh => 'Atualizar análise';

  @override
  String get owlAiUnavailable =>
      'O assistente IA está temporariamente indisponível.';

  @override
  String get owlAiErrorRetry =>
      'Não foi possível carregar as recomendações. Toque para tentar novamente.';

  @override
  String get owlAiRefreshing => 'Atualizando suas recomendações…';

  @override
  String get owlAiRefreshingSubtitle => 'Analisando seu portfólio e metas';

  @override
  String get owlAiAskNewRecs => 'Atualizar';

  @override
  String get owlHistoryButton => 'Histórico';

  @override
  String get owlHistoryTitle => 'Histórico da Coruja';

  @override
  String get owlHistoryEmpty =>
      'Ainda não há sessões. Peça recomendações à coruja para começar seu histórico.';

  @override
  String owlHistorySessionBanner(String date) {
    return 'Sessão de $date';
  }

  @override
  String owlHistoryDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Há $days dias',
      one: 'Ontem',
      zero: 'Hoje',
    );
    return '$_temp0';
  }

  @override
  String owlHistoryContext(String portfolio, String cash) {
    return 'Portfólio $portfolio · Dinheiro $cash';
  }

  @override
  String get owlAiCashAvailable => 'Disponível para investir';

  @override
  String get portfolioActive => 'Carteira ativa';

  @override
  String get greetingMorning => 'Bom dia,';

  @override
  String get greetingAfternoon => 'Boa tarde,';

  @override
  String get greetingEvening => 'Boa noite,';

  @override
  String get alertsTitle => 'Alertas de preço';

  @override
  String get alertsSettingsLabel => 'Alertas de preço';

  @override
  String get alertsEmpty => 'Você ainda não tem alertas de preço.';

  @override
  String get alertsEmptyHint =>
      'Crie um para ser avisado quando um ativo atingir seu preço-alvo.';

  @override
  String get alertsCreateTitle => 'Novo alerta de preço';

  @override
  String get alertsAssetLabel => 'Ativo';

  @override
  String get alertsConditionLabel => 'Condição';

  @override
  String get alertsSearchHint => 'Busque por símbolo ou nome';

  @override
  String get alertsSelectAssetFirst => 'Selecione um ativo primeiro';

  @override
  String alertsCurrentPrice(String price) {
    return 'Atual: $price';
  }

  @override
  String get alertsDirectionAbove => 'Sobe até ou acima de';

  @override
  String get alertsDirectionBelow => 'Cai até ou abaixo de';

  @override
  String get alertsTargetPriceHint => 'Preço-alvo (USD)';

  @override
  String get alertsCreateButton => 'Criar alerta';

  @override
  String get alertsCreated => 'Alerta criado';

  @override
  String get alertsDeleted => 'Alerta excluído';

  @override
  String get alertsStatusActive => 'Ativo';

  @override
  String get alertsStatusTriggered => 'Disparado';

  @override
  String alertsConditionAbove(String price) {
    return 'Acima de $price';
  }

  @override
  String alertsConditionBelow(String price) {
    return 'Abaixo de $price';
  }

  @override
  String get alertsErrorAlreadyMet =>
      'O preço atual já atende a este alvo. Escolha um diferente.';

  @override
  String get alertsErrorLimit => 'Você atingiu o máximo de 20 alertas ativos.';

  @override
  String get alertsErrorDuplicate =>
      'Você já tem um alerta idêntico para este ativo.';

  @override
  String get alertsErrorUnknownSymbol => 'Ativo desconhecido.';

  @override
  String get alertsDeleteTooltip => 'Excluir alerta';

  @override
  String get loginSessionTerminated =>
      'Sua sessão foi encerrada. Faça login novamente.';

  @override
  String get authErrorUserNotFound => 'Não existe uma conta com este e-mail';

  @override
  String get authErrorInvalidCredentials => 'E-mail ou senha inválidos';

  @override
  String get authErrorInvalidEmail => 'Formato de e-mail inválido';

  @override
  String get authErrorUserDisabled => 'Esta conta foi desativada';

  @override
  String get authErrorTooManyRequests =>
      'Muitas tentativas falhas. Tente novamente mais tarde';

  @override
  String get authErrorNetwork => 'Erro de rede. Verifique sua conexão';

  @override
  String get authErrorEmailInUse => 'Já existe uma conta com este e-mail';

  @override
  String get authErrorWeakPassword =>
      'A senha é muito fraca. Use pelo menos 6 caracteres';

  @override
  String get authErrorOperationNotAllowed =>
      'Contas de e-mail/senha não estão habilitadas';

  @override
  String get authErrorAccountExistsDifferentMethod =>
      'Já existe uma conta com este e-mail usando outro método de login';

  @override
  String get authErrorGoogleCancelled => 'Login com Google cancelado';

  @override
  String get authErrorWrongPassword => 'A senha está incorreta';

  @override
  String get authErrorRequiresRecentLogin => 'Saia e entre novamente primeiro';

  @override
  String get authErrorNoUser => 'Nenhum usuário conectado';

  @override
  String get authErrorVerificationEmailFailed =>
      'Não foi possível enviar o e-mail de verificação. Tente novamente';

  @override
  String get authErrorRefreshFailed =>
      'Não foi possível atualizar o status. Tente novamente';

  @override
  String get authErrorDeletionFailed =>
      'Não foi possível excluir a conta. Tente novamente';

  @override
  String get authErrorUnexpected =>
      'Ocorreu um erro inesperado. Tente novamente';

  @override
  String get goalFormTargetLabel => 'Valor alvo';

  @override
  String get goalFormDateLabel => 'Data alvo';

  @override
  String get goalFormCreateButton => 'Criar meta';

  @override
  String get goalFormNameRequired => 'Digite um nome para a meta';

  @override
  String get goalFormTargetRequired => 'Digite um valor alvo';

  @override
  String get goalFormTargetInvalid => 'O valor deve ser maior que zero';

  @override
  String get goalFormDateRequired => 'Selecione uma data alvo';

  @override
  String get goalFormCustomDate => 'Personalizada';

  @override
  String get goalFormCreateFailed =>
      'Não foi possível criar a meta. Tente novamente.';

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
  String get currencyUSD => 'Dólar americano';

  @override
  String get currencyEUR => 'Euro';

  @override
  String get currencyGBP => 'Libra esterlina';

  @override
  String get currencyCOP => 'Peso colombiano';

  @override
  String get currencyBRL => 'Real brasileiro';

  @override
  String get currencyMXN => 'Peso mexicano';

  @override
  String get currencyCAD => 'Dólar canadense';

  @override
  String get currencyARS => 'Peso argentino';

  @override
  String get currencyCLP => 'Peso chileno';

  @override
  String get currencyPEN => 'Sol peruano';

  @override
  String get currencyCHF => 'Franco suíço';

  @override
  String get currencyJPY => 'Iene japonês';

  @override
  String get currencyAUD => 'Dólar australiano';

  @override
  String get tradingSubtotal => 'Subtotal';

  @override
  String get tradingCommission => 'Comissão Investy';

  @override
  String get tradingFeeSec31 => 'Taxa SEC';

  @override
  String get tradingFeeFinraTaf => 'Taxa de atividade FINRA';

  @override
  String get tradingFeeFinraCat => 'Taxa CAT da FINRA';

  @override
  String get tradingFeeBrokerSpread => 'Comissão da corretora';

  @override
  String get tradingTotalToPay => 'Total a pagar';

  @override
  String get tradingYouReceive => 'Você recebe';

  @override
  String get tradingQuoteUnavailable =>
      'Não foi possível calcular o custo. Tente novamente.';

  @override
  String tradingOrderTooSmall(String min) {
    return 'O pedido mínimo é $min';
  }

  @override
  String get tradingSellTooSmall =>
      'Esta venda não cobre suas taxas. Venda um pouco mais.';

  @override
  String get onboardCurrencyTitle => 'Escolha sua moeda';

  @override
  String get onboardCurrencyBody =>
      'Você verá seus saldos e preços nesta moeda. Não pode ser alterada depois.';
}
