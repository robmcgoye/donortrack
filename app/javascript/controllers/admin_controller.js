import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="admin"
export default class extends Controller {
  static values = { userId: Number }

  grantAdmin() {
    this.sendRequest(true)
  }

  revokeAdmin() {
    this.sendRequest(false)
  }

  async sendRequest(admin) {
    const getCsrfToken = () => document.querySelector('meta[name="csrf-token"]').content;

    try {
      const response = await fetch(`/users/${this.userIdValue}/update_admin`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': getCsrfToken(),
          'Accept': 'text/vnd.turbo-stream.html',
        },
        body: JSON.stringify({ admin })
      });
      if (!response.ok) {
        throw new Error(`Request failed with status ${response.status}`);
      }
  
      const data = await response.json();
      fetch(`/users/${this.userIdValue}/processed_admin`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'text/vnd.turbo-stream.html',
          'X-CSRF-Token': getCsrfToken()
        },
        body: JSON.stringify({ message: data.message, response_type: data.response_type })
      })
      .then(response => response.text())
      .then(html => {
        const messagesElement1 = document.getElementById('messages');
        messagesElement1.innerHTML = html;
        const messagesElement2 = document.getElementById(`admin_button_${data.userid}`);
        messagesElement2.innerHTML = html;
        const messagesElement3 = document.getElementById(`user_edit_header_${data.userid}`);
        messagesElement3.innerHTML = html;
      });
  
    } catch (error) {
      console.error("An error occurred:", error);
      
      // Optional: Provide user feedback in the UI
      this.displayError("Unable to update admin status. Please try again.");
    }
  }
  displayError(message) {
    console.log(message);
    // Display an error message to the user
    // const errorContainer = document.querySelector('#error-container');
    // if (errorContainer) {
    //   errorContainer.textContent = message;
    //   errorContainer.classList.remove('hidden'); // Make it visible, if hidden
    // }
  }
}
