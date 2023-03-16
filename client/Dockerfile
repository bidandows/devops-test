FROM node:19 AS builder

WORKDIR /app


ARG REACT_APP_COMMENTS_API=http://comments.afri-tech.xyz:4005
ARG REACT_APP_POSTS_API=http://posts.afri-tech.xyz:4005
ARG REACT_APP_QUERY_API=http://query.afri-tech.xyz:4005


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