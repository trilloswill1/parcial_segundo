FROM tomcat:8.5.96-jdk8

# Limpia la webapp ROOT por defecto de la imagen oficial
RUN rm -rf /usr/local/tomcat/webapps/ROOT/*

# La app web se despliega como contexto ROOT
COPY . /usr/local/tomcat/webapps/ROOT/

# El entrypoint no debe quedar dentro de la webapp desplegada
RUN rm -f /usr/local/tomcat/webapps/ROOT/docker-entrypoint.sh

# Quita las webapps de ejemplo que trae la imagen
RUN rm -rf /usr/local/tomcat/webapps/docs \
           /usr/local/tomcat/webapps/examples \
           /usr/local/tomcat/webapps/manager \
           /usr/local/tomcat/webapps/host-manager

COPY docker-entrypoint.sh /usr/local/tomcat/docker-entrypoint.sh
RUN chmod +x /usr/local/tomcat/docker-entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/usr/local/tomcat/docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]
