import { Controller } from "@hotwired/stimulus"
//  
// Connects to data-controller="card-radio-button"
export default class extends Controller {
  static targets = ['radio'];
  static values = { foundationId: Number }
  static outlets = [ "organization-select" ]
  connect() {
    this.element.addEventListener('click', this.handleClick);
  }
  
  disconnect() {
    this.element.removeEventListener('click', this.handleClick);
  }
  
  handleClick = (e) => {
    e.preventDefault(); // prevent the click from occurring twice
    if (this.radioTarget.checked) {
      return;
    }
    if (this.hasOrganizationSelectOutlet) {
      this.organizationSelectOutlet.hideCardFooter();
    }
    this.radioTarget.checked = true;
    this.removeSelectedClass();
    this.element.classList.add('selected');
    this.loadPartial();
  }

  removeSelectedClass() {
    const cards = document.querySelectorAll('.card-radiobtn');
    cards.forEach((card) => {
      card.classList.remove('selected');
    });
  }

  loadPartial() {
    const selectedOption = this.radioTarget.value;
    let partialName;

    if (selectedOption === 'new') {
      partialName = 'new_organization';
    } else if (selectedOption === 'existing') {
      partialName = 'existing_organization';
    }

    const partialURL = `foundations/${this.foundationIdValue}/donations/${partialName}`;
    this.#turbo_get(partialURL);
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
