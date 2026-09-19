<template>
  <q-layout view="lHh Lpr lFf" class="shell" :style="{ '--plant-primary': plantConfig?.color_primario || '#1267c8' }">
    <q-header class="topbar">
      <q-toolbar class="toolbar">
        <q-btn
          flat
          round
          dense
          icon="menu"
          class="mobile-menu"
          aria-label="Abrir menú"
          @click="drawer = !drawer"
        />
        <div class="search">
          <q-icon name="search" /><input
            v-model="search"
            placeholder="Buscar en Velkoryx..."
            aria-label="Buscar"
          /><kbd>Ctrl + K</kbd>
        </div>
        <q-space />
        <q-btn
          flat
          round
          dense
          icon="notifications_none"
          aria-label="Notificaciones"
          class="top-action"
          @click="showNotifications = !showNotifications"
          ><i class="notice-dot"
        /></q-btn>
        <q-btn
          flat
          round
          dense
          :icon="light ? 'dark_mode' : 'light_mode'"
          aria-label="Cambiar tema"
          class="top-action"
          @click="light = !light"
        />
        <button class="profile" @click="showProfile = !showProfile">
          <span class="avatar">CM</span
          ><span><strong>Carlos Méndez</strong><small>Administrador</small></span
          ><q-icon name="expand_more" />
        </button>
      </q-toolbar>
      <div v-if="showNotifications" class="popover notifications">
        <strong>Notificaciones</strong>
        <p>3 avisos requieren tu atención.</p>
      </div>
      <div v-if="showProfile" class="popover profile-menu">
        <strong>Carlos Méndez</strong>
        <p>Administrador · {{ plantConfig?.nombre || 'Planta' }}</p>
      </div>
    </q-header>
    <q-drawer v-model="drawer" show-if-above :width="210" class="sidebar">
      <div class="side-content">
        <div class="brand"><img :src="apiAssetUrl(plantConfig?.logo) || logo" :alt="plantConfig?.nombre_sistema || 'VELKORYX Industrial Operating System'" /></div>
        <nav aria-label="Navegación principal">
          <template v-for="item in navigation" :key="item.id">
            <button
              :class="['nav-item', { active: activeId === item.id || (item.children && activeId.startsWith('settings-')) }]"
              :aria-expanded="item.children ? settingsOpen : undefined"
              @click="item.children ? (settingsOpen = !settingsOpen) : select(item)"
            >
              <q-icon :name="item.icon" size="18px" />
              <span>{{ item.label }}</span>
              <q-icon v-if="item.children" :name="settingsOpen ? 'expand_less' : 'expand_more'" size="16px" class="nav-chevron" />
            </button>
            <div v-if="item.children && settingsOpen" class="submenu">
              <button
                v-for="child in item.children"
                :key="child.id"
                :class="['submenu-item', { active: activeId === child.id }]"
                @click="select(child)"
              >
                {{ child.label }}
              </button>
            </div>
          </template>
        </nav>
        <div class="side-footer">EVERYTHING<br />YOUR FACTORY<br />RUNS ON.</div>
      </div>
    </q-drawer>
    <q-page-container :class="{ 'light-mode': light }"
      ><router-view :section="section" :search="search"
    /></q-page-container>
  </q-layout>
</template>
<script setup>
import { ref, watch, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { loadPlantConfig, plantConfig } from '../services/plantConfig.js'
import { apiAssetUrl } from '../services/api.js'
import logo from '../img/ve.png'

const route = useRoute()
const router = useRouter()
const drawer = ref(false)
const section = ref('Inicio')
const activeId = ref('home')
const settingsOpen = ref(false)
const search = ref('')
const light = ref(false)
const showNotifications = ref(false)
const showProfile = ref(false)
const navigation = [
  { id: 'home', label: 'Inicio', icon: 'home' },
  { id: 'customers', label: 'Clientes', icon: 'groups' },
  { id: 'suppliers', label: 'Proveedores', icon: 'local_shipping' },
  { id: 'inventory', label: 'Inventario', icon: 'inventory_2' },
  { id: 'purchases', label: 'Compras', icon: 'shopping_cart' },
  { id: 'sales', label: 'Ventas', icon: 'point_of_sale' },
  { id: 'logistics', label: 'Logística', icon: 'local_shipping' },
  { id: 'finance', label: 'Finanzas', icon: 'account_balance_wallet' },
  { id: 'people', label: 'Recursos Humanos', icon: 'groups' },
  {
    id: 'settings', label: 'Configuración', icon: 'settings',
    children: [
      { id: 'settings-plant', label: 'Planta', path: '/configuracion/planta' },
      { id: 'settings-products', label: 'Productos' },
      { id: 'settings-customers', label: 'Clientes' },
      { id: 'settings-suppliers', label: 'Proveedores' },
      { id: 'settings-materials', label: 'Materia Prima' },
    ],
  },
]
function select(item) {
  activeId.value = item.id
  section.value = item.label
  if (item.path) router.push(item.path)
  else if (route.path !== '/') router.push('/')
  if (window.innerWidth < 900) drawer.value = false
}
watch(() => route.path, path => {
  if (path === '/configuracion/planta') {
    activeId.value = 'settings-plant'
    section.value = 'Planta'
    settingsOpen.value = true
  } else if (activeId.value === 'settings-plant') {
    activeId.value = 'home'
    section.value = 'Inicio'
  }
}, { immediate: true })
function handleShortcut(event) {
  if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'k') {
    event.preventDefault()
    document.querySelector('.search input')?.focus()
  }
}
watch(plantConfig, value => {
  document.title = value?.nombre_sistema || 'VELKORYX'
  const favicon = document.querySelector('link[rel="icon"]')
  if (favicon) favicon.href = apiAssetUrl(value?.favicon) || '/favicon.ico'
})
onMounted(() => {
  window.addEventListener('keydown', handleShortcut)
  loadPlantConfig().catch(() => {})
})
onUnmounted(() => window.removeEventListener('keydown', handleShortcut))
</script>
