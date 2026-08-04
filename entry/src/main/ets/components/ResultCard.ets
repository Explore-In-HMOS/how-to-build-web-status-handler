import { ErrorHandlerEvent, ErrorHandlerEventStatus } from '../model/ErrorHandlerEvent'

@Component
export struct ResultCard {
  @Prop latestEvent: ErrorHandlerEvent | undefined
  @Prop refreshTick: number = 0

  private getStatusLabel(): string {
    if (this.latestEvent === undefined) {
      return 'WAITING'
    }
    return this.latestEvent.status
  }
  private getStatusColor(): string {
    if (this.latestEvent === undefined) {
      return '#64748B'
    }
    if (this.latestEvent.status === ErrorHandlerEventStatus.SUCCESS) {
      return '#16A34A'
    }
    if (this.latestEvent.status === ErrorHandlerEventStatus.ERROR) {
      return '#DC2626'
    }
    if (this.latestEvent.status === ErrorHandlerEventStatus.WARNING) {
      return '#D97706'
    }

    return '#2563EB'
  }

  private getBorderColor(): string {
    if (this.latestEvent === undefined) {
      return '#475569'
    }
    return this.getStatusColor()
  }

  build() {
    Column() {
      Text(`${this.refreshTick}`)
        .width(0)
        .height(0)
        .opacity(0)

      Row() {
        Text('Result')
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)

        Text(this.getStatusLabel())
          .fontSize(8)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .padding({
            left: 7,
            right: 7,
            top: 2,
            bottom: 2
          })
          .borderRadius(10)
          .backgroundColor(this.getStatusColor())
          .margin({ left: 6 })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      if (this.latestEvent !== undefined) {
        Text(this.latestEvent.type)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 7 })

        Text(this.latestEvent.message)
          .fontSize(10)
          .opacity(0.76)
          .textAlign(TextAlign.Center)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })

        Text(this.latestEvent.action)
          .fontSize(9)
          .opacity(0.6)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })
      } else {
        Text('No result yet.')
          .fontSize(11)
          .opacity(0.68)
          .textAlign(TextAlign.Center)
          .margin({ top: 7 })

        Text('Run a test to capture WebView callbacks.')
          .fontSize(9)
          .opacity(0.52)
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })
      }
    }
    .width('80%')
    .padding(10)
    .borderRadius(18)
    .border({
      width: 1,
      color: this.getBorderColor()
    })
    .alignItems(HorizontalAlign.Center)
  }
}