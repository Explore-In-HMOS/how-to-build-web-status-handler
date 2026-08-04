import { ErrorHandlerViewModel } from '../viewmodel/ErrorHandlerViewModel'

@Component
export struct LatestEventCard {
  @ObjectLink viewModel: ErrorHandlerViewModel

  build() {
    Column() {
      Text('Latest Event')
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 4 })

      if (this.viewModel.uiState.latestEvent !== undefined) {
        Text(this.viewModel.uiState.latestEvent.type)
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.viewModel.uiState.latestEvent.message)
          .fontSize(10)
          .opacity(0.72)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Center)
          .margin({ top: 3 })

        Text(this.viewModel.uiState.latestEvent.action)
          .fontSize(9)
          .opacity(0.58)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 3 })
      } else {
        Text('No event yet.')
          .fontSize(11)
          .opacity(0.65)
      }
    }
    .width('78%')
    .padding(8)
    .borderRadius(16)
    .alignItems(HorizontalAlign.Center)
  }
}