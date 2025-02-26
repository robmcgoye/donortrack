import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="organization-select"
export default class extends Controller {
  static targets = ["cardFooter"];
  connect() {
    this.hideCardFooter();
  }

  hideCardFooter() {
    this.cardFooterTarget.style.display = "none";
  }

  showCardFooter() {
    this.cardFooterTarget.style.display = "block";
  }

  filter(event) {
    this.hideCardFooter();
  }
}
