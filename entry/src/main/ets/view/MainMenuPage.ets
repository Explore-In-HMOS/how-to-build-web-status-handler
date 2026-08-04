import { ErrorHandlerViewModel } from '../viewmodel/ErrorHandlerViewModel'
import { ErrorHandlerScreen } from '../model/ErrorHandlerUiState'
import { ArcList, ArcListItem } from '@kit.ArkUI'

@Component
export struct MainMenuPage {
  @Link activeScreen: ErrorHandlerScreen
  @ObjectLink viewModel: ErrorHandlerViewModel

  @Builder
  private MenuButton(
    title: string,
    description: string,
    onClickAction: () => void
  ): void {
    Column() {
      Button(title, {
        type: ButtonType.Capsule,
        stateEffect: true
      })
        .width('76%')
        .height(44)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .onClick((): void => {
          onClickAction()
        })

      Text(description)
        .fontSize(9)
        .opacity(0.65)
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('72%')
        .margin({ top: 5 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 6, bottom: 8 })
  }

  build() {
    ArcList() {
      ArcListItem() {
        Column() {
          Text('Web Error Handler')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .maxLines(1)

          Text('Choose how you want to test WebView behavior.')
            .fontSize(10)
            .opacity(0.68)
            .textAlign(TextAlign.Center)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 5 })
        }
        .width('80%')
        .alignItems(HorizontalAlign.Center)
        .padding({ top: 8, bottom: 8 })
      }

      ArcListItem() {
        this.MenuButton(
          'Scenario Test',
          'Use predefined WebView error, auth and security scenarios.',
          (): void => {
            this.viewModel.showScenarioTestScreen()
            this.activeScreen = ErrorHandlerScreen.SCENARIO_TEST
          }
        )
      }

      ArcListItem() {
        this.MenuButton(
          'Custom URL Test',
          'Enter a URL and inspect WebView callbacks.',
          (): void => {
            this.viewModel.showCustomUrlTestScreen()
            this.activeScreen = ErrorHandlerScreen.CUSTOM_URL_TEST
          }
        )
      }
    }
    .width('100%')
    .height('100%')
  }
}