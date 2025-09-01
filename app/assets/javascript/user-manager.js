// app/javascript/user-manager.js

class UserManager {
  constructor() {
    this.filters = {
      userSearch: ''
    };
    this.pagination = {
      currentPage: 1,
      itemsPerPage: 10,
      totalItems: 0,
      totalPages: 0
    };
    this.filteredUsers = [];
    this.allUsers = [];
    this.init();
  }

  init() {
    this.bindEvents();
    this.loadUsers();
    this.applyFiltersAndPaginate();
  }

  loadUsers() {
    // Obtener todos los elementos .card dentro de #users (excluyendo el título)
    this.allUsers = Array.from(document.querySelectorAll('#users > div'))
      .filter(el => !el.textContent.includes('Listado de Usuarios'));
    this.filteredUsers = [...this.allUsers];
    console.log('👥 Usuarios cargados:', this.allUsers.length);
  }

  bindEvents() {
    // Filtro de usuarios
    const userSearch = document.getElementById('user-search');

    if (userSearch) {
      userSearch.addEventListener('input', (e) => {
        this.filters.userSearch = e.target.value.toLowerCase().trim();
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
    if (downloadBtn) {
      downloadBtn.addEventListener('click', (e) => {
        e.preventDefault();
        window.location.href = '/users/export?type=user';
      });
    }
  }

  applyFiltersAndPaginate() {
    this.applyFilters();
    this.pagination.currentPage = 1; // Resetear a la primera página cuando se filtran
    this.updateDisplay();
  }

  applyFilters() {
    this.filteredUsers = this.allUsers.filter(user => {
      let shouldShow = true;
      
      // Filtro de búsqueda - buscar en todo el contenido del usuario
      if (this.filters.userSearch) {
        const textContent = user.textContent.toLowerCase();
        const searchTerm = this.filters.userSearch;
        shouldShow = textContent.includes(searchTerm);
      }

      return shouldShow;
    });

    this.pagination.totalItems = this.filteredUsers.length;
    this.pagination.totalPages = Math.ceil(this.pagination.totalItems / this.pagination.itemsPerPage);
  }

  updateDisplay() {
    // Ocultar todos los usuarios primero
    this.allUsers.forEach(user => {
      user.classList.add('hidden');
    });

    // Calcular qué usuarios mostrar en la página actual
    const startIndex = (this.pagination.currentPage - 1) * this.pagination.itemsPerPage;
    const endIndex = startIndex + this.pagination.itemsPerPage;
    const usersToShow = this.filteredUsers.slice(startIndex, endIndex);

    // Mostrar solo los usuarios de la página actual
    usersToShow.forEach(user => {
      user.classList.remove('hidden');
    });

    this.updateResultsCount();
    this.updatePaginationControls();

    console.log('📄 Página actual:', this.pagination.currentPage);
    console.log('👥 Mostrando usuarios:', startIndex + 1, 'a', Math.min(endIndex, this.pagination.totalItems));
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

  clearFilters() {
    // Limpiar inputs
    const userSearch = document.getElementById('user-search');

    if (userSearch) userSearch.value = '';

    // Limpiar filtros internos
    this.filters = {
      userSearch: ''
    };

    // Resetear paginación
    this.pagination.currentPage = 1;
    
    // Aplicar filtros y actualizar display
    this.applyFilters();
    this.updateDisplay();
  }
}

// Función global para limpiar filtros (la necesitas en el HTML)
window.clearAllFilters = function() {
  if (window.userManager) {
    window.userManager.clearFilters();
  }
};

// Inicialización automática
document.addEventListener('DOMContentLoaded', function() {
  // Solo inicializar si estamos en una página que tiene el dashboard de usuarios
  if (document.getElementById('users')) {
    window.userManager = new UserManager();
    console.log('✅ User Manager con paginación inicializado');
  }
});

// Exportar para uso en módulos (si usas importmap)
export { UserManager };