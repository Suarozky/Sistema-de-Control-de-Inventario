// app/javascript/user-manager.js
// Dependencia: base-manager.js debe cargarse antes

class UserManager extends BaseManager {
  constructor() {
    super({
      filters: {
        userSearch: ''
      },
      containerSelector: '#users',
      itemSelector: '.card',
      exportUrl: '/users/export?type=user'
    });
    this.init();
  }

  init() {
    super.init();
    this.bindSpecificEvents();
  }

  loadItems() {
    // Obtener todos los elementos .card dentro de #users
    this.allItems = Array.from(document.querySelectorAll('#users .card'));
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

// UserManager está disponible globalmente