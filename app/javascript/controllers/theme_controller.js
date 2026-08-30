import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "finance-web-theme"

// Connects to data-controller="theme"
export default class extends Controller {
  static targets = ["icon"]

  connect() {
    this.reflectIcon()
  }

  toggle() {
    const next = this.isDark() ? "light" : "dark"
    document.documentElement.setAttribute("data-theme", next)
    try {
      localStorage.setItem(STORAGE_KEY, next)
    } catch (e) {
      console.error(e)
    }
    this.reflectIcon()
  }

  isDark() {
    return document.documentElement.getAttribute("data-theme") === "dark"
  }

  reflectIcon() {
    if (!this.hasIconTarget) return
    this.iconTarget.textContent = this.isDark() ? "☀️" : "🌙"
  }
}
