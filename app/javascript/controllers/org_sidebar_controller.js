import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "btn" ]
  static values = { selected: { type: Number, default: -1 } }

  initialize() {
    // this.selectedValue = 0;
    const side_bar = document.getElementById("sidebar-controller");
    side_bar.classList.toggle('active');
  }

  connect() {
    // console.log("Yo... hello!")
  }

  // organization(e) {
  //   this.selectedValue = 1;
  //   e.preventDefault();
  // }

  // contribution(e) {
  //   this.selectedValue = 2;
  //   e.preventDefault();
  // }

  // accounting(e) {
  //   this.selectedValue = 3;
  //   e.preventDefault();
  // }

  // report(e) {
  //   this.selectedValue = 4;
  //   e.preventDefault();
  // }

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


}
