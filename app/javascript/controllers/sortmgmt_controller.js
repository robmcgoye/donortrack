import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sortmgmt"
export default class extends Controller {
  static targets = [ "sort_icon", "query" ];
  static values = { selected: { type: Number, default: 0 }, 
                    query: { type: String, default: ""},
                    dir: { type: Number, default: 1},
                    url: String 
                  };
  #sort_dirs = [];
  #query = "";

  initialize() {
   for (let index = 0; index < this.sort_iconTargets.length; index++) {
      this.#sort_dirs.push(1);
    };
    for (let index = 0; index < this.#sort_dirs.length; index++) {
      if (index == this.selectedValue) {
        this.#sort_dirs[index] = this.dirValue;
      }
    };
    if (this.hasQueryTarget) {
      this.queryTarget.value = this.queryValue;
      this.#query = this.queryTarget.value;  
    }
  }

  update_query(){
    this.queryTarget.value = this.#query;
  }

  filter(e) {
    this.#query = this.queryTarget.value;
    if (this.#sort_dirs[0] == 2) {
      this.#sort_dirs[0] = 1;
    }
    if (this.selectedValue == 0) {
      this.selectedValueChanged();
    } else {
      this.selectedValue = 0;
    }
    e.preventDefault();
  }

  #get_current_sort_dir(){
    if (this.#sort_dirs[this.selectedValue] == 1) {
      return 2;
    } else {
      return 1;
    }
  }

  show(e){
    const url = `${e.srcElement.getAttribute("data-url")}&by=${this.selectedValue}&dir=${this.#get_current_sort_dir()}&query=${this.#get_query()}`;
    this.#turbo_get(url);
    e.preventDefault();
  }

  sort(e) {
    this.urlValue = e.srcElement.getAttribute("data-url");
    this.#set_selected(e.srcElement.getAttribute("data-value"));
    e.preventDefault();
  }

  #set_selected(value) {
    if (this.selectedValue != value) {
      this.selectedValue = value;
      this.#reset_sort_dir(value);
    } else {
      this.selectedValueChanged();
    }
  }
  
  #get_query() {
    if (this.hasQueryTarget){
      this.#query = this.queryTarget.value;
      return this.queryTarget.value;
    } else {
      return "";
    }
  }

  get_query_url() {
    return `${this.urlValue}&dir=${this.#sort_dirs[this.selectedValue]}&query=${this.#get_query()}`;
  }

  get_filter() {
    let search = "";
    let url = this.get_query_url();
    let search_starting_position = url.indexOf("?");
    if ((search_starting_position > 0) && ((search_starting_position + 1) < url.length)) {
      search = url.slice((search_starting_position + 1), url.length);
    }
    return search;
  }

  selectedValueChanged() {
    const url = this.get_query_url();
    // const url = `${this.urlValue}&dir=${this.#sort_dirs[this.selectedValue]}`;
    this.#turbo_get(url);
    this.#set_sort_icon();
  }

  #set_sort_icon() {
    this.sort_iconTargets.forEach((element, index) => {
      if (index == this.selectedValue) {
        if (this.#sort_dirs[index] == 1) {
          element.classList.remove('bi-sort-alpha-down-alt'); 
          element.classList.add('bi-sort-alpha-down');
          this.#sort_dirs[index] = 2;
        } else {
          element.classList.remove('bi-sort-alpha-down');
          element.classList.add('bi-sort-alpha-down-alt'); 
          this.#sort_dirs[index] = 1;
        }
      } else {
        element.classList.remove('bi-sort-alpha-down');
        element.classList.remove('bi-sort-alpha-down-alt');  
      }
    });
  }  

  #reset_sort_dir(current_index) {
    for (let index = 0; index < this.#sort_dirs.length; index++) {
      if (index != current_index) {
        this.#sort_dirs[index] = 1;
      }
    }
  }

  #turbo_get(request){
    fetch(request, {
      method: "GET",
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      }
    })
      .then(r => r.text())
      .then(html => Turbo.renderStreamMessage(html))
  }

}
