import { Controller } from '@hotwired/stimulus'

// Keeps the imposter range honest while the host fiddles with settings:
// only counts the player cap allows are shown (player cap slider ÷ 3, up to the limit),
// so the pill rows shrink and grow with the slider, and min never passes max.
export default class extends Controller {
  static targets = ['cap', 'min', 'max']
  static values = { perImposter: Number, limit: Number }

  connect() {
    this.refresh()
  }

  refresh(event) {
    const allowed = Math.max(1, Math.min(Math.floor(Number(this.capTarget.value) / this.perImposterValue), this.limitValue))

    this.limitOptions(this.minTargets, allowed)
    this.limitOptions(this.maxTargets, allowed)
    this.keepOrdered(event?.target)
    this.markRange()
  }

  limitOptions(inputs, allowed) {
    inputs.forEach((input) => {
      const unavailable = Number(input.value) > allowed

      input.disabled = unavailable
      input.hidden = unavailable
      this.labelFor(input).hidden = unavailable
      if (input.checked && unavailable) this.check(inputs, allowed)
    })
  }

  labelFor(input) {
    return input.closest('.segmented-control').querySelector(`label[for="${input.id}"]`)
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
      this.labelFor(input).classList.toggle('segmented-control__label--in-range', value >= min && value <= max)
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
