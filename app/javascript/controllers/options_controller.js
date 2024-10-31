import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="options"
export default class extends Controller {
  static values = {
    checked: String
  }
  frm = {};

  initialize() {
    console.log("hello");
    const radiobtn = document.getElementById(this.checkedValue);
    radiobtn.checked = true;
    this.frm = document.getElementById("set_contribution_type");
    this.frm.value = radiobtn.value;
    console.log(this.frm.value);
  }

  radio_clicked(e) {
    // const frm = document.getElementById("set_contribution_type");
    const rb_value = e.srcElement.getAttribute("value");
    this.frm.value = rb_value;
    console.log(this.frm.value);
  }
}
