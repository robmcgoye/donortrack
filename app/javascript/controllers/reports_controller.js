import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reports"
export default class extends Controller {
  static targets = [ "btn" ]

  connect() {
    if (this.btnTargets.length > 0 ) {
      this.btnTargets[0].classList.add('active');
    }
  }

  submit_report(report_name){
    let report_form = document.getElementById(report_name);
    let report_handle = window.open("", report_name, 'popup=yes,height=600,width=800');
    if (report_handle) {
      report_form.target = report_name;
      report_form.submit();
    } else {
       alert('You must allow popups to print reports.');
    }  
  }

  print_commitment(e) {
    e.preventDefault();
    this.submit_report("commitment_report"); 
  }

  print_contribution(e) {
    e.preventDefault();
    let starting_date = document.forms["contribution_report"]["contribution_report_form[starting_date]"].value;
    let ending_date = document.forms["contribution_report"]["contribution_report_form[ending_date]"].value;
    if (((starting_date.length > 0) & (ending_date.length > 0)) & (starting_date <= ending_date)){
      let funds_element = document.querySelector('#contribution_report_form_funds');
      let donors_element = document.querySelector('#contribution_report_form_donors');
      let types_element = document.querySelector('#contribution_report_form_types');
      if ((funds_element.value.length > 0) & (donors_element.value.length > 0) & (types_element.value.length > 0)) {
        this.submit_report("contribution_report");
      } else {
        alert("Please make sure that all options have a selection (Funds, Donors, Types).");
      }
      // 
    } else {
      alert("Please enter a valid date range.");      
    }
  }

  toggle(e) {
    this.btnTargets.forEach((element) => {
      if (e.srcElement == element) {
        element.classList.add('active');
      } else {
        element.classList.remove('active');
      }
    });    
  }

}
