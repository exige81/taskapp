import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["taskName"]

  connect() {
    if (!this.hasTaskNameTarget) return

    const taskName = this.taskNameTarget
    const isRemoveStrikethru = taskName.classList.contains('remove-strikethru')
    const hasAnimation = taskName.classList.contains('strikethru') || isRemoveStrikethru

    if (hasAnimation) {
      this.isErase = isRemoveStrikethru
      this.handleAnimationEnd = this.handleAnimationEnd.bind(this)
      taskName.addEventListener('animationend', this.handleAnimationEnd, { once: true })
    }
  }

  disconnect() {
    if (this.hasTaskNameTarget && this.handleAnimationEnd) {
      this.taskNameTarget.removeEventListener('animationend', this.handleAnimationEnd)
    }
  }

  handleAnimationEnd(event) {
    // Only respond to our strike/erase animations
    if (event.animationName === 'strike' || event.animationName === 'erase') {
      // For erase animation, clear cache to prevent flash of old strikethrough
      if (this.isErase) {
        Turbo.cache.clear()
      }
      // Refresh page to re-sort tasks
      Turbo.visit(window.location.href, { action: "replace" })
    }
  }
}
