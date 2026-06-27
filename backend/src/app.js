const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth.routes');
const liftingRoutes = require('./routes/lifting.routes');
const foodRoutes = require('./routes/food.routes');
const cardioRoutes = require('./routes/cardio.routes');
const bodyWeightRoutes = require('./routes/bodyweight.routes');
const dashboardRoutes = require('./routes/dashboard.routes');
const tipsRoutes = require('./routes/tips.routes');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/lifting', liftingRoutes);
app.use('/api/food', foodRoutes);
app.use('/api/cardio', cardioRoutes);
app.use('/api/bodyweight', bodyWeightRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/tips', tipsRoutes);

app.get('/', (req, res) => {
  res.send('Hybrid Athlete Tracker API is running');
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ success: false, error: err.message || 'Internal Server Error' });
});

module.exports = app;
