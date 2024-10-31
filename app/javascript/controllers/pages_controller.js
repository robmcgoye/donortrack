import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pages"
export default class extends Controller {
  static values = {
    sbnum: Number
  }
  static outlets = [ "sidebar" ]

  connect() {
    this.sidebarOutlet.selectedValue = this.sbnumValue;
    this.sidebarOutlet.selectedValueChanged();
  }
}
