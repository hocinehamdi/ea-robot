const express = require('express');
const cors = require('cors');
const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// Simulation State
let robotState = {
    connected: false,
    battery: 100,
    thermalState: 'NOMINAL', // NOMINAL, FAIR, SERIOUS, CRITICAL
    moving: false,
    lastUpdated: Date.now()
};

// 10% chance of random 500 error middleware
app.use((req, res, next) => {
    if (Math.random() < 0.1) {
        console.log(`[SIMULATION] Random 500 Error for ${req.method} ${req.url}`);
        return res.status(500).json({ error: 'Internal Server Error' });
    }
    next();
});

// Middleware to simulate network latency
app.use((req, res, next) => {
    const delay = Math.floor(Math.random() * 500); // 0-500ms delay
    setTimeout(next, delay);
});

// GET /status
app.get('/status', (req, res) => {
    res.json(robotState);
});

// POST /connect
app.post('/connect', (req, res) => {
    robotState.connected = true;
    res.json({ message: 'Connected to robot', status: robotState });
});

// POST /disconnect
app.post('/disconnect', (req, res) => {
    robotState.connected = false;
    robotState.moving = false;
    res.json({ message: 'Disconnected from robot', status: robotState });
});

// POST /move
app.post('/move', (req, res) => {
    if (!robotState.connected) {
        return res.status(400).json({ error: 'Cannot move, robot not connected' });
    }
    console.log('[COMMAND] Move received');
    robotState.moving = true;
    res.json({ message: 'Movement updated', moving: robotState.moving });
});

// POST /stop
app.post('/stop', (req, res) => {
    console.log('[COMMAND] Stop received');
    robotState.moving = false;
    res.json({ message: 'Robot stopped', moving: robotState.moving });
});

// SSE for real-time battery and movement telemetry
app.get('/telemetry', (req, res) => {
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');
    res.flushHeaders();

    console.log('[SSE] Client connected to telemetry');

    const intervalId = setInterval(() => {
        // Drop battery by 0.1% every second
        if (robotState.battery > 0) {
            robotState.battery = parseFloat((robotState.battery - 0.1).toFixed(1));
        }

        // Randomly adjust thermal state if moving
        if (robotState.moving) {
            const states = ['NOMINAL', 'FAIR', 'SERIOUS'];
            robotState.thermalState = states[Math.floor(Math.random() * states.length)];
        } else {
            robotState.thermalState = 'NOMINAL';
        }

        const data = JSON.stringify({
            connected: robotState.connected,
            battery: robotState.battery,
            thermalState: robotState.thermalState,
            moving: robotState.moving,
            timestamp: Date.now()
        });

        res.write(`data: ${data}\n\n`);
    }, 1000);

    req.on('close', () => {
        console.log('[SSE] Client disconnected');
        clearInterval(intervalId);
    });
});

app.listen(port, () => {
    console.log(`Mock Robot API listening at http://localhost:${port}`);
});
