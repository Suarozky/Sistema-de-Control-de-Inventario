// app/javascript/user-manager.js
import { BaseManager } from './base-manager.js';

class UserManager extends BaseManager {
  constructor() {
    super({
      filters: {
        userSearch: ''
      },
      containerSelector: '#users',
      itemSelector: '> div',
      exportUrl: '/users/export?type=user'
    });
    this.init();
  }

  init() {
    super.init();
    this.bindSpecificEvents();
  }

  loadItems() {
    // Obtener todos los elementos div dentro de #users (excluyendo el título)
    this.allItems = Array.from(document.querySelectorAll('#users > div'))
      .filter(el => !el.textContent.includes('Listado de Usuarios'));
    this.filteredItems = [...this.allItems];
    console.log('👥 Usuarios cargados:', this.allItems.length);
  }

  bindSpecificEvents() {
    // Filtro de usuarios
    const userSearch = document.getElementById('user-search');

    if (userSearch) {
      userSearch.addEventListener('input', (e) => {
        this.filters.userSearch = e.target.value.toLowerCase().trim();
        this.applyFiltersAndPaginate();
      });
    }
  }

  applyFilters() {
    this.filteredItems = this.allItems.filter(user => {
      let shouldShow = true;
      
      // Filtro de búsqueda - buscar en todo el contenido del usuario
      if (this.filters.userSearch) {
        const textContent = user.textContent.toLowerCase();
        shouldShow = this.searchInText(textContent, this.filters.userSearch);
      }

      return shouldShow;
    });

    this.updatePaginationData();
  }


  clearFilters() {
    // Limpiar inputs
    const userSearch = document.getElementById('user-search');

    if (userSearch) userSearch.value = '';

    // Limpiar filtros internos
    this.filters = {
      userSearch: ''
    };

    // Usar método padre
    super.clearFilters();
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