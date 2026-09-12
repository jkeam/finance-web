import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="date-filter"
export default class extends Controller {
  static targets = ["toggleButton", "content", "startDate", "endDate"];

  toggle(event) {
    const isOpen = this.contentTarget.classList.toggle("is-open");
    event.currentTarget.setAttribute("aria-expanded", isOpen ? "true" : "false");
  }

  clear() {
    this.startDateTarget.value = "";
    this.endDateTarget.value = "";
  }
}
