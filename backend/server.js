const express = require('express');
const cors = require('cors');
const config = require('./config/config');
const connectDB = require('./utils/database');
const { auth } = require('./middleware/auth');

// Import routes
const userRoutes = require('./routes/userRoutes');
const zoneRoutes = require('./routes/zoneRoutes');
const taskRoutes = require('./routes/taskRoutes');
const announcementRoutes = require('./routes/announcementRoutes');
const assignedTaskRoutes = require('./routes/assignedTaskRoutes');
const ticketRoutes = require('./routes/ticketRoutes');
const fileRoutes = require('./routes/fileRoutes');
const authRoutes = require('./routes/authRoutes');
const locationRoutes = require('./routes/locationRoutes');
const categoryRoutes = require('./routes/categoryRoutes');
const cylinderExpiryRoutes = require('./routes/cylinderExpiryRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const moduleRoutes = require('./routes/moduleRoutes');

// Initialize express appp
const app = express();

// Connect to MongoDB
connectDB();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Root route
app.get('/api', (req, res) => {
  res.json({
    message: 'Sardar Noor Ul Hassan Cloud Intern at Cloudelligent, Deployed Three Tier App with Codepipeline+ECS+ALB through Terraform',
  });
});

// Public routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/modules', moduleRoutes);

// Protected routes
app.use('/api/zones', auth, zoneRoutes);
app.use('/api/tasks', auth, taskRoutes);
app.use('/api/announcements', auth, announcementRoutes);
app.use('/api/assigned-tasks', auth, assignedTaskRoutes);
app.use('/api/tickets', auth, ticketRoutes);
app.use('/api/files', auth, fileRoutes);
app.use('/api/locations', auth, locationRoutes);
app.use('/api/categories', auth, categoryRoutes);
app.use('/api/cylinder-expiry', auth, cylinderExpiryRoutes);
app.use('/api/notifications', auth, notificationRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ 
    message: 'Something went wrong!',
    error: config.nodeEnv === 'development' ? err.message : undefined
  });
});

// Start server
app.listen(config.port, () => {
  console.log(`Server is running on port ${config.port} in ${config.nodeEnv} mode`);
});

//test