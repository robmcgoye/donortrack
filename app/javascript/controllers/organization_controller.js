import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="organization"
export default class extends Controller {
  static values = {
    organizationId: Number,
    organizationName: String
  }
  static outlets = [ "organization-select" ]

  setOrganization(e) {
    // e.preventDefault();
    if (this.hasOrganizationSelectOutlet) {
      this.organizationSelectOutlet.showCardFooter();
    }
    const organizationId = this.hasOrganizationIdValue ? this.organizationIdValue : null;
    const organizationName = this.hasOrganizationNameValue ? this.organizationNameValue : "Unknown Organization";

    if (organizationId !== null) {
      document.getElementById('selected_organization_id').value = organizationId;
    } else {
      console.error("Organization ID is not set.");
    }

    document.getElementById('organization_placeholder').innerText = organizationName;
  }
}
