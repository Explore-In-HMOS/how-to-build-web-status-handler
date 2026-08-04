export enum ErrorHandlerAuthAction {
  SSL_CONFIRM = 'SSL_CONFIRM',
  SSL_CANCEL = 'SSL_CANCEL',
  HTTP_AUTH_CONFIRM = 'HTTP_AUTH_CONFIRM',
  HTTP_AUTH_CANCEL = 'HTTP_AUTH_CANCEL',
  CLIENT_AUTH_CONFIRM = 'CLIENT_AUTH_CONFIRM',
  CLIENT_AUTH_CANCEL = 'CLIENT_AUTH_CANCEL',
  CLIENT_AUTH_IGNORE = 'CLIENT_AUTH_IGNORE',
  CLEAR_ALL = 'CLEAR_ALL'
}

export interface ErrorHandlerAuthOperationResult {
  success: boolean
  action: ErrorHandlerAuthAction
  message: string
  details: string[]
}

export interface ErrorHandlerHttpAuthCredential {
  username: string
  password: string
}

export interface ErrorHandlerClientCertificateCredential {
  privateKeyFilePath: string
  certificateChainFilePath: string
}

export interface ErrorHandlerAuthHandlerState {
  hasSslHandler: boolean
  hasHttpAuthHandler: boolean
  hasClientAuthHandler: boolean
}

export class ErrorHandlerAuthManager {
  private sslHandler: SslErrorHandler | undefined = undefined
  private httpAuthHandler: HttpAuthHandler | undefined = undefined
  private clientAuthHandler: ClientAuthenticationHandler | undefined = undefined

  storeSslHandler(handler: SslErrorHandler): ErrorHandlerAuthOperationResult {
    this.sslHandler = handler

    return {
      success: true,
      action: ErrorHandlerAuthAction.SSL_CONFIRM,
      message: 'SSL handler stored.',
      details: [
        'SslErrorHandler reference was stored.',
        'The handler can be resolved after user decision.'
      ]
    }
  }

  storeHttpAuthHandler(handler: HttpAuthHandler): ErrorHandlerAuthOperationResult {
    this.httpAuthHandler = handler

    return {
      success: true,
      action: ErrorHandlerAuthAction.HTTP_AUTH_CONFIRM,
      message: 'HTTP auth handler stored.',
      details: [
        'HttpAuthHandler reference was stored.',
        'The handler can be resolved after credential input.'
      ]
    }
  }

  storeClientAuthHandler(
    handler: ClientAuthenticationHandler
  ): ErrorHandlerAuthOperationResult {
    this.clientAuthHandler = handler

    return {
      success: true,
      action: ErrorHandlerAuthAction.CLIENT_AUTH_CONFIRM,
      message: 'Client authentication handler stored.',
      details: [
        'ClientAuthenticationHandler reference was stored.',
        'The handler can be resolved after certificate decision.'
      ]
    }
  }

  confirmSslError(): ErrorHandlerAuthOperationResult {
    if (this.sslHandler === undefined) {
      return this.createMissingHandlerResult(
        ErrorHandlerAuthAction.SSL_CONFIRM,
        'SSL handler is not available.'
      )
    }

    this.sslHandler.handleConfirm()
    this.sslHandler = undefined

    return {
      success: true,
      action: ErrorHandlerAuthAction.SSL_CONFIRM,
      message: 'SSL warning accepted.',
      details: [
        'User selected Proceed.',
        'SslErrorHandler handleConfirm was requested.',
        'SSL handler reference was cleared.'
      ]
    }
  }

  cancelSslError(): ErrorHandlerAuthOperationResult {
    if (this.sslHandler === undefined) {
      return this.createMissingHandlerResult(
        ErrorHandlerAuthAction.SSL_CANCEL,
        'SSL handler is not available.'
      )
    }

    this.sslHandler.handleCancel()
    this.sslHandler = undefined

    return {
      success: true,
      action: ErrorHandlerAuthAction.SSL_CANCEL,
      message: 'SSL warning cancelled.',
      details: [
        'User selected Cancel.',
        'SslErrorHandler handleCancel was requested.',
        'SSL handler reference was cleared.'
      ]
    }
  }

  confirmHttpAuth(
    username: string,
    password: string
  ): ErrorHandlerAuthOperationResult {
    if (this.httpAuthHandler === undefined) {
      return this.createMissingHandlerResult(
        ErrorHandlerAuthAction.HTTP_AUTH_CONFIRM,
        'HTTP auth handler is not available.'
      )
    }

    this.httpAuthHandler.confirm(username, password)
    this.httpAuthHandler = undefined

    return {
      success: true,
      action: ErrorHandlerAuthAction.HTTP_AUTH_CONFIRM,
      message: 'HTTP authentication submitted.',
      details: [
        `Username provided: ${username.length > 0}`,
        `Password provided: ${password.length > 0}`,
        'Password value was not logged.',
        'HttpAuthHandler confirm was requested.',
        'HTTP auth handler reference was cleared.'
      ]
    }
  }

  confirmHttpAuthWithCredential(
    credential: ErrorHandlerHttpAuthCredential
  ): ErrorHandlerAuthOperationResult {
    return this.confirmHttpAuth(
      credential.username,
      credential.password
    )
  }

  cancelHttpAuth(): ErrorHandlerAuthOperationResult {
    if (this.httpAuthHandler === undefined) {
      return this.createMissingHandlerResult(
        ErrorHandlerAuthAction.HTTP_AUTH_CANCEL,
        'HTTP auth handler is not available.'
      )
    }

    this.httpAuthHandler.cancel()
    this.httpAuthHandler = undefined

    return {
      success: true,
      action: ErrorHandlerAuthAction.HTTP_AUTH_CANCEL,
      message: 'HTTP authentication cancelled.',
      details: [
        'User selected Cancel.',
        'HttpAuthHandler cancel was requested.',
        'HTTP auth handler reference was cleared.'
      ]
    }
  }

  confirmClientAuthentication(
    privateKeyFilePath: string,
    certificateChainFilePath: string
  ): ErrorHandlerAuthOperationResult {
    if (this.clientAuthHandler === undefined) {
      return this.createMissingHandlerResult(
        ErrorHandlerAuthAction.CLIENT_AUTH_CONFIRM,
        'Client authentication handler is not available.'
      )
    }

    this.clientAuthHandler.confirm(
      privateKeyFilePath,
      certificateChainFilePath
    )

    this.clientAuthHandler = undefined

    return {
      success: true,
      action: ErrorHandlerAuthAction.CLIENT_AUTH_CONFIRM,
      message: 'Client certificate submitted.',
      details: [
        `Private key path provided: ${privateKeyFilePath.length > 0}`,
        `Certificate chain path provided: ${certificateChainFilePath.length > 0}`,
        'ClientAuthenticationHandler confirm was requested.',
        'Client authentication handler reference was cleared.'
      ]
    }
  }

  confirmClientAuthenticationWithCredential(
    credential: ErrorHandlerClientCertificateCredential
  ): ErrorHandlerAuthOperationResult {
    return this.confirmClientAuthentication(
      credential.privateKeyFilePath,
      credential.certificateChainFilePath
    )
  }

  cancelClientAuthentication(): ErrorHandlerAuthOperationResult {
    if (this.clientAuthHandler === undefined) {
      return this.createMissingHandlerResult(
        ErrorHandlerAuthAction.CLIENT_AUTH_CANCEL,
        'Client authentication handler is not available.'
      )
    }

    this.clientAuthHandler.cancel()
    this.clientAuthHandler = undefined

    return {
      success: true,
      action: ErrorHandlerAuthAction.CLIENT_AUTH_CANCEL,
      message: 'Client authentication cancelled.',
      details: [
        'User selected Cancel.',
        'ClientAuthenticationHandler cancel was requested.',
        'Client authentication handler reference was cleared.'
      ]
    }
  }

  ignoreClientAuthentication(): ErrorHandlerAuthOperationResult {
    if (this.clientAuthHandler === undefined) {
      return this.createMissingHandlerResult(
        ErrorHandlerAuthAction.CLIENT_AUTH_IGNORE,
        'Client authentication handler is not available.'
      )
    }

    this.clientAuthHandler.ignore()
    this.clientAuthHandler = undefined

    return {
      success: true,
      action: ErrorHandlerAuthAction.CLIENT_AUTH_IGNORE,
      message: 'Client authentication ignored.',
      details: [
        'User selected Ignore.',
        'ClientAuthenticationHandler ignore was requested.',
        'Client authentication handler reference was cleared.'
      ]
    }
  }

  clearSslHandler(): void {
    this.sslHandler = undefined
  }

  clearHttpAuthHandler(): void {
    this.httpAuthHandler = undefined
  }

  clearClientAuthHandler(): void {
    this.clientAuthHandler = undefined
  }

  clearAllHandlers(): ErrorHandlerAuthOperationResult {
    this.sslHandler = undefined
    this.httpAuthHandler = undefined
    this.clientAuthHandler = undefined

    return {
      success: true,
      action: ErrorHandlerAuthAction.CLEAR_ALL,
      message: 'All authentication handlers were cleared.',
      details: [
        'SSL handler cleared.',
        'HTTP auth handler cleared.',
        'Client authentication handler cleared.'
      ]
    }
  }

  hasSslHandler(): boolean {
    return this.sslHandler !== undefined
  }

  hasHttpAuthHandler(): boolean {
    return this.httpAuthHandler !== undefined
  }

  hasClientAuthHandler(): boolean {
    return this.clientAuthHandler !== undefined
  }

  getHandlerState(): ErrorHandlerAuthHandlerState {
    return {
      hasSslHandler: this.hasSslHandler(),
      hasHttpAuthHandler: this.hasHttpAuthHandler(),
      hasClientAuthHandler: this.hasClientAuthHandler()
    }
  }

  private createMissingHandlerResult(
    action: ErrorHandlerAuthAction,
    message: string
  ): ErrorHandlerAuthOperationResult {
    return {
      success: false,
      action: action,
      message: message,
      details: [
        'Handler reference was undefined.',
        'The callback may be simulated or the handler may have already been resolved.'
      ]
    }
  }
}