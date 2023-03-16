require('dotenv').config();
const express = require("express");
const bodyParser = require("body-parser");
const axios = require("axios");

const app = express();
const events = [];
app.use(bodyParser.json());

app.post("/events", (req, res) => {
  const event = req.body;
  events.push(event);

  axios
    .post(`${process.env.REACT_POSTS_API}/events` || "http://localhost:4000/events", event)
    .catch((err) => console.error(err));
  axios
    .post(`${process.env.REACT_COMMENTS_API}/events` || "http://localhost:4001/events", event)
    .catch((err) => console.error(err));
  axios
    .post(`${process.env.REACT_QUERY_API}/events` || "http://localhost:4002/events", event)
    .catch((err) => console.error(err));
  axios
    .post(` ${process.env.REACT_MODERATION_API}/events` || "http://localhost:4003/events", event)
    .catch((err) => console.error(err));

  res.send({ status: "OK" });
});

app.get("/events", (req, res) => {
  res.send(events);
});

app.listen(4005, () => console.log("Listening on http://localhost:4005"));
