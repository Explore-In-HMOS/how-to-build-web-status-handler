import { ErrorHandlerScenario } from '../model/ErrorHandlerScenario'
import {ErrorHandlerEventStatus, ErrorHandlerEventType } from '../model/ErrorHandlerEvent'
import { ErrorHandlerPrompt, ErrorHandlerPromptAction, ErrorHandlerPromptType } from '../model/ErrorHandlerPrompt'
import { ErrorHandlerRunMode, ErrorHandlerScreen,  ErrorHandlerUiState } from '../model/ErrorHandlerUiState'
import { ErrorHandlerAuthManager } from '../service/ErrorHandlerAuthManager'
import { ErrorHandlerLogger } from '../service/ErrorHandlerLogger'
import { ErrorHandlerWebControllerManager } from '../service/ErrorHandlerWebControllerManager'
import { ErrorHandlerNavigationHistoryViewModel } from './ErrorHandlerNavigationHistoryViewModel'
import { ErrorHandlerSchemeManager } from '../service/ErrorHandlerSchemeManager'

export class ErrorHandlerRunViewModel {
  private uiState: ErrorHandlerUiState
  private historyViewModel: ErrorHandlerNavigationHistoryViewModel
  private authManager: ErrorHandlerAuthManager
  private schemeManager: ErrorHandlerSchemeManager
  private webControllerManager: ErrorHandlerWebControllerManager
  private notifyUiChanged: () => void
  private customNavigationStartHandler: ((url: string) => void) | undefined = undefined

  constructor(
    uiState: ErrorHandlerUiState,
    historyViewModel: ErrorHandlerNavigationHistoryViewModel,
    authManager: ErrorHandlerAuthManager,
    schemeManager: ErrorHandlerSchemeManager,
    webControllerManager: ErrorHandlerWebControllerManager,
    notifyUiChanged: () => void
  ) {
    this.uiState = uiState
    this.historyViewModel = historyViewModel
    this.authManager = authManager
    this.schemeManager = schemeManager
    this.webControllerManager = webControllerManager
    this.notifyUiChanged = notifyUiChanged
  }


  selectScenario(scenario: ErrorHandlerScenario): void {
    this.uiState.selectedScenario = scenario
    this.uiState.currentUrl = scenario.testUrl
    this.uiState.latestEvent = undefined
    this.uiState.selectedEvent = undefined
    this.uiState.pendingPrompt = undefined
    this.uiState.loadingProgress = 0
    this.uiState.statusMessage = `${scenario.shortTitle} selected.`

    this.notifyUiChanged()
  }

  setRunMode(runMode: ErrorHandlerRunMode): void {
    this.uiState.runMode = runMode
    this.uiState.pendingPrompt = undefined
    this.uiState.statusMessage = `${runMode} mode selected.`

    this.notifyUiChanged()
  }
  runSelectedScenario(): void {
    if (this.uiState.pendingPrompt !== undefined) {
      this.uiState.statusMessage = 'Resolve the current prompt before running again.'
      this.notifyUiChanged()
      return
    }

    this.authManager.clearAllHandlers()

    this.uiState.activeScreen = ErrorHandlerScreen.SCENARIO_TEST
    this.uiState.latestEvent = undefined
    this.uiState.selectedEvent = undefined
    this.uiState.pendingPrompt = undefined
    this.uiState.currentUrl = this.uiState.selectedScenario.testUrl
    this.uiState.loadingProgress = 0
    this.uiState.statusMessage = 'Running selected scenario...'

    this.notifyUiChanged()

    if (this.uiState.runMode === ErrorHandlerRunMode.SIMULATED) {
      this.runSimulatedScenario()
      this.notifyUiChanged()
      return
    }

    this.prepareLiveScenario()
    this.notifyUiChanged()
  }

  retrySelectedScenario(): void {
    if (!this.uiState.selectedScenario.supportsRetry) {
      this.uiState.statusMessage = 'Retry is not supported for this scenario.'
      return
    }

    if (this.uiState.runMode === ErrorHandlerRunMode.SIMULATED) {
      this.historyViewModel.addEvent({
        scenarioId: this.uiState.selectedScenario.id,
        type: ErrorHandlerEventType.RETRY,
        status: ErrorHandlerEventStatus.INFO,
        url: this.uiState.selectedScenario.testUrl,
        message: 'Retry requested for simulated scenario.',
        action: 'Simulated retry event created.',
        details: [
          `Scenario: ${this.uiState.selectedScenario.shortTitle}`,
          'Retry button clicked.',
          'Simulated retry flow executed.'
        ],
        isSimulated: true
      })
      return
    }

    const reloadResult = this.webControllerManager.reloadActiveUrl()

    if (!reloadResult.success) {
      this.uiState.statusMessage = reloadResult.message
      ErrorHandlerLogger.error(
        'SCENARIO_RETRY',
        reloadResult.message
      )
      return
    }

    this.historyViewModel.addEvent({
      scenarioId: this.uiState.selectedScenario.id,
      type: ErrorHandlerEventType.RETRY,
      status: ErrorHandlerEventStatus.INFO,
      url: reloadResult.url,
      message: 'Retry requested.',
      action: 'WebView reload requested.',
      details: [
        `URL: ${reloadResult.url}`,
        'Retry button clicked.',
        'WebView controller reload requested.'
      ],
      isSimulated: false
    })
  }

  bindCustomNavigationStartHandler(handler: (url: string) => void): void {
    this.customNavigationStartHandler = handler
  }

  runCustomUrlTest(rawUrl: string): void {
    this.uiState.latestEvent = undefined
    this.uiState.selectedEvent = undefined
    this.uiState.pendingPrompt = undefined

    const normalizedUrl: string = this.normalizeCustomUrl(rawUrl)



    if (normalizedUrl.length === 0) {
      this.uiState.statusMessage = 'Enter a valid URL.'
      this.notifyUiChanged()
      return
    }


    if (!this.isAllowedCustomUrl(normalizedUrl)) {
      this.uiState.statusMessage = 'This URL scheme is not allowed.'
      this.notifyUiChanged()
      return
    }


    if (!this.hasValidCustomUrlHost(normalizedUrl)) {
      this.uiState.statusMessage = 'Enter a full URL or a valid domain such as example.com.'
      this.notifyUiChanged()
      return
    }

    this.authManager.clearAllHandlers()

    this.uiState.activeScreen = ErrorHandlerScreen.CUSTOM_URL_TEST
    this.uiState.latestEvent = undefined
    this.uiState.selectedEvent = undefined
    this.uiState.pendingPrompt = undefined
    this.uiState.currentUrl = normalizedUrl
    this.uiState.isWebVisible = true
    this.uiState.isLoading = true
    this.uiState.loadingProgress = 0
    this.uiState.statusMessage = 'Loading custom URL...'

    if (this.customNavigationStartHandler !== undefined) {
      this.customNavigationStartHandler(normalizedUrl)
    }

    this.notifyUiChanged()

    ErrorHandlerLogger.info(
      'CUSTOM_URL',
      'Custom URL test started.'
    )

    this.requestLiveUrlLoad(normalizedUrl)
    this.notifyUiChanged()
  }

  private runSimulatedScenario(): void {
    this.uiState.isWebVisible = false
    this.uiState.isLoading = false
    this.uiState.loadingProgress = 0

    const selectedScenarioId: string = this.uiState.selectedScenario.id

    if (selectedScenarioId === 'RESOURCE_ERROR') {
      this.createSimulatedResourceError()
      return
    }

    if (selectedScenarioId === 'HTTP_ERROR') {
      this.createSimulatedHttpError()
      return
    }

    if (selectedScenarioId === 'SSL_ERROR') {
      this.createSimulatedSslError()
      return
    }

    if (selectedScenarioId === 'HTTP_AUTH') {
      this.createSimulatedHttpAuthRequest()
      return
    }

    if (selectedScenarioId === 'CLIENT_AUTH') {
      this.createSimulatedClientAuthenticationRequest()
      return
    }

    if (selectedScenarioId === 'CUSTOM_HANDLER') {
      this.createSimulatedCustomResource()
      return
    }

    this.createSimulatedPageLoad()
  }

  private prepareLiveScenario(): void {
    this.uiState.pendingPrompt = undefined
    this.uiState.selectedEvent = undefined
    this.uiState.currentUrl = this.uiState.selectedScenario.testUrl
    this.uiState.isWebVisible = true
    this.uiState.isLoading = true
    this.uiState.loadingProgress = 0
    this.uiState.statusMessage = 'Loading scenario URL...'

    ErrorHandlerLogger.info(
      'SCENARIO_LIVE',
      'Live scenario started.'
    )

    this.requestLiveUrlLoad(this.uiState.currentUrl)
  }

  private requestLiveUrlLoad(url: string): void {
    const loadResult = this.webControllerManager.loadUrl(url)

    if (!loadResult.success) {
      this.uiState.statusMessage = 'Preparing WebView controller...'

      ErrorHandlerLogger.info(
        'WEB_CONTROLLER',
        loadResult.message
      )

      this.notifyUiChanged()
    }
  }
  private normalizeCustomUrl(rawUrl: string): string {
    const trimmedUrl: string = rawUrl.trim()

    if (trimmedUrl.length === 0) {
      return ''
    }

    const lowerUrl: string = trimmedUrl.toLowerCase()

    if (lowerUrl.startsWith('https://') ||
      lowerUrl.startsWith('http://') ||
      lowerUrl.startsWith('weberrorhandler://')) {
      return trimmedUrl
    }

    return `https://${trimmedUrl}`
  }

  private hasValidCustomUrlHost(url: string): boolean {
    const lowerUrl: string = url.toLowerCase()

    if (lowerUrl.startsWith('weberrorhandler://')) {
      return true
    }

    if (!lowerUrl.startsWith('https://') &&
      !lowerUrl.startsWith('http://')) {
      return false
    }

    const withoutProtocol: string = lowerUrl
      .replace('https://', '')
      .replace('http://', '')

    const host: string = withoutProtocol.split('/')[0]

    if (!host.includes('.')) {
      return false
    }

    const hostParts: string[] = host.split('.')
    const tld: string = hostParts[hostParts.length - 1]

    if (tld.length < 2) {
      return false
    }

    if (host.includes('..')) {
      return false
    }

    return host.length >= 4
  }

  private isAllowedCustomUrl(url: string): boolean {
    const lowerUrl: string = url.toLowerCase()

    if (lowerUrl.startsWith('javascript:') ||
      lowerUrl.startsWith('file:') ||
      lowerUrl.startsWith('data:') ||
      lowerUrl.startsWith('about:')) {
      return false
    }

    return lowerUrl.startsWith('https://') ||
      lowerUrl.startsWith('http://') ||
      lowerUrl.startsWith('weberrorhandler://')
  }

  private createSimulatedPageLoad(): void {
    this.historyViewModel.addEvent({
      scenarioId: this.uiState.selectedScenario.id,
      type: ErrorHandlerEventType.PAGE_LOAD,
      status: ErrorHandlerEventStatus.SUCCESS,
      url: this.uiState.selectedScenario.testUrl,
      message: 'Simulated page load completed.',
      action: 'No error handler action required.',
      details: [
        `Scenario: ${this.uiState.selectedScenario.shortTitle}`,
        `URL: ${this.uiState.selectedScenario.testUrl}`,
        'Simulated onPageBegin callback received.',
        'Simulated onPageEnd callback received.'
      ],
      isSimulated: true
    })
  }

  private createSimulatedResourceError(): void {
    this.historyViewModel.addEvent({
      scenarioId: this.uiState.selectedScenario.id,
      type: ErrorHandlerEventType.RESOURCE_ERROR,
      status: ErrorHandlerEventStatus.ERROR,
      url: this.uiState.selectedScenario.testUrl,
      message: 'Domain could not be resolved.',
      action: 'Resource error captured and stored.',
      details: [
        `Request URL: ${this.uiState.selectedScenario.testUrl}`,
        'Method: GET',
        'Main frame: true',
        `Retry allowed: ${this.uiState.selectedScenario.supportsRetry}`
      ],
      isSimulated: true
    })
  }

  private createSimulatedHttpError(): void {
    this.historyViewModel.addEvent({
      scenarioId: this.uiState.selectedScenario.id,
      type: ErrorHandlerEventType.HTTP_ERROR,
      status: ErrorHandlerEventStatus.ERROR,
      url: this.uiState.selectedScenario.testUrl,
      message: 'HTTP 404 Not Found.',
      action: 'HTTP error response captured.',
      details: [
        `Request URL: ${this.uiState.selectedScenario.testUrl}`,
        'Status code: 404',
        'Reason phrase: Not Found',
        'onHttpErrorReceive callback simulated.'
      ],
      isSimulated: true
    })
  }

  private createSimulatedSslError(): void {
    this.uiState.pendingPrompt = new ErrorHandlerPrompt({
      type: ErrorHandlerPromptType.SSL_ERROR,
      title: 'SSL Warning',
      message: 'SSL certificate validation failed.',
      primaryLabel: 'Proceed',
      primaryAction: ErrorHandlerPromptAction.PROCEED,
      secondaryLabel: 'Cancel',
      secondaryAction: ErrorHandlerPromptAction.CANCEL
    })

    this.historyViewModel.addEvent({
      scenarioId: this.uiState.selectedScenario.id,
      type: ErrorHandlerEventType.SSL_ERROR,
      status: ErrorHandlerEventStatus.ERROR,
      url: this.uiState.selectedScenario.testUrl,
      message: 'SSL certificate validation failed.',
      action: 'Waiting for user decision.',
      details: [
        `Request URL: ${this.uiState.selectedScenario.testUrl}`,
        'onSslErrorEventReceive callback simulated.',
        'SSL prompt created.',
        'No real SslErrorHandler is used in simulated mode.'
      ],
      isSimulated: true
    })
  }

  private createSimulatedHttpAuthRequest(): void {
    this.uiState.pendingPrompt = new ErrorHandlerPrompt({
      type: ErrorHandlerPromptType.HTTP_AUTH,
      title: 'Authentication Required',
      message: 'Host: auth.weberrorhandler.test',
      primaryLabel: 'Confirm',
      primaryAction: ErrorHandlerPromptAction.CONFIRM,
      secondaryLabel: 'Cancel',
      secondaryAction: ErrorHandlerPromptAction.CANCEL,
      requiresCredentialInput: true
    })

    this.historyViewModel.addEvent({
      scenarioId: this.uiState.selectedScenario.id,
      type: ErrorHandlerEventType.HTTP_AUTH,
      status: ErrorHandlerEventStatus.ERROR,
      url: this.uiState.selectedScenario.testUrl,
      message: 'HTTP authentication request received.',
      action: 'Waiting for credentials.',
      details: [
        'Host: auth.weberrorhandler.test',
        'Realm: Restricted Area',
        'onHttpAuthRequest callback simulated.',
        'Credential prompt opened.'
      ],
      isSimulated: true
    })
  }

  private createSimulatedClientAuthenticationRequest(): void {
    this.uiState.pendingPrompt = new ErrorHandlerPrompt({
      type: ErrorHandlerPromptType.CLIENT_AUTH,
      title: 'Client Certificate Required',
      message: 'Host: client-auth.weberrorhandler.test:443',
      primaryLabel: 'Use Certificate',
      primaryAction: ErrorHandlerPromptAction.USE_CERTIFICATE,
      secondaryLabel: 'Cancel',
      secondaryAction: ErrorHandlerPromptAction.CANCEL,
      tertiaryLabel: 'Ignore',
      tertiaryAction: ErrorHandlerPromptAction.IGNORE
    })

    this.historyViewModel.addEvent({
      scenarioId: this.uiState.selectedScenario.id,
      type: ErrorHandlerEventType.CLIENT_AUTH,
      status: ErrorHandlerEventStatus.WARNING,
      url: this.uiState.selectedScenario.testUrl,
      message: 'Client authentication request received.',
      action: 'Waiting for certificate decision.',
      details: [
        'Host: client-auth.weberrorhandler.test',
        'Port: 443',
        'Key types: RSA, EC',
        'onClientAuthenticationRequest callback simulated.',
        'Certificate prompt opened.'
      ],
      isSimulated: true
    })
  }

  private createSimulatedCustomResource(): void {
    const url: string = this.uiState.selectedScenario.testUrl
    const isCustomScheme: boolean =
      url.toLowerCase().startsWith('weberrorhandler://')

    if (!isCustomScheme) {
      this.historyViewModel.addEvent({
        scenarioId: this.uiState.selectedScenario.id,
        type: ErrorHandlerEventType.CUSTOM_RESOURCE,
        status: ErrorHandlerEventStatus.WARNING,
        url: url,
        message: 'Custom scheme was not detected.',
        action: 'Custom resource simulation completed without scheme handling.',
        details: [
          `Request URL: ${url}`,
          'Expected scheme: weberrorhandler://',
          'Custom scheme branch was not executed.'
        ],
        isSimulated: true
      })
      return
    }

    this.historyViewModel.addEvent({
      scenarioId: this.uiState.selectedScenario.id,
      type: ErrorHandlerEventType.CUSTOM_RESOURCE,
      status: ErrorHandlerEventStatus.SUCCESS,
      url: url,
      message: 'Custom scheme handler executed.',
      action: 'Synthetic custom resource event created.',
      details: [
        `Request URL: ${url}`,
        'Custom scheme detected.',
        'Custom resource handler simulated.',
        'Synthetic WebResourceResponse behavior represented as an event.'
      ],
      isSimulated: true
    })
  }
}