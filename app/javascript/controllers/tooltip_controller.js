import { Controller } from "@hotwired/stimulus";
import bootstrap from "bootstrap";

// Connects to data-controller="tooltip"
export default class extends Controller {
  static targets = ["tooltip"];

  connect() {
    this.initializeTooltips();
  }

  initializeTooltips() {
    this.tooltipElements = this.tooltipTargets.map(
      (element) => new bootstrap.Tooltip(element)
    );
  }
}
