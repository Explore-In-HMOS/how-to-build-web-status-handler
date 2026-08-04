import { ErrorHandlerEvent, ErrorHandlerEventOptions } from '../model/ErrorHandlerEvent'
import { ErrorHandlerScreen, ErrorHandlerUiState } from '../model/ErrorHandlerUiState'
import { ErrorHandlerLogger } from '../service/ErrorHandlerLogger'

export class ErrorHandlerNavigationHistoryViewModel {
  private uiState: ErrorHandlerUiState
  private nextEventId: number = 1
  private previousTestScreen: ErrorHandlerScreen = ErrorHandlerScreen.SCENARIO_TEST
  private notifyUiChanged: () => void

  constructor(
    uiState: ErrorHandlerUiState,
    notifyUiChanged: () => void
  ) {
    this.uiState = uiState
    this.notifyUiChanged = notifyUiChanged
  }


  showMainMenuScreen(): void {
    this.uiState.activeScreen = ErrorHandlerScreen.MAIN_MENU
    this.uiState.pendingPrompt = undefined
    this.uiState.selectedEvent = undefined
    this.uiState.statusMessage = 'Choose a test mode.'
    this.notifyUiChanged()
  }

  showScenarioTestScreen(): void {
    this.previousTestScreen = ErrorHandlerScreen.SCENARIO_TEST
    this.uiState.activeScreen = ErrorHandlerScreen.SCENARIO_TEST
    this.uiState.pendingPrompt = undefined
    this.uiState.selectedEvent = undefined
    this.uiState.statusMessage = 'Select a scenario to start.'
    this.notifyUiChanged()
  }

  showScenarioPickerScreen(): void {
    this.uiState.activeScreen = ErrorHandlerScreen.SCENARIO_PICKER
    this.uiState.pendingPrompt = undefined
    this.uiState.selectedEvent = undefined
    this.uiState.statusMessage = 'Choose a scenario.'
    this.notifyUiChanged()
  }

  showCustomUrlTestScreen(): void {
    this.previousTestScreen = ErrorHandlerScreen.CUSTOM_URL_TEST
    this.uiState.activeScreen = ErrorHandlerScreen.CUSTOM_URL_TEST
    this.uiState.pendingPrompt = undefined
    this.uiState.selectedEvent = undefined
    this.uiState.isWebVisible = false
    this.uiState.isLoading = false
    this.uiState.loadingProgress = 0
    this.uiState.statusMessage = 'Enter a URL to test WebView callbacks.'
    this.notifyUiChanged()
  }

  showScenarioScreen(): void {
    this.showScenarioTestScreen()
  }

  showHistoryScreen(): void {
    if (this.uiState.activeScreen === ErrorHandlerScreen.SCENARIO_TEST ||
      this.uiState.activeScreen === ErrorHandlerScreen.CUSTOM_URL_TEST) {
      this.previousTestScreen = this.uiState.activeScreen

    }

    this.uiState.activeScreen = ErrorHandlerScreen.HISTORY
    this.uiState.pendingPrompt = undefined
    this.uiState.selectedEvent = undefined
    this.uiState.statusMessage = 'Review captured WebView events.'
    this.notifyUiChanged()
  }

  returnToPreviousTestScreen(): void {
    this.uiState.activeScreen = this.previousTestScreen
    this.uiState.selectedEvent = undefined

    if (this.previousTestScreen === ErrorHandlerScreen.SCENARIO_TEST) {
      this.uiState.statusMessage = 'Select a scenario to start.'
      return
    }

    this.uiState.statusMessage = 'Enter a URL to test WebView callbacks.'
    this.notifyUiChanged()
  }

  showEventDetails(event: ErrorHandlerEvent): void {
    this.uiState.selectedEvent = event
    this.uiState.activeScreen = ErrorHandlerScreen.DETAILS
    this.uiState.statusMessage = 'Review event details.'
    this.notifyUiChanged()
  }

  closeEventDetails(): void {
    this.uiState.selectedEvent = undefined
    this.uiState.activeScreen = ErrorHandlerScreen.HISTORY
    this.uiState.statusMessage = 'Review captured WebView events.'
    this.notifyUiChanged()
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

    this.notifyUiChanged()
  }

  clearEventHistory(): void {
    this.uiState.eventHistory = []
    this.uiState.latestEvent = undefined
    this.uiState.selectedEvent = undefined
    this.uiState.statusMessage = 'Event history cleared.'
    this.notifyUiChanged()
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