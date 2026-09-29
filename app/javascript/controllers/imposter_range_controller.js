import { Controller } from '@hotwired/stimulus'

// Keeps the imposter range honest while the host fiddles with settings:
// options above (player cap ÷ 3, up to the limit) are disabled, and min never passes max.
export default class extends Controller {
  static targets = ['cap', 'min', 'max']
  static values = { perImposter: Number, limit: Number }

  connect() {
    this.refresh()
  }

  refresh(event) {
    const allowed = Math.max(1, Math.min(Math.floor(this.selected(this.capTargets) / this.perImposterValue), this.limitValue))

    this.limitOptions(this.minTargets, allowed)
    this.limitOptions(this.maxTargets, allowed)
    this.keepOrdered(event?.target)
    this.markRange()
  }

  limitOptions(inputs, allowed) {
    inputs.forEach((input) => {
      input.disabled = Number(input.value) > allowed
      if (input.checked && input.disabled) this.check(inputs, allowed)
    })
  }

  keepOrdered(changed) {
    const min = this.selected(this.minTargets)
    const max = this.selected(this.maxTargets)
    if (min <= max) return

    if (this.minTargets.includes(changed)) this.check(this.maxTargets, min)
    else this.check(this.minTargets, max)
  }

  // Highlights every count between min and max so the pair reads as one range.
  markRange() {
    const min = this.selected(this.minTargets)
    const max = this.selected(this.maxTargets)

    this.maxTargets.forEach((input) => {
      const value = Number(input.value)
      input.closest('.segmented-control')
        ?.querySelector(`label[for="${input.id}"]`)
        ?.classList.toggle('segmented-control__label--in-range', value >= min && value <= max)
    })
  }

  selected(inputs) {
    return Number(inputs.find((input) => input.checked)?.value || 0)
  }

  check(inputs, value) {
    const input = inputs.find((candidate) => Number(candidate.value) === value)
    if (input) input.checked = true
  }
}
