function hideReceiptEmailDiv() {
  window.receiptEmailDiv.style.display = 'none';
}

function showReceiptEmailDiv() {
  window.receiptEmailDiv.style.display = 'block';
}

function defineElements() {
  window.bankTransferButton = document.getElementById('payment_summary_form_temp_payment_method_bank_transfer');
  window.cardButton = document.getElementById('payment_summary_form_temp_payment_method_card');
  window.receiptEmailDiv = document.getElementById('receipt_email_div');
}

function addListenersToButtons() {
  window.bankTransferButton.addEventListener('change', hideReceiptEmailDiv);
  window.cardButton.addEventListener('change', showReceiptEmailDiv);
}

window.addEventListener('load', function() {
  defineElements();
  addListenersToButtons();

  if(window.cardButton.checked == false) {
    hideReceiptEmailDiv();
  }
});
