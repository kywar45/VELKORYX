<template>
  <q-page class="dashboard">
    <header class="welcome">
      <div><h1>{{ section === 'Inicio' ? 'Bienvenido, Carlos' : section }}</h1><p>Aquí está el panorama general de tu operación.</p></div>
      <div class="welcome-tools"><span class="tagline">MÁS QUE UN ERP.<br />EL SISTEMA OPERATIVO DE TU FÁBRICA.</span><div class="plant"><q-icon name="apartment" size="22px" /> {{ plantConfig?.nombre || 'Planta sin configurar' }}</div><div class="clock"><span>{{ date }}</span><strong>{{ time }}</strong></div></div>
    </header>
    <div class="stats">
      <article v-for="stat in stats" :key="stat.label" class="stat"><div :class="['stat-icon', stat.color]"><q-icon :name="stat.icon" size="25px" /></div><div class="stat-text"><small>{{ stat.label }}</small><strong>{{ stat.value }}</strong><span>{{ stat.unit }}</span><p :class="stat.trendColor"><q-icon :name="stat.arrow" size="14px" /> {{ stat.trend }} <em>{{ stat.compare }}</em></p></div></article>
    </div>
    <div class="panels">
      <section class="panel production"><div class="panel-title"><h2>Producción en tiempo real</h2><select v-model="lineFilter" aria-label="Filtrar líneas"><option>Todas las líneas</option><option>En producción</option><option>Ajuste de calidad</option></select></div><div class="lines"><div v-for="line in filteredLines" :key="line.name" class="line"><div class="machine"><q-icon :name="line.icon" size="31px" /></div><div class="line-body"><strong>{{ line.name }}</strong><div class="line-meta"><i :class="['dot', line.color]" />{{ line.status }}<span>{{ line.count }}</span><b>{{ line.progress }}%</b></div><div class="track"><div :class="line.color" :style="{ width: line.progress + '%' }" /></div></div></div></div></section>
      <section class="panel orders"><div class="panel-title"><h2>Órdenes de producción</h2><button class="link-button" @click="allOrders = !allOrders">{{ allOrders ? 'Ver menos' : 'Ver todas' }}</button></div><div class="table-scroll"><table><thead><tr><th># OP</th><th>Producto</th><th>Avance</th><th>Estado</th></tr></thead><tbody><tr v-for="order in filteredOrders" :key="order.id"><td>{{ order.id }}</td><td>{{ order.product }}</td><td><div class="mini-track"><div :style="{ width: order.progress + '%' }" /></div> {{ order.progress }}%</td><td><span :class="['badge', order.state]">{{ order.label }}</span></td></tr></tbody></table></div></section>
      <section class="panel alerts"><div class="panel-title"><h2>Alertas y notificaciones</h2><button class="link-button" @click="allAlerts = !allAlerts">{{ allAlerts ? 'Ver menos' : 'Ver todas' }}</button></div><button v-for="alert in filteredAlerts" :key="alert.title" class="alert" @click="selectedAlert = alert"><span :class="['alert-icon', alert.color]"><q-icon :name="alert.icon" size="17px" /></span><span class="alert-label"><strong>{{ alert.title }}</strong><small>{{ alert.detail }}</small></span><span class="alert-time">{{ alert.time }}</span><q-icon name="chevron_right" size="17px" /></button></section>
      <section class="panel kpis"><div class="panel-title"><h2>Indicadores clave (KPIs)</h2><select v-model="period" aria-label="Periodo"><option>Últimos 7 días</option><option>Últimos 30 días</option><option>Este mes</option></select></div><div class="kpi-grid"><div v-for="kpi in kpis" :key="kpi.label" class="kpi"><span>{{ kpi.label }}</span><div class="ring" :style="{ '--value': kpi.value, '--color': kpi.color }"><strong>{{ kpi.value }}%</strong></div><small><q-icon name="arrow_upward" size="13px" /> {{ kpi.change }}</small></div></div></section>
      <section class="panel materials"><div class="panel-title material-title"><div><h2>Consumo de materia prima</h2><p>Top 5 · Últimos 30 días</p></div></div><div class="material-list"><div v-for="material in materials" :key="material.name" class="material"><span>{{ material.name }}</span><div class="material-track"><div :style="{ width: material.width + '%' }" /></div><small>{{ material.amount }}</small></div></div></section>
      <section class="panel locations"><div class="panel-title"><h2>Planta</h2><button class="link-button" @click="mapOpen = true">Ver datos</button></div><div class="location-view"><div class="factory"><div class="building"><div class="building-name"><q-icon name="domain" size="25px" /> {{ plantConfig?.nombre_sistema || 'VELKORYX' }}</div><div class="windows" /></div></div><div class="location-info"><div><strong>{{ plantConfig?.nombre || 'Planta sin configurar' }}</strong><span><i :class="['dot', Number(plantConfig?.estatus) === 1 ? 'green' : 'orange']" /> {{ plantConfig ? (Number(plantConfig.estatus) === 1 ? 'Activa' : 'Inactiva') : 'Pendiente' }}</span></div><div><span>{{ plantConfig?.ciudad || 'Ciudad pendiente' }}</span><span>{{ plantConfig?.estado || plantConfig?.pais || '' }}</span></div></div></div></section>
    </div>
    <footer class="footer"><div><strong>{{ plantConfig?.nombre_sistema || 'VELKORYX' }}</strong><small>v1.0.0</small></div><span>{{ plantConfig?.slogan || 'Manufacturing. Connected.' }}</span><span>Construyendo un futuro más productivo.</span></footer>
    <q-dialog v-model="alertDialog"><q-card class="dialog"><q-card-section><div class="text-h6">{{ selectedAlert?.title }}</div><p>{{ selectedAlert?.detail }}</p><small>{{ selectedAlert?.time }}</small></q-card-section><q-card-actions align="right"><q-btn flat label="Cerrar" v-close-popup /></q-card-actions></q-card></q-dialog>
    <q-dialog v-model="mapOpen"><q-card class="dialog"><q-card-section><div class="text-h6">{{ plantConfig?.nombre || 'Planta sin configurar' }}</div><p>{{ [plantConfig?.calle, plantConfig?.numero_exterior, plantConfig?.colonia, plantConfig?.ciudad, plantConfig?.estado, plantConfig?.pais].filter(Boolean).join(', ') || 'Dirección pendiente' }}</p><p v-if="plantConfig?.latitud && plantConfig?.longitud">Coordenadas: {{ plantConfig.latitud }}, {{ plantConfig.longitud }}</p></q-card-section><q-card-actions align="right"><q-btn flat label="Cerrar" v-close-popup /></q-card-actions></q-card></q-dialog>
  </q-page>
</template>
<script setup>
import { computed, ref } from 'vue'
import { plantConfig } from '../services/plantConfig.js'
const props = defineProps({ section: { type: String, default: 'Inicio' }, search: { type: String, default: '' } })
const lineFilter = ref('Todas las líneas')
const period = ref('Últimos 7 días')
const allOrders = ref(false)
const allAlerts = ref(false)
const selectedAlert = ref(null)
const alertDialog = computed({ get: () => !!selectedAlert.value, set: value => { if (!value) selectedAlert.value = null } })
const mapOpen = ref(false)
const now = new Date()
const date = new Intl.DateTimeFormat('es-MX', { day: 'numeric', month: 'short', year: 'numeric' }).format(now)
const time = new Intl.DateTimeFormat('es-MX', { hour: '2-digit', minute: '2-digit' }).format(now)
const stats = [
  { label: 'Producción de hoy', value: '12,480', unit: 'unidades', icon: 'signal_cellular_alt', color: 'green', trend: '8.5%', arrow: 'arrow_upward', trendColor: 'positive', compare: 'vs. ayer' },
  { label: 'Órdenes en proceso', value: '18', unit: 'órdenes', icon: 'view_in_ar', color: 'blue', trend: '12%', arrow: 'arrow_upward', trendColor: 'positive', compare: 'vs. semana anterior' },
  { label: 'Inventario crítico', value: '3', unit: 'materiales', icon: 'inventory_2', color: 'orange', trend: '2 nuevos', arrow: 'arrow_downward', trendColor: 'negative', compare: '' },
  { label: 'Disponibilidad de equipos', value: '92.3%', unit: 'OEE', icon: 'build', color: 'steel', trend: '1.8%', arrow: 'arrow_upward', trendColor: 'positive', compare: 'vs. semana anterior' },
  { label: 'Costo por unidad', value: '$1.28', unit: 'MXN', icon: 'attach_money', color: 'green', trend: '4.2%', arrow: 'arrow_downward', trendColor: 'positive', compare: 'vs. mes anterior' },
]
const lines = [
  { name: 'Línea 1 · Inyección', status: 'En producción', count: '8,240 / 10,000', progress: 82, color: 'green', icon: 'precision_manufacturing' },
  { name: 'Línea 2 · Termoformado', status: 'En producción', count: '3,120 / 4,000', progress: 78, color: 'green', icon: 'settings_input_component' },
  { name: 'Línea 3 · Ensamble', status: 'Ajuste de calidad', count: '620 / 1,000', progress: 62, color: 'orange', icon: 'settings_suggest' },
  { name: 'Línea 4 · Empaque', status: 'En producción', count: '4,500 / 5,000', progress: 90, color: 'green', icon: 'inventory' },
]
const orders = [
  ['OP-10028','Charola 1kg',82,'process','En proceso'], ['OP-10027','Vaso 12oz',100,'complete','Completada'],
  ['OP-10026','Tapa DT-90',45,'process','En proceso'], ['OP-10025','Envase 500ml',0,'scheduled','Programada'],
  ['OP-10024','Caja logística',100,'complete','Completada'], ['OP-10023','Contenedor 5L',18,'process','En proceso'],
  ['OP-10022','Bandeja 2kg',64,'process','En proceso'], ['OP-10021','Tapa universal',100,'complete','Completada'],
].map(([id,product,progress,state,label]) => ({ id,product,progress,state,label }))
const alerts = [
  ['Inventario bajo','Resina PET (RP-001)','Hace 12 min','inventory_2','red'],
  ['Mantenimiento programado','Extrusora EX-02','Hoy 2:00 PM','warning','orange'],
  ['Orden completada','OP-10027','Hace 1 hr','info','blue'],
  ['Desviación de calidad','Lote L-4502','Hace 2 hrs','error','red'],
  ['Nuevo pedido de cliente','Cliente: Comercializadora del Norte','Hace 3 hrs','description','steel'],
  ['Recepción de materiales','Resina PP · Almacén A','Ayer','inventory','green'],
].map(([title,detail,time,icon,color]) => ({ title,detail,time,icon,color }))
const kpis = [
  { label: 'OEE', value: 92.3, change: '1.8%', color: '#38d5a2' },
  { label: 'Calidad', value: 98.1, change: '0.6%', color: '#4aa6ff' },
  { label: 'Cumplimiento', value: 87.4, change: '4.2%', color: '#ffad3e' },
  { label: 'Eficiencia', value: 85.6, change: '2.1%', color: '#9a6cff' },
]
const materials = [
  ['Resina PP',84,'12,450 kg'], ['Resina PET',64,'9,870 kg'], ['Aditivo UV',19,'2,340 kg'],
  ['Colorante Blanco',15,'1,980 kg'], ['Masterbatch',9,'1,230 kg'],
].map(([name,width,amount]) => ({ name,width,amount }))
const matches = value => value.toLowerCase().includes(props.search.toLowerCase())
const filteredLines = computed(() => lines.filter(line => (lineFilter.value === 'Todas las líneas' || line.status === lineFilter.value) && matches(line.name)))
const filteredOrders = computed(() => orders.filter(order => matches(order.id + ' ' + order.product)).slice(0, allOrders.value ? 8 : 6))
const filteredAlerts = computed(() => alerts.filter(alert => matches(alert.title + ' ' + alert.detail)).slice(0, allAlerts.value ? 6 : 5))
</script>
