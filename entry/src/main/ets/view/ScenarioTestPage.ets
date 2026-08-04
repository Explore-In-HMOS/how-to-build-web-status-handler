import {ArcButton,ArcButtonOptions,ArcButtonPosition, ArcButtonStyleMode, ArcList, ArcListItem } from '@kit.ArkUI'
import { ErrorHandlerViewModel } from '../viewmodel/ErrorHandlerViewModel'
import { CallbackTraceCard } from '../components/CallbackTraceCard'
import { ErrorHandlerRunMode, ErrorHandlerScreen } from '../model/ErrorHandlerUiState'
import { ResultCard } from '../components/ResultCard'
import { PromptPanel } from '../components/PromptPanel'

@Component
export struct ScenarioTestPage {
  @Prop refreshTick: number = 0

  @ObjectLink viewModel: ErrorHandlerViewModel
  @Link activeScreen: ErrorHandlerScreen

  private runScenario(): void {
    if (this.viewModel.uiState.pendingPrompt !== undefined) {
      return
    }
    this.viewModel.runSelectedScenario()
  }

  private toggleRunMode(): void {
    if (this.viewModel.uiState.runMode === ErrorHandlerRunMode.SIMULATED) {
      this.viewModel.setRunMode(ErrorHandlerRunMode.LIVE)
      return
    }

    this.viewModel.setRunMode(ErrorHandlerRunMode.SIMULATED)
  }

  private openScenarioPicker(): void {
    this.viewModel.showScenarioPickerScreen()
    this.activeScreen = ErrorHandlerScreen.SCENARIO_PICKER
  }

  private createTopArcOptions(): ArcButtonOptions {
    return new ArcButtonOptions({
      label: 'Menu',
      position: ArcButtonPosition.TOP_EDGE,
      styleMode: ArcButtonStyleMode.NORMAL_LIGHT,
      onClick: (): void => {
        this.viewModel.showMainMenuScreen()
        this.activeScreen = ErrorHandlerScreen.MAIN_MENU
      }
    })
  }

  private createBottomArcOptions(): ArcButtonOptions {
    return new ArcButtonOptions({
      label: this.viewModel.uiState.pendingPrompt !== undefined ? 'Prompt' : 'Run',
      position: ArcButtonPosition.BOTTOM_EDGE,
      styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
      onClick: (): void => {
        this.runScenario()
      }
    })
  }

  @Builder
  private HeaderSection(): void {
    Column() {
      Text('Scenario Test')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .maxLines(1)

      Text(this.viewModel.uiState.statusMessage)
        .fontSize(10)
        .opacity(0.62)
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 4 })
    }
    .width('80%')
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 8, bottom: 6 })
  }

  @Builder
  private SelectedScenarioSection(): void {
    Column() {
      Text('Selected Scenario')
        .fontSize(10)
        .opacity(0.68)
        .textAlign(TextAlign.Center)

      Text(this.viewModel.uiState.selectedScenario.shortTitle)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 4 })

      Text(this.viewModel.uiState.selectedScenario.category)
        .fontSize(9)
        .opacity(0.58)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .margin({ top: 3 })

      Button('Change', {
        type: ButtonType.Capsule,
        stateEffect: true
      })
        .width(92)
        .height(32)
        .fontSize(11)
        .margin({ top: 8 })
        .onClick((): void => {
          this.openScenarioPicker()
        })
    }
    .width('80%')
    .padding(11)
    .borderRadius(20)
    .border({
      width: 1,
      color: '#2563EB'
    })
    .alignItems(HorizontalAlign.Center)
    .onClick((): void => {
      this.openScenarioPicker()
    })
  }

  @Builder
  private ModeSection(): void {
    Row() {
      Text('Mode')
        .fontSize(10)
        .opacity(0.62)
        .margin({ right: 6 })

      Text(this.viewModel.uiState.runMode)
        .fontSize(11)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .padding({
          left: 9,
          right: 9,
          top: 3,
          bottom: 3
        })
        .borderRadius(12)
        .backgroundColor(
          this.viewModel.uiState.runMode === ErrorHandlerRunMode.SIMULATED
            ? '#2563EB'
            : '#16A34A'
        )
    }
    .width('80%')
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick((): void => {
      this.toggleRunMode()
    })
  }

  @Builder
  private ResultActionsSection(): void {
    Column() {
      Row() {
        Button('Logs', {
          type: ButtonType.Capsule,
          stateEffect: true
        })
          .fontSize(11)
          .height(32)
          .width(64)
          .onClick((): void => {
            this.viewModel.showHistoryScreen()
            this.activeScreen = ErrorHandlerScreen.HISTORY
          })

        Button('Retry', {
          type: ButtonType.Capsule,
          stateEffect: true
        })
          .fontSize(11)
          .height(32)
          .width(64)
          .margin({ left: 8 })
          .onClick((): void => {
            this.viewModel.retrySelectedScenario()
          })
      }
      .justifyContent(FlexAlign.Center)

      Text('Use Retry after a failed resource test.')
        .fontSize(8)
        .opacity(0.48)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 4 })
    }
    .width('80%')
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 4, bottom: 4 })
  }

  build() {
    Stack() {
      Column() {
        Text(`${this.refreshTick}`)
          .width(0)
          .height(0)
          .opacity(0)

        Text(`${this.viewModel.uiRefreshKey}`)
          .width(0)
          .height(0)
          .opacity(0)

        ArcButton({
          options: this.createTopArcOptions()
        })
          .width(170)
          .height(44)

        ArcList() {
          ArcListItem() {
            this.HeaderSection()
          }

          ArcListItem() {
            this.SelectedScenarioSection()
          }

          ArcListItem() {
            this.ModeSection()
          }

          ArcListItem() {
            ResultCard({
              latestEvent: this.viewModel.uiState.latestEvent,
              refreshTick: this.refreshTick
            })
          }

          ArcListItem() {
            CallbackTraceCard({
              latestEvent: this.viewModel.uiState.latestEvent,
              refreshTick: this.refreshTick
            })
          }

          ArcListItem() {
            this.ResultActionsSection()
          }

          ArcListItem() {
            PromptPanel({
              viewModel: this.viewModel
            })
          }
        }
        .width('100%')
        .layoutWeight(1)

        ArcButton({
          options: this.createBottomArcOptions()
        })
          .width(170)
          .height(44)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)

    }
    .width('100%')
    .height('100%')
  }

}