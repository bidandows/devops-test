FROM node:19 AS builder

WORKDIR /app


ARG REACT_APP_COMMENTS_API=https://comments.afri-tech.xyz
ARG REACT_APP_POSTS_API=https://posts.afri-tech.xyz
ARG REACT_APP_QUERY_API=https://query.afri-tech.xyz


ENV REACT_APP_COMMENTS_API=${REACT_APP_COMMENTS_API}
ENV REACT_APP_POSTS_API=${REACT_APP_POSTS_API}
ENV REACT_APP_QUERY_API=${REACT_APP_QUERY_API}

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build


FROM nginx

WORKDIR /usr/share/nginx/html

COPY --from=builder /app/build/ .

CMD [ "nginx", "-g", "daemon off;" ]