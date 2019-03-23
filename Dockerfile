FROM node:9-slim
ENV PORT 8080
EXPOSE 8080
WORKDIR /usr/src/app
COPY . .
RUN mkdir -p /home/jenkins/.docker
ADD config.json  /home/jenkins/.docker
RUN  chmod g+rw /home/jenkins/.docker/config.json
CMD ["npm", "start"]
