import { webview } from '@kit.ArkWeb'
import { BusinessError } from '@kit.BasicServicesKit'
import { ErrorHandlerLogger } from './ErrorHandlerLogger'

export interface ErrorHandlerWebControllerResult {
  success: boolean
  url: string
  message: string
}

export class ErrorHandlerWebControllerManager {
  private controller: webview.WebviewController | undefined = undefined
  private activeUrl: string = ''
  private pendingUrl: string = ''

  attachController(controller: webview.WebviewController): void {
    this.controller = controller

    ErrorHandlerLogger.info(
      'WEB_CONTROLLER',
      'WebView controller attached.'
    )

    this.loadPendingUrlIfNeeded()
  }

  detachController(): void {
    this.controller = undefined

    ErrorHandlerLogger.info(
      'WEB_CONTROLLER',
      'WebView controller detached.'
    )
  }

  loadUrl(url: string): ErrorHandlerWebControllerResult {
    this.activeUrl = url

    if (this.controller === undefined) {
      this.pendingUrl = url

      return {
        success: false,
        url: url,
        message: 'URL loading deferred because WebView controller is not attached yet.'
      }
    }

    try {
      this.controller.loadUrl(url)

      return {
        success: true,
        url: url,
        message: 'URL load requested.'
      }
    } catch (error) {
      const businessError: BusinessError = error as BusinessError

      ErrorHandlerLogger.error(
        'WEB_CONTROLLER',
        `Failed to load URL. Code: ${businessError.code}, Message: ${businessError.message}`
      )

      return {
        success: false,
        url: url,
        message: 'URL load request failed.'
      }
    }
  }

  reloadActiveUrl(): ErrorHandlerWebControllerResult {
    if (this.activeUrl.length === 0) {
      return {
        success: false,
        url: '',
        message: 'No active URL to reload.'
      }
    }

    return this.loadUrl(this.activeUrl)
  }

  hasController(): boolean {
    return this.controller !== undefined
  }

  getActiveUrl(): string {
    return this.activeUrl
  }

  private loadPendingUrlIfNeeded(): void {
    if (this.pendingUrl.length === 0) {
      return
    }

    const url: string = this.pendingUrl
    this.pendingUrl = ''

    const result: ErrorHandlerWebControllerResult = this.loadUrl(url)

    if (result.success) {
      ErrorHandlerLogger.info(
        'WEB_CONTROLLER',
        'Pending URL loaded after controller attachment.'
      )
      return
    }

    ErrorHandlerLogger.error(
      'WEB_CONTROLLER',
      result.message
    )
  }
}