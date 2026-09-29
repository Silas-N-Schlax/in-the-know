import { Controller } from '@hotwired/stimulus'

// The secret note, delivered in an envelope.
// Opening:  closed → flap-open → card-out → card-front (the card slides up, then comes forward to read)
// Closing:  card-front → card-back → card-in → sealed → gone, then the form submits
// Each state is a data attribute the CSS animates; the timings below match its transitions.
const OPEN = [['flap-open', 0], ['card-out', 420], ['card-front', 520]]
const CLOSE = [['card-back', 0], ['card-in', 420], ['sealed', 460], ['gone', 420], ['submit', 520]]

export default class extends Controller {
  static targets = ['form', 'prompt']

  open() {
    if (this.state !== 'closed') return

    this.play(OPEN)
  }

  close(event) {
    if (this.state === 'submitting') return
    event.preventDefault()
    if (this.state !== 'card-front') return this.submit()

    this.play(CLOSE)
  }

  play(steps) {
    if (this.reducedMotion) {
      const [last] = steps[steps.length - 1]
      return last === 'submit' ? this.submit() : this.setState(last)
    }

    let delay = 0
    steps.forEach(([state, wait]) => {
      delay += wait
      setTimeout(() => (state === 'submit' ? this.submit() : this.setState(state)), delay)
    })
  }

  submit() {
    this.setState('submitting')
    this.formTarget.requestSubmit()
  }

  setState(state) {
    this.element.dataset.envelopeState = state
  }

  get state() {
    return this.element.dataset.envelopeState
  }

  get reducedMotion() {
    return window.matchMedia('(prefers-reduced-motion: reduce)').matches
  }
}
