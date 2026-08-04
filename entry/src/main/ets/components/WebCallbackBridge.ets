import { webview } from '@kit.ArkWeb'
import { BusinessError } from '@kit.BasicServicesKit'
import { ErrorHandlerViewModel } from '../viewmodel/ErrorHandlerViewModel'
import { ErrorHandlerLogger } from '../service/ErrorHandlerLogger'

@Component
export struct WebCallbackBridge {
  @ObjectLink viewModel: ErrorHandlerViewModel
  logTag: string = 'WEB_CALLBACK_BRIDGE'

  private webController: webview.WebviewController = new webview.WebviewController()
  private isControllerAttached: boolean = false

  aboutToDisappear(): void {
    this.viewModel.detachWebController()
    this.isControllerAttached = false

    ErrorHandlerLogger.info(
      this.logTag,
      'Web callback bridge disappeared. WebView controller detached.'
    )
  }

  private attachControllerIfNeeded(): void {
    if (this.isControllerAttached) {
      return
    }

    try {
      this.viewModel.attachWebController(this.webController)
      this.isControllerAttached = true

      ErrorHandlerLogger.info(
        this.logTag,
        'WebView controller attached from WebCallbackBridge.'
      )
    } catch (error) {
      const businessError: BusinessError = error as BusinessError

      ErrorHandlerLogger.error(
        this.logTag,
        'Failed to attach WebView controller from WebCallbackBridge.',
        {
          code: businessError.code,
          message: businessError.message
        }
      )
    }
  }

  private readHttpStatusCode(response: WebResourceResponse): number {
    try {
      return response.getResponseCode()
    } catch (error) {
      const businessError: BusinessError = error as BusinessError

      ErrorHandlerLogger.error(
        this.logTag,
        'Failed to read HTTP status code.',
        {
          code: businessError.code,
          message: businessError.message
        }
      )

      return 0
    }
  }

  private readHttpReasonPhrase(response: WebResourceResponse): string {
    try {
      return response.getReasonMessage()
    } catch (error) {
      const businessError: BusinessError = error as BusinessError

      ErrorHandlerLogger.error(
        this.logTag,
        'Failed to read HTTP reason phrase.',
        {
          code: businessError.code,
          message: businessError.message
        }
      )

      return ''
    }
  }

  private shouldIgnoreUrl(url: string): boolean {
    const lowerUrl: string = url.toLowerCase()

    return lowerUrl.length === 0 ||
      lowerUrl === 'about:blank' ||
      lowerUrl.startsWith('about:blank')
  }

  build() {
    Web({
      src: 'about:blank',
      controller: this.webController
    })
      .width(1)
      .height(1)
      .opacity(0.01)
      .onControllerAttached((): void => {
        this.attachControllerIfNeeded()
      })
      .onPageBegin((event): void => {
        if (event === undefined) {
          return
        }

        if (this.shouldIgnoreUrl(event.url)) {
          return
        }

        this.viewModel.handlePageBegin(event.url)
      })
      .onPageEnd((event): void => {
        if (event === undefined) {
          return
        }

        if (this.shouldIgnoreUrl(event.url)) {
          return
        }

        this.viewModel.handlePageEnd(event.url)
      })
      .onProgressChange((event): void => {
        if (event === undefined) {
          return
        }

        this.viewModel.handleProgressChange(event.newProgress)
      })
      .onErrorReceive((event): void => {
        if (event === undefined) {
          return
        }

        this.viewModel.handleResourceError(
          event.request,
          event.error
        )
      })
      .onHttpErrorReceive((event): void => {
        if (event === undefined) {
          return
        }

        this.viewModel.handleHttpError(
          event.request,
          this.readHttpStatusCode(event.response),
          this.readHttpReasonPhrase(event.response)
        )
      })
      .onSslErrorEventReceive((event): void => {
        if (event === undefined) {
          return
        }

        this.viewModel.handleSslError(
          event.handler,
          'SSL certificate validation failed.'
        )
      })
      .onHttpAuthRequest((event): boolean => {
        if (event === undefined) {
          return false
        }

        return this.viewModel.handleHttpAuthRequest(
          event.handler,
          event.host,
          event.realm
        )
      })
      .onClientAuthenticationRequest((event): void => {
        if (event === undefined) {
          return
        }

        this.viewModel.handleClientAuthenticationRequest(
          event.handler,
          event.host,
          event.port,
          event.keyTypes,
          event.issuers
        )
      })
  }
}