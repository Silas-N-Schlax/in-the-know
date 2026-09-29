import { Controller } from '@hotwired/stimulus'

// Shows the panel only while the checked radio in this section has the configured value.
export default class extends Controller {
  static targets = ['panel']
  static values = { show: String }

  connect() {
    this.update()
  }

  update() {
    const checked = this.element.querySelector('input[type="radio"]:checked')
    this.panelTarget.hidden = checked?.value !== this.showValue
  }
}
