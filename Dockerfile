FROM ghcr.io/astral-sh/uv:latest AS uv


FROM scratch AS model

WORKDIR /app
COPY model ./model
COPY models ./models
COPY README.md LICENSE ./

ARG IMAGE_CREATED
ARG IMAGE_VERSION
ARG IMAGE_REVISION
LABEL org.opencontainers.image.created="${IMAGE_CREATED}" \
      org.opencontainers.image.authors="Jisoo Song <jeesoo9595@snu.ac.kr>" \
      org.opencontainers.image.source="https://github.com/heavyedge/classification-model" \
      org.opencontainers.image.version="${IMAGE_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.title="HeavyEdge Classification Models (model)" \
      org.opencontainers.image.description="Trained model from heavyedge/profile-dataset."


FROM python:slim AS infer
COPY --from=uv /uv /uvx /usr/local/bin/

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY model ./model
COPY models ./models
COPY README.md LICENSE ./

ARG IMAGE_CREATED
ARG IMAGE_VERSION
ARG IMAGE_REVISION
LABEL org.opencontainers.image.created="${IMAGE_CREATED}" \
      org.opencontainers.image.authors="Jisoo Song <jeesoo9595@snu.ac.kr>" \
      org.opencontainers.image.source="https://github.com/heavyedge/classification-model" \
      org.opencontainers.image.version="${IMAGE_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.title="HeavyEdge Classification Models (infer)" \
      org.opencontainers.image.description="Inference environment for heavyedge/classification-model."


FROM python:slim AS dev
COPY --from=uv /uv /uvx /usr/local/bin/

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential ca-certificates curl git jq openssl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

ARG IMAGE_CREATED
ARG IMAGE_VERSION
ARG IMAGE_REVISION
LABEL org.opencontainers.image.created="${IMAGE_CREATED}" \
      org.opencontainers.image.authors="Jisoo Song <jeesoo9595@snu.ac.kr>" \
      org.opencontainers.image.source="https://github.com/heavyedge/classification-model" \
      org.opencontainers.image.version="${IMAGE_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.title="HeavyEdge Classification Models (dev)" \
      org.opencontainers.image.description="Development environment for heavyedge/classification-model."


FROM python:slim AS base
COPY --from=uv /uv /uvx /usr/local/bin/

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --exclude=.* --exclude=_* . .

ARG IMAGE_CREATED
ARG IMAGE_VERSION
ARG IMAGE_REVISION
LABEL org.opencontainers.image.created="${IMAGE_CREATED}" \
      org.opencontainers.image.authors="Jisoo Song <jeesoo9595@snu.ac.kr>" \
      org.opencontainers.image.source="https://github.com/heavyedge/classification-model" \
      org.opencontainers.image.version="${IMAGE_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.title="HeavyEdge Classification Models" \
      org.opencontainers.image.description="Base environment for heavyedge/classification-model."
