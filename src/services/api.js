const baseUrl = import.meta.env.VITE_API_BASE_URL

export function apiUrl(path) {
  if (!baseUrl) {
    throw new Error('Configura VITE_API_BASE_URL en .env.local')
  }

  return new URL(path.replace(/^\/+/, ''), baseUrl.endsWith('/') ? baseUrl : `${baseUrl}/`).toString()
}

export function apiAssetUrl(path) {
  if (!path) return null
  return /^https?:\/\//i.test(path) ? path : apiUrl(path)
}
