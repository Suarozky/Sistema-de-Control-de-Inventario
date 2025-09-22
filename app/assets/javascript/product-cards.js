// app/assets/javascripts/product-cards.js
// o app/javascript/product-cards.js (si usas Webpack/Vite)

class ProductCard {
  constructor(cardElement) {
    this.card = cardElement;
    this.originalValues = {};
    this.initializeElements();
    this.bindEvents();
  }

  initializeElements() {
    this.editBtn = this.card.querySelector('.edit-btn');
    this.saveBtn = this.card.querySelector('.save-btn');
    this.historyBtn = this.card.querySelector('.history-btn');
  }

  bindEvents() {
    this.editBtn?.addEventListener('click', () => this.enterEditMode());
    this.saveBtn?.addEventListener('click', (e) => this.handleSave(e));
  }

  enterEditMode() {
    console.log('Entrando en modo edición');
    
    // Guardar valores originales
    const displayFields = this.card.querySelectorAll('.display-field');
    const selects = this.card.querySelectorAll('select.edit-field');
    const inputDate = this.card.querySelector('input.edit-field');
    
    this.originalValues = {
      model: displayFields[0]?.textContent.trim() || '',
      brand: displayFields[1]?.textContent.trim() || '',
      owner: displayFields[2]?.textContent.trim() || '',
      entryDate: displayFields[3]?.textContent.trim() || '',
      modelValue: selects[0]?.value || '',
      brandValue: selects[1]?.value || '',
      ownerValue: selects[2]?.value || '',
      dateValue: inputDate?.value || ''
    };

    // Cambiar interfaz
    this.card.querySelectorAll('.display-field').forEach(el => el.style.display = 'none');
    this.card.querySelectorAll('.edit-field').forEach(el => el.style.display = 'inline');
    this.editBtn.style.display = 'none';
    this.historyBtn.style.display = 'none';
    this.saveBtn.style.display = 'inline';
  }

  async handleSave(e) {
    e.preventDefault();
    console.log('Guardando cambios');
    
    const productId = this.card.dataset.productId;
    const selects = this.card.querySelectorAll('select.edit-field');
    const inputDate = this.card.querySelector('input.edit-field');

    const formData = {
      model: selects[0]?.value || '',
      brand: selects[1]?.value || '',
      ownerId: selects[2]?.value || '',
      entryDate: inputDate?.value || ''
    };

    const ownerName = selects[2]?.options[selects[2].selectedIndex]?.textContent.trim() || '';

    // Detectar cambios
    const changes = this.detectChanges(formData, ownerName);

    if (changes.length === 0) {
      console.log('No hay cambios');
      this.exitEditMode();
      return;
    }

    // Mostrar modal de confirmación
    if (window.ProductModalUtils?.showConfirmationModal) {
      window.ProductModalUtils.showConfirmationModal(changes, () => {
        this.saveProduct(productId, formData);
      });
    } else {
      await this.saveProduct(productId, formData);
    }
  }

  detectChanges(formData, ownerName) {
    const changes = [];
    
    if (formData.model !== this.originalValues.modelValue) {
      changes.push(`<strong>Modelo:</strong> ${this.originalValues.model} → ${formData.model}`);
    }
    if (formData.brand !== this.originalValues.brandValue) {
      changes.push(`<strong>Marca:</strong> ${this.originalValues.brand} → ${formData.brand}`);
    }
    if (formData.ownerId !== this.originalValues.ownerValue) {
      changes.push(`<strong>Propietario:</strong> ${this.originalValues.owner} → ${ownerName}`);
    }
    if (formData.entryDate !== this.originalValues.dateValue) {
      const formattedDate = this.formatDate(formData.entryDate);
      changes.push(`<strong>Fecha:</strong> ${this.originalValues.entryDate} → ${formattedDate}`);
    }

    return changes;
  }

  async saveProduct(productId, formData) {
    try {
      const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
      
      const response = await fetch(`/products/${productId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': token
        },
        body: JSON.stringify({ 
          product: { 
            model: formData.model, 
            brand: formData.brand, 
            ownerid: formData.ownerId,
            entry_date: formData.entryDate || null
          } 
        })
      });

      if (response.ok) {
        const data = await response.json();
        this.updateDisplay(data);
        this.exitEditMode();
        
        if (window.ProductModalUtils?.showSuccessMessage) {
          window.ProductModalUtils.showSuccessMessage();
        }
      } else {
        console.error('Error en la respuesta:', response.status);
        alert("Error al actualizar el producto");
      }
    } catch (error) {
      console.error('Error:', error);
      alert("Error al actualizar el producto: " + error.message);
    }
  }

  updateDisplay(data) {
    const displayFields = this.card.querySelectorAll('.display-field');
    if (displayFields[0]) displayFields[0].textContent = data.model;
    if (displayFields[1]) displayFields[1].textContent = data.brand;
    if (displayFields[2]) displayFields[2].textContent = data.owner_name;
    if (displayFields[3]) displayFields[3].textContent = data.entry_date;
  }

  exitEditMode() {
    this.card.querySelectorAll('.display-field').forEach(el => el.style.display = 'inline');
    this.card.querySelectorAll('.edit-field').forEach(el => el.style.display = 'none');
    this.editBtn.style.display = 'inline';
    this.historyBtn.style.display = 'inline';
    this.saveBtn.style.display = 'none';
  }

  formatDate(dateStr) {
    if (!dateStr) return '';
    const date = new Date(dateStr);
    return date.toLocaleDateString('es-ES', { 
      day: '2-digit', 
      month: '2-digit', 
      year: 'numeric' 
    });
  }
}

// Inicialización automática
document.addEventListener('DOMContentLoaded', function() {
  console.log('Inicializando ProductCards');
  
  // Inicializar todas las tarjetas existentes
  document.querySelectorAll('.card[data-product-id]').forEach(card => {
    new ProductCard(card);
  });
});

// Función global para inicializar nuevas tarjetas (útil para AJAX)
window.initializeProductCards = function(container = document) {
  container.querySelectorAll('.card[data-product-id]').forEach(card => {
    if (!card.hasAttribute('data-initialized')) {
      new ProductCard(card);
      card.setAttribute('data-initialized', 'true');
    }
  });
};