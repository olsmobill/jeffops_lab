#!/bin/bash

set -e

echo "⚙️ Creating Next.js frontend in ~/jeffops_lab/frontend"

# 1. Scaffold the Next.js app
npx create-next-app@14 frontend --typescript --no-tailwind --eslint --app

cd frontend

echo "🛠️ Configuring production build and Docker support..."

# 2. Add Dockerfile
cat <<'EOF' > Dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY . .
RUN npm install && npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app ./
EXPOSE 3000
CMD ["npm", "start"]
EOF

# 3. Add NGINX support (optional if needed)
echo "📦 Installing NGINX reverse proxy support (optional via docker-compose later)"

# 4. Add custom production start script to package.json
npm pkg set scripts.start="next start -p 3000"

echo "✅ Next.js frontend scaffolded and Dockerfile added."

# 5. Final tip
echo -e "\n🚀 To build and run:\n"
echo "cd ~/jeffops_lab/frontend"
echo "docker build -t olsmobill/jeffops-frontend:latest ."
echo "docker run -d -p 3002:3000 olsmobill/jeffops-frontend:latest"
