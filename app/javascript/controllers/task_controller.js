import { Controller } from "@hotwired/stimulus"

// Animation duration from CSS (50ms) plus buffer for rendering
const ANIMATION_DURATION = 150

export default class extends Controller {
  static targets = ["taskName"]

  connect() {
    // Check if task name element has an animated class (newly toggled)
    if (this.hasTaskNameTarget) {
      const taskName = this.taskNameTarget
      const hasAnimation = taskName.classList.contains('strikethru') ||
                          taskName.classList.contains('remove-strikethru')

      if (hasAnimation) {
        // Wait for animation to complete, then refresh to re-sort tasks
        this.animationTimeout = setTimeout(() => {
          Turbo.visit(window.location.href, { action: "replace" })
        }, ANIMATION_DURATION)
      }
    }
  }

  disconnect() {
    // Clean up timeout if element is removed before animation completes
    if (this.animationTimeout) {
      clearTimeout(this.animationTimeout)
    }
  }
}
