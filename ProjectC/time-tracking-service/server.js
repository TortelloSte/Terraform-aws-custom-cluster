const express = require('express');
const jwt = require('jsonwebtoken');

const app = express();
app.use(express.json());

// Mock database per le ore
const timeEntries = [];

// Middleware di autenticazione
const authenticate = (req, res, next) => {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    if (!token) return res.status(401).send('Accesso negato');
    try {
        req.user = jwt.verify(token, 'secret_key');
        next();
    } catch {
        res.status(400).send('Token non valido');
    }
};

// Endpoint per clock-in
app.post('/clock-in', authenticate, (req, res) => {
    const entry = { user: req.user.username, clockIn: new Date(), clockOut: null };
    timeEntries.push(entry);
    res.status(200).json(entry);
});

// Endpoint per clock-out
app.post('/clock-out', authenticate, (req, res) => {
    const entry = timeEntries.find(e => e.user === req.user.username && !e.clockOut);
    if (!entry) return res.status(400).send('Errore: nessun clock-in trovato');
    entry.clockOut = new Date();
    res.status(200).json(entry);
});

const PORT = 3001;
app.listen(PORT, () => console.log(`Time Tracking Service running on port ${PORT}`));