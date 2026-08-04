import {ArcButton,ArcButtonOptions,ArcButtonPosition, ArcButtonStyleMode, ArcList, ArcListItem } from '@kit.ArkUI'
import { ErrorHandlerViewModel } from '../viewmodel/ErrorHandlerViewModel'
import { ErrorHandlerScreen } from '../model/ErrorHandlerUiState'
import { CustomUrlInputPanel } from '../components/CustomUrlInputPanel'
import { ResultCard } from '../components/ResultCard'
import { PromptPanel } from '../components/PromptPanel'
import { CallbackTraceCard } from '../components/CallbackTraceCard'

@Component
export struct CustomUrlTestPage {
  @Prop refreshTick: number = 0

  @ObjectLink viewModel: ErrorHandlerViewModel
  @Link activeScreen: ErrorHandlerScreen

  @State private customUrlInput: string = ''

  private runCustomUrl(): void {
    if (this.viewModel.uiState.pendingPrompt !== undefined) {
      return
    }

    this.viewModel.runCustomUrlTest(this.customUrlInput)
  }

  private clearCustomUrl(): void {
    this.customUrlInput = ''
    this.viewModel.uiState.statusMessage = 'Enter a URL to test WebView callbacks.'
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
        this.runCustomUrl()
      }
    })
  }

  @Builder
  private HeaderSection(): void {
    Column() {
      Text('Custom URL Test')
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

        Button('Clear', {
          type: ButtonType.Capsule,
          stateEffect: true
        })
          .fontSize(11)
          .height(32)
          .width(64)
          .margin({ left: 8 })
          .onClick((): void => {
            this.clearCustomUrl()
          })
      }
      .justifyContent(FlexAlign.Center)

      Text('Use Clear to reset the input only.')
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
            CustomUrlInputPanel({
              customUrlInput: $customUrlInput
            })
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