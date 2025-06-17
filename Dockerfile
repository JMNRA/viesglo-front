# --- Etapa Base ---
# Usar una imagen Alpine de Node.js con la versión exacta para ligereza y consistencia.
FROM node:22.16.0-alpine AS base
WORKDIR /app
# Habilitar corepack para usar pnpm sin instalación manual.
RUN corepack enable

# --- Etapa de Desarrollo ---
# Esta etapa instala TODAS las dependencias y está optimizada para el desarrollo local.
FROM base AS development
# Copiar manifiestos de paquetes y lockfile para cachear la instalación de dependencias.
COPY package.json pnpm-lock.yaml ./
# Instalar todas las dependencias, incluidas las de desarrollo.
RUN pnpm install
# Copiar el resto del código fuente.
COPY . .
# Exponer el puerto de la aplicación. El puerto de HMR se gestiona en devcontainer.json.
EXPOSE 3000
# El comando por defecto para esta etapa es iniciar el servidor de desarrollo.
CMD ["pnpm", "run", "dev"]

# --- Etapa de Construcción (Builder) ---
# Esta etapa construye la aplicación para producción.
FROM development AS builder
# El código y las dependencias ya están presentes desde la etapa 'development'.
# Generar la salida de producción en el directorio.output.
RUN pnpm run build

# --- Etapa de Producción ---
# Esta etapa crea la imagen final, optimizada y ligera.
FROM base AS production
ENV NODE_ENV=production
# Copiar solo los artefactos de construcción necesarios desde la etapa 'builder'.
COPY --from=builder /app/.output ./.output
# Copiar el package.json para que el servidor de Nuxt pueda acceder a él si es necesario.
COPY --from=builder /app/package.json ./package.json
# Exponer el puerto de producción.
EXPOSE 3000
# Healthcheck para verificar que la aplicación esté funcionando
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/ || exit 1
# El comando por defecto es iniciar el servidor de producción de Nuxt.
CMD ["node", ".output/server/index.mjs"]
