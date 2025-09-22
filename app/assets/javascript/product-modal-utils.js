// app/assets/javascripts/product-modal-utils.js
window.ProductModalUtils = {
  showConfirmationModal: function(changes, onConfirm) {
    const modal = document.getElementById('confirmModal');
    const changesList = document.getElementById('changesList');
    const confirmBtn = document.getElementById('confirmSave');
    const cancelBtn = document.getElementById('cancelModal');

    changesList.innerHTML = changes.map(c => `<div class="mb-1">${c}</div>`).join('');
    modal.classList.remove("hidden");

    confirmBtn.onclick = () => {
      modal.classList.add("hidden");
      onConfirm();
    };

    cancelBtn.onclick = () => modal.classList.add("hidden");
    modal.onclick = (e) => {
      if (e.target === modal) modal.classList.add("hidden");
    };
  },

  showSuccessMessage: function() {
    const msg = document.createElement("div");
    msg.className = "fixed top-4 right-4 bg-green-500 text-white px-4 py-2 rounded shadow";
    msg.textContent = "✓ Producto actualizado correctamente";
    document.body.appendChild(msg);
    setTimeout(() => msg.remove(), 3000);
  }
};