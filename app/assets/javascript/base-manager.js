// app/javascript/base-manager.js

class BaseManager {
  constructor(options = {}) {
    this.filters = options.filters || {};
    this.pagination = {
      currentPage: 1,
      itemsPerPage: options.itemsPerPage || 10,
      totalItems: 0,
      totalPages: 0
    };
    this.filteredItems = [];
    this.allItems = [];
    this.containerSelector = options.containerSelector || '';
    this.itemSelector = options.itemSelector || '';
    this.exportUrl = options.exportUrl || '';
  }

  init() {
    this.bindCommonEvents();
    this.loadItems();
    this.applyFiltersAndPaginate();
  }

  loadItems() {
    if (this.containerSelector && this.itemSelector) {
      this.allItems = Array.from(document.querySelectorAll(`${this.containerSelector} ${this.itemSelector}`));
    } else {
      console.warn('Container and item selectors not defined in child class');
      return;
    }
    
    this.filteredItems = [...this.allItems];
    console.log(`📦 Items cargados: ${this.allItems.length}`);
  }

  bindCommonEvents() {
    // Paginación
    this.bindPaginationEvents();
    
    // Exportación
    this.bindExportEvents();
  }

  bindPaginationEvents() {
    const itemsPerPageSelect = document.getElementById('items-per-page');
    const prevBtn = document.getElementById('prev-page');
    const nextBtn = document.getElementById('next-page');

    if (itemsPerPageSelect) {
      itemsPerPageSelect.addEventListener('change', (e) => {
        this.pagination.itemsPerPage = parseInt(e.target.value);
        this.pagination.currentPage = 1;
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

  applyFiltersAndPaginate() {
    this.applyFilters();
    this.pagination.currentPage = 1;
    this.updateDisplay();
  }

  applyFilters() {
    // Método base - debe ser implementado en las clases hijas
    console.warn('applyFilters method should be implemented in child class');
    this.filteredItems = [...this.allItems];
    this.updatePaginationData();
  }

  updatePaginationData() {
    this.pagination.totalItems = this.filteredItems.length;
    this.pagination.totalPages = Math.ceil(this.pagination.totalItems / this.pagination.itemsPerPage);
  }

  updateDisplay() {
    // Ocultar todos los elementos
    this.allItems.forEach(item => {
      item.classList.add('hidden');
    });

    // Calcular elementos a mostrar
    const startIndex = (this.pagination.currentPage - 1) * this.pagination.itemsPerPage;
    const endIndex = startIndex + this.pagination.itemsPerPage;
    const itemsToShow = this.filteredItems.slice(startIndex, endIndex);

    // Mostrar elementos de la página actual
    itemsToShow.forEach(item => {
      item.classList.remove('hidden');
    });

    this.updateResultsCount();
    this.updatePaginationControls();

    console.log(`📄 Página actual: ${this.pagination.currentPage}`);
    console.log(`📦 Mostrando elementos: ${startIndex + 1} a ${Math.min(endIndex, this.pagination.totalItems)}`);
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

      this.generatePageNumbers(pageNumbers);
    }
  }

  generatePageNumbers(container) {
    const maxButtons = 7;
    let startPage = Math.max(1, this.pagination.currentPage - Math.floor(maxButtons / 2));
    let endPage = Math.min(this.pagination.totalPages, startPage + maxButtons - 1);
    
    // Ajustar si estamos cerca del final
    if (endPage - startPage < maxButtons - 1) {
      startPage = Math.max(1, endPage - maxButtons + 1);
    }

    // Botón primera página
    if (startPage > 1) {
      this.createPageButton(container, 1, false);
      if (startPage > 2) {
        this.createEllipsis(container);
      }
    }

    // Botones de páginas
    for (let i = startPage; i <= endPage; i++) {
      this.createPageButton(container, i, i === this.pagination.currentPage);
    }

    // Botón última página
    if (endPage < this.pagination.totalPages) {
      if (endPage < this.pagination.totalPages - 1) {
        this.createEllipsis(container);
      }
      this.createPageButton(container, this.pagination.totalPages, false);
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

  createEllipsis(container) {
    const ellipsis = document.createElement('span');
    ellipsis.textContent = '...';
    ellipsis.className = 'px-2 py-1 text-gray-500';
    container.appendChild(ellipsis);
  }

  clearFilters() {
    // Método base - debe ser implementado en las clases hijas
    console.warn('clearFilters method should be implemented in child class');
    
    // Resetear paginación
    this.pagination.currentPage = 1;
    
    // Aplicar filtros y actualizar display
    this.applyFilters();
    this.updateDisplay();
  }

  // Métodos utilitarios
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

  searchInText(text, searchTerm) {
    return text.toLowerCase().includes(searchTerm.toLowerCase().trim());
  }
}

// Exportar para uso en módulos
export { BaseManager };