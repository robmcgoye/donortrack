import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="admin"
export default class extends Controller {
  static values = { userId: Number }

  async grantAdmin() {
    await this.updateAdminStatus(true);
  }

  async revokeAdmin() {
    await this.updateAdminStatus(false);
  }

  async updateAdminStatus(admin) {
    try {
      const response = await this.sendRequest(admin);
      
      if (!response.ok) {
        throw new Error(`Request failed with status ${response.status}`);
      }

      const data = await response.json();
      await this.updateUI(data);
    } catch (error) {
      console.error("An error occurred:", error);
      this.displayError("Unable to update admin status. Please try again.");
    }
  }

  async sendRequest(admin) {
    const csrfToken = this.getCsrfToken();
    const url = `/users/${this.userIdValue}/update_admin`;
    
    return await fetch(url, {
      method: 'PATCH',
      headers: this.getHeaders(),
      body: JSON.stringify({ admin })
    });
  }

  async updateUI(data) {
    const messagesElement1 = document.getElementById('messages');
    const messagesElement2 = document.getElementById(`admin_button_${data.userid}`);
    const messagesElement3 = document.getElementById(`user_edit_header_${data.userid}`);

    const response = await fetch(`/users/${this.userIdValue}/processed_admin`, {
      method: 'POST',
      headers: this.getHeaders(),
      body: JSON.stringify({ message: data.message, response_type: data.response_type })
    });

    const html = await response.text();
    
    // Update the DOM with the new HTML content
    if (messagesElement1) messagesElement1.innerHTML = html;
    if (messagesElement2) messagesElement2.innerHTML = html;
    if (messagesElement3) messagesElement3.innerHTML = html;
  }

  getCsrfToken() {
    return document.querySelector('meta[name="csrf-token"]').content;
  }

  getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'text/vnd.turbo-stream.html',
      'X-CSRF-Token': this.getCsrfToken()
    };
  }

  displayError(message) {
    // Handle UI error display (e.g., show an error banner)
    console.log(message);
    // Example:
    // const errorContainer = document.querySelector('#error-container');
    // if (errorContainer) {
    //   errorContainer.textContent = message;
    //   errorContainer.classList.remove('hidden');
    // }
  }
}
