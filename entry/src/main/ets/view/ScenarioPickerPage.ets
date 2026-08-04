import {ArcButton,ArcButtonOptions,ArcButtonPosition, ArcButtonStyleMode, ArcList, ArcListItem } from '@kit.ArkUI'
import { ErrorHandlerViewModel } from '../viewmodel/ErrorHandlerViewModel'
import { ErrorHandlerScreen } from '../model/ErrorHandlerUiState'
import { ERROR_HANDLER_SCENARIOS, ErrorHandlerScenario } from '../model/ErrorHandlerScenario'

@Component
export struct ScenarioPickerPage {
  @ObjectLink viewModel: ErrorHandlerViewModel
  @Link activeScreen: ErrorHandlerScreen

  private goBack(): void {
    this.viewModel.showScenarioTestScreen()
    this.activeScreen = ErrorHandlerScreen.SCENARIO_TEST
  }

  private selectScenario(scenario: ErrorHandlerScenario): void {
    this.viewModel.selectScenario(scenario)
    this.viewModel.showScenarioTestScreen()
    this.activeScreen = ErrorHandlerScreen.SCENARIO_TEST
  }

  private createTopArcOptions(): ArcButtonOptions {
    return new ArcButtonOptions({
      label: 'Back',
      position: ArcButtonPosition.TOP_EDGE,
      styleMode: ArcButtonStyleMode.NORMAL_LIGHT,
      onClick: (): void => {
        this.goBack()
      }
    })
  }

  private createBottomArcOptions(): ArcButtonOptions {
    return new ArcButtonOptions({
      label: 'Back',
      position: ArcButtonPosition.BOTTOM_EDGE,
      styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
      onClick: (): void => {
        this.goBack()
      }
    })
  }

  @Builder
  private HeaderSection(): void {
    Column() {
      Text('Choose Scenario')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .maxLines(1)

      Text(`Current: ${this.viewModel.uiState.selectedScenario.shortTitle}`)
        .fontSize(10)
        .opacity(0.6)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 4 })
    }
    .width('80%')
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 8, bottom: 8 })
  }

  @Builder
  private PickerItem(scenario: ErrorHandlerScenario): void {
    Column() {
      Text(
        this.viewModel.uiState.selectedScenario.id === scenario.id
          ? `● ${scenario.shortTitle}`
          : scenario.shortTitle
      )
        .fontSize(14)
        .fontWeight(
          this.viewModel.uiState.selectedScenario.id === scenario.id
            ? FontWeight.Bold
            : FontWeight.Regular
        )
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(scenario.category)
        .fontSize(9)
        .opacity(0.58)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .margin({ top: 3 })
    }
    .width('78%')
    .padding(10)
    .borderRadius(18)
    .alignItems(HorizontalAlign.Center)
    .onClick((): void => {
      this.selectScenario(scenario)
    })
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
          this.HeaderSection()
        }

        ForEach(
          ERROR_HANDLER_SCENARIOS,
          (scenario: ErrorHandlerScenario): void => {
            ArcListItem() {
              this.PickerItem(scenario)
            }
          },
          (scenario: ErrorHandlerScenario): string => scenario.id
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