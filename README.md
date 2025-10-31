# nuxt-docker-template [[中](/README.zh.md)|En]

This is a project template for running Nuxt 3/4 (SSR mode) in Docker.

This configuration is optimized for both **development mode** (with hot reload) and **production mode** (optimized SSR builds).

## 🚀 Deployment Steps

This project uses the `.env` file in the root directory to control the run mode.

### 1. Development Mode

* **Features:** Starts a `nuxt dev` server with support for hot reload (HMR).

* **Purpose:** Daily development.

<!-- end list -->

1. **Configure `.env`**

Ensure your `.env` file is set to development mode:

```.env
DEV_MODE=true

NODE_ENV=development

PORT=3000

# Production mode

# DEV_MODE=false

# NODE_ENV=production

# PORT=80
```

2. **Start the Service**

Build and start the container using `docker compose up`:

```bash
docker compose up --build
```

3. **Access**

You can now access your application at `http://localhost:3000`. Any changes you make locally to `.vue` or other project files will immediately take effect in your browser.

### 2. Production Mode

* **Features:** Run `nuxt build` to optimize the `.output` directory and start the production server directly using `node`.

* **Purpose:** Deploy to a server.

<!-- end list -->

1. **Configure `.env`**

Ensure the `.env` file is set to production mode (comment out development mode):

```.env
# Development mode

# DEV_MODE=true

# NODE_ENV=development

# PORT=3000

# Production mode

DEV_MODE=false

NODE_ENV=production

PORT=80
```

2. **Start the service**

Build and start the service using `docker compose up` in detached mode (`-d`):

```bash
docker compose up -d --build
```
3. **Access**

You can now access your production application at `http://localhost:80`.

### Stopping Services

To stop all running containers (development or production), run:

```bash
docker compose down
```

-----

## ⚙️ How It Works

* **`.env`**

* This is the only control switch. The `DEV_MODE` variable is read by `docker-compose.yml` and passed to the `Dockerfile` during the build process.

* **`Dockerfile`**

* **Multi-stage build logic**: Using `ARG DEV_MODE`, the `Dockerfile` can determine whether to run `pnpm run build` during the build process.

* In production mode (`DEV_MODE=false`), it builds the `.output` directory.

* In development mode, it skips the `build` step to speed up startup.

* **`docker-compose.yml`**

* **`command`**: Uses `if` statements. If `DEV_MODE=true`, it runs `pnpm run dev`; otherwise, it runs `node .output/server/index.mjs` to start the production server.

* **`volumes`:** This is crucial for enabling development/production coexistence:

* `.:/app`: Mounts local code into the container, enabling hot reloading.

* `/app/node_modules`: Uses **anonymous volumes**. This "protects" the `node_modules` installed in the `Dockerfile` from being overwritten by local (potentially non-existent or incompatible) `node_modules`.

* `/app/.output`: Also uses **anonymous volumes**. This "protects" the `.output` directory generated during the **production build** in the `Dockerfile` from being "hidden" by the `.:/app` mount.