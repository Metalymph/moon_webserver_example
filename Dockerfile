# Use Node.js runtime as the base image
FROM node:24-slim

# Set working directory
WORKDIR /app

# Copy the pre-built JavaScript files and dependencies
COPY target/js/release/build/cmd/main/main.js ./main.js
COPY package.json* ./

# Install dependencies if package.json exists
RUN if [ -f package.json ]; then npm install; fi

# Use the existing node user from the base image
RUN chown -R node:node /app

USER node

# Expose port 4000
EXPOSE 4000

# Set the entrypoint to run the JavaScript application
ENTRYPOINT ["node", "main.js"]
