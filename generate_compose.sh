#!/bin/bash
if [ -e "srcs/docker-compose.yml" ]; then
    sudo rm srcs/docker-compose.yml
fi
cat <<EOF > srcs/docker-compose.yml
services:
  mariadb:
    container_name: mariadb
    env_file: ".env"
    networks:
      - inception
    build:
      context: requirements/mariadb
      dockerfile: Dockerfile
    volumes:
      - mariadb:/var/lib/mysql
    restart: unless-stopped
    expose:
      - "3306"

  nginx:
    container_name: nginx
    volumes:
      - wordpress:/var/www/wordpress
    networks:
      - inception
    depends_on:
      - wordpress
      - mariadb
      - static_web
    build:
     context: requirements/nginx
     dockerfile: Dockerfile
    env_file:
      - .env
    ports:
      - "443:443"
    restart: on-failure

  wordpress:
    container_name: wordpress
    env_file: 
      - .env
    volumes:
      - wordpress:/var/www/wordpress
    networks:
      - inception
    build:
     context: requirements/wordpress
     dockerfile: Dockerfile
    depends_on:
      - mariadb
      - redis
    restart: on-failure
    expose:
      - "9000"

  adminer:
    container_name: adminer
    env_file:
      - .env
    networks:
      - inception
    build:
      context: requirements/bonus/adminer
      dockerfile: Dockerfile
    depends_on:
      - mariadb
    restart: on-failure
    expose :
      - "8080"
    

  static_web:
    container_name: static_web
    env_file:
      - .env
    networks:
      - inception
    build:
      context: requirements/bonus/static_web
      dockerfile: Dockerfile
    restart: on-failure
    expose :
      - "9254"

  grafana:
    container_name: grafana
    env_file:
      - .env
    networks:
      - inception
    depends_on:
      - mariadb
    build:
      context: requirements/bonus/grafana
      dockerfile: Dockerfile
    restart: unless-stopped
    expose :
      - "8878"

  redis:
    container_name: redis
    env_file:
      - .env
    networks:
      - inception
    build:
      context: requirements/bonus/redis
      dockerfile: Dockerfile
    restart: unless-stopped
    expose :
      - "6379"  

  ftp_server:
    container_name: ftp_server
    env_file:
      - .env
    networks:
      - inception
    ports : 
      - "21:21"
      - "21000-21010:21000-21010"
    build:
      context: requirements/bonus/ftp_server
      dockerfile: Dockerfile
    restart: unless-stopped
    depends_on:
      - wordpress
    volumes:
      - wordpress:/var/www/wordpress

volumes:
    wordpress:
      driver: local
      driver_opts:
        type: 'none'
        o: 'bind'
        device: '/home/${USER}/inception_data/wordpress'
    mariadb:
      driver: local
      driver_opts:
        type: 'none'
        o: 'bind'
        device: '/home/${USER}/inception_data/mariadb'

networks:
   inception:
     driver: bridge
EOF
