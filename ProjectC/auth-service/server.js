const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

const app = express();
app.use(express.json());

// Mock database
const users = []; // Sostituiscilo con un vero database più tardi

// Endpoint per la registrazione
app.post('/register', async (req, res) => {
    const { username, password } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);
    users.push({ username, password: hashedPassword });
    res.status(201).send('Utente registrato');
});

// Endpoint per il login
app.post('/login', async (req, res) => {
    const { username, password } = req.body;
    const user = users.find(u => u.username === username);
    if (!user || !(await bcrypt.compare(password, user.password))) {
        return res.status(401).send('Credenziali non valide');
    }
    const token = jwt.sign({ username }, 'secret_key', { expiresIn: '1h' });
    res.json({ token });
});

const PORT = 3000;
app.listen(PORT, () => console.log(`Auth Service running on port ${PORT}`));