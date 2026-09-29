import { Controller } from '@hotwired/stimulus'

// Shows the secret only while the button is held down, so it's never left on screen.
export default class extends Controller {
  static targets = ['secret']

  show(event) {
    event.preventDefault()
    this.secretTarget.hidden = false
  }

  hide() {
    this.secretTarget.hidden = true
  }
}
