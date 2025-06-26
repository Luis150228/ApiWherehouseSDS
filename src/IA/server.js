import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import cookieParser from 'cookie-parser'; // ✅ agregado
import sequelize from './src/config/db.js';
import errorHandler from './src/middleware/errorHandler.js';

// Rutas
import authRoutes from './src/routes/auth.routes.js';
import userRoutes from './src/routes/user.routes.js';
import logger from './src/middleware/logger.js';

dotenv.config();
const app = express();

// Middlewares
app.use(helmet());
app.use(cors({
  origin: 'http://localhost:5173',
  credentials: true
}));
app.use(morgan('dev'));
app.use(express.json());
app.use(cookieParser()); // ✅ agregado

// Rutas
app.get('/health', (req, res) => {
  res.json({ status: 'API Inventario Running', version: '1.0.0' });
});
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);

// Middleware global
app.use(logger)
app.use(errorHandler);

const startServer = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Conectado exitosamente a la base de datos de Inventarios.');

    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
      console.log(`🚀 Servidor escuchando en puerto ${PORT}`);
    });
  } catch (error) {
    console.error('❌ Error al conectar a la base de datos:', error);
    process.exit(1);
  }
};

startServer();