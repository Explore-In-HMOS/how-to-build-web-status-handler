export enum ErrorHandlerPromptType {
  SSL_ERROR = 'SSL_ERROR',
  HTTP_AUTH = 'HTTP_AUTH',
  CLIENT_AUTH = 'CLIENT_AUTH'
}

export enum ErrorHandlerPromptAction {
  PROCEED = 'PROCEED',
  CANCEL = 'CANCEL',
  CONFIRM = 'CONFIRM',
  IGNORE = 'IGNORE',
  USE_CERTIFICATE = 'USE_CERTIFICATE'
}

export interface ErrorHandlerPromptOptions {
  type: ErrorHandlerPromptType
  title: string
  message: string
  host?: string
  port?: number
  realm?: string
  details?: string[]
  primaryAction: ErrorHandlerPromptAction
  primaryLabel: string
  secondaryAction: ErrorHandlerPromptAction
  secondaryLabel: string
  tertiaryAction?: ErrorHandlerPromptAction
  tertiaryLabel?: string
  requiresCredentialInput?: boolean
  isSimulated?: boolean
}

export class ErrorHandlerPrompt {
  type: ErrorHandlerPromptType
  title: string
  message: string
  host: string
  port: number
  realm: string
  details: string[]
  primaryAction: ErrorHandlerPromptAction
  primaryLabel: string
  secondaryAction: ErrorHandlerPromptAction
  secondaryLabel: string
  tertiaryAction?: ErrorHandlerPromptAction
  tertiaryLabel?: string
  requiresCredentialInput: boolean
  isSimulated: boolean

  constructor(options: ErrorHandlerPromptOptions) {
    this.type = options.type
    this.title = options.title
    this.message = options.message
    this.host = options.host ?? ''
    this.port = options.port ?? 0
    this.realm = options.realm ?? ''
    this.details = options.details ?? []
    this.primaryAction = options.primaryAction
    this.primaryLabel = options.primaryLabel
    this.secondaryAction = options.secondaryAction
    this.secondaryLabel = options.secondaryLabel
    this.tertiaryAction = options.tertiaryAction
    this.tertiaryLabel = options.tertiaryLabel
    this.requiresCredentialInput = options.requiresCredentialInput ?? false
    this.isSimulated = options.isSimulated ?? false
  }
}