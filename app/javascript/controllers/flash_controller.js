import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
  connect() {
    const node = this.element;
    // this.animateCSS("rubberBand").then(() => {
    //   this.animateCSS("zoomOut").then(() => {
    //     // node.style.visibility = "hidden";
    //     node.innerHTML="";
    //   });
    // });
    setTimeout(() => {
      this.animateCSS("zoomOut").then(() => {
        // node.style.visibility = "hidden";
        node.innerHTML="";
      });
      // this.animateCSS("rubberBand").then(() => {
      //   this.animateCSS("zoomOut").then(() => {
      //     // node.style.visibility = "hidden";
      //     node.innerHTML="";
      //   });
      // });
    }, 4000);
  }

  animateCSS(animation) {
    // We create a Promise and return it
    return new Promise((resolve, _reject) => {
      const animationName = `animate__${animation}`;
      const node = this.element;
      node.classList.add("animate__animated", animationName);

      // When the animation ends, we clean the classes and resolve the Promise
      function handleAnimationEnd(event) {
        event.stopPropagation();
        node.classList.remove("animate__animated", animationName);
        resolve("Animation ended");
      }

      node.addEventListener("animationend", handleAnimationEnd);
    });
  }

}
