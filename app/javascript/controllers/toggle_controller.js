import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle"
export default class extends Controller {
  // static targets = [ "sort_icon", "query" ];
  // static values = { selected: { type: Number, default: 0 }, 
  //                   query: { type: String, default: ""},
  //                   dir: { type: Number, default: 1},
  //                   url: String 
  //                 };

  connect() {
  }
  
  update(e) {
    const element = e.srcElement;
    // console.log(element);
    if (element.classList.contains("bi-chevron-left")) {
      element.classList.remove('bi-chevron-left');
      element.classList.add('bi-chevron-down');
    } else {
      element.classList.remove('bi-chevron-down');
      element.classList.add('bi-chevron-left');
    }
 
  }

}
