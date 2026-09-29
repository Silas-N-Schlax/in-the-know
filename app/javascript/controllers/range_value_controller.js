import { Controller } from '@hotwired/stimulus'

// Shows a range slider's value as you drag, and fills the track up to the thumb.
export default class extends Controller {
  static targets = ['input', 'output']

  connect() {
    this.update()
  }

  update() {
    const { min, max, value } = this.inputTarget
    const filled = ((value - min) / (max - min)) * 100

    this.outputTarget.textContent = value
    this.inputTarget.style.setProperty('--range-fill', `${filled}%`)
  }
}
