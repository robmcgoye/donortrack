import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static outlets = [ "sidebar" ]
  static targets = [ "navbartoggler" ]

  initialize() {
    this.view_foundations();
  }

  edit_password() {
    this.set_page("FDN: Change password");
  }

  edit_email() {
    this.set_page("FDN: Change email");
  }

  view_sessions() {
    this.set_page("FDN: Sessions");
  }

  view_accounts() {
    this.set_page("FDN: Accounts");
  }

  view_foundations() {
    this.set_page("Foundations");
  }

  set_page(title) {
    const is_toggler_expanded = this.navbartogglerTarget.getAttribute("aria-expanded");
    document.title = title;
    this.sidebarOutlet.selectedValue = -1;
    if(is_toggler_expanded == "true"){
      this.navbartogglerTarget.click();
    }
  }

  toggle() {
    const side_bar = document.getElementById("sidebar-controller");
    side_bar.classList.toggle('active');
 }
 
}
