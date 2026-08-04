import { ErrorHandlerEvent } from '../model/ErrorHandlerEvent'

interface TraceLine {
  id: string;
  order: number;
  content: string;
}

@Component
export struct CallbackTraceCard {
  @Prop latestEvent: ErrorHandlerEvent | undefined
  @Prop refreshTick: number = 0

  private getTraceLines(): string[] {
    if (this.latestEvent === undefined) {
      return []
    }

    if (this.latestEvent.details.length > 0) {
      return this.latestEvent.details.slice(0, 4)
    }

    return [
      `Event type: ${this.latestEvent.type}`,
      `Status: ${this.latestEvent.status}`,
      `Action: ${this.latestEvent.action}`
    ]
  }

  @State private traceLines: TraceLine[] = [];
  private nextTraceId: number = 0;
  private nextTraceOrder: number = 1;

  private addTraceLine(content: string): void {
    const traceLine: TraceLine = {
      id: `trace-${this.nextTraceId++}`,
      order: this.nextTraceOrder++,
      content: content
    };

    this.traceLines = [...this.traceLines, traceLine];
  }

  build() {
    Column() {
      Text(`${this.refreshTick}`)
        .width(0)
        .height(0)
        .opacity(0)

      Text('Callback Trace')
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)

      if (this.latestEvent === undefined) {
        Text('No callback trace yet.')
          .fontSize(10)
          .opacity(0.62)
          .textAlign(TextAlign.Center)
          .margin({ top: 6 })

        Text('Run a test to see handler activity.')
          .fontSize(8)
          .opacity(0.48)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })
      } else {
        ForEach(
          this.traceLines,
          (item: TraceLine): void => {
            Row() {
              Text(`${item.order}.`)
                .fontSize(9)
                .opacity(0.55)
                .width(18)
                .textAlign(TextAlign.End)

              Text(item.content)
                .fontSize(9)
                .opacity(0.72)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ left: 5 })
            }
            .width('100%')
            .alignItems(VerticalAlign.Top)
            .margin({ top: 5 })
          },
          (item: TraceLine): string => item.id
        )

        if (this.latestEvent.details.length > 4) {
          Text('Open Logs for full details.')
            .fontSize(8)
            .opacity(0.48)
            .textAlign(TextAlign.Center)
            .margin({ top: 6 })
        }
      }
    }
    .width('80%')
    .padding(10)
    .borderRadius(18)
    .border({
      width: 1,
      color: '#64748B'
    })
    .alignItems(HorizontalAlign.Center)
  }
}