import { ErrorHandlerScenario, ERROR_HANDLER_SCENARIOS } from './ErrorHandlerScenario'
import { ErrorHandlerEvent } from './ErrorHandlerEvent'
import { ErrorHandlerPrompt } from './ErrorHandlerPrompt'

export enum ErrorHandlerScreen {
  MAIN_MENU = 'MAIN_MENU',
  SCENARIO_TEST = 'SCENARIO_TEST',
  SCENARIO_PICKER = 'SCENARIO_PICKER',
  CUSTOM_URL_TEST = 'CUSTOM_URL_TEST',
  HISTORY = 'HISTORY',
  DETAILS = 'DETAILS'
}

export enum ErrorHandlerRunMode {
  SIMULATED = 'SIMULATED',
  LIVE = 'LIVE'
}

export class ErrorHandlerUiState {
  activeScreen: ErrorHandlerScreen = ErrorHandlerScreen.MAIN_MENU
  runMode: ErrorHandlerRunMode = ErrorHandlerRunMode.SIMULATED

  selectedScenario: ErrorHandlerScenario = ERROR_HANDLER_SCENARIOS[0]

  currentUrl: string = ''
  isLoading: boolean = false
  loadingProgress: number = 0

  latestEvent: ErrorHandlerEvent | undefined = undefined
  selectedEvent: ErrorHandlerEvent | undefined = undefined
  eventHistory: ErrorHandlerEvent[] = []

  pendingPrompt: ErrorHandlerPrompt | undefined = undefined

  retryCount: number = 0
  maxRetryCount: number = 2

  isWebVisible: boolean = false
  statusMessage: string = 'Select a scenario to start.'
}