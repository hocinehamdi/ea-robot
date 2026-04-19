# Robot Mock API Server

This is a lightweight Node.js Express server designed to mock the status and movement of a humanoid robot. It includes built-in resiliency testing features like random failures and network latency.

## Features
- **Robot State Simulation**: Tracks connection, battery, thermal state, and movement.
- **SSE Telemetry**: Real-time updates via Server-Sent Events.
- **Resiliency Testing**: 
  - 10% chance of returning a `500 Internal Server Error`.
  - Random network latency (0-500ms) on all requests.

## Installation

Ensure you have [Node.js](https://nodejs.org/) installed, then run:

```bash
cd mock_server
npm install
```

## Running the Server

```bash
npm start
```
The server will start at `http://localhost:3000`.

## API Endpoints

**Summary:**
- `GET /status` → `{ connected: boolean, battery: number, moving: boolean }`
- `POST /connect`
- `POST /disconnect`
- `POST /move`
- `POST /stop`

### 1. Robot Status
`GET /status`
- **Response**: Current full state of the robot.
- **Example**:
  ```json
  {
    "connected": true,
    "battery": 98.5,
    "thermalState": "NOMINAL",
    "moving": false
  }
  ```

### 2. Connection Management
`POST /connect`
- **Action**: Sets the robot to `connected`.

`POST /disconnect`
- **Action**: Sets the robot to `disconnected` and stops movement.

### 3. Movement Control
`POST /move`
- **Action**: Sets `moving` to `true`.

`POST /stop`
- **Action**: Sets `moving` to `false`.

### 4. Real-time Telemetry (SSE)
`GET /telemetry`
- **Protocol**: Server-Sent Events (SSE).
- **Stream**: Sends a JSON packet every 1 second containing updated battery, thermal, and movement data.
- **Note**: Use a library like `EventSource` (Web) or a Stream-based client (Flutter) to consume this.

## Simulation Rules
- **Battery Drain**: Decreases by 0.1% every second while the telemetry stream is active.
- **Thermal Logic**: If the robot is `moving`, the thermal state will randomly fluctuate between `NOMINAL`, `FAIR`, and `SERIOUS`.
