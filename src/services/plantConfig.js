import { shallowRef } from 'vue'
import { getPlantConfiguration, savePlantConfiguration, uploadPlantImages } from './plantas.js'

export const plantConfig = shallowRef(null)
let pendingLoad = null

export function loadPlantConfig() {
  if (!pendingLoad) {
    pendingLoad = getPlantConfiguration()
      .then(result => {
        plantConfig.value = result.data
        return result.data
      })
      .finally(() => { pendingLoad = null })
  }
  return pendingLoad
}

export async function persistPlantConfig(data) {
  const result = await savePlantConfiguration(data)
  plantConfig.value = result.data
  return result.data
}

export async function persistPlantImages(images) {
  const result = await uploadPlantImages(images)
  plantConfig.value = result.data
  return result.data
}
