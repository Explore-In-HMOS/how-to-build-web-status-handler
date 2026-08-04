import { ErrorHandlerEvent, ErrorHandlerEventOptions } from '../model/ErrorHandlerEvent'
import { ErrorHandlerUiState } from '../model/ErrorHandlerUiState'
import { ErrorHandlerLogger } from './ErrorHandlerLogger'

export class ErrorHandlerHistoryService {
  private uiState: ErrorHandlerUiState
  private nextEventId: number = 1

  constructor(uiState: ErrorHandlerUiState) {
    this.uiState = uiState
  }

  addEvent(eventOptions: ErrorHandlerEventOptions): void {
    const event: ErrorHandlerEvent = new ErrorHandlerEvent(
      this.nextEventId++,
      this.createTimestamp(),
      eventOptions
    )

    this.uiState.latestEvent = event
    this.uiState.eventHistory.unshift(event)

    ErrorHandlerLogger.logEvent(event)
  }

  clearEventHistory(): void {
    this.uiState.eventHistory = []
    this.uiState.latestEvent = undefined
    this.uiState.selectedEvent = undefined
    this.uiState.statusMessage = 'Event history cleared.'
  }

  showEventDetails(event: ErrorHandlerEvent): void {
    this.uiState.selectedEvent = event
  }

  clearSelectedEvent(): void {
    this.uiState.selectedEvent = undefined
  }

  private createTimestamp(): string {
    const date: Date = new Date()

    const hours: string = this.padTimeValue(date.getHours())
    const minutes: string = this.padTimeValue(date.getMinutes())
    const seconds: string = this.padTimeValue(date.getSeconds())

    return `${hours}:${minutes}:${seconds}`
  }

  private padTimeValue(value: number): string {
    if (value < 10) {
      return `0${value}`
    }

    return `${value}`
  }
}