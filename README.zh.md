# nuxt-docker-template [中|[En](/README.md)]

这是一个用于在 Docker 中运行 Nuxt 3/4 (SSR 模式) 的项目模板。

此配置已针对**开发模式**（具有热重载）和**生产模式**（经过优化的 SSR 构建）进行了优化。

## 🚀 部署步骤

该项目使用根目录下的 `.env` 文件来控制运行模式。

### 1\. 开发模式 (Development Mode)

  * **特点：** 启动 `nuxt dev` 服务器，支持代码热重载 (HMR)。
  * **用途：** 日常开发。

<!-- end list -->

1.  **配置 `.env`** 

    确保 `.env` 文件设置为开发模式：

    ```.env
    DEV_MODE=true
    NODE_ENV=development
    PORT=3000

    # 生产模式
    # DEV_MODE=false
    # NODE_ENV=production
    # PORT=80
    ```

2.  **启动服务**

    使用 `docker compose up` 构建并启动容器：

    ```bash
    docker compose up --build
    ```

3.  **访问**

    现在可以在 `http://localhost:3000` 访问你的应用。你本地对 `.vue` 或其他项目文件的任何修改都会立即在浏览器中生效。

### 2\. 生产模式 (Production Mode)

  * **特点：** 运行 `nuxt build` 构建优化的 `.output` 目录，并使用 `node` 直接启动生产服务器。
  * **用途：** 部署到服务器。

<!-- end list -->

1.  **配置 `.env`** 

    确保 `.env` 文件设置为生产模式（将开发模式注释掉）：

    ```.env
    # 开发模式
    # DEV_MODE=true
    # NODE_ENV=development
    # PORT=3000

    # 生产模式
    DEV_MODE=false
    NODE_ENV=production
    PORT=80
    ```

2.  **启动服务**

    使用 `docker compose up` 构建并以分离模式 (`-d`) 启动：

    ```bash
    docker compose up -d --build
    ```

3.  **访问**

    现在可以在 `http://localhost:80` 访问你的生产应用。

### 停止服务

要停止所有正在运行的容器（无论开发还是生产），请运行：

```bash
docker compose down
```

-----

## ⚙️ 它是如何工作的

  * **`.env`** 

      * 这是唯一的控制开关 。`DEV_MODE` 变量  会被 `docker-compose.yml` 读取，并传递到 `Dockerfile` 的构建过程中。

  * **`Dockerfile`** 

      * **多阶段构建逻辑**：使用 `ARG DEV_MODE`，`Dockerfile` 可以在构建时判断是否要运行 `pnpm run build`。
      * 在生产模式下 (`DEV_MODE=false`)，它会构建 `.output` 目录。
      * 在开发模式下，它会跳过 `build` 步骤，以加快启动速度。

  * **`docker-compose.yml`**

      * **`command`**：使用 `if` 语句。如果 `DEV_MODE=true`，它运行 `pnpm run dev`；否则，它运行 `node .output/server/index.mjs` 来启动生产服务器。
      * **`volumes`**：这是实现开发/生产共存的关键：
          * `.:/app`：将本地代码挂载到容器中，实现热重载。
          * `/app/node_modules`：使用**匿名卷**。这会“保护”在 `Dockerfile` 中安装的 `node_modules`，防止它被本地的（可能不存在或不兼容的）`node_modules` 覆盖。
          * `/app/.output`：同样使用**匿名卷**。这会“保护”在 `Dockerfile` **生产构建**时生成的 `.output` 目录，防止它被 `.:/app` 挂载“隐藏”掉。