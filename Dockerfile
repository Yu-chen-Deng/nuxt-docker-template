FROM node:22-alpine

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Configure CI environment variables to allow non-interactive installation
ENV CI=true

# Allow pnpm to run build scripts (needed for esbuild and other dependencies)
ENV PNPM_ALLOW_BUILD_SCRIPTS=true

# Copy dependency manifests
COPY pnpm-lock.yaml package*.json ./

# Install *all* dependencies (including dev)
# This is required for `pnpm run dev`
RUN pnpm install --frozen-lockfile

# Copy all source code
# (In development mode, this step will be overridden by the volume in docker-compose)
COPY . .

# Receive build parameters from docker-compose
ARG DEV_MODE=false

# Run 'build' only in production mode (for SSR)
# Note: Here we use 'build' instead of 'generate'
RUN if [ "$DEV_MODE" = "false" ]; then \
      echo "Running production build (SSR)..."; \
      pnpm run build; \
    else \
      echo "Skipping production build for dev mode"; \
    fi

# Expose ports (will be overridden by .env and docker-compose)
EXPOSE 3000

# Default command (will be overridden by docker-compose)
CMD ["pnpm", "run", "dev"]