import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="whatif"
// Debounces slider/number/radio inputs and auto-submits the form so the server
// (single source of truth for the retirement math) recomputes the turbo frame.
// The form lives outside the turbo frame on purpose (so a frame swap never
// interrupts an in-progress drag), which means nothing about it - which slider
// is disabled, what value it holds - can be updated by the server re-rendering
// the frame. This controller owns all of that client-side instead: each slider
// is a UI-only control (no name attribute) paired with a hidden field that
// actually submits, and both the disabled state and the values are reconciled
// here on every radio change and every frame load.
export default class extends Controller {
  static targets = [
    "form", "computed",
    "age", "ageValue", "ageHidden",
    "spending", "spendingValue", "spendingHidden",
    "salary", "salaryValue", "salaryHidden"
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
    if (this.hasAgeTarget) this.ageTarget.disabled = solveFor === "age";
    if (this.hasSalaryTarget) this.salaryTarget.disabled = solveFor === "salary";
    if (this.hasSpendingTarget) this.spendingTarget.disabled = solveFor === "spending";
  }

  ageChanged() {
    if (this.hasAgeValueTarget && this.hasAgeTarget) {
      this.ageValueTarget.textContent = this.ageTarget.value;
    }
    if (this.hasAgeHiddenTarget && this.hasAgeTarget) {
      this.ageHiddenTarget.value = this.ageTarget.value;
    }
    this.scheduleSubmit();
  }

  spendingChanged() {
    if (this.hasSpendingValueTarget && this.hasSpendingTarget) {
      this.spendingValueTarget.textContent = this.formatCurrency(this.spendingTarget.value);
    }
    if (this.hasSpendingHiddenTarget && this.hasSpendingTarget) {
      this.spendingHiddenTarget.value = this.spendingTarget.value;
    }
    this.scheduleSubmit();
  }

  salaryChanged() {
    if (this.hasSalaryValueTarget && this.hasSalaryTarget) {
      this.salaryValueTarget.textContent = this.formatCurrency(this.salaryTarget.value);
    }
    if (this.hasSalaryHiddenTarget && this.hasSalaryTarget) {
      this.salaryHiddenTarget.value = this.salaryTarget.value;
    }
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
  // just computed: which field is disabled, and every slider/hidden field's value.
  frameLoaded() {
    if (this.hasComputedTarget) {
      const data = this.computedTarget.dataset;

      this.applyDisabled(data.solveFor);

      if (this.hasAgeTarget) {
        this.ageTarget.value = data.age;
        if (this.hasAgeValueTarget) this.ageValueTarget.textContent = data.age;
      }
      if (this.hasAgeHiddenTarget) this.ageHiddenTarget.value = data.age;

      if (this.hasSalaryTarget) {
        this.salaryTarget.value = data.salaryCents;
        if (this.hasSalaryValueTarget) this.salaryValueTarget.textContent = this.formatCurrency(data.salaryCents);
      }
      if (this.hasSalaryHiddenTarget) this.salaryHiddenTarget.value = data.salaryCents;

      if (this.hasSpendingTarget) {
        this.spendingTarget.value = data.spendingCents;
        if (this.hasSpendingValueTarget) this.spendingValueTarget.textContent = this.formatCurrency(data.spendingCents);
      }
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
