export enum ErrorHandlerEventType {
  PAGE_LOAD = 'PAGE_LOAD',
  RESOURCE_ERROR = 'RESOURCE_ERROR',
  HTTP_ERROR = 'HTTP_ERROR',
  SSL_ERROR = 'SSL_ERROR',
  HTTP_AUTH = 'HTTP_AUTH',
  CLIENT_AUTH = 'CLIENT_AUTH',
  CUSTOM_RESOURCE = 'CUSTOM_RESOURCE',
  RETRY = 'RETRY'
}

export enum ErrorHandlerEventStatus {
  INFO = 'INFO',
  SUCCESS = 'SUCCESS',
  WARNING = 'WARNING',
  ERROR = 'ERROR'
}

export interface ErrorHandlerEventOptions {
  scenarioId: string
  type: ErrorHandlerEventType
  status: ErrorHandlerEventStatus
  url: string
  message: string
  action?: string
  errorCode?: number
  requestMethod?: string
  isMainFrame?: boolean
  isRedirect?: boolean
  details?: string[]
  isSimulated?: boolean
}

export class ErrorHandlerEvent {
  id: number
  timestamp: string
  scenarioId: string
  type: ErrorHandlerEventType
  status: ErrorHandlerEventStatus
  url: string
  message: string
  action: string
  errorCode: number
  requestMethod: string
  isMainFrame: boolean
  isRedirect: boolean
  details: string[]
  isSimulated: boolean

  constructor(id: number, timestamp: string, options: ErrorHandlerEventOptions) {
    this.id = id
    this.timestamp = timestamp
    this.scenarioId = options.scenarioId
    this.type = options.type
    this.status = options.status
    this.url = options.url
    this.message = options.message
    this.action = options.action ?? ''
    this.errorCode = options.errorCode ?? 0
    this.requestMethod = options.requestMethod ?? ''
    this.isMainFrame = options.isMainFrame ?? false
    this.isRedirect = options.isRedirect ?? false
    this.details = options.details ?? []
    this.isSimulated = options.isSimulated ?? false
  }
}