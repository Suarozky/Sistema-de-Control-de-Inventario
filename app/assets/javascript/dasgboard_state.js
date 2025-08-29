// Estado global para tu dashboard Rails
class DashboardGlobalState {
  constructor() {
    this.storageKey = 'dashboard_state_v1';
    this.state = this.loadPersistedState();
    this.listeners = new Map();
    this.initializeGlobalSync();
  }

  // Cargar estado persistente
  loadPersistedState() {
    try {
      const saved = localStorage.getItem(this.storageKey);
      const defaultState = {
        activeTab: 'products',
        searchUrls: {},
        userPreferences: {},
        navigationHistory: [],
        lastUpdate: Date.now()
      };
      return saved ? { ...defaultState, ...JSON.parse(saved) } : defaultState;
    } catch (e) {
      return this.getDefaultState();
    }
  }

  // Tu método principal para cambiar tabs
  setActiveTab(tabName) {
    this.setState({ activeTab: tabName });
    this.syncTabsUI();
    this.updateSearchUrl(tabName);
  }

  // Sincronizar UI con estado
  syncTabsUI() {
    const activeTab = this.state.activeTab;
    
    // Limpiar estados anteriores
    document.querySelectorAll('.tab-btn.active, .tab-content.active')
      .forEach(el => el.classList.remove('active'));
    
    // Activar elementos correctos
    const tabButton = document.querySelector(`[data-tab="${activeTab}"]`);
    const tabContent = document.getElementById(activeTab);
    
    if (tabButton && tabContent) {
      tabButton.classList.add('active');
      tabContent.classList.add('active');
    }
  }

  // Actualizar URL de búsqueda (tu funcionalidad existente)
  updateSearchUrl(tabName) {
    const searchLink = document.getElementById('search-link');
    const urls = {
      products: this.state.searchUrls.products || '/products/new',
      users: this.state.searchUrls.users || '/users/new'
    };
    
    if (searchLink && urls[tabName]) {
      searchLink.href = urls[tabName];
    }
  }

  // Método para Rails - configurar URLs desde el servidor
  setSearchUrls(urls) {
    this.setState({ searchUrls: urls });
  }

  // Estado general
  setState(newState) {
    this.state = { ...this.state, ...newState, lastUpdate: Date.now() };
    this.persistState();
    this.notifyListeners();
  }

  persistState() {
    try {
      localStorage.setItem(this.storageKey, JSON.stringify(this.state));
    } catch (e) {
      console.warn('No se pudo persistir estado:', e);
    }
  }

  // Sistema de eventos para componentes
  subscribe(event, callback) {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, []);
    }
    this.listeners.get(event).push(callback);
  }

  notifyListeners() {
    if (this.listeners.has('stateChange')) {
      this.listeners.get('stateChange').forEach(cb => cb(this.state));
    }
  }

  // Sincronización entre tabs del navegador
  initializeGlobalSync() {
    window.addEventListener('storage', (e) => {
      if (e.key === this.storageKey) {
        this.state = JSON.parse(e.newValue || '{}');
        this.syncTabsUI();
        this.notifyListeners();
      }
    });

    // Persistir estado al salir
    window.addEventListener('beforeunload', () => {
      this.persistState();
    });
  }
}