import { ErrorHandlerEvent } from '../model/ErrorHandlerEvent'

@Component
export struct EventLogItem {
  event: ErrorHandlerEvent | undefined = undefined
  onSelectAction: (event: ErrorHandlerEvent) => void = (): void => {}

  build() {
    if (this.event !== undefined) {
      Column() {
        Text(this.event.type)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.event.message)
          .fontSize(10)
          .opacity(0.72)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Center)
          .margin({ top: 3 })

        Text(`${this.event.timestamp} | ${this.event.isSimulated ? 'SIM' : 'LIVE'}`)
          .fontSize(9)
          .opacity(0.55)
          .margin({ top: 3 })
      }
      .width('78%')
      .padding(8)
      .borderRadius(16)
      .alignItems(HorizontalAlign.Center)
      .onClick((): void => {
        if (this.event !== undefined) {
          this.onSelectAction(this.event)
        }
      })
    }
  }
}