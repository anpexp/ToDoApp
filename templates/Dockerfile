# --- build stage ---
FROM node:18-slim AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --quiet || true
COPY . .
# optional build step for frontends; ignore failure if not present
RUN npm run build --if-present || true

# --- runtime ---
FROM node:18-slim
ENV NODE_ENV=production
WORKDIR /app
COPY --from=build /app /app
EXPOSE 3000
CMD ["npm","start"]
