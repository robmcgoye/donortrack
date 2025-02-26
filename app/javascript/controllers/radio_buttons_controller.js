import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['button', 'selectedOption'];

  connect() {
    this.buttonTargets.forEach((button) => {
      button.addEventListener('click', this.handleClick.bind(this));
    });
    this.setDefaultClick();
  }

  handleClick(event) {
    const button = event.target;
    this.buttonTargets.forEach((otherButton) => {
      otherButton.classList.remove('active');
    });
    button.classList.add('active');
    this.selectedOptionTarget.value = button.dataset.value;
    event.preventDefault();
  }

  setDefaultClick() {
    this.buttonTargets[0].click();
  }
}
