import { apiUrl } from './api.js'

async function request(method, data) {
  const response = await fetch(apiUrl('plantas.php'), {
    method,
    headers: data ? { 'Content-Type': 'application/json' } : undefined,
    body: data ? JSON.stringify(data) : undefined,
  })
  return parseResponse(response)
}

async function parseResponse(response) {
  const result = await response.json().catch(() => null)
  if (!response.ok) {
    throw new Error(result?.message || 'No se pudo conectar con el servidor')
  }
  return result
}

export const getPlantConfiguration = () => request('GET')
export const savePlantConfiguration = data => request('PUT', data)

export async function uploadPlantImages(images) {
  const body = new FormData()
  for (const [field, file] of Object.entries(images)) {
    if (file) body.append(field, file)
  }
  const response = await fetch(apiUrl('planta-imagenes.php'), { method: 'POST', body })
  return parseResponse(response)
}
