import {ErrorHandlerEventOptions, ErrorHandlerEventStatus, ErrorHandlerEventType } from '../model/ErrorHandlerEvent'

export enum ErrorHandlerSchemeRouteType {
  SUCCESS = 'SUCCESS',
  OFFLINE = 'OFFLINE',
  FAILURE = 'FAILURE',
  JSON = 'JSON',
  HTML = 'HTML',
  UNKNOWN = 'UNKNOWN'
}

export interface ErrorHandlerSchemeRoute {
  type: ErrorHandlerSchemeRouteType
  statusCode: number
  reasonPhrase: string
  mimeType: string
  encoding: string
  body: string
  message: string
  action: string
}

export interface ErrorHandlerSchemeHeader {
  headerKey: string
  headerValue: string
}

export class ErrorHandlerSchemeResponseFactory {
  createRoute(url: string): ErrorHandlerSchemeRoute {
    const lowerUrl: string = url.toLowerCase()

    if (lowerUrl.includes('offline')) {
      return this.createOfflineRoute()
    }

    if (lowerUrl.includes('failure') || lowerUrl.includes('error')) {
      return this.createFailureRoute()
    }

    if (lowerUrl.includes('json')) {
      return this.createJsonRoute(url)
    }

    if (lowerUrl.includes('html')) {
      return this.createHtmlRoute(url)
    }

    return this.createSuccessRoute(url)
  }

  createResponse(route: ErrorHandlerSchemeRoute): WebResourceResponse {
    const response: WebResourceResponse = new WebResourceResponse()

    response.setResponseData(route.body)
    response.setResponseEncoding(route.encoding)
    response.setResponseMimeType(route.mimeType)
    response.setResponseCode(route.statusCode)
    response.setReasonMessage(route.reasonPhrase)
    response.setResponseHeader(this.createDefaultHeaders())

    return response
  }

  createEvent(
    scenarioId: string,
    url: string,
    isSimulated: boolean,
    route: ErrorHandlerSchemeRoute
  ): ErrorHandlerEventOptions {
    return {
      scenarioId: scenarioId,
      type: ErrorHandlerEventType.CUSTOM_RESOURCE,
      status: this.mapRouteStatus(route),
      url: url,
      message: route.message,
      action: route.action,
      details: [
        `Request URL: ${url}`,
        `Route type: ${route.type}`,
        `Status code: ${route.statusCode}`,
        `Reason phrase: ${route.reasonPhrase}`,
        `MIME type: ${route.mimeType}`,
        `Encoding: ${route.encoding}`,
        `Simulated: ${isSimulated}`
      ],
      isSimulated: isSimulated
    }
  }

  private createSuccessRoute(url: string): ErrorHandlerSchemeRoute {
    return {
      type: ErrorHandlerSchemeRouteType.SUCCESS,
      statusCode: 200,
      reasonPhrase: 'OK',
      mimeType: 'text/plain',
      encoding: 'UTF-8',
      body: `Custom scheme response generated for ${url}`,
      message: 'Custom scheme response generated.',
      action: 'Custom scheme handler executed successfully.'
    }
  }

  private createOfflineRoute(): ErrorHandlerSchemeRoute {
    return {
      type: ErrorHandlerSchemeRouteType.OFFLINE,
      statusCode: 503,
      reasonPhrase: 'Service Unavailable',
      mimeType: 'text/plain',
      encoding: 'UTF-8',
      body: 'The custom scheme resource is currently offline.',
      message: 'Custom scheme offline response generated.',
      action: 'Custom scheme handler returned an offline response.'
    }
  }

  private createFailureRoute(): ErrorHandlerSchemeRoute {
    return {
      type: ErrorHandlerSchemeRouteType.FAILURE,
      statusCode: 500,
      reasonPhrase: 'Internal Error',
      mimeType: 'text/plain',
      encoding: 'UTF-8',
      body: 'The custom scheme handler generated a failure response.',
      message: 'Custom scheme failure response generated.',
      action: 'Custom scheme handler returned a failure response.'
    }
  }

  private createJsonRoute(url: string): ErrorHandlerSchemeRoute {
    return {
      type: ErrorHandlerSchemeRouteType.JSON,
      statusCode: 200,
      reasonPhrase: 'OK',
      mimeType: 'application/json',
      encoding: 'UTF-8',
      body: this.createJsonBody(url),
      message: 'Custom scheme JSON response generated.',
      action: 'Custom scheme handler returned a JSON response.'
    }
  }

  private createHtmlRoute(url: string): ErrorHandlerSchemeRoute {
    return {
      type: ErrorHandlerSchemeRouteType.HTML,
      statusCode: 200,
      reasonPhrase: 'OK',
      mimeType: 'text/html',
      encoding: 'UTF-8',
      body: this.createHtmlBody(url),
      message: 'Custom scheme HTML response generated.',
      action: 'Custom scheme handler returned an HTML response.'
    }
  }

  private createJsonBody(url: string): string {
    return `{"success":true,"source":"weberrorhandler","url":"${url}"}`
  }

  private createHtmlBody(url: string): string {
    return `<html><body><h3>Custom Scheme Response</h3><p>${url}</p></body></html>`
  }

  private createDefaultHeaders(): ErrorHandlerSchemeHeader[] {
    return [
      {
        headerKey: 'Access-Control-Allow-Origin',
        headerValue: '*'
      },
      {
        headerKey: 'Cache-Control',
        headerValue: 'no-store'
      },
      {
        headerKey: 'X-WebErrorHandler-Source',
        headerValue: 'custom-scheme'
      }
    ]
  }

  private mapRouteStatus(
    route: ErrorHandlerSchemeRoute
  ): ErrorHandlerEventStatus {
    if (route.statusCode >= 500) {
      return ErrorHandlerEventStatus.ERROR
    }

    if (route.statusCode >= 400) {
      return ErrorHandlerEventStatus.WARNING
    }

    return ErrorHandlerEventStatus.SUCCESS
  }
}