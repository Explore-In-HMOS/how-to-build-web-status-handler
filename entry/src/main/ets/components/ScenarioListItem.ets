import { ErrorHandlerViewModel } from '../viewmodel/ErrorHandlerViewModel'
import { ErrorHandlerScenario } from '../model/ErrorHandlerScenario'

@Component
export struct ScenarioListItem {
  @ObjectLink viewModel: ErrorHandlerViewModel

  scenario: ErrorHandlerScenario | undefined = undefined

  build() {
    if (this.scenario !== undefined) {
      Column() {
        Text(
          this.viewModel.uiState.selectedScenario.id === this.scenario.id
            ? `● ${this.scenario.shortTitle}`
            : this.scenario.shortTitle
        )
          .fontSize(13)
          .fontWeight(
            this.viewModel.uiState.selectedScenario.id === this.scenario.id
              ? FontWeight.Bold
              : FontWeight.Regular
          )
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.scenario.category)
          .fontSize(9)
          .opacity(0.6)
          .maxLines(1)
          .margin({ top: 2 })
      }
      .width('76%')
      .padding(8)
      .borderRadius(16)
      .alignItems(HorizontalAlign.Center)
      .onClick((): void => {
        if (this.scenario !== undefined) {
          this.viewModel.selectScenario(this.scenario)
        }
      })
    }
  }
}