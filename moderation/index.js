require('dotenv').config();
const express = require("express");
const bodyParser = require("body-parser");
const axios = require("axios");
const app = express();

app.use(bodyParser.json());

const comments = {};

app.post("/events", async (req, res) => {
  const { type, data } = req.body;

  if (type === "CommentCreated") {
    const status = data.content.includes("orange") ? "rejected" : "approved";
    await axios.post(`${process.env.REACT_EVENT_BUS}/events` || "http://localhost:4005/events", {
      type: "CommentModerated",
      data: { id: data.id, content: data.content, postId: data.postId, status },
    });
  }
});

app.listen(4003, () => {
  console.log("Listening on http://localhost:4003");
});
