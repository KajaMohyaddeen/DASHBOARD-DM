const express = require("express");
const mysql = require("mysql2");
const bodyParser = require("body-parser");
const cookieParser = require("cookie-parser");
const app = express();
const port = 3000;
const cors = require('cors');

// app.use(cors({
//   origin: ["http://localhost:3000", "http://127.0.0.1:3000"],
//   credentials: true,
// })); // Add this line
app.use(cors());
app.use(bodyParser.json());
app.use(cookieParser());

// Create a connection to the database
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "kaja1011@",
  database: "Info",
});

// Connect to the database
db.connect((err) => {
  if (err) {
    throw err;
  }
  console.log("MySQL connected...");
});


// app.get("/", (req, res) => {
//   console.log("home sweet home");
// });

// Create a new user
app.post("/adduser", (req, res) => {
  const { name, email, active } = req.body;

  if (active == 1) {
    boolActive = true;
  } else {
    boolActive = false;
  }
  const values = [name, email, boolActive];
  const sql = "INSERT INTO users (name, email,active) VALUES (?, ?,?)";
  console.log(values);

  db.query(sql, values, (err, result) => {
    if (err) {
      return res.status(500).send(err);
    }
  }
  );
  res.send('User added...');
});

// update User Active  status
app.put("/unregister-user", (req, res) => {
  const { email } = req.body;

  const values = [email];
  const sql = "UPDATE users SET active=0 WHERE EMAIL = (?)";
  // console.log(values);

  db.query(sql, values, (err, result) => {
    if (err) {
      return res.status(500).send(err);
    }
    res.send("User updated...");
  });
});

// Get all users
app.get("/users", (req, res) => {
  const sql = "SELECT * FROM users order by name ";
  db.query(sql, (err, results) => {
    if (err) {
      return res.status(500).send(err);
    }
    res.json(results).status(200);
    console.log("all users");
  });
});

// Get a single user by ID
app.get("/user/:id", (req, res) => {
  const sql = "SELECT * FROM users WHERE id = ?";
  db.query(sql, [req.params.id], (err, result) => {
    if (err) {
      return res.status(500).send(err);
    }
    res.json(result);
  });
});

// Get Stats
app.get("/stats", (req, res) => {
  const sql = "SELECT Active,COUNT(ACTIVE) count FROM users GROUP BY Active";
  db.query(sql, [req.params.id], (err, result) => {
    if (err) {
      return res.status(500).send(err);
    }
    res.json(result);
  });
});

// Update a user by ID
app.put("/user/:id", (req, res) => {
  const { name, email } = req.body;
  const sql = "UPDATE users SET name = ?, email = ? WHERE id = ?";
  db.query(sql, [name, email, req.params.id], (err, result) => {
    if (err) {
      return res.status(500).send(err);
    }
    res.send("User updated...");
  });
});

// Delete a user by ID
app.delete("/user/:id", (req, res) => {
  const sql = "DELETE FROM users WHERE id = ?";
  db.query(sql, [req.params.id], (err, result) => {
    if (err) {
      return res.status(500).send(err);
    }
    res.send("User deleted...");
  });
});

// app.listen(port, () => {
//   console.log(`Server running on port ${port}`);
// });

app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on port ${port}`);
});

