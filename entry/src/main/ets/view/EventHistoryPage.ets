import {ArcButton,ArcButtonOptions,ArcButtonPosition, ArcButtonStyleMode, ArcList, ArcListItem } from '@kit.ArkUI'
import { ErrorHandlerViewModel } from '../viewmodel/ErrorHandlerViewModel'
import { ErrorHandlerEvent } from '../model/ErrorHandlerEvent'
import { ErrorHandlerScreen } from '../model/ErrorHandlerUiState'
import { EventLogItem } from '../components/EventLogItem'

@Component
export struct EventHistoryPage {
  @ObjectLink viewModel: ErrorHandlerViewModel
  @Link activeScreen: ErrorHandlerScreen
  @Prop refreshTick: number = 0

  private createTopArcOptions(): ArcButtonOptions {
    return new ArcButtonOptions({
      label: 'Back',
      position: ArcButtonPosition.TOP_EDGE,
      styleMode: ArcButtonStyleMode.NORMAL_LIGHT,
      onClick: (): void => {
        this.viewModel.returnToPreviousTestScreen()
        this.activeScreen = this.viewModel.uiState.activeScreen
      }
    })
  }

  private createBottomArcOptions(): ArcButtonOptions {
    return new ArcButtonOptions({
      label: 'Clear',
      position: ArcButtonPosition.BOTTOM_EDGE,
      styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
      onClick: (): void => {
        this.viewModel.clearEventHistory()
      }
    })
  }

  @Builder
  private HeaderSection(): void {
    Column() {
      Text('Event Logs')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)

      Text('Tap an item for details.')
        .fontSize(10)
        .opacity(0.65)
        .textAlign(TextAlign.Center)
        .margin({ top: 4 })

      Text('Top: Back | Bottom: Clear')
        .fontSize(9)
        .opacity(0.5)
        .textAlign(TextAlign.Center)
        .margin({ top: 3 })
    }
    .width('80%')
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 8, bottom: 8 })
  }

  @Builder
  private EmptySection(): void {
    Column() {
      Text('No logs yet.')
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)

      Text('Run a scenario or custom URL test first.')
        .fontSize(10)
        .opacity(0.62)
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 4 })
    }
    .width('78%')
    .alignItems(HorizontalAlign.Center)
    .padding(10)
  }

  build() {
    Column() {
      Text(`${this.viewModel.uiRefreshKey}`)
        .width(0)
        .height(0)
        .opacity(0)

      Row() {
        ArcButton({
          options: this.createTopArcOptions()
        })
          .width(160)
          .height(46)
      }
      .width('100%')
      .height(46)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      ArcList() {
        ArcListItem() {
          this.HeaderSection()
        }

        if (this.viewModel.uiState.eventHistory.length === 0) {
          ArcListItem() {
            this.EmptySection()
          }
        }

        ForEach(
          this.viewModel.uiState.eventHistory,
          (event: ErrorHandlerEvent): void => {
            ArcListItem() {
              EventLogItem({
                event: event,
                onSelectAction: (selectedEvent: ErrorHandlerEvent): void => {
                  this.viewModel.showEventDetails(selectedEvent)
                  this.activeScreen = ErrorHandlerScreen.DETAILS
                }
              })
            }
          },
          (event: ErrorHandlerEvent): string => event.id.toString()
        )
      }
      .width('100%')
      .layoutWeight(1)

      Row() {
        ArcButton({
          options: this.createBottomArcOptions()
        })
          .width(170)
          .height(50)
      }
      .width('100%')
      .height(50)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }
}