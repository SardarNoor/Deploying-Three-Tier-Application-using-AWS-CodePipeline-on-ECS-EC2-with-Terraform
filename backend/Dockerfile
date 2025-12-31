FROM node:18-alpine

WORKDIR /app

# Install deps first (better caching)
COPY package*.json ./
RUN npm ci --omit=dev

# App source
COPY . .

# TLS CA bundle for DocumentDB
# We'll download global-bundle.pem in CodeBuild (recommended) OR keep it in repo under backend/certs/.
# For now assume you commit it to backend/certs/global-bundle.pem
RUN mkdir -p /app/certs

ENV NODE_ENV=production
EXPOSE 5000

CMD ["npm","start"]
