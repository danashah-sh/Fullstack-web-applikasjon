const express = require('express');
const cors = require('cors');
const db = require('./db');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 4000;

// Hent kommende bookings
app.get('/bookings', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT b.*, c.first_name, c.last_name, t.name AS table_name
       FROM bookings b
       LEFT JOIN customers c ON b.customer_id = c.id
       LEFT JOIN restaurant_tables t ON b.table_id = t.id
       WHERE b.booking_time >= now()
       ORDER BY b.booking_time ASC
       LIMIT 200`
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Feil ved henting av bookings' });
  }
});

// Opprett booking
app.post('/bookings', async (req, res) => {
  const { first_name, last_name, email, phone, table_id, booking_time, guests, note } = req.body;

  try {
    // Sjekk om kunden finnes
    let customerResult = await db.query(
      `SELECT id FROM customers WHERE email = $1`,
      [email]
    );

    let customer_id;
    if (customerResult.rows.length > 0) {
      customer_id = customerResult.rows[0].id;
    } else {
      const newCustomer = await db.query(
        `INSERT INTO customers (first_name, last_name, email, phone)
         VALUES ($1, $2, $3, $4) RETURNING id`,
        [first_name, last_name, email, phone]
      );
      customer_id = newCustomer.rows[0].id;
    }

    // Opprett booking
    const bookingResult = await db.query(
      `INSERT INTO bookings (customer_id, table_id, booking_time, guests, note, status)
       VALUES ($1, $2, $3, $4, $5, 'booked') RETURNING *`,
      [customer_id, table_id, booking_time, guests, note]
    );

    res.status(201).json(bookingResult.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Noe gikk galt' });
  }
});

// Login (demo)
app.post('/login', async (req, res) => {
  const { username, password } = req.body;
  try {
    const result = await db.query(
      'SELECT * FROM employees WHERE username = $1 AND password = $2',
      [username, password]
    );

    if (result.rows.length === 1) {
      res.json({ success: true });
    } else {
      res.status(401).json({ success: false });
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Feil ved login' });
  }
});

app.listen(PORT, () => console.log(`Server kjører på port ${PORT}`));
