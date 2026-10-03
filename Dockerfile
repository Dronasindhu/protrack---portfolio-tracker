# Stage 1: Build the app
FROM node:18-alpine AS builder
WORKDIR /app

# Copy dependency definitions
COPY package*.json ./

# Install all dependencies (including devDependencies for building)
RUN npm install

# Copy the rest of the application source code
COPY . .

# Build the frontend/project for production
RUN npm run build

# Stage 2: Run the production server
FROM node:18-alpine AS runner
WORKDIR /app

# Copy package files and install production-only dependencies
COPY package*.json ./
RUN npm install --production

# Copy built artifacts and the server script from the builder stage
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/server.ts ./server.ts

# CapRover uses port 3000 by default for container routing
ENV PORT=3000
EXPOSE 3000

# Start the application server
CMD ["npx", "tsx", "server.ts"]