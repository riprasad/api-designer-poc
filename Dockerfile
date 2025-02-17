FROM registry.access.redhat.com/ubi8/nginx-118

USER root

# Install dos2unix utility
RUN yum install -y dos2unix

# Configure certificate and key
RUN mkdir -p /etc/pki/nginx/private && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/pki/nginx/private/server.key -out /etc/pki/nginx/server.crt --batch && \
    chown -R 1001:0 /etc/pki/nginx/ && chmod 755 /etc/pki/nginx/private/server.key /etc/pki/nginx/server.crt && chmod -R g+w /opt/app-root/src

# Copy configuration scripts
COPY --chown=1001:0 build/configs/create-config.sh /usr/local/bin/create-config.sh
COPY --chown=1001:0 build/configs/configure-keycloak.sh /usr/local/bin/configure-keycloak.sh
COPY --chown=1001:0 build/configs/entrypoint.sh /usr/local/bin/entrypoint.sh

# Copy nginx config
COPY --chown=1001:0 build/configs/nginx.conf /etc/nginx/nginx.conf

# To avoid build failure in windows, convert text files from DOS line
# endings (carriage return + line feed) to Unix line endings (line feed).
RUN dos2unix /usr/local/bin/create-config.sh && \
    dos2unix /usr/local/bin/configure-keycloak.sh && \
    dos2unix /usr/local/bin/entrypoint.sh && \
    dos2unix /etc/nginx/nginx.conf

# Copy dist files
COPY --chown=1001:0 dist/ .

# Expose port 8080 for http and 1337 for https
EXPOSE 8080 1337


USER 1001
CMD /usr/local/bin/entrypoint.sh
