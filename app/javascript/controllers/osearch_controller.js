import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="osearch"
export default class extends Controller {
  static values = { create: { type: Boolean, default: false }
                  };
  static outlets = [ "sortmgmt" ]

  connect() {
    if (this.createValue == true) {
      this.sortmgmtOutlet.filter();
    } else {
      this.sortmgmtOutlet.update_query();
    }      
  }

  print_query(e) {
    let url = e.srcElement.getAttribute("data-url");
    window.open(`${url}?${this.sortmgmtOutlet.get_filter()}`, 'organization_report', 'popup=yes,height=600,width=800');
    e.preventDefault();    
  }

}
