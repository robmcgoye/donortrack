
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reconciliation"
export default class extends Controller {
  static targets = [ "balance", "journal" ];
  static values = { reconciliationbalance: { type: Number } };
  #running_balance = 0;
  #money = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  });

  initialize() {
    this.balanceTarget.innerHTML = this.#get_reconciliation_balance(true);
  }

  update_balance(e) {
    const amount = Number(e.srcElement.getAttribute("data-value"));
    if (e.srcElement.checked) {
      this.#running_balance = this.#running_balance + amount;
    } else {
      this.#running_balance = this.#running_balance - amount;
    }
    this.balanceTarget.innerHTML = this.#get_reconciliation_balance(true);
  }

  reconcile(e) {
    if ((this.#running_balance - this.reconciliationbalanceValue) != 0) {
      if (confirm("Not balanced. Do you want to create a journal entry to balance it according to the statement?")) {
        alert("Currently not supported!");
        console.log(`setup journal entry... ${this.#get_reconciliation_balance(false)}`);
        this.journalTarget.value = ((this.#get_reconciliation_balance(false) / 100) * -1);
        e.preventDefault();
      } else {
        e.preventDefault();
      }
    }
  }

  #get_reconciliation_balance(formatted){
    if (formatted){
      return this.#money.format((this.#running_balance - this.reconciliationbalanceValue) / 100);
    } else {
      return this.#running_balance - this.reconciliationbalanceValue;
    }
  }

}
