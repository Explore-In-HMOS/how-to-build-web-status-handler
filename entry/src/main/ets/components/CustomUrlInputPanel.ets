@Component
export struct CustomUrlInputPanel {
  @Link customUrlInput: string

  build() {
    Column() {
      Text('Target URL')
        .fontSize(10)
        .opacity(0.68)
        .textAlign(TextAlign.Center)

      TextInput({
        placeholder: 'example.com',
        text: this.customUrlInput
      })
        .width('78%')
        .height(38)
        .fontSize(11)
        .margin({ top: 7 })
        .onChange((value: string): void => {
          this.customUrlInput = value
        })

      Text('Allowed: https, http, weberrorhandler')
        .fontSize(8)
        .opacity(0.55)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 6 })
    }
    .width('80%')
    .padding(11)
    .borderRadius(20)
    .border({
      width: 1,
      color: '#16A34A'
    })
    .alignItems(HorizontalAlign.Center)
  }
}