FROM --platform=${BUILDPLATFORM} node:18 AS build

ARG TARGETARCH

WORKDIR /opt/node_app

COPY . .

# do not ignore optional dependencies:
# Error: Cannot find module @rollup/rollup-linux-x64-gnu
RUN --mount=type=cache,target=/root/.cache/yarn \
    npm_config_target_arch=${TARGETARCH} yarn --network-timeout 600000

ARG NODE_ENV=production
ARG PUBLIC_URL=/

RUN npm_config_target_arch=${TARGETARCH} VITE_BASE=${PUBLIC_URL} yarn build:app:docker

FROM nginx:1.27-alpine

ARG PUBLIC_URL=/

COPY --from=build /opt/node_app/excalidraw-app/build /usr/share/nginx/html${PUBLIC_URL}

HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1
