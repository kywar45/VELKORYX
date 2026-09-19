<template>
  <q-page class="plants-page">
    <header class="plants-heading">
      <div><span class="section-path">CONFIGURACIÓN / PLANTA</span><h1>Configuración de la planta</h1><p>Datos oficiales de la fábrica que utiliza este sistema.</p></div>
    </header>

    <div v-if="notice" :class="['plant-notice', notice.type]" role="status">
      <q-icon :name="notice.type === 'error' ? 'error_outline' : 'check_circle_outline'" size="18px" />
      {{ notice.text }}
      <button aria-label="Cerrar aviso" @click="notice = null"><q-icon name="close" /></button>
    </div>

    <div class="plant-config-workspace">
      <div v-if="loading" class="plant-config-loading"><q-spinner size="22px" /> Cargando configuración...</div>
      <main v-else class="plant-editor">
        <div class="plant-editor-head">
          <div><span class="editor-eyebrow">DATOS DE LA PLANTA</span><h2>{{ form.nombre || 'Planta por configurar' }}</h2><small v-if="form.id">{{ form.codigo }} · ID {{ form.id }}</small><small v-else>Completa los datos y guarda la configuración inicial.</small></div>
          <div class="editor-actions">
            <q-btn unelevated icon="save" label="Guardar" class="primary-command" :loading="saving" @click="savePlant" />
          </div>
        </div>

        <div class="plant-tabs" role="tablist" aria-label="Datos de la planta">
          <button v-for="item in tabs" :key="item.id" :class="{ active: tab === item.id }" role="tab" :aria-selected="tab === item.id" @click="tab = item.id">{{ item.label }}</button>
        </div>

        <form class="plant-form" novalidate @submit.prevent="savePlant">
          <div v-show="tab === 'general'" class="form-section">
            <div class="form-section-heading"><h3>Identificación</h3><p>Información principal y fiscal de la planta.</p></div>
            <div class="form-grid">
              <label><span>Código <b>*</b></span><input v-model="form.codigo" maxlength="30" placeholder="MTY-01" /></label>
              <label><span>Nombre <b>*</b></span><input v-model="form.nombre" maxlength="150" placeholder="Planta Monterrey" /></label>
              <label><span>Nombre corto</span><input v-model="form.nombre_corto" maxlength="80" placeholder="Monterrey" /></label>
              <label><span>ID de empresa</span><input v-model="form.id_empresa" type="number" min="1" placeholder="Opcional" /></label>
              <label><span>Razón social</span><input v-model="form.razon_social" maxlength="200" /></label>
              <label><span>RFC</span><input v-model="form.rfc" maxlength="20" /></label>
              <label class="full"><span>Descripción</span><textarea v-model="form.descripcion" maxlength="500" rows="3" placeholder="Actividad principal de esta planta" /></label>
            </div>
            <label class="status-control"><input v-model="form.estatus" type="checkbox" /><span>Planta activa</span></label>
          </div>

          <div v-show="tab === 'contacto'" class="form-section">
            <div class="form-section-heading"><h3>Contacto</h3><p>Canales de comunicación de la planta.</p></div>
            <div class="form-grid">
              <label><span>Teléfono</span><input v-model="form.telefono" maxlength="30" type="tel" /></label>
              <label><span>Teléfono secundario</span><input v-model="form.telefono_secundario" maxlength="30" type="tel" /></label>
              <label><span>Correo electrónico</span><input v-model="form.email" maxlength="150" type="email" placeholder="contacto@empresa.com" /></label>
              <label><span>Sitio web</span><input v-model="form.sitio_web" maxlength="250" type="url" placeholder="https://empresa.com" /></label>
            </div>
          </div>

          <div v-show="tab === 'direccion'" class="form-section">
            <div class="form-section-heading"><h3>Dirección</h3><p>Ubicación postal de la fábrica.</p></div>
            <div class="form-grid">
              <label class="full"><span>Calle</span><input v-model="form.calle" maxlength="150" /></label>
              <label><span>Número exterior</span><input v-model="form.numero_exterior" maxlength="30" /></label>
              <label><span>Número interior</span><input v-model="form.numero_interior" maxlength="30" /></label>
              <label><span>Colonia</span><input v-model="form.colonia" maxlength="150" /></label>
              <label><span>Municipio</span><input v-model="form.municipio" maxlength="150" /></label>
              <label><span>Ciudad</span><input v-model="form.ciudad" maxlength="150" /></label>
              <label><span>Estado</span><input v-model="form.estado" maxlength="150" /></label>
              <label><span>Código postal</span><input v-model="form.codigo_postal" maxlength="20" /></label>
              <label><span>País</span><input v-model="form.pais" maxlength="100" /></label>
            </div>
          </div>

          <div v-show="tab === 'localizacion'" class="form-section">
            <div class="form-section-heading"><h3>Localización y formato</h3><p>Coordenadas y preferencias regionales.</p></div>
            <div class="form-grid">
              <label><span>Latitud</span><input v-model="form.latitud" type="number" min="-90" max="90" step="any" placeholder="25.6866142" /></label>
              <label><span>Longitud</span><input v-model="form.longitud" type="number" min="-180" max="180" step="any" placeholder="-100.3161126" /></label>
              <label><span>Zona horaria <b>*</b></span><input v-model="form.zona_horaria" maxlength="100" placeholder="America/Mexico_City" /></label>
              <label><span>Idioma <b>*</b></span><input v-model="form.idioma" maxlength="10" placeholder="es-MX" /></label>
              <label><span>Moneda <b>*</b></span><input v-model="form.moneda" maxlength="3" placeholder="MXN" /></label>
            </div>
          </div>

          <div v-show="tab === 'identidad'" class="form-section">
            <div class="form-section-heading"><h3>Identidad visual</h3><p>Nombre, recursos y colores de esta planta.</p></div>
            <div class="form-grid">
              <label><span>Nombre del sistema <b>*</b></span><input v-model="form.nombre_sistema" maxlength="100" /></label>
              <label><span>Slogan</span><input v-model="form.slogan" maxlength="200" /></label>
              <div class="image-fields">
                <div v-for="imageField in imageFields" :key="imageField.key" class="image-field">
                  <div :class="['image-preview', { square: imageField.key === 'favicon' }]">
                    <img v-if="imagePreview(imageField.key)" :src="imagePreview(imageField.key)" :alt="imageField.label" />
                    <q-icon v-else name="image" size="28px" />
                  </div>
                  <div class="image-field-info">
                    <strong>{{ imageField.label }}</strong>
                    <small>{{ selectedImages[imageField.key]?.name || (imageField.key === 'favicon' ? 'PNG, JPG, WebP o ICO · máximo 5 MB' : 'PNG, JPG o WebP · máximo 5 MB') }}</small>
                    <div class="image-field-actions">
                      <label class="image-upload-button">
                        <q-icon name="upload_file" size="16px" /> {{ form[imageField.key] || selectedImages[imageField.key] ? 'Cambiar imagen' : 'Subir imagen' }}
                        <input type="file" :accept="imageField.key === 'favicon' ? 'image/png,image/jpeg,image/webp,image/x-icon,image/vnd.microsoft.icon,.ico' : 'image/png,image/jpeg,image/webp'" :aria-label="'Subir ' + imageField.label.toLowerCase()" @change="selectImage(imageField.key, $event)" />
                      </label>
                      <button v-if="selectedImages[imageField.key]" type="button" class="image-text-button" @click="cancelImage(imageField.key)">Cancelar</button>
                      <button v-if="form[imageField.key]" type="button" class="image-remove-button" :aria-label="'Quitar ' + imageField.label.toLowerCase()" :title="'Quitar ' + imageField.label.toLowerCase()" @click="removeImage(imageField.key)"><q-icon name="delete_outline" size="17px" /></button>
                    </div>
                  </div>
                </div>
              </div>
              <label><span>Color primario</span><div class="color-field"><input v-model="form.color_primario" type="color" aria-label="Elegir color primario" /><input v-model="form.color_primario" maxlength="7" /></div></label>
              <label><span>Color secundario</span><div class="color-field"><input v-model="form.color_secundario" type="color" aria-label="Elegir color secundario" /><input v-model="form.color_secundario" maxlength="7" /></div></label>
            </div>
          </div>
        </form>
        <div class="plant-editor-footer"><span v-if="form.id">UUID: {{ form.uuid }}</span><span v-else>Los campos con * son obligatorios.</span><q-btn unelevated icon="save" label="Guardar cambios" class="primary-command" :loading="saving" @click="savePlant" /></div>
      </main>
    </div>
  </q-page>
</template>

<script setup>
import { onMounted, onUnmounted, reactive, ref } from 'vue'
import { apiAssetUrl } from '../services/api.js'
import { loadPlantConfig, persistPlantConfig, persistPlantImages } from '../services/plantConfig.js'

const tabs = [
  { id: 'general', label: 'General' },
  { id: 'contacto', label: 'Contacto' },
  { id: 'direccion', label: 'Dirección' },
  { id: 'localizacion', label: 'Localización' },
  { id: 'identidad', label: 'Identidad' },
]
const imageFields = [
  { key: 'logo', label: 'Logo' },
  { key: 'logo_oscuro', label: 'Logo oscuro' },
  { key: 'favicon', label: 'Favicon' },
]
const emptyPlant = () => ({
  id: null, uuid: null, id_empresa: null, codigo: '', nombre: '', nombre_corto: '',
  descripcion: '', razon_social: '', rfc: '', telefono: '', telefono_secundario: '',
  email: '', sitio_web: '', calle: '', numero_exterior: '', numero_interior: '',
  colonia: '', municipio: '', ciudad: '', estado: '', codigo_postal: '', pais: 'México',
  latitud: null, longitud: null, zona_horaria: 'America/Mexico_City', idioma: 'es-MX',
  moneda: 'MXN', logo: '', logo_oscuro: '', favicon: '', color_primario: '#1683FF',
  color_secundario: '#0D1724', nombre_sistema: 'VELKORYX',
  slogan: 'Industrial Operating System', estatus: true,
})
const form = ref(emptyPlant())
const loading = ref(true)
const saving = ref(false)
const tab = ref('general')
const notice = ref(null)
const selectedImages = reactive({ logo: null, logo_oscuro: null, favicon: null })
const previewUrls = reactive({ logo: null, logo_oscuro: null, favicon: null })

function setForm(plant, keepTab = false) {
  form.value = { ...emptyPlant(), ...plant, estatus: Number(plant.estatus) === 1 }
  if (!keepTab) tab.value = 'general'
}
function imagePreview(field) {
  return previewUrls[field] || apiAssetUrl(form.value[field])
}
function cancelImage(field) {
  if (previewUrls[field]) URL.revokeObjectURL(previewUrls[field])
  previewUrls[field] = null
  selectedImages[field] = null
}
function removeImage(field) {
  cancelImage(field)
  form.value[field] = null
}
function selectImage(field, event) {
  const file = event.target.files?.[0]
  event.target.value = ''
  if (!file) return
  const iconFile = field === 'favicon' && (['image/x-icon', 'image/vnd.microsoft.icon'].includes(file.type) || file.name.toLowerCase().endsWith('.ico'))
  if ((!['image/png', 'image/jpeg', 'image/webp'].includes(file.type) && !iconFile) || file.size > 5 * 1024 * 1024) {
    notice.value = { type: 'error', text: 'Selecciona una imagen PNG, JPG o WebP de hasta 5 MB. El favicon también admite ICO.' }
    return
  }
  cancelImage(field)
  selectedImages[field] = file
  previewUrls[field] = URL.createObjectURL(file)
  notice.value = null
}
async function loadPlant() {
  loading.value = true
  try {
    setForm((await loadPlantConfig()) || emptyPlant())
  } catch (error) {
    notice.value = { type: 'error', text: error.message }
  } finally {
    loading.value = false
  }
}
async function savePlant() {
  if (saving.value) return
  if (!form.value.codigo.trim() || !form.value.nombre.trim()) {
    tab.value = 'general'
    notice.value = { type: 'error', text: 'Código y nombre son obligatorios.' }
    return
  }
  if (!form.value.zona_horaria.trim() || !form.value.idioma.trim() || !form.value.moneda.trim()) {
    tab.value = 'localizacion'
    notice.value = { type: 'error', text: 'Completa zona horaria, idioma y moneda.' }
    return
  }
  if (!form.value.nombre_sistema.trim()) {
    tab.value = 'identidad'
    notice.value = { type: 'error', text: 'El nombre del sistema es obligatorio.' }
    return
  }
  saving.value = true
  let dataSaved = false
  try {
    let saved = await persistPlantConfig(form.value)
    dataSaved = true
    if (imageFields.some(field => selectedImages[field.key])) {
      saved = await persistPlantImages(selectedImages)
    }
    setForm(saved, true)
    imageFields.forEach(field => cancelImage(field.key))
    notice.value = { type: 'success', text: 'Configuración de la planta guardada.' }
  } catch (error) {
    notice.value = { type: 'error', text: dataSaved ? `Datos guardados, imágenes pendientes: ${error.message}` : error.message }
  } finally {
    saving.value = false
  }
}
onMounted(loadPlant)
onUnmounted(() => imageFields.forEach(field => cancelImage(field.key)))
</script>
