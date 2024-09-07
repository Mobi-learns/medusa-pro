# Stage 1: Build the app
FROM node:16-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies without development packages
RUN npm ci --production

# Copy the rest of the application code
COPY . .

# Build the application (if you have a build step, e.g., for React)
# RUN npm run build

# Stage 2: Create the final, smaller image
FROM node:16-alpine

# Set working directory
WORKDIR /app

# Copy only the necessary files from the build stage
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app ./

# Expose the application port
EXPOSE 9000

# Set environment to production
ENV NODE_ENV=production

# Start the application
CMD ["npm", "run", "start"]
