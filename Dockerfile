# Stage 1: Build Next.js app
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package.json and lock file first to leverage Docker cache
COPY package.json yarn.lock* ./

# Install all dependencies (dev + prod)
RUN yarn install --frozen-lockfile

# Copy the rest of the application
COPY . .

# Build the Next.js app
RUN yarn build
# Stage 2: Production image
FROM node:20-alpine AS runner

WORKDIR /app
# Set environment to production
ENV NODE_ENV=production
# Copy only necessary files from builder
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/public ./public
# Start Next.js in production mode
CMD ["yarn", "start"]