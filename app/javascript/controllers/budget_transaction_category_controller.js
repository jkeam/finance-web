import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="budget-transaction-category"
export default class extends Controller {
  static targets = ["links", "template"];

  add_association(event) {
    event.preventDefault();
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime());
    this.linksTarget.insertAdjacentHTML('beforeend', content);
  }

  remove_association(event) {
    event.preventDefault();
    let item = event.target.closest(".budget-transaction-category");
    item.querySelector("input[name*='_destroy']").value = 1;
    item.style.display = 'none';
  }
}
