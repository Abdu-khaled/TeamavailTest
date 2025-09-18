# slim Node.js image
FROM node:18-slim

# Set working directory 
WORKDIR /app

# Copy package files first for caching
COPY package*.json ./

# Install dependencies
RUN npm install --production


# Copy rest of the app 
COPY . .

# Expose the app port
EXPOSE 3000


# Run the app
CMD [ "node", "sever.js" ]