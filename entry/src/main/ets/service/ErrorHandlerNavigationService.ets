import { ErrorHandlerScreen, ErrorHandlerUiState } from '../model/ErrorHandlerUiState'
import { ErrorHandlerEvent } from '../model/ErrorHandlerEvent'

export class ErrorHandlerNavigationService {
  private uiState: ErrorHandlerUiState
  private previousTestScreen: ErrorHandlerScreen = ErrorHandlerScreen.SCENARIO_TEST

  constructor(uiState: ErrorHandlerUiState) {
    this.uiState = uiState
  }

  showMainMenuScreen(): void {
    this.uiState.activeScreen = ErrorHandlerScreen.MAIN_MENU
    this.uiState.pendingPrompt = undefined
    this.uiState.selectedEvent = undefined
    this.uiState.statusMessage = 'Choose a test mode.'
  }

  showScenarioTestScreen(): void {
    this.previousTestScreen = ErrorHandlerScreen.SCENARIO_TEST
    this.uiState.activeScreen = ErrorHandlerScreen.SCENARIO_TEST
    this.uiState.pendingPrompt = undefined
    this.uiState.selectedEvent = undefined
    this.uiState.statusMessage = 'Select a scenario to start.'
  }

  showScenarioPickerScreen(): void {
    this.uiState.activeScreen = ErrorHandlerScreen.SCENARIO_PICKER
    this.uiState.pendingPrompt = undefined
    this.uiState.selectedEvent = undefined
    this.uiState.statusMessage = 'Choose a scenario.'
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
  }

  returnToPreviousTestScreen(): void {
    this.uiState.activeScreen = this.previousTestScreen
    this.uiState.selectedEvent = undefined

    if (this.previousTestScreen === ErrorHandlerScreen.SCENARIO_TEST) {
      this.uiState.statusMessage = 'Select a scenario to start.'
      return
    }

    this.uiState.statusMessage = 'Enter a URL to test WebView callbacks.'
  }

  showEventDetails(event: ErrorHandlerEvent): void {
    this.uiState.selectedEvent = event
    this.uiState.activeScreen = ErrorHandlerScreen.DETAILS
    this.uiState.statusMessage = 'Review event details.'
  }

  closeEventDetails(): void {
    this.uiState.selectedEvent = undefined
    this.uiState.activeScreen = ErrorHandlerScreen.HISTORY
    this.uiState.statusMessage = 'Review captured WebView events.'
  }
}