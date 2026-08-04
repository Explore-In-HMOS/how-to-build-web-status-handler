import { hilog } from '@kit.PerformanceAnalysisKit'
import { ErrorHandlerEvent } from '../model/ErrorHandlerEvent'

export interface ErrorHandlerErrorInfo {
  code?: number
  message?: string
}

export class ErrorHandlerLogger {
  private static readonly DOMAIN: number = 0xD001
  private static readonly TAG: string = 'WebErrorHandler'

  static info(scope: string, message: string): void {
    const safeMessage = ErrorHandlerLogger.sanitize(message)

    hilog.info(
      ErrorHandlerLogger.DOMAIN,
      ErrorHandlerLogger.TAG,
      '[%{public}s] %{public}s',
      scope,
      safeMessage
    )
  }

  static warn(scope: string, message: string): void {
    const safeMessage = ErrorHandlerLogger.sanitize(message)

    hilog.warn(
      ErrorHandlerLogger.DOMAIN,
      ErrorHandlerLogger.TAG,
      '[%{public}s] %{public}s',
      scope,
      safeMessage
    )
  }

  static error(
    scope: string,
    message: string,
    error?: ErrorHandlerErrorInfo
  ): void {
    const safeMessage = ErrorHandlerLogger.sanitize(message)
    const errorCode = error?.code ?? -1
    const errorMessage = ErrorHandlerLogger.sanitize(
      error?.message ?? 'Unknown error'
    )

    hilog.error(
      ErrorHandlerLogger.DOMAIN,
      ErrorHandlerLogger.TAG,
      '[%{public}s] %{public}s | code=%{public}d | reason=%{public}s',
      scope,
      safeMessage,
      errorCode,
      errorMessage
    )
  }

  static logEvent(event: ErrorHandlerEvent): void {
    const mode = event.isSimulated ? 'SIMULATED' : 'LIVE'
    const safeUrl = ErrorHandlerLogger.sanitizeUrl(event.url)
    const safeAction = ErrorHandlerLogger.sanitize(event.action)

    hilog.info(
      ErrorHandlerLogger.DOMAIN,
      ErrorHandlerLogger.TAG,
      '[EVENT] id=%{public}d type=%{public}s status=%{public}s mode=%{public}s url=%{public}s action=%{public}s',
      event.id,
      event.type,
      event.status,
      mode,
      safeUrl,
      safeAction
    )
  }

  static logPromptDecision(
    promptType: string,
    action: string,
    host: string,
    isSimulated: boolean
  ): void {
    const mode = isSimulated ? 'SIMULATED' : 'LIVE'
    const safeHost = ErrorHandlerLogger.sanitize(host)

    hilog.info(
      ErrorHandlerLogger.DOMAIN,
      ErrorHandlerLogger.TAG,
      '[PROMPT] type=%{public}s action=%{public}s host=%{public}s mode=%{public}s',
      promptType,
      action,
      safeHost,
      mode
    )
  }

  private static sanitizeUrl(url: string): string {
    const queryIndex = url.indexOf('?')

    if (queryIndex < 0) {
      return ErrorHandlerLogger.sanitize(url)
    }

    const baseUrl = url.substring(0, queryIndex)
    return `${ErrorHandlerLogger.sanitize(baseUrl)}?[REDACTED]`
  }

  private static sanitize(value: string): string {
    return value
      .replace(/password\s*[:=]\s*[^,\s]+/gi, 'password=[REDACTED]')
      .replace(/passwd\s*[:=]\s*[^,\s]+/gi, 'passwd=[REDACTED]')
      .replace(/token\s*[:=]\s*[^,\s]+/gi, 'token=[REDACTED]')
      .replace(/authorization\s*[:=]\s*[^,\s]+/gi, 'authorization=[REDACTED]')
      .replace(/cookie\s*[:=]\s*[^,\s]+/gi, 'cookie=[REDACTED]')
  }
}