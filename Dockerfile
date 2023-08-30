FROM --platform=$BUILDPLATFORM node:17.7-alpine3.14 AS client-builder
ARG VERSION=23.2
ARG MINOR=2
ARG PATCH=208
ARG BUILD=1534
WORKDIR /app/client
# https://www.oracle.com/database/sqldeveloper/technologies/db-actions/download/#
ADD ords-${VERSION}.${MINOR}.${PATCH}.${BUILD}.zip .
RUN unzip -d /opt/ords ords-${VERSION}.${MINOR}.${PATCH}.${BUILD}.zip
# cache packages in layer
COPY client/package.json /app/client/package.json
COPY client/package-lock.json /app/client/package-lock.json
RUN --mount=type=cache,target=/usr/src/app/.npm \
    npm set cache /usr/src/app/.npm && \
    npm ci
# install
COPY client /app/client
RUN npm run build

FROM golang:1.17-alpine AS builder
ENV CGO_ENABLED=0
WORKDIR /backend
COPY vm/go.* .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go mod download
COPY vm/. .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go build -trimpath -ldflags="-s -w" -o bin/service

FROM alpine:3.15
RUN apk update && apk add --no-cache bash tini openjdk17-jre-headless && \
    mkdir -p /home/sdw/config && \
    echo "sdw:x:1000:1000:sdw:/home/sdw:/bin/bash" >> /etc/passwd && \
    echo "sdw:x:1000:sdw" >> /etc/group

LABEL org.opencontainers.image.title="Oracle SQLDeveloper Web"
LABEL org.opencontainers.image.description="Docker Extension for using an embedded version of Oracle SQLDeveloper Web."
LABEL org.opencontainers.image.vendor="Marcelo Ochoa"
LABEL com.docker.desktop.extension.api.version=">= 0.2.3"
LABEL com.docker.extension.categories="database,utility-tools"
LABEL com.docker.extension.screenshots="[{\"alt\":\"Login Page\", \"url\":\"https://raw.githubusercontent.com/marcelo-ochoa/sdw-docker-extension/main/docs/images/screenshot1.png\"},\
    {\"alt\":\"SQL: Execute queries and scripts, and create database objects\", \"url\":\"https://raw.githubusercontent.com/marcelo-ochoa/sdw-docker-extension/main/docs/images/screenshot2.png\"},\
    {\"alt\":\"REST: Deploy REST APIs for your database\", \"url\":\"https://raw.githubusercontent.com/marcelo-ochoa/sdw-docker-extension/main/docs/images/screenshot3.png\"},\
    {\"alt\":\"JSON: Manage your JSON Document Database\", \"url\":\"https://raw.githubusercontent.com/marcelo-ochoa/sdw-docker-extension/main/docs/images/screenshot4.png\"}]"
LABEL com.docker.extension.publisher-url="https://github.com/marcelo-ochoa/sdw-docker-extension"
LABEL com.docker.extension.additional-urls="[{\"title\":\"Documentation\",\"url\":\"https://github.com/marcelo-ochoa/sdw-docker-extension/blob/main/README.md\"},\
    {\"title\":\"License\",\"url\":\"https://github.com/marcelo-ochoa/sdw-docker-extension/blob/main/LICENSE\"}]"
LABEL com.docker.extension.detailed-description="Docker Extension for using Oracle SQLDeveloper Web"
LABEL com.docker.extension.changelog="See full <a href=\"https://github.com/marcelo-ochoa/sdw-docker-extension/blob/main/CHANGELOG.md\">change log</a>"
LABEL com.docker.desktop.extension.icon="https://raw.githubusercontent.com/marcelo-ochoa/sdw-docker-extension/main/client/public/favicon.ico"
LABEL com.docker.extension.detailed-description="Oracle SQL Developer is a free, integrated development environment that simplifies the development and management of Oracle Database in both traditional and Cloud deployments. \
    SQL Developer offers complete end-to-end development of your PL/SQL applications, a worksheet for running queries and scripts, a DBA console for managing the database, \
    a reports interface, a complete data modeling solution, and a migration platform for moving your 3rd party databases to Oracle."
COPY sdw.svg metadata.json docker-compose.yml ./

COPY --from=client-builder /app/client/dist ui
COPY --from=client-builder /opt/ords /opt/ords
COPY --from=builder /backend/bin/service /
COPY --chown=1000:1000 sdw.sh adb.sh cleanup.sh default.pwd adb.pwd /home/sdw/
RUN  sed -i 's/\${JAVA}/\${JAVA} -Xmx4096m/g' /opt/ords/bin/ords

ENTRYPOINT ["/sbin/tini", "--", "/service", "-socket", "/run/guest-services/sdw-docker-extension.sock"]
