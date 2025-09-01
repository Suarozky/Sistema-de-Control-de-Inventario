// app/javascript/dashboard-manager.js

class ProductManager {
  constructor() {
    this.filters = {
      productSearch: '',
      dateFrom: '',
      dateTo: ''
    };
    this.pagination = {
      currentPage: 1,
      itemsPerPage: 10,
      totalItems: 0,
      totalPages: 0
    };
    this.filteredProducts = [];
    this.allProducts = [];
    this.init();
  }

  init() {
    this.bindEvents();
    this.loadProducts();
    this.applyFiltersAndPaginate(); // en lugar de solo updateDisplay()
  }

  loadProducts() {
    // Obtener todos los elementos .card dentro de #products (excluyendo el título)
    this.allProducts = Array.from(document.querySelectorAll('#products .card'));
    this.filteredProducts = [...this.allProducts];
    console.log('📦 Productos cargados:', this.allProducts.length);
  }

  bindEvents() {
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

    // Paginación
    const itemsPerPageSelect = document.getElementById('items-per-page');
    const prevBtn = document.getElementById('prev-page');
    const nextBtn = document.getElementById('next-page');

    if (itemsPerPageSelect) {
      itemsPerPageSelect.addEventListener('change', (e) => {
        this.pagination.itemsPerPage = parseInt(e.target.value);
        this.pagination.currentPage = 1; // Resetear a la primera página
        this.applyFiltersAndPaginate();
      });
    }

    if (prevBtn) {
      prevBtn.addEventListener('click', () => {
        if (this.pagination.currentPage > 1) {
          this.pagination.currentPage--;
          this.updateDisplay();
        }
      });
    }

    if (nextBtn) {
      nextBtn.addEventListener('click', () => {
        if (this.pagination.currentPage < this.pagination.totalPages) {
          this.pagination.currentPage++;
          this.updateDisplay();
        }
      });
    }

    // Exportación
    const downloadBtn = document.getElementById('download-btn');
    const exportSelect = document.getElementById('export-type');

    if (downloadBtn && exportSelect) {
      downloadBtn.addEventListener('click', (e) => {
        e.preventDefault();
        const type = exportSelect.value;
        const url = `/products/export?type=${type}`;
        window.location.href = url;
      });
    }
  }

  applyFiltersAndPaginate() {
    this.applyFilters();
    this.pagination.currentPage = 1; // Resetear a la primera página cuando se filtran
    this.updateDisplay();
  }

  applyFilters() {
    this.filteredProducts = this.allProducts.filter(product => {
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
        
        // Buscar en modelo, marca y owner
        const modeloMatch = modelo.includes(searchTerm);
        const marcaMatch = marca.includes(searchTerm);
        const ownerMatch = owner.includes(searchTerm);
        
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

    this.pagination.totalItems = this.filteredProducts.length;
    this.pagination.totalPages = Math.ceil(this.pagination.totalItems / this.pagination.itemsPerPage);
  }

  updateDisplay() {
    // Ocultar todos los productos primero
    this.allProducts.forEach(product => {
      product.classList.add('hidden');
    });

    // Calcular qué productos mostrar en la página actual
    const startIndex = (this.pagination.currentPage - 1) * this.pagination.itemsPerPage;
    const endIndex = startIndex + this.pagination.itemsPerPage;
    const productsToShow = this.filteredProducts.slice(startIndex, endIndex);

    // Mostrar solo los productos de la página actual
    productsToShow.forEach(product => {
      product.classList.remove('hidden');
    });

    this.updateResultsCount();
    this.updatePaginationControls();

    console.log('📄 Página actual:', this.pagination.currentPage);
    console.log('📦 Mostrando productos:', startIndex + 1, 'a', Math.min(endIndex, this.pagination.totalItems));
  }

  updateResultsCount() {
    const resultsCount = document.getElementById('results-count');
    if (resultsCount) {
      const startIndex = (this.pagination.currentPage - 1) * this.pagination.itemsPerPage;
      const endIndex = Math.min(startIndex + this.pagination.itemsPerPage, this.pagination.totalItems);
      
      if (this.pagination.totalItems === 0) {
        resultsCount.textContent = 'No se encontraron resultados';
      } else if (this.pagination.totalPages === 1) {
        resultsCount.textContent = `Mostrando todos los resultados (${this.pagination.totalItems})`;
      } else {
        resultsCount.textContent = `Mostrando ${startIndex + 1}-${endIndex} de ${this.pagination.totalItems} resultados`;
      }
    }
  }

  updatePaginationControls() {
    const prevBtn = document.getElementById('prev-page');
    const nextBtn = document.getElementById('next-page');
    const pageNumbers = document.getElementById('page-numbers');

    // Actualizar botones anterior/siguiente
    if (prevBtn) {
      prevBtn.disabled = this.pagination.currentPage <= 1;
    }

    if (nextBtn) {
      nextBtn.disabled = this.pagination.currentPage >= this.pagination.totalPages;
    }

    // Generar números de página
    if (pageNumbers) {
      pageNumbers.innerHTML = '';
      
      if (this.pagination.totalPages <= 1) {
        return;
      }

      // Calcular rango de páginas a mostrar
      const maxButtons = 7;
      let startPage = Math.max(1, this.pagination.currentPage - Math.floor(maxButtons / 2));
      let endPage = Math.min(this.pagination.totalPages, startPage + maxButtons - 1);
      
      // Ajustar si estamos cerca del final
      if (endPage - startPage < maxButtons - 1) {
        startPage = Math.max(1, endPage - maxButtons + 1);
      }

      // Botón primera página
      if (startPage > 1) {
        this.createPageButton(pageNumbers, 1, false);
        if (startPage > 2) {
          const ellipsis = document.createElement('span');
          ellipsis.textContent = '...';
          ellipsis.className = 'px-2 py-1 text-gray-500';
          pageNumbers.appendChild(ellipsis);
        }
      }

      // Botones de páginas
      for (let i = startPage; i <= endPage; i++) {
        this.createPageButton(pageNumbers, i, i === this.pagination.currentPage);
      }

      // Botón última página
      if (endPage < this.pagination.totalPages) {
        if (endPage < this.pagination.totalPages - 1) {
          const ellipsis = document.createElement('span');
          ellipsis.textContent = '...';
          ellipsis.className = 'px-2 py-1 text-gray-500';
          pageNumbers.appendChild(ellipsis);
        }
        this.createPageButton(pageNumbers, this.pagination.totalPages, false);
      }
    }
  }

  createPageButton(container, pageNumber, isActive) {
    const button = document.createElement('button');
    button.textContent = pageNumber;
    button.className = `px-3 py-1 text-sm rounded-md transition-colors duration-200 ${
      isActive 
        ? 'bg-blue-500 text-white' 
        : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
    }`;
    
    if (!isActive) {
      button.addEventListener('click', () => {
        this.pagination.currentPage = pageNumber;
        this.updateDisplay();
      });
    }
    
    container.appendChild(button);
  }

  parseDate(dateStr) {
    // Convierte fechas en múltiples formatos a objeto Date
    const cleanDate = dateStr.trim().replace(/[-\.]/g, '/');
    
    let parts = cleanDate.split('/');
    
    // Formato dd/mm/yyyy
    if (parts.length === 3 && parts[2].length === 4) {
      const day = parseInt(parts[0], 10);
      const month = parseInt(parts[1], 10) - 1;
      const year = parseInt(parts[2], 10);
      
      if (!isNaN(day) && !isNaN(month) && !isNaN(year) && 
          day >= 1 && day <= 31 && month >= 0 && month <= 11) {
        return new Date(year, month, day);
      }
    }
    
    // Formato yyyy/mm/dd
    if (parts.length === 3 && parts[0].length === 4) {
      const year = parseInt(parts[0], 10);
      const month = parseInt(parts[1], 10) - 1;
      const day = parseInt(parts[2], 10);
      
      if (!isNaN(day) && !isNaN(month) && !isNaN(year) && 
          day >= 1 && day <= 31 && month >= 0 && month <= 11) {
        return new Date(year, month, day);
      }
    }
    
    // Intentar con Date.parse como último recurso
    const parsedDate = new Date(dateStr);
    if (!isNaN(parsedDate.getTime())) {
      return parsedDate;
    }
    
    return null;
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

    // Resetear paginación
    this.pagination.currentPage = 1;
    
    // Aplicar filtros y actualizar display
    this.applyFilters();
    this.updateDisplay();
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