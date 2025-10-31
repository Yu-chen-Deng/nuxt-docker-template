// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },

  vite: {
    server: {
      watch: {
        usePolling: true, // Force polling to detect file changes (for Docker environments)
        interval: 100,    // Check interval (milliseconds)
      },
    },
  },
})
