

module.exports = {
  port: process.env.PORT || 5000,
  mongoUri: process.env.MONGODB_URI ,
  jwtSecret: process.env.JWT_SECRET || 'your_jwt_secret_key_here',
  nodeEnv: process.env.NODE_ENV || 'development',
  allowedFileTypes: [
    'image/png',
    'image/jpeg',
    'image/webp',
    'application/pdf',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'text/csv',
    'application/txt'
  ],
  initialZones: {
    'Zone A': ['Cheezious Headquarters', 'Cheezious I-8', 'Cheezious F-7/1', 'Cheezious F-7/2', 'Cheezious G-9'],
    'Zone B': ['Cheezious F-10', 'Cheezious F-11', 'Cheezious E-11', 'Cheezious WAH CANTT', 'Cheezious G-13', 'Cheezious GOLRA'],
    'Zone C': ['Cheezious SADDAR', 'Cheezious Commercial 1 & 2', 'Cheezious OLD WORKSHOP', 'Cheezious Support Center'],
    'Zone D': ['Cheezious GHAURI TOWN', 'Cheezious TRAMRI', 'Cheezious PWD', 'Cheezious SCHEME 3'],
    'Zone E': ['Cheezious ADYALA', 'Cheezious KALMA', 'Cheezious BAHRIA', 'Cheezious ZARAJ GT ROAD', 'Cheezious GIGA', 'Cheezious Warehouse HUMAK'],
    'Zone F': ['Cheezious PESHAWAR', 'Cheezious MARDAN'],
  }
}; 