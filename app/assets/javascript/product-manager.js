// app/javascript/product-manager.js
import { BaseManager } from './base-manager.js';

class ProductManager extends BaseManager {
  constructor() {
    super({
      filters: {
        productSearch: '',
        dateFrom: '',
        dateTo: ''
      },
      containerSelector: '#products',
      itemSelector: '.card',
      exportUrl: '/products/export'
    });
    this.init();
  }

  init() {
    super.init();
    this.bindSpecificEvents();
  }

  loadItems() {
    // Obtener todos los elementos .card dentro de #products
    this.allItems = Array.from(document.querySelectorAll('#products .card'));
    this.filteredItems = [...this.allItems];
    console.log('📦 Productos cargados:', this.allItems.length);
  }

  bindSpecificEvents() {
    // Filtros de productos
    const productSearch = document.getElementById('product-search');
    const dateFrom = document.getElementById('date-from');
    const dateTo = document.getElementById('date-to');

    if (productSearch) {
      productSearch.addEventListener('input', (e) => {
        this.filters.productSearch = e.target.value.toLowerCase().trim();
        this.applyFiltersAndPaginate();
      });
    }

    if (dateFrom) {
      dateFrom.addEventListener('change', () => {
        this.filters.dateFrom = document.getElementById('date-from').value;
        this.applyFiltersAndPaginate();
      });
    }

    if (dateTo) {
      dateTo.addEventListener('change', () => {
        this.filters.dateTo = document.getElementById('date-to').value;
        this.applyFiltersAndPaginate();
      });
    }
  }

  bindExportEvents() {
    const downloadBtn = document.getElementById('download-btn');
    const exportSelect = document.getElementById('export-type');

    if (downloadBtn) {
      downloadBtn.addEventListener('click', (e) => {
        e.preventDefault();
        let url = this.exportUrl;
        
        if (exportSelect) {
          const type = exportSelect.value;
          url = `${this.exportUrl}?type=${type}`;
        }
        
        window.location.href = url;
      });
    }
  }

  applyFilters() {
    this.filteredItems = this.allItems.filter(product => {
      let shouldShow = true;
      
      // Obtener solo el texto de los spans .display-field
      const displayFields = product.querySelectorAll('.display-field');
      let modelo = '';
      let marca = '';
      let owner = '';
      let fecha = '';
      
      if (displayFields.length >= 4) {
        modelo = displayFields[0].textContent.trim().toLowerCase();
        marca = displayFields[1].textContent.trim().toLowerCase();
        owner = displayFields[2].textContent.trim().toLowerCase();
        fecha = displayFields[3].textContent.trim();
      }

      // Filtro de búsqueda por texto
      if (this.filters.productSearch) {
        const searchTerm = this.filters.productSearch;
        
        // Buscar en modelo, marca y owner usando método heredado
        const modeloMatch = this.searchInText(modelo, searchTerm);
        const marcaMatch = this.searchInText(marca, searchTerm);
        const ownerMatch = this.searchInText(owner, searchTerm);
        
        shouldShow = modeloMatch || marcaMatch || ownerMatch;
      }

      // Filtro de fecha
      if (shouldShow && (this.filters.dateFrom || this.filters.dateTo)) {
        const productDate = this.parseDate(fecha);
        
        if (productDate) {
          if (this.filters.dateFrom) {
            const fromDate = new Date(this.filters.dateFrom);
            shouldShow = shouldShow && productDate >= fromDate;
          }
          
          if (this.filters.dateTo) {
            const toDate = new Date(this.filters.dateTo);
            shouldShow = shouldShow && productDate <= toDate;
          }
        } else if (this.filters.dateFrom || this.filters.dateTo) {
          shouldShow = false;
        }
      }

      return shouldShow;
    });

    this.updatePaginationData();
  }


  clearFilters() {
    // Limpiar inputs
    const productSearch = document.getElementById('product-search');
    const dateFrom = document.getElementById('date-from');
    const dateTo = document.getElementById('date-to');

    if (productSearch) productSearch.value = '';
    if (dateFrom) dateFrom.value = '';
    if (dateTo) dateTo.value = '';

    // Limpiar filtros internos
    this.filters = {
      productSearch: '',
      dateFrom: '',
      dateTo: ''
    };

    // Usar método padre
    super.clearFilters();
  }
}

// Función global para limpiar filtros
function clearAllFilters() {
  if (window.productManager) {
    window.productManager.clearFilters();
  }
}

// Hacer la función disponible globalmente
window.clearAllFilters = clearAllFilters;

// Inicialización
document.addEventListener('DOMContentLoaded', function() {
  window.productManager = new ProductManager();
  console.log('✅ Product Manager con paginación inicializado');
});

// Exportar para uso en módulos
export { ProductManager, clearAllFilters };