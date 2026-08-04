import { BusinessError } from '@kit.BasicServicesKit'
import { ErrorHandlerEventOptions } from '../model/ErrorHandlerEvent'
import { ErrorHandlerLogger } from './ErrorHandlerLogger'
import { ErrorHandlerSchemeResponseFactory, ErrorHandlerSchemeRoute } from './ErrorHandlerSchemeResponseFactory'

export interface ErrorHandlerSchemeHandleResult {
  success: boolean
  url: string
  message: string
  response?: WebResourceResponse
  event?: ErrorHandlerEventOptions
}

export class ErrorHandlerSchemeManager {
  private static readonly CUSTOM_SCHEME_PREFIX: string = 'weberrorhandler://'

  private responseFactory: ErrorHandlerSchemeResponseFactory =
    new ErrorHandlerSchemeResponseFactory()

  isCustomSchemeUrl(url: string): boolean {
    return url.toLowerCase().startsWith(ErrorHandlerSchemeManager.CUSTOM_SCHEME_PREFIX)
  }

  isCustomSchemeURL(url: string): boolean {
    return this.isCustomSchemeUrl(url)
  }

  isSupportedCustomScheme(url: string): boolean {
    return this.isCustomSchemeUrl(url)
  }

  shouldInterceptRequest(request: WebResourceRequest): boolean {
    const url: string = this.readRequestUrl(request)

    if (url.length === 0) {
      return false
    }

    return this.isCustomSchemeUrl(url)
  }

  createCustomSchemeResponse(url: string): WebResourceResponse {
    const route: ErrorHandlerSchemeRoute = this.responseFactory.createRoute(url)
    return this.responseFactory.createResponse(route)
  }

  createCustomSchemeEvent(
    scenarioId: string,
    url: string,
    isSimulated: boolean
  ): ErrorHandlerEventOptions {
    const route: ErrorHandlerSchemeRoute = this.responseFactory.createRoute(url)

    return this.responseFactory.createEvent(
      scenarioId,
      url,
      isSimulated,
      route
    )
  }

  handleCustomSchemeUrl(
    scenarioId: string,
    url: string,
    isSimulated: boolean
  ): ErrorHandlerSchemeHandleResult {
    if (!this.isCustomSchemeUrl(url)) {
      return {
        success: false,
        url: url,
        message: 'URL is not a supported custom scheme.'
      }
    }

    const route: ErrorHandlerSchemeRoute = this.responseFactory.createRoute(url)
    const response: WebResourceResponse = this.responseFactory.createResponse(route)
    const event: ErrorHandlerEventOptions = this.responseFactory.createEvent(
      scenarioId,
      url,
      isSimulated,
      route
    )

    ErrorHandlerLogger.info(
      'CUSTOM_SCHEME',
      'Custom scheme URL handled.'
    )

    return {
      success: true,
      url: url,
      message: route.message,
      response: response,
      event: event
    }
  }

  handleCustomSchemeRequest(
    scenarioId: string,
    request: WebResourceRequest,
    isSimulated: boolean
  ): ErrorHandlerSchemeHandleResult {
    const url: string = this.readRequestUrl(request)

    if (url.length === 0) {
      return {
        success: false,
        url: '',
        message: 'Request URL could not be read.'
      }
    }

    return this.handleCustomSchemeUrl(
      scenarioId,
      url,
      isSimulated
    )
  }

  createCustomSchemeResponseFromRequest(
    request: WebResourceRequest
  ): WebResourceResponse | undefined {
    const url: string = this.readRequestUrl(request)

    if (!this.isCustomSchemeUrl(url)) {
      return undefined
    }

    return this.createCustomSchemeResponse(url)
  }

  createCustomSchemeEventFromRequest(
    scenarioId: string,
    request: WebResourceRequest,
    isSimulated: boolean
  ): ErrorHandlerEventOptions | undefined {
    const url: string = this.readRequestUrl(request)

    if (!this.isCustomSchemeUrl(url)) {
      return undefined
    }

    return this.createCustomSchemeEvent(
      scenarioId,
      url,
      isSimulated
    )
  }

  getCustomSchemePrefix(): string {
    return ErrorHandlerSchemeManager.CUSTOM_SCHEME_PREFIX
  }

  normalizeCustomSchemeUrl(url: string): string {
    const trimmedUrl: string = url.trim()

    if (trimmedUrl.length === 0) {
      return ''
    }

    if (this.isCustomSchemeUrl(trimmedUrl)) {
      return trimmedUrl
    }

    if (trimmedUrl.startsWith('//')) {
      return `weberrorhandler:${trimmedUrl}`
    }

    return trimmedUrl
  }

  private readRequestUrl(request: WebResourceRequest): string {
    try {
      return request.getRequestUrl()
    } catch (error) {
      const businessError: BusinessError = error as BusinessError

      ErrorHandlerLogger.error(
        'CUSTOM_SCHEME',
        'Failed to read request URL.',
        {
          code: businessError.code,
          message: businessError.message
        }
      )

      return ''
    }
  }
}