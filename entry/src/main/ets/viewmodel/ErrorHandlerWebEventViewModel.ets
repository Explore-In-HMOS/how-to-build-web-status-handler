import {ErrorHandlerEventOptions, ErrorHandlerEventStatus, ErrorHandlerEventType } from '../model/ErrorHandlerEvent'
import { ErrorHandlerPrompt, ErrorHandlerPromptAction, ErrorHandlerPromptType } from '../model/ErrorHandlerPrompt'
import { ErrorHandlerRunMode, ErrorHandlerScreen, ErrorHandlerUiState } from '../model/ErrorHandlerUiState'
import {ErrorHandlerAuthAction,ErrorHandlerAuthManager,ErrorHandlerAuthOperationResult} from '../service/ErrorHandlerAuthManager'
import { ErrorHandlerLogger } from '../service/ErrorHandlerLogger'
import { ErrorHandlerWebManager } from '../service/ErrorHandlerWebManager'
import { ErrorHandlerNavigationHistoryViewModel } from './ErrorHandlerNavigationHistoryViewModel'

export class ErrorHandlerWebEventViewModel {
  private uiState: ErrorHandlerUiState
  private historyViewModel: ErrorHandlerNavigationHistoryViewModel
  private webManager: ErrorHandlerWebManager
  private authManager: ErrorHandlerAuthManager
  private customNavigationToken: number = 0
  private customNavigationHasHandlerCallback: boolean = false
  private hasTerminalCallbackEvent: boolean = false
  private customUrlResultLocked: boolean = false
  private customUrlFallbackToken: number = 0
  private notifyUiChanged: () => void

  constructor(
    uiState: ErrorHandlerUiState,
    historyViewModel: ErrorHandlerNavigationHistoryViewModel,
    webManager: ErrorHandlerWebManager,
    authManager: ErrorHandlerAuthManager,
    notifyUiChanged: () => void
  ) {
    this.uiState = uiState
    this.historyViewModel = historyViewModel
    this.webManager = webManager
    this.authManager = authManager
    this.notifyUiChanged = notifyUiChanged
  }

  handlePageBegin(url: string): void {
    this.uiState.isLoading = true
    this.uiState.loadingProgress = 0
    this.uiState.statusMessage = 'Page loading started.'

    this.notifyUiChanged()
  }

  resetCustomUrlResultState(): void {
    this.customUrlResultLocked = false
    this.customUrlFallbackToken++
  }

  handlePageEnd(url: string): void {
    this.uiState.isLoading = false
    this.uiState.loadingProgress = 100
    this.uiState.statusMessage = 'Page loaded.'

    if (this.uiState.activeScreen !== ErrorHandlerScreen.CUSTOM_URL_TEST) {
      this.notifyUiChanged()
      return
    }

    if (this.customUrlResultLocked) {
      this.uiState.statusMessage = 'Custom URL finished with a captured WebView handler callback.'
      this.notifyUiChanged()
      return
    }
    const fallbackToken: number = this.customUrlFallbackToken

    setTimeout((): void => {
      if (this.uiState.activeScreen !== ErrorHandlerScreen.CUSTOM_URL_TEST) {
        return
      }

      if (fallbackToken !== this.customUrlFallbackToken) {
        return
      }

      if (this.customUrlResultLocked) {
        return
      }

      this.customUrlResultLocked = true
      this.historyViewModel.addEvent({
        scenarioId: 'CUSTOM_URL_TEST',
        type: ErrorHandlerEventType.PAGE_LOAD,
        status: ErrorHandlerEventStatus.INFO,
        url: url,
        message: 'Navigation finished without a WebView error handler callback.',
        action: 'No WebView error handler callback was triggered.',
        details: [
          `URL: ${url}`,
          'onPageEnd callback was received.',
          'No resource, HTTP, SSL, HTTP auth, or client auth callback was captured before the fallback check.',
          'This means the application did not capture a WebView error handler case for this custom URL.'
        ],
        isSimulated: false
      })
      this.notifyUiChanged()
    }, 500)
    this.notifyUiChanged()
  }

  private isCustomUrlTestActive(): boolean {
    return this.uiState.activeScreen === ErrorHandlerScreen.CUSTOM_URL_TEST
  }
  private normalizeUrlForCompare(url: string): string {
    let normalizedUrl: string = url.trim().toLowerCase()
    if (normalizedUrl.endsWith('/')) {
      normalizedUrl = normalizedUrl.substring(0, normalizedUrl.length - 1)
    }
    return normalizedUrl
  }

  private isSameCustomUrl(callbackUrl: string, currentUrl: string): boolean {
    const normalizedCallbackUrl: string = this.normalizeUrlForCompare(callbackUrl)
    const normalizedCurrentUrl: string = this.normalizeUrlForCompare(currentUrl)
    return normalizedCallbackUrl === normalizedCurrentUrl
  }
  private isCurrentCustomUrl(url: string): boolean {
    if (this.uiState.currentUrl.length === 0) {
      return false
    }
    const currentUrl: string = this.normalizeUrlForCompare(this.uiState.currentUrl)
    const callbackUrl: string = this.normalizeUrlForCompare(url)

    return callbackUrl === currentUrl
  }
  startCustomUrlNavigation(url: string): void {
    this.customUrlResultLocked = false
    this.customUrlFallbackToken++
    ErrorHandlerLogger.info(
      'CUSTOM_URL',
      `Custom URL result state reset. url=${url}`
    )
  }

  private readRequestUrl(request: WebResourceRequest): string {
    try {
      return request.getRequestUrl()
    } catch (error) {
      return ''
    }
  }

  private shouldAcceptCustomRequestEvent(request: WebResourceRequest): boolean {
    if (this.uiState.activeScreen !== ErrorHandlerScreen.CUSTOM_URL_TEST) {
      return true
    }
    const requestUrl: string = this.readRequestUrl(request)
    const currentUrl: string = this.uiState.currentUrl
    ErrorHandlerLogger.info(
      'CUSTOM_URL',
      `Accept check. locked=${this.customUrlResultLocked}, currentUrl=${currentUrl}, requestUrl=${requestUrl}`
    )

    if (this.customUrlResultLocked) {
      ErrorHandlerLogger.info(
        'CUSTOM_URL',
        'Custom URL callback ignored because result is already locked.'
      )
      return false
    }

    if (requestUrl.length === 0) {
      ErrorHandlerLogger.info(
        'CUSTOM_URL',
        'Custom URL callback ignored because request URL is empty.'
      )
      return false
    }

    if (!this.isSameCustomUrl(requestUrl, currentUrl)) {
      ErrorHandlerLogger.info(
        'CUSTOM_URL',
        'Custom URL callback ignored because request URL does not match current custom URL.'
      )
      return false
    }

    return true
  }
  private isMainFrameRequest(request: WebResourceRequest): boolean {
    try {
      return request.isMainFrame()
    } catch (error) {
      return true
    }
  }

  private shouldIgnoreCustomRequestEvent(request: WebResourceRequest): boolean {
    if (!this.isCustomUrlTestActive()) {
      return false
    }

    if (this.customUrlResultLocked) {
      return true
    }

    if (!this.isMainFrameRequest(request)) {
      return true
    }

    return false
  }

  private lockCustomUrlResultIfNeeded(): void {
    if (this.uiState.activeScreen !== ErrorHandlerScreen.CUSTOM_URL_TEST) {
      return
    }

    this.customUrlResultLocked = true
    this.customUrlFallbackToken++
  }

  handleProgressChange(progress: number): void {
    this.uiState.loadingProgress = progress
  }

  private isSuspiciousHost(url: string): boolean {
    const lowerUrl: string = url.toLowerCase()

    if (!lowerUrl.startsWith('https://') && !lowerUrl.startsWith('http://'))
    {
      return false
    }

    const withoutProtocol: string = lowerUrl
      .replace('https://', '')
      .replace('http://', '')

    const host: string = withoutProtocol.split('/')[0]

    if (!host.includes('.')) {
      return true
    }

    const hostParts: string[] = host.split('.')
    const tld: string = hostParts[hostParts.length - 1]

    return tld.length < 2 || host.includes('..')
  }

  handleResourceError(
    request: WebResourceRequest,
    error: WebResourceError
  ): void {
    if (!this.shouldAcceptCustomRequestEvent(request)) {
      ErrorHandlerLogger.info(
        'CUSTOM_URL',
        'Resource error ignored because request URL does not match current custom URL or result is already locked.'
      )
      return
    }

    this.lockCustomUrlResultIfNeeded()

    if (this.uiState.activeScreen === ErrorHandlerScreen.CUSTOM_URL_TEST) {
      this.customUrlResultLocked = true
    }

    this.uiState.isLoading = false

    const eventOptions: ErrorHandlerEventOptions =
      this.webManager.createResourceErrorEvent(
        this.getCurrentSourceId(),
        request,
        error
      )

    this.historyViewModel.addEvent(eventOptions)
    this.notifyUiChanged()
  }

  handleHttpError(
    request: WebResourceRequest,
    httpStatusCode: number,
    reasonPhrase: string
  ): void {
    if (!this.shouldAcceptCustomRequestEvent(request)) {
      ErrorHandlerLogger.info(
        'CUSTOM_URL',
        'HTTP error ignored because request URL does not match current custom URL or result is already locked.'
      )
      return
    }

    this.lockCustomUrlResultIfNeeded()
    this.uiState.isLoading = false

    ErrorHandlerLogger.info(
      'CUSTOM_URL',
      `Accepted HTTP error. currentUrl=${this.uiState.currentUrl}, status=${httpStatusCode}, reason=${reasonPhrase}`
    )

    const eventOptions: ErrorHandlerEventOptions =
      this.webManager.createHttpErrorEvent(
        this.getCurrentSourceId(),
        request,
        httpStatusCode,
        reasonPhrase
      )

    this.historyViewModel.addEvent(eventOptions)
    this.notifyUiChanged()
  }

  startCustomNavigationWatch(url: string): void {
    this.customNavigationToken++
    const currentToken: number = this.customNavigationToken

    setTimeout((): void => {
      if (currentToken !== this.customNavigationToken) {
        return
      }

      if (this.uiState.activeScreen !== ErrorHandlerScreen.CUSTOM_URL_TEST) {
        return
      }

      if (this.uiState.latestEvent !== undefined &&
        this.uiState.latestEvent.scenarioId === 'CUSTOM_URL_TEST') {
        return
      }

      this.uiState.isLoading = false
      this.uiState.statusMessage = 'No terminal WebView callback was received.'

      this.historyViewModel.addEvent({
        scenarioId: 'CUSTOM_URL_TEST',
        type: ErrorHandlerEventType.PAGE_LOAD,
        status: ErrorHandlerEventStatus.WARNING,
        url: url,
        message: 'No terminal WebView callback was received.',
        action: 'The navigation may still be pending, redirected, blocked, or handled internally by WebView.',
        details: [
          `URL: ${url}`,
          'Custom URL navigation was started.',
          'No error handler callback was captured before timeout.',
          'No page end callback was captured before timeout.',
          'Try a deterministic test URL.'
        ],
        isSimulated: false
      })

      this.notifyUiChanged()
    }, 8000)
  }
  handleSslError(
    handler: SslErrorHandler,
    errorDescription: string
  ): void {
    if (this.isCustomUrlTestActive() && this.customUrlResultLocked) {
      ErrorHandlerLogger.info(
        'CUSTOM_URL',
        'SSL error ignored because custom URL already has a result.'
      )
      return
    }

    this.lockCustomUrlResultIfNeeded()

    this.customNavigationToken++
    this.uiState.isLoading = false
    this.authManager.storeSslHandler(handler)

    this.uiState.pendingPrompt = new ErrorHandlerPrompt({
      type: ErrorHandlerPromptType.SSL_ERROR,
      title: 'SSL Warning',
      message: errorDescription,
      primaryLabel: 'Proceed',
      primaryAction: ErrorHandlerPromptAction.PROCEED,
      secondaryLabel: 'Cancel',
      secondaryAction: ErrorHandlerPromptAction.CANCEL
    })

    this.historyViewModel.addEvent({
      scenarioId: this.getCurrentSourceId(),
      type: ErrorHandlerEventType.SSL_ERROR,
      status: ErrorHandlerEventStatus.WARNING,
      url: this.uiState.currentUrl,
      message: errorDescription,
      action: 'Waiting for user decision.',
      details: [
        'onSslErrorEventReceive callback received.',
        'SslErrorHandler stored.',
        'SSL warning prompt created.'
      ],
      isSimulated: false
    })
    this.notifyUiChanged()
  }

  handleHttpAuthRequest(
    handler: HttpAuthHandler,
    host: string,
    realm: string
  ): boolean {
    if (this.isCustomUrlTestActive() && this.customUrlResultLocked) {
      ErrorHandlerLogger.info(
        'CUSTOM_URL',
        'HTTP auth request ignored because custom URL already has a result.'
      )
      return false
    }
    this.lockCustomUrlResultIfNeeded()


    this.customNavigationToken++
    this.uiState.isLoading = false
    this.authManager.storeHttpAuthHandler(handler)

    this.uiState.pendingPrompt = new ErrorHandlerPrompt({
      type: ErrorHandlerPromptType.HTTP_AUTH,
      title: 'Authentication Required',
      message: `Host: ${host}`,
      primaryLabel: 'Confirm',
      primaryAction: ErrorHandlerPromptAction.CONFIRM,
      secondaryLabel: 'Cancel',
      secondaryAction: ErrorHandlerPromptAction.CANCEL,
      requiresCredentialInput: true
    })

    this.historyViewModel.addEvent({
      scenarioId: this.getCurrentSourceId(),
      type: ErrorHandlerEventType.HTTP_AUTH,
      status: ErrorHandlerEventStatus.WARNING,
      url: this.uiState.currentUrl,
      message: 'HTTP authentication request received.',
      action: 'Waiting for credentials.',
      details: [
        `Host: ${host}`,
        `Realm: ${realm}`,
        'onHttpAuthRequest callback received.',
        'HttpAuthHandler stored.',
        'Credential prompt opened.'
      ],
      isSimulated: false
    })

    this.notifyUiChanged()
    return true
  }

  handleClientAuthenticationRequest(
    handler: ClientAuthenticationHandler,
    host: string,
    port: number,
    keyTypes: string[],
    issuers: string[]
  ): void {
    if (this.uiState.activeScreen === ErrorHandlerScreen.CUSTOM_URL_TEST) {
      this.customNavigationHasHandlerCallback = true
    }

    this.lockCustomUrlResultIfNeeded()

    this.customNavigationToken++
    this.uiState.isLoading = false
    this.authManager.storeClientAuthHandler(handler)

    this.uiState.pendingPrompt = new ErrorHandlerPrompt({
      type: ErrorHandlerPromptType.CLIENT_AUTH,
      title: 'Client Certificate Required',
      message: `Host: ${host}:${port}`,
      primaryLabel: 'Use Certificate',
      primaryAction: ErrorHandlerPromptAction.USE_CERTIFICATE,
      secondaryLabel: 'Cancel',
      secondaryAction: ErrorHandlerPromptAction.CANCEL,
      tertiaryLabel: 'Ignore',
      tertiaryAction: ErrorHandlerPromptAction.IGNORE
    })

    this.historyViewModel.addEvent({
      scenarioId: this.getCurrentSourceId(),
      type: ErrorHandlerEventType.CLIENT_AUTH,
      status: ErrorHandlerEventStatus.WARNING,
      url: this.uiState.currentUrl,
      message: 'Client authentication request received.',
      action: 'Waiting for certificate decision.',
      details: [
        `Host: ${host}`,
        `Port: ${port}`,
        `Key types: ${keyTypes.join(', ')}`,
        `Issuers: ${issuers.join(', ')}`,
        'onClientAuthenticationRequest callback received.',
        'ClientAuthenticationHandler stored.'
      ],
      isSimulated: false
    })
    this.notifyUiChanged()
  }

  resolvePrompt(
    action: ErrorHandlerPromptAction,
    username: string,
    password: string,
    privateKeyFilePath: string,
    certificateChainFilePath: string
  ): void {
    if (this.uiState.pendingPrompt === undefined) {
      return
    }

    const promptType: ErrorHandlerPromptType = this.uiState.pendingPrompt.type

    if (promptType === ErrorHandlerPromptType.SSL_ERROR) {
      this.resolveSslPrompt(action)
      return
    }

    if (promptType === ErrorHandlerPromptType.HTTP_AUTH) {
      this.resolveHttpAuthPrompt(action, username, password)
      return
    }

    if (promptType === ErrorHandlerPromptType.CLIENT_AUTH) {
      this.resolveClientAuthPrompt(
        action,
        privateKeyFilePath,
        certificateChainFilePath
      )
    }
    this.notifyUiChanged()
  }

  private resolveSslPrompt(action: ErrorHandlerPromptAction): void {
    let result: ErrorHandlerAuthOperationResult

    if (this.isSimulatedScenarioPrompt()) {
      result = this.createSimulatedAuthResult(
        action === ErrorHandlerPromptAction.PROCEED
          ? ErrorHandlerAuthAction.SSL_CONFIRM
          : ErrorHandlerAuthAction.SSL_CANCEL,
        action === ErrorHandlerPromptAction.PROCEED
          ? 'SSL warning accepted.'
          : 'SSL warning cancelled.',
        [
          action === ErrorHandlerPromptAction.PROCEED
            ? 'User selected Proceed.'
            : 'User selected Cancel.',
          'No real SslErrorHandler is used in simulated mode.',
          'Prompt closed.'
        ]
      )
    } else if (action === ErrorHandlerPromptAction.PROCEED) {
      result = this.authManager.confirmSslError()
    } else {
      result = this.authManager.cancelSslError()
    }

    this.addPromptResultEvent(
      ErrorHandlerEventType.SSL_ERROR,
      result
    )

    this.uiState.pendingPrompt = undefined
    this.uiState.statusMessage = 'SSL prompt resolved.'
    this.notifyUiChanged()
  }

  private resolveHttpAuthPrompt(
    action: ErrorHandlerPromptAction,
    username: string,
    password: string
  ): void {
    let result: ErrorHandlerAuthOperationResult

    if (this.isSimulatedScenarioPrompt()) {
      result = this.createSimulatedAuthResult(
        action === ErrorHandlerPromptAction.CONFIRM
          ? ErrorHandlerAuthAction.HTTP_AUTH_CONFIRM
          : ErrorHandlerAuthAction.HTTP_AUTH_CANCEL,
        action === ErrorHandlerPromptAction.CONFIRM
          ? 'HTTP authentication submitted.'
          : 'HTTP authentication cancelled.',
        [
          action === ErrorHandlerPromptAction.CONFIRM
            ? `Username provided: ${username.length > 0}`
            : 'User selected Cancel.',
          action === ErrorHandlerPromptAction.CONFIRM
            ? `Password provided: ${password.length > 0}`
            : 'No credentials were submitted.',
          'No real HttpAuthHandler is used in simulated mode.',
          'Prompt closed.'
        ]
      )
    } else if (action === ErrorHandlerPromptAction.CONFIRM) {
      result = this.authManager.confirmHttpAuth(username, password)
    } else {
      result = this.authManager.cancelHttpAuth()
    }

    this.addPromptResultEvent(
      ErrorHandlerEventType.HTTP_AUTH,
      result
    )

    this.uiState.pendingPrompt = undefined
    this.uiState.statusMessage = 'HTTP auth prompt resolved.'

    this.notifyUiChanged()
  }

  private resolveClientAuthPrompt(
    action: ErrorHandlerPromptAction,
    privateKeyFilePath: string,
    certificateChainFilePath: string
  ): void {
    let result: ErrorHandlerAuthOperationResult

    if (this.isSimulatedScenarioPrompt()) {
      result = this.createSimulatedClientAuthResult(
        action,
        privateKeyFilePath,
        certificateChainFilePath
      )
    } else if (action === ErrorHandlerPromptAction.USE_CERTIFICATE) {
      result = this.authManager.confirmClientAuthentication(
        privateKeyFilePath,
        certificateChainFilePath
      )
    } else if (action === ErrorHandlerPromptAction.IGNORE) {
      result = this.authManager.ignoreClientAuthentication()
    } else {
      result = this.authManager.cancelClientAuthentication()
    }

    this.addPromptResultEvent(
      ErrorHandlerEventType.CLIENT_AUTH,
      result
    )

    this.uiState.pendingPrompt = undefined
    this.uiState.statusMessage = 'Client auth prompt resolved.'

    this.notifyUiChanged()
  }

  private createSimulatedClientAuthResult(
    action: ErrorHandlerPromptAction,
    privateKeyFilePath: string,
    certificateChainFilePath: string
  ): ErrorHandlerAuthOperationResult {
    if (action === ErrorHandlerPromptAction.USE_CERTIFICATE) {
      return this.createSimulatedAuthResult(
        ErrorHandlerAuthAction.CLIENT_AUTH_CONFIRM,
        'Client certificate submitted.',
        [
          `Private key path provided: ${privateKeyFilePath.length > 0}`,
          `Certificate chain path provided: ${certificateChainFilePath.length > 0}`,
          'No real ClientAuthenticationHandler is used in simulated mode.',
          'Prompt closed.'
        ]
      )
    }

    if (action === ErrorHandlerPromptAction.IGNORE) {
      return this.createSimulatedAuthResult(
        ErrorHandlerAuthAction.CLIENT_AUTH_IGNORE,
        'Client authentication ignored.',
        [
          'User selected Ignore.',
          'No real ClientAuthenticationHandler is used in simulated mode.',
          'Prompt closed.'
        ]
      )
    }

    return this.createSimulatedAuthResult(
      ErrorHandlerAuthAction.CLIENT_AUTH_CANCEL,
      'Client authentication cancelled.',
      [
        'User selected Cancel.',
        'No real ClientAuthenticationHandler is used in simulated mode.',
        'Prompt closed.'
      ]
    )
    this.notifyUiChanged()
  }

  private addPromptResultEvent(
    type: ErrorHandlerEventType,
    result: ErrorHandlerAuthOperationResult
  ): void {
    this.historyViewModel.addEvent({
      scenarioId: this.getCurrentSourceId(),
      type: type,
      status: result.success
        ? ErrorHandlerEventStatus.INFO
        : ErrorHandlerEventStatus.WARNING,
      url: this.uiState.currentUrl,
      message: result.message,
      action: result.action,
      details: result.details,
      isSimulated: this.isSimulatedScenarioPrompt()
    })
    this.notifyUiChanged()
  }

  private createSimulatedAuthResult(
    action: ErrorHandlerAuthAction,
    message: string,
    details: string[]
  ): ErrorHandlerAuthOperationResult {
    return {
      success: true,
      action: action,
      message: message,
      details: details
    }
  }

  private isSimulatedScenarioPrompt(): boolean {
    return this.uiState.activeScreen !== ErrorHandlerScreen.CUSTOM_URL_TEST &&
      this.uiState.runMode === ErrorHandlerRunMode.SIMULATED
  }

  private getCurrentSourceId(): string {
    if (this.uiState.activeScreen === ErrorHandlerScreen.CUSTOM_URL_TEST) {
      return 'CUSTOM_URL_TEST'
    }

    return this.uiState.selectedScenario.id
  }
}