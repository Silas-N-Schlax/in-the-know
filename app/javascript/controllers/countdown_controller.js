import { Controller } from '@hotwired/stimulus'

// Counts down to endsAt. With submit enabled (the host screen), it submits its form at zero,
// which opens voting. The server ignores the submit if voting is already open.
export default class extends Controller {
  static targets = ['clock']
  static values = { endsAt: String, submit: Boolean }

  connect() {
    this.submitted = false
    this.tick()
    this.timer = setInterval(() => this.tick(), 250)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  // A live page refresh can connect this controller before its end time is filled in; tick again once it is.
  endsAtValueChanged() {
    this.tick()
  }

  tick() {
    const endsAt = Date.parse(this.endsAtValue)
    if (Number.isNaN(endsAt) || !this.hasClockTarget) return

    const remaining = Math.max(0, Math.ceil((endsAt - Date.now()) / 1000))
    const minutes = Math.floor(remaining / 60)
    const seconds = String(remaining % 60).padStart(2, '0')

    this.clockTarget.textContent = `${minutes}:${seconds}`
    this.element.classList.toggle('timer--urgent', remaining <= 10)

    if (remaining === 0) this.finish()
  }

  finish() {
    clearInterval(this.timer)
    if (!this.submitValue || this.submitted || this.element.tagName !== 'FORM') return

    this.submitted = true
    this.element.requestSubmit()
  }
}
