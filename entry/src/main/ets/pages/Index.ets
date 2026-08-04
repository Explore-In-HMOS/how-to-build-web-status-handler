import { ErrorHandlerViewModel } from '../viewmodel/ErrorHandlerViewModel'
import { ErrorHandlerScreen } from '../model/ErrorHandlerUiState'
import { MainMenuPage } from '../view/MainMenuPage'
import { ScenarioTestPage } from '../view/ScenarioTestPage'
import { ScenarioPickerPage } from '../view/ScenarioPickerPage'
import { CustomUrlTestPage } from '../view/CustomUrlTestPage'
import { EventHistoryPage } from '../view/EventHistoryPage'
import { EventDetailPage } from '../view/EventDetailPage'
import { WebCallbackBridge } from '../components/WebCallbackBridge'

@Entry
@Component
struct Index {
  @State private viewModel: ErrorHandlerViewModel = new ErrorHandlerViewModel()
  @State private activeScreen: ErrorHandlerScreen = ErrorHandlerScreen.MAIN_MENU
  @State private refreshTick: number = 0

  aboutToAppear(): void {
    this.viewModel.bindUiRefreshHandler((): void => {
      this.refreshTick++
    })
  }

  build() {
    Stack() {
      if (this.activeScreen === ErrorHandlerScreen.MAIN_MENU) {
        MainMenuPage({
          viewModel: this.viewModel,
          activeScreen: $activeScreen
        })
          .width('100%')
          .height('100%')
      } else if (this.activeScreen === ErrorHandlerScreen.SCENARIO_TEST) {
        ScenarioTestPage({
          viewModel: this.viewModel,
          activeScreen: $activeScreen,
          refreshTick: this.refreshTick
        })
          .width('100%')
          .height('100%')
      } else if (this.activeScreen === ErrorHandlerScreen.SCENARIO_PICKER) {
        ScenarioPickerPage({
          viewModel: this.viewModel,
          activeScreen: $activeScreen
        })
          .width('100%')
          .height('100%')
      } else if (this.activeScreen === ErrorHandlerScreen.CUSTOM_URL_TEST) {
        CustomUrlTestPage({
          viewModel: this.viewModel,
          activeScreen: $activeScreen,
          refreshTick: this.refreshTick
        })
          .width('100%')
          .height('100%')
      } else if (this.activeScreen === ErrorHandlerScreen.HISTORY) {
        EventHistoryPage({
          viewModel: this.viewModel,
          activeScreen: $activeScreen,
          refreshTick: this.refreshTick
        })
          .width('100%')
          .height('100%')
      } else if (this.activeScreen === ErrorHandlerScreen.DETAILS) {
        EventDetailPage({
          viewModel: this.viewModel,
          activeScreen: $activeScreen
        })
          .width('100%')
          .height('100%')
      }

      WebCallbackBridge({
        viewModel: this.viewModel,
        logTag: 'GLOBAL_WEB_BRIDGE'
      })
    }
    .width('100%')
    .height('100%')
  }
}