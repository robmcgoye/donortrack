import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "sidebar", "icon", "btn" ]; // Declare targets
  static values = { selected: { type: Number, default: -1 } }

  initialize() {
    this.selectedValue = 0;
    this.toggle();
    // const side_bar = document.getElementById("sidebar-controller");
    // side_bar.classList.toggle('active');
  }

  connect() {
    // console.log("connect");
  }

  selectedValueChanged() {
    this.setButtonState();
    if (this.selectedValue == 0) {
      document.title = "FDN: Dashboard";
    } else if (this.selectedValue == 1) {
      document.title = "FDN: Organizations";
    } else if (this.selectedValue == 2) {
      document.title = "FDN: Contributions";
    } else if (this.selectedValue == 3) {
      document.title = "FDN: Accounting";
    } else if (this.selectedValue == 4) {
      document.title = "FDN: Reports";
    } else if (this.selectedValue == 5) {
      document.title = "FDN: Settings";
    }
  }

  setButtonState() {
    this.btnTargets.forEach((element, index) => {
      if (index == this.selectedValue) {
        element.classList.add('active');
      } else {
        element.classList.remove('active');
      }
    });
  }
  
  toggle() {
    this.sidebarTarget.classList.toggle("collapsed"); // Toggle the collapsed class
    document.body.classList.toggle("collapsed-sidebar"); // Update layout class
    this.updateIcon(); // Update the toggle icon
  }

  updateIcon() {
    // Replace the icon's inner HTML with the appropriate icon
    if (this.sidebarTarget.classList.contains("collapsed")) {
      this.iconTarget.innerHTML = `<i class="bi bi-chevron-double-right"></i>`;
    } else {
      this.iconTarget.innerHTML = `<i class="bi bi-chevron-double-left"></i>`;
    }
  }
}
