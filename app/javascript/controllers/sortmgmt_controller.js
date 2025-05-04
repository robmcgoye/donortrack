import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sortmgmt"
export default class extends Controller {
  static targets = ["sort_icon", "query"];
  static values = {
    selected: { type: Number, default: 0 },
    query: { type: String, default: "" },
    dir: { type: Number, default: 1 },
    url: String
  };

  sortDirs = [];
  queryText = "";

  initialize() {
    this.sortDirs = this.sort_iconTargets.map((_, index) =>
      index === this.selectedValue ? this.dirValue : 1
    );

    if (this.hasQueryTarget) {
      this.queryTarget.value = this.queryValue;
      this.queryText = this.queryValue;
    }
  }

  updateQuery() {
    this.queryTarget.value = this.queryText;
  }

  filter(event) {
    event.preventDefault();
    this.queryText = this.queryTarget.value;

    // Reset direction for column 0 if needed
    if (this.sortDirs[0] === 2) {
      this.sortDirs[0] = 1;
    }

    // Re-apply sort
    if (this.selectedValue === 0) {
      this.selectedValueChanged();
    } else {
      this.selectedValue = 0;
    }
  }

//   show(event) {
//     event.preventDefault();
//     const target = event.target;
//     const url = `${target.dataset.url}&by=${this.selectedValue}&dir=${this.nextSortDir()}&query=${this.getQuery()}`;
// console.log(url);
//     this.turboGet(url);
//   }

  sort(event) {
    event.preventDefault();
    // const target = event.target;
    const target = event.target.closest("[data-url]");
    const value = Number(target.dataset.value);
    this.urlValue = target.dataset.url;
    this.setSelected(value);
  }

  setSelected(index) {
    if (this.selectedValue !== index) {
      this.selectedValue = index;
      this.resetSortDirsExcept(index);
    } else {
      this.selectedValueChanged();
    }
  }

  selectedValueChanged() {
    const url = this.getQueryUrl();
    // console.log(url);
    this.turboGet(url);
    this.setSortIcons();
  }

  nextSortDir() {
    return this.sortDirs[this.selectedValue] === 1 ? 2 : 1;
  }

  getQuery() {
    if (this.hasQueryTarget) {
      this.queryText = this.queryTarget.value;
      return this.queryText;
    }
    return "";
  }

  getQueryUrl() {
    return `${this.urlValue}&dir=${this.sortDirs[this.selectedValue]}&query=${this.getQuery()}`;
  }

  getFilter() {
    const url = this.getQueryUrl();
    const queryString = url.split("?")[1];
    return queryString || "";
  }

  setSortIcons() {
    this.sort_iconTargets.forEach((icon, index) => {
      if (index === this.selectedValue) {
        if (this.sortDirs[index] === 1) {
          icon.classList.remove("bi-sort-alpha-down-alt");
          icon.classList.add("bi-sort-alpha-down");
          this.sortDirs[index] = 2;
        } else {
          icon.classList.remove("bi-sort-alpha-down");
          icon.classList.add("bi-sort-alpha-down-alt");
          this.sortDirs[index] = 1;
        }
      } else {
        icon.classList.remove("bi-sort-alpha-down", "bi-sort-alpha-down-alt");
      }
    });
  }

  resetSortDirsExcept(activeIndex) {
    this.sortDirs = this.sortDirs.map((_, index) => index === activeIndex ? this.sortDirs[index] : 1);
  }

  turboGet(url) {
    fetch(url, {
      method: "GET",
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      }
    })
      .then(response => response.text())
      .then(html => Turbo.renderStreamMessage(html));
  }
}
