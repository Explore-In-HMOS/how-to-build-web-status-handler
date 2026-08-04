import {ArcButton,ArcButtonOptions,ArcButtonPosition, ArcButtonStyleMode, ArcList, ArcListItem } from '@kit.ArkUI'
import { ErrorHandlerViewModel } from '../viewmodel/ErrorHandlerViewModel'
import { ErrorHandlerScreen } from '../model/ErrorHandlerUiState'

@Component
export struct EventDetailPage {
  @Link activeScreen: ErrorHandlerScreen
  @ObjectLink viewModel: ErrorHandlerViewModel

  private createTopArcOptions(): ArcButtonOptions {
    return new ArcButtonOptions({
      label: 'Back',
      position: ArcButtonPosition.TOP_EDGE,
      styleMode: ArcButtonStyleMode.NORMAL_LIGHT,
      onClick: (): void => {
        this.viewModel.closeEventDetails()
        this.activeScreen = ErrorHandlerScreen.HISTORY
      }
    })
  }

  private createBottomArcOptions(): ArcButtonOptions {
    return new ArcButtonOptions({
      label: 'Back',
      position: ArcButtonPosition.BOTTOM_EDGE,
      styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
      onClick: (): void => {
        this.viewModel.closeEventDetails()
      }
    })
  }

  private compactText(value: string, maxLength: number): string {
    if (value.length <= maxLength) {
      return value
    }

    return `${value.substring(0, maxLength)}...`
  }

  @Builder
  private DetailSection(): void {
    Column() {
      Text('Event Detail')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .margin({ bottom: 8 })

      if (this.viewModel.uiState.selectedEvent !== undefined) {
        Text(this.viewModel.uiState.selectedEvent.type)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.viewModel.uiState.selectedEvent.message)
          .fontSize(10)
          .opacity(0.72)
          .textAlign(TextAlign.Center)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })

        Text(this.compactText(this.viewModel.uiState.selectedEvent.url, 42))
          .fontSize(9)
          .opacity(0.58)
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })

        Text(`Action: ${this.viewModel.uiState.selectedEvent.action}`)
          .fontSize(9)
          .opacity(0.65)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })

        ForEach(
          this.viewModel.uiState.selectedEvent.details,
          (detail: string): void => {
            Text(detail)
              .fontSize(9)
              .opacity(0.58)
              .textAlign(TextAlign.Center)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ top: 3 })
          },
          (detail: string): string => detail
        )
      } else {
        Text('No selected event.')
          .fontSize(11)
          .opacity(0.65)
          .textAlign(TextAlign.Center)
      }

      Text('Use arc buttons to go back.')
        .fontSize(8)
        .opacity(0.5)
        .textAlign(TextAlign.Center)
        .margin({ top: 8 })
    }
    .width('80%')
    .padding({ top: 8, bottom: 16 })
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Column() {
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
          this.DetailSection()
        }
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