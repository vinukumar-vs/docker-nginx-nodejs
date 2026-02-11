FROM nginx:alpine

# Backup default NGINX config for later testing
RUN mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak

# Copy custom NGINX config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# NGINX runs in foreground by default in Docker
CMD ["nginx", "-g", "daemon off;"]
