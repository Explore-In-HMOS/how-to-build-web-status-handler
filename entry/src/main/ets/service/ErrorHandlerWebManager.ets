import { BusinessError } from '@kit.BasicServicesKit'
import {ErrorHandlerEventOptions, ErrorHandlerEventStatus, ErrorHandlerEventType } from '../model/ErrorHandlerEvent'
import { ErrorHandlerLogger } from './ErrorHandlerLogger'

export interface ErrorHandlerRetryTarget {
  url: string
  method: string
  isMainFrame: boolean
  isRedirect: boolean
}

export class ErrorHandlerWebManager {
  private static readonly SAFE_RETRY_METHOD: string = 'GET'

  createPageStartEvent(
    scenarioId: string,
    url: string,
    isSimulated: boolean = false
  ): ErrorHandlerEventOptions {
    ErrorHandlerLogger.info(
      'WEB_MANAGER',
      `Page load started. scenario=${scenarioId}, url=${url}`
    )

    return {
      scenarioId: scenarioId,
      type: ErrorHandlerEventType.PAGE_LOAD,
      status: ErrorHandlerEventStatus.INFO,
      url: url,
      message: 'Page loading started.',
      action: 'Load started',
      details: [
        'WebView page load event received.'
      ],
      isSimulated: isSimulated
    }
  }

  createPageEndEvent(
    scenarioId: string,
    url: string,
    isSimulated: boolean = false
  ): ErrorHandlerEventOptions {
    ErrorHandlerLogger.info(
      'WEB_MANAGER',
      `Page load completed. scenario=${scenarioId}, url=${url}`
    )

    return {
      scenarioId: scenarioId,
      type: ErrorHandlerEventType.PAGE_LOAD,
      status: ErrorHandlerEventStatus.SUCCESS,
      url: url,
      message: 'Page loading completed.',
      action: 'Load completed',
      details: [
        'WebView page end event received.'
      ],
      isSimulated: isSimulated
    }
  }

  createProgressEvent(
    scenarioId: string,
    url: string,
    progress: number,
    isSimulated: boolean = false
  ): ErrorHandlerEventOptions {
    const safeProgress: number = this.normalizeProgress(progress)

    ErrorHandlerLogger.info(
      'WEB_MANAGER',
      `Loading progress changed. scenario=${scenarioId}, progress=${safeProgress}`
    )

    return {
      scenarioId: scenarioId,
      type: ErrorHandlerEventType.PAGE_LOAD,
      status: ErrorHandlerEventStatus.INFO,
      url: url,
      message: `Page loading progress: ${safeProgress}%.`,
      action: 'Progress updated',
      details: [
        `Progress: ${safeProgress}%`
      ],
      isSimulated: isSimulated
    }
  }

  createResourceErrorEvent(
    scenarioId: string,
    request: WebResourceRequest,
    error: WebResourceError,
    isSimulated: boolean = false
  ): ErrorHandlerEventOptions {
    const url: string = this.readRequestUrl(request)
    const method: string = this.readRequestMethod(request)
    const isMainFrame: boolean = this.readMainFrame(request)
    const isRedirect: boolean = this.readRedirect(request)
    const errorCode: number = this.readErrorCode(error)
    const errorInfo: string = this.readErrorInfo(error)

    const retryTarget: ErrorHandlerRetryTarget = {
      url: url,
      method: method,
      isMainFrame: isMainFrame,
      isRedirect: isRedirect
    }

    const retryAllowed: boolean = this.canRetryRequest(retryTarget)
    const retryBlockReason: string = retryAllowed
      ? ''
      : this.getRetryBlockReason(retryTarget)

    ErrorHandlerLogger.error(
      'WEB_RESOURCE_ERROR',
      `Resource loading failed. url=${url}, method=${method}, mainFrame=${isMainFrame}, redirect=${isRedirect}`,
      {
        code: errorCode,
        message: errorInfo
      }
    )

    const details: string[] = [
      `Error code: ${errorCode}`,
      `Method: ${method}`,
      `Main frame: ${isMainFrame}`,
      `Redirect: ${isRedirect}`,
      `Retry allowed: ${retryAllowed}`
    ]

    if (retryBlockReason.length > 0) {
      details.push(`Retry reason: ${retryBlockReason}`)
    }

    return {
      scenarioId: scenarioId,
      type: ErrorHandlerEventType.RESOURCE_ERROR,
      status: ErrorHandlerEventStatus.ERROR,
      url: url,
      message: errorInfo.length > 0
        ? errorInfo
        : 'Web resource loading failed.',
      errorCode: errorCode,
      requestMethod: method,
      isMainFrame: isMainFrame,
      isRedirect: isRedirect,
      action: retryAllowed
        ? 'Retry available'
        : 'Retry unavailable',
      details: details,
      isSimulated: isSimulated
    }
  }

  createHttpErrorEvent(
    scenarioId: string,
    request: WebResourceRequest,
    httpStatusCode: number,
    reasonPhrase: string,
    isSimulated: boolean = false
  ): ErrorHandlerEventOptions {
    const url: string = this.readRequestUrl(request)
    const method: string = this.readRequestMethod(request)
    const isMainFrame: boolean = this.readMainFrame(request)
    const isRedirect: boolean = this.readRedirect(request)

    const retryTarget: ErrorHandlerRetryTarget = {
      url: url,
      method: method,
      isMainFrame: isMainFrame,
      isRedirect: isRedirect
    }

    const retryAllowed: boolean = this.canRetryRequest(retryTarget)
    const retryBlockReason: string = retryAllowed
      ? ''
      : this.getRetryBlockReason(retryTarget)

    ErrorHandlerLogger.warn(
      'HTTP_ERROR',
      `HTTP error received. status=${httpStatusCode}, url=${url}, method=${method}`
    )

    const details: string[] = [
      `HTTP status: ${httpStatusCode}`,
      `Method: ${method}`,
      `Main frame: ${isMainFrame}`,
      `Redirect: ${isRedirect}`,
      `Retry allowed: ${retryAllowed}`
    ]

    if (retryBlockReason.length > 0) {
      details.push(`Retry reason: ${retryBlockReason}`)
    }

    return {
      scenarioId: scenarioId,
      type: ErrorHandlerEventType.HTTP_ERROR,
      status: ErrorHandlerEventStatus.ERROR,
      url: url,
      message: reasonPhrase.length > 0
        ? reasonPhrase
        : `HTTP request failed with status ${httpStatusCode}.`,
      errorCode: httpStatusCode,
      requestMethod: method,
      isMainFrame: isMainFrame,
      isRedirect: isRedirect,
      action: retryAllowed
        ? 'Retry available'
        : 'Retry unavailable',
      details: details,
      isSimulated: isSimulated
    }
  }

  createRequestDetailsEvent(
    scenarioId: string,
    request: WebResourceRequest,
    isSimulated: boolean = false
  ): ErrorHandlerEventOptions {
    const url: string = this.readRequestUrl(request)
    const method: string = this.readRequestMethod(request)
    const isMainFrame: boolean = this.readMainFrame(request)
    const isRedirect: boolean = this.readRedirect(request)

    ErrorHandlerLogger.info(
      'WEB_REQUEST',
      `Request details captured. url=${url}, method=${method}, mainFrame=${isMainFrame}, redirect=${isRedirect}`
    )

    return {
      scenarioId: scenarioId,
      type: ErrorHandlerEventType.PAGE_LOAD,
      status: ErrorHandlerEventStatus.INFO,
      url: url,
      message: 'Web request details captured.',
      requestMethod: method,
      isMainFrame: isMainFrame,
      isRedirect: isRedirect,
      action: 'View details',
      details: [
        `Method: ${method}`,
        `Main frame: ${isMainFrame}`,
        `Redirect: ${isRedirect}`
      ],
      isSimulated: isSimulated
    }
  }

  canRetryRequest(target: ErrorHandlerRetryTarget): boolean {
    const isSafeMethod: boolean =
      target.method.toUpperCase() === ErrorHandlerWebManager.SAFE_RETRY_METHOD

    const hasValidUrl: boolean = target.url.length > 0

    const retryAllowed: boolean =
      hasValidUrl &&
        isSafeMethod &&
        target.isMainFrame &&
        !target.isRedirect

    ErrorHandlerLogger.info(
      'RETRY_POLICY',
      `Retry evaluated. allowed=${retryAllowed}, method=${target.method}, mainFrame=${target.isMainFrame}, redirect=${target.isRedirect}`
    )

    return retryAllowed
  }

  getRetryBlockReason(target: ErrorHandlerRetryTarget): string {
    if (target.url.length === 0) {
      return 'The request URL is unavailable.'
    }

    if (
      target.method.toUpperCase() !==
        ErrorHandlerWebManager.SAFE_RETRY_METHOD
    ) {
      return 'Only GET requests can be retried automatically.'
    }

    if (!target.isMainFrame) {
      return 'Only main frame requests can be retried.'
    }

    if (target.isRedirect) {
      return 'Redirect requests cannot be retried automatically.'
    }

    return ''
  }

  private normalizeProgress(progress: number): number {
    if (progress < 0) {
      return 0
    }

    if (progress > 100) {
      return 100
    }

    return progress
  }

  private readRequestUrl(
    request: WebResourceRequest
  ): string {
    try {
      return request.getRequestUrl()
    } catch (error) {
      const businessError: BusinessError = error as BusinessError

      ErrorHandlerLogger.error(
        'WEB_REQUEST',
        'Failed to read request URL.',
        {
          code: businessError.code,
          message: businessError.message
        }
      )

      return ''
    }
  }

  private readRequestMethod(
    request: WebResourceRequest
  ): string {
    try {
      return request.getRequestMethod()
    } catch (error) {
      const businessError: BusinessError = error as BusinessError

      ErrorHandlerLogger.error(
        'WEB_REQUEST',
        'Failed to read request method.',
        {
          code: businessError.code,
          message: businessError.message
        }
      )

      return ''
    }
  }

  private readMainFrame(
    request: WebResourceRequest
  ): boolean {
    try {
      return request.isMainFrame()
    } catch (error) {
      const businessError: BusinessError = error as BusinessError

      ErrorHandlerLogger.error(
        'WEB_REQUEST',
        'Failed to read main frame information.',
        {
          code: businessError.code,
          message: businessError.message
        }
      )

      return false
    }
  }

  private readRedirect(
    request: WebResourceRequest
  ): boolean {
    try {
      return request.isRedirect()
    } catch (error) {
      const businessError: BusinessError = error as BusinessError

      ErrorHandlerLogger.error(
        'WEB_REQUEST',
        'Failed to read redirect information.',
        {
          code: businessError.code,
          message: businessError.message
        }
      )

      return false
    }
  }

  private readErrorCode(
    error: WebResourceError
  ): number {
    try {
      return error.getErrorCode()
    } catch (exception) {
      const businessError: BusinessError = exception as BusinessError

      ErrorHandlerLogger.error(
        'WEB_RESOURCE_ERROR',
        'Failed to read web resource error code.',
        {
          code: businessError.code,
          message: businessError.message
        }
      )

      return -1
    }
  }

  private readErrorInfo(
    error: WebResourceError
  ): string {
    try {
      return error.getErrorInfo()
    } catch (exception) {
      const businessError: BusinessError = exception as BusinessError

      ErrorHandlerLogger.error(
        'WEB_RESOURCE_ERROR',
        'Failed to read web resource error information.',
        {
          code: businessError.code,
          message: businessError.message
        }
      )

      return 'Unknown web resource error.'
    }
  }
}