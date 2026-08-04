import { ErrorHandlerViewModel } from '../viewmodel/ErrorHandlerViewModel'
import { ErrorHandlerPromptAction, ErrorHandlerPromptType } from '../model/ErrorHandlerPrompt'

@Component
export struct PromptPanel {
  @ObjectLink viewModel: ErrorHandlerViewModel

  @State private authUsername: string = ''
  @State private authPassword: string = ''
  @State private privateKeyFilePath: string = ''
  @State private certificateChainFilePath: string = ''

  private resolvePrompt(action: ErrorHandlerPromptAction): void {
    this.viewModel.resolvePrompt(
      action,
      this.authUsername,
      this.authPassword,
      this.privateKeyFilePath,
      this.certificateChainFilePath
    )

    this.authPassword = ''
  }

  @Builder
  private CredentialInputs(): void {
    if (this.viewModel.uiState.pendingPrompt !== undefined &&
      this.viewModel.uiState.pendingPrompt.type === ErrorHandlerPromptType.HTTP_AUTH) {
      TextInput({
        placeholder: 'Username',
        text: this.authUsername
      })
        .width('74%')
        .height(30)
        .fontSize(10)
        .onChange((value: string): void => {
          this.authUsername = value
        })

      TextInput({
        placeholder: 'Password',
        text: this.authPassword
      })
        .width('74%')
        .height(30)
        .fontSize(10)
        .type(InputType.Password)
        .margin({ top: 4 })
        .onChange((value: string): void => {
          this.authPassword = value
        })
    }
  }

  @Builder
  private CertificateInputs(): void {
    if (this.viewModel.uiState.pendingPrompt !== undefined &&
      this.viewModel.uiState.pendingPrompt.type === ErrorHandlerPromptType.CLIENT_AUTH) {
      TextInput({
        placeholder: 'Private key path',
        text: this.privateKeyFilePath
      })
        .width('74%')
        .height(30)
        .fontSize(9)
        .onChange((value: string): void => {
          this.privateKeyFilePath = value
        })

      TextInput({
        placeholder: 'Cert chain path',
        text: this.certificateChainFilePath
      })
        .width('74%')
        .height(30)
        .fontSize(9)
        .margin({ top: 4 })
        .onChange((value: string): void => {
          this.certificateChainFilePath = value
        })
    }
  }

  @Builder
  private ActionButtons(): void {
    if (this.viewModel.uiState.pendingPrompt !== undefined) {
      Column() {
        Button(this.viewModel.uiState.pendingPrompt.primaryLabel, {
          type: ButtonType.Capsule,
          stateEffect: true
        })
          .fontSize(10)
          .height(32)
          .width(120)
          .onClick((): void => {
            this.resolvePrompt(
              this.viewModel.uiState.pendingPrompt!.primaryAction
            )
          })

        Row() {
          Button(this.viewModel.uiState.pendingPrompt.secondaryLabel, {
            type: ButtonType.Capsule,
            stateEffect: true
          })
            .fontSize(10)
            .height(30)
            .width(68)
            .onClick((): void => {
              this.resolvePrompt(
                this.viewModel.uiState.pendingPrompt!.secondaryAction
              )
            })

          if (this.viewModel.uiState.pendingPrompt.tertiaryAction !== undefined &&
            this.viewModel.uiState.pendingPrompt.tertiaryLabel !== undefined) {
            Button(this.viewModel.uiState.pendingPrompt.tertiaryLabel, {
              type: ButtonType.Capsule,
              stateEffect: true
            })
              .fontSize(10)
              .height(30)
              .width(68)
              .margin({ left: 8 })
              .onClick((): void => {
                this.resolvePrompt(
                  this.viewModel.uiState.pendingPrompt!.tertiaryAction!
                )
              })
          }
        }
        .justifyContent(FlexAlign.Center)
        .margin({ top: 8 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
  }

  build() {
    if (this.viewModel.uiState.pendingPrompt !== undefined) {
      Column() {
        Text(`${this.viewModel.uiRefreshKey}`)
          .width(0)
          .height(0)
          .opacity(0)

        Text(this.viewModel.uiState.pendingPrompt.title)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.viewModel.uiState.pendingPrompt.message)
          .fontSize(10)
          .opacity(0.72)
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4, bottom: 6 })

        this.CredentialInputs()

        this.CertificateInputs()

        this.ActionButtons()
      }
      .width('80%')
      .padding(8)
      .borderRadius(18)
      .alignItems(HorizontalAlign.Center)
    }
  }
}