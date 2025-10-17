const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const app = express();
const db = new sqlite3.Database('./database.db');  // Database lokal

// Inisialisasi database
db.serialize(() => {
  db.run(`CREATE TABLE IF NOT EXISTS tagihan (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    jenis TEXT,
    jumlah REAL,
    status TEXT
  )`);

  // Insert data dummy (jika belum ada)
  db.run("INSERT OR IGNORE INTO tagihan (jenis, jumlah, status) VALUES ('PBB', 100000, 'belum bayar')");
  db.run("INSERT OR IGNORE INTO tagihan (jenis, jumlah, status) VALUES ('Retribusi', 50000, 'belum bayar')");
});

// Endpoint untuk mendapatkan daftar tagihan
app.get('/tagihan', (req, res) => {
  db.all("SELECT * FROM tagihan", [], (err, rows) => {
    if (err) {
      res.status(500).json({ error: err.message });
    } else {
      res.json(rows);
    }
  });
});

// Endpoint untuk membayar tagihan
app.post('/bayar/:id', (req, res) => {
  const id = req.params.id;
  db.run("UPDATE tagihan SET status = 'dibayar' WHERE id = ?", [id], function(err) {
    if (err) {
      res.status(500).json({ error: err.message });
    } else {
      res.json({ message: 'Pembayaran berhasil' });
    }
  });
});

// Jalankan server
app.listen(3000, () => {
  console.log('Server berjalan di http://localhost:3000');
});
