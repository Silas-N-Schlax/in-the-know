import { Controller } from '@hotwired/stimulus'

// Copies the source field's value to the clipboard and briefly confirms it on the button.
export default class extends Controller {
  static targets = ['source', 'button']

  async copy() {
    const text = this.sourceTarget.value || this.sourceTarget.textContent.trim()

    try {
      await navigator.clipboard.writeText(text)
    } catch (_error) {
      this.sourceTarget.select?.()
      document.execCommand('copy')
    }

    this.confirm()
  }

  confirm() {
    if (!this.hasButtonTarget) return

    const original = this.buttonTarget.textContent
    this.buttonTarget.textContent = 'Copied'
    setTimeout(() => { this.buttonTarget.textContent = original }, 1500)
  }
}
