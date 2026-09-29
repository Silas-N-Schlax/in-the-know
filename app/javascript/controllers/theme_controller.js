import { Controller } from '@hotwired/stimulus'

// Flips between light and dark themes and remembers the choice on this device.
export default class extends Controller {
  toggle() {
    const root = document.documentElement
    const next = this.currentMode(root) === 'dark' ? 'light' : 'dark'

    root.dataset.themeMode = next
    try { localStorage.setItem('theme-mode', next) } catch (_error) { /* storage may be blocked */ }
  }

  currentMode(root) {
    if (root.dataset.themeMode) return root.dataset.themeMode

    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
  }
}
