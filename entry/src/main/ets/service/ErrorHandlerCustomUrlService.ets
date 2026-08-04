import { ErrorHandlerScreen, ErrorHandlerUiState } from '../model/ErrorHandlerUiState'
import { ErrorHandlerAuthManager } from './ErrorHandlerAuthManager'
import { ErrorHandlerLogger } from './ErrorHandlerLogger'
import { ErrorHandlerWebControllerManager } from './ErrorHandlerWebControllerManager'

export class ErrorHandlerCustomUrlService {
  private uiState: ErrorHandlerUiState
  private authManager: ErrorHandlerAuthManager
  private webControllerManager: ErrorHandlerWebControllerManager

  constructor(
    uiState: ErrorHandlerUiState,
    authManager: ErrorHandlerAuthManager,
    webControllerManager: ErrorHandlerWebControllerManager
  ) {
    this.uiState = uiState
    this.authManager = authManager
    this.webControllerManager = webControllerManager
  }

  runCustomUrlTest(rawUrl: string): void {
    const normalizedUrl: string = this.normalizeCustomUrl(rawUrl)

    if (normalizedUrl.length === 0) {
      this.uiState.statusMessage = 'Enter a valid URL.'
      return
    }

    if (!this.hasValidCustomUrlHost(normalizedUrl)) {
      this.uiState.statusMessage = 'This URL scheme is not allowed.'
      return
    }

    this.authManager.clearAllHandlers()

    this.uiState.activeScreen = ErrorHandlerScreen.CUSTOM_URL_TEST
    this.uiState.pendingPrompt = undefined
    this.uiState.selectedEvent = undefined
    this.uiState.currentUrl = normalizedUrl
    this.uiState.isWebVisible = true
    this.uiState.isLoading = true
    this.uiState.loadingProgress = 0
    this.uiState.statusMessage = 'Loading custom URL...'

    ErrorHandlerLogger.info(
      'CUSTOM_URL',
      'Custom URL test started.'
    )

    this.requestLiveUrlLoad(normalizedUrl)
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

  private requestLiveUrlLoad(url: string): void {
    const loadResult = this.webControllerManager.loadUrl(url)

    if (!loadResult.success) {
      ErrorHandlerLogger.info(
        'CUSTOM_URL',
        'WebView controller is not ready yet. URL will be loaded by Web component source.'
      )
    }
  }
}