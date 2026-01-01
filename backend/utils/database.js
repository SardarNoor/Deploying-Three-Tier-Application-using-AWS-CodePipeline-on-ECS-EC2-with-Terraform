const mongoose = require('mongoose');
const config = require('../config/config');

const connectDB = async () => {
  try {
    console.log('Attempting to connect to MongoDB...');
    console.log('Value of process.env.MONGODB_URI:', process.env.MONGODB_URI);
    console.log('Value of config.mongoUri:', config.mongoUri);
    await mongoose.connect(config.mongoUri, {
  tls: true,
  tlsCAFile: '/app/certs/global-bundle.pem',
  retryWrites: false,
  serverSelectionTimeoutMS: 5000,
});

    console.log('MongoDB connected successfully');

    console.log('Connected database name:', mongoose.connection.db.databaseName);
    
    // Initialize GridFS bucket
    global.gridfsBucket = new mongoose.mongo.GridFSBucket(mongoose.connection.db, {
      bucketName: 'uploads'
    });
  } catch (error) {
    console.error('MongoDB connection error:', error);
    process.exit(1);
  }
};

module.exports = connectDB; 