import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="whatif"
// Debounces slider/number/radio inputs and auto-submits the form so the server
// (single source of truth for the retirement math) recomputes the turbo frame.
// The form lives outside the turbo frame on purpose (so a frame swap never
// interrupts an in-progress drag), which means nothing about it - which slider
// is disabled, what value it holds - can be updated by the server re-rendering
// the frame. This controller owns all of that client-side instead: each field
// is a slider + a number input (both UI-only, no name attribute) paired with a
// hidden field that actually submits, and all three are reconciled here on
// every edit, every radio change, and every frame load.
export default class extends Controller {
  static targets = [
    "form", "computed",
    "age", "ageValue", "ageNumber", "ageHidden",
    "spending", "spendingValue", "spendingNumber", "spendingHidden",
    "salary", "salaryValue", "salaryNumber", "salaryHidden"
  ];
  static values = { delay: { type: Number, default: 400 } };

  connect() {
    this.timeout = null;
  }

  disconnect() {
    clearTimeout(this.timeout);
  }

  // Fires immediately on radio change, ahead of the debounced round-trip, so the
  // sliders don't stay stuck in whatever disabled state the last full page load
  // happened to render.
  solveForChanged(event) {
    this.applyDisabled(event.target.value);
    this.scheduleSubmit();
  }

  applyDisabled(solveFor) {
    const ageDisabled = solveFor === "age";
    const salaryDisabled = solveFor === "salary";
    const spendingDisabled = solveFor === "spending";

    if (this.hasAgeTarget) this.ageTarget.disabled = ageDisabled;
    if (this.hasAgeNumberTarget) this.ageNumberTarget.disabled = ageDisabled;
    if (this.hasSalaryTarget) this.salaryTarget.disabled = salaryDisabled;
    if (this.hasSalaryNumberTarget) this.salaryNumberTarget.disabled = salaryDisabled;
    if (this.hasSpendingTarget) this.spendingTarget.disabled = spendingDisabled;
    if (this.hasSpendingNumberTarget) this.spendingNumberTarget.disabled = spendingDisabled;
  }

  // Age is a plain integer, shared as-is between the slider, the number input, and the hidden field.

  ageChanged() {
    this.setAge(this.ageTarget.value);
  }

  ageNumberChanged() {
    this.setAge(this.ageNumberTarget.value);
  }

  setAge(value) {
    if (this.hasAgeTarget) this.ageTarget.value = value;
    if (this.hasAgeNumberTarget) this.ageNumberTarget.value = value;
    if (this.hasAgeValueTarget) this.ageValueTarget.textContent = value;
    if (this.hasAgeHiddenTarget) this.ageHiddenTarget.value = value;
    this.scheduleSubmit();
  }

  // Salary/spending sliders and hidden fields work in cents; their number inputs show whole
  // dollars (matching the formatted currency readout), so every edit needs a unit conversion.

  spendingChanged() {
    this.setSpendingCents(this.spendingTarget.value);
  }

  spendingNumberChanged() {
    this.setSpendingCents(Math.round(Number(this.spendingNumberTarget.value) * 100));
  }

  setSpendingCents(cents) {
    if (this.hasSpendingTarget) this.spendingTarget.value = cents;
    if (this.hasSpendingNumberTarget) this.spendingNumberTarget.value = (Number(cents) / 100).toFixed(2);
    if (this.hasSpendingValueTarget) this.spendingValueTarget.textContent = this.formatCurrency(cents);
    if (this.hasSpendingHiddenTarget) this.spendingHiddenTarget.value = cents;
    this.scheduleSubmit();
  }

  salaryChanged() {
    this.setSalaryCents(this.salaryTarget.value);
  }

  salaryNumberChanged() {
    this.setSalaryCents(Math.round(Number(this.salaryNumberTarget.value) * 100));
  }

  setSalaryCents(cents) {
    if (this.hasSalaryTarget) this.salaryTarget.value = cents;
    if (this.hasSalaryNumberTarget) this.salaryNumberTarget.value = (Number(cents) / 100).toFixed(2);
    if (this.hasSalaryValueTarget) this.salaryValueTarget.textContent = this.formatCurrency(cents);
    if (this.hasSalaryHiddenTarget) this.salaryHiddenTarget.value = cents;
    this.scheduleSubmit();
  }

  scheduleSubmit() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.formTarget.requestSubmit();
    }, this.delayValue);
  }

  // Fires on the turbo-frame element once its new content has been loaded.
  // Reconciles the (persistent, never-reloaded) form against what the server
  // just computed: which field is disabled, and every slider/number/hidden value.
  frameLoaded() {
    if (this.hasComputedTarget) {
      const data = this.computedTarget.dataset;

      this.applyDisabled(data.solveFor);

      if (this.hasAgeTarget) this.ageTarget.value = data.age;
      if (this.hasAgeNumberTarget) this.ageNumberTarget.value = data.age;
      if (this.hasAgeValueTarget) this.ageValueTarget.textContent = data.age;
      if (this.hasAgeHiddenTarget) this.ageHiddenTarget.value = data.age;

      if (this.hasSalaryTarget) this.salaryTarget.value = data.salaryCents;
      if (this.hasSalaryNumberTarget) this.salaryNumberTarget.value = (Number(data.salaryCents) / 100).toFixed(2);
      if (this.hasSalaryValueTarget) this.salaryValueTarget.textContent = this.formatCurrency(data.salaryCents);
      if (this.hasSalaryHiddenTarget) this.salaryHiddenTarget.value = data.salaryCents;

      if (this.hasSpendingTarget) this.spendingTarget.value = data.spendingCents;
      if (this.hasSpendingNumberTarget) this.spendingNumberTarget.value = (Number(data.spendingCents) / 100).toFixed(2);
      if (this.hasSpendingValueTarget) this.spendingValueTarget.textContent = this.formatCurrency(data.spendingCents);
      if (this.hasSpendingHiddenTarget) this.spendingHiddenTarget.value = data.spendingCents;

      this.updateChart(data.chartData);
    }
  }

  // The chart's container div is rendered fresh (as part of the frame's content) on every
  // what-if update, so the canvas Chartkick drew into on the previous load is discarded along
  // with it - calling updateData() on the old Chartkick.charts[id] instance would silently
  // redraw a detached, invisible canvas while the new empty container sits there forever
  // showing "Loading...". Constructing a fresh chart against whatever container currently
  // has this id (exactly what Chartkick's own generated script would do) avoids that.
  updateChart(chartDataJson) {
    if (!chartDataJson || !window.Chartkick) return;

    new window.Chartkick.LineChart("retirement-projection-chart", JSON.parse(chartDataJson), {});
  }

  formatCurrency(cents) {
    return (Number(cents) / 100).toLocaleString(undefined, {
      style: "currency",
      currency: "USD",
      maximumFractionDigits: 0
    });
  }
}
