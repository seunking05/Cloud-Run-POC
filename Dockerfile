# Use an official Node.js runtime as a base image
FROM node:18-alpine

# Set the working directory
WORKDIR /usr/src/app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install --production

# Copy the rest of the app
COPY . .

# Expose port 8080 (Cloud Run expects this)
EXPOSE 8080

# Start the app
CMD ["node", "index.js"]
