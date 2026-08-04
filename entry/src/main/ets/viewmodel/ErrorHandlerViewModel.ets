import { webview } from '@kit.ArkWeb'
import { ERROR_HANDLER_SCENARIOS, ErrorHandlerScenario } from '../model/ErrorHandlerScenario'
import { ErrorHandlerEvent } from '../model/ErrorHandlerEvent'
import { ErrorHandlerPromptAction } from '../model/ErrorHandlerPrompt'
import { ErrorHandlerRunMode, ErrorHandlerScreen, ErrorHandlerUiState } from '../model/ErrorHandlerUiState'
import { ErrorHandlerAuthManager } from '../service/ErrorHandlerAuthManager'
import { ErrorHandlerLogger } from '../service/ErrorHandlerLogger'
import { ErrorHandlerWebControllerManager } from '../service/ErrorHandlerWebControllerManager'
import { ErrorHandlerWebManager } from '../service/ErrorHandlerWebManager'
import { ErrorHandlerNavigationHistoryViewModel } from './ErrorHandlerNavigationHistoryViewModel'
import { ErrorHandlerRunViewModel } from './ErrorHandlerRunViewModel'
import { ErrorHandlerWebEventViewModel } from './ErrorHandlerWebEventViewModel'
import { ErrorHandlerSchemeManager } from '../service/ErrorHandlerSchemeManager'

@Observed
export class ErrorHandlerViewModel {
  uiState: ErrorHandlerUiState = new ErrorHandlerUiState()
  uiRefreshKey: number = 0

  private uiRefreshHandler: (() => void) | undefined = undefined

  bindUiRefreshHandler(handler: () => void): void {
    this.uiRefreshHandler = handler
  }

  notifyUiChanged(): void {
    this.uiRefreshKey++

    if (this.uiRefreshHandler !== undefined) {
      this.uiRefreshHandler()
    }
  }

  private webManager: ErrorHandlerWebManager = new ErrorHandlerWebManager()
  private authManager: ErrorHandlerAuthManager = new ErrorHandlerAuthManager()
  private schemeManager: ErrorHandlerSchemeManager = new ErrorHandlerSchemeManager()
  private webControllerManager: ErrorHandlerWebControllerManager = new ErrorHandlerWebControllerManager()

  private navigationHistoryViewModel: ErrorHandlerNavigationHistoryViewModel
  private runViewModel: ErrorHandlerRunViewModel
  private webEventViewModel: ErrorHandlerWebEventViewModel

  constructor() {
    this.navigationHistoryViewModel =
      new ErrorHandlerNavigationHistoryViewModel(
        this.uiState,
        (): void => {
          this.notifyUiChanged()
        }
      )

    this.runViewModel = new ErrorHandlerRunViewModel(
      this.uiState,
      this.navigationHistoryViewModel,
      this.authManager,
      this.schemeManager,
      this.webControllerManager,
      (): void => {
        this.notifyUiChanged()
      }
    )
    this.runViewModel.bindCustomNavigationStartHandler((url: string): void => {
      this.webEventViewModel.startCustomUrlNavigation(url)
    })

    this.webEventViewModel = new ErrorHandlerWebEventViewModel(
      this.uiState,
      this.navigationHistoryViewModel,
      this.webManager,
      this.authManager,
      (): void => {
        this.notifyUiChanged()
      }
    )
  }
  showMainMenuScreen(): void {
    this.navigationHistoryViewModel.showMainMenuScreen()
  }

  showScenarioTestScreen(): void {
    this.navigationHistoryViewModel.showScenarioTestScreen()
  }

  showScenarioPickerScreen(): void {
    this.navigationHistoryViewModel.showScenarioPickerScreen()
  }

  showCustomUrlTestScreen(): void {
    this.navigationHistoryViewModel.showCustomUrlTestScreen()
  }

  showScenarioScreen(): void {
    this.navigationHistoryViewModel.showScenarioScreen()
  }

  showHistoryScreen(): void {
    this.navigationHistoryViewModel.showHistoryScreen()
  }

  returnToPreviousTestScreen(): void {
    this.navigationHistoryViewModel.returnToPreviousTestScreen()
  }

  showEventDetails(event: ErrorHandlerEvent): void {
    this.navigationHistoryViewModel.showEventDetails(event)
  }

  closeEventDetails(): void {
    this.navigationHistoryViewModel.closeEventDetails()
  }

  resetCustomUrlResultState(): void {
    this.webEventViewModel.resetCustomUrlResultState()
  }

  clearEventHistory(): void {
    this.navigationHistoryViewModel.clearEventHistory()
  }

  selectScenario(scenario: ErrorHandlerScenario): void {
    this.runViewModel.selectScenario(scenario)
  }

  setRunMode(runMode: ErrorHandlerRunMode): void {
    this.runViewModel.setRunMode(runMode)
  }

  runSelectedScenario(): void {
    this.runViewModel.runSelectedScenario()
  }

  retrySelectedScenario(): void {
    this.runViewModel.retrySelectedScenario()
  }

  runCustomUrlTest(rawUrl: string): void {
    this.runViewModel.runCustomUrlTest(rawUrl)

    if (this.uiState.activeScreen === ErrorHandlerScreen.CUSTOM_URL_TEST &&
      this.uiState.currentUrl.length > 0) {
      this.webEventViewModel.startCustomNavigationWatch(this.uiState.currentUrl)
    }
  }

  attachWebController(controller: webview.WebviewController): void {
    this.webControllerManager.attachController(controller)
    ErrorHandlerLogger.info(
      'WEB_CONTROLLER',
      'WebView controller attached.'
    )
  }

  detachWebController(): void {
    this.webControllerManager.detachController()
    ErrorHandlerLogger.info(
      'WEB_CONTROLLER',
      'WebView controller detached.'
    )
  }
  handlePageBegin(url: string): void {
    this.webEventViewModel.handlePageBegin(url)
  }

  handlePageEnd(url: string): void {
    this.webEventViewModel.handlePageEnd(url)
  }

  handleProgressChange(progress: number): void {
    this.webEventViewModel.handleProgressChange(progress)
  }

  startCustomNavigationWatch(url: string): void {
    this.webEventViewModel.startCustomNavigationWatch(url)
  }

  handleResourceError(
    request: WebResourceRequest,
    error: WebResourceError
  ): void {
    this.webEventViewModel.handleResourceError(request, error)
  }

  handleHttpError(
    request: WebResourceRequest,
    httpStatusCode: number,
    reasonPhrase: string
  ): void {
    this.webEventViewModel.handleHttpError(
      request,
      httpStatusCode,
      reasonPhrase
    )
  }

  handleSslError(
    handler: SslErrorHandler,
    errorDescription: string
  ): void {
    this.webEventViewModel.handleSslError(
      handler,
      errorDescription
    )
  }

  handleHttpAuthRequest(
    handler: HttpAuthHandler,
    host: string,
    realm: string
  ): boolean {
    return this.webEventViewModel.handleHttpAuthRequest(
      handler,
      host,
      realm
    )
  }

  handleClientAuthenticationRequest(
    handler: ClientAuthenticationHandler,
    host: string,
    port: number,
    keyTypes: string[],
    issuers: string[]
  ): void {
    this.webEventViewModel.handleClientAuthenticationRequest(
      handler,
      host,
      port,
      keyTypes,
      issuers
    )
  }

  resolvePrompt(
    action: ErrorHandlerPromptAction,
    username: string,
    password: string,
    privateKeyFilePath: string,
    certificateChainFilePath: string
  ): void {
    this.webEventViewModel.resolvePrompt(
      action,
      username,
      password,
      privateKeyFilePath,
      certificateChainFilePath
    )
  }

  getScenarioList(): ErrorHandlerScenario[] {
    return ERROR_HANDLER_SCENARIOS
  }
}