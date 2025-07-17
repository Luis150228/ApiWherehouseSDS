import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
// import cookieParser from 'cookie-parser';
import sequelize from './src/config/db.js';
import errorHandler from './src/middleware/errorHandler.js';

// Importamos las rutas
import authRoutes from './src/routes/auth.routes.js';
import userRoutes from './src/routes/user.routes.js';
import catequiposRoutes from './src/routes/catEquipos.routes.js';
import suppliers from './src/routes/supplier.routes.js';
import logger from './src/middleware/logger.js';

// Configuramos las variables de entorno
dotenv.config();

// Inicializamos Express
const app = express();

// Middlewares globales
app.use(helmet());
app.use(cors());
// app.use(cors({
//   origin: 'http://localhost:5173',
//   credentials: true
// }));
app.use(morgan('dev'));
app.use(express.json());
// app.use(cookieParser());

// Health check route
app.get('/health', (req, res) => {
  res.json({ status: 'API Inventario Running', version: '1.0.0' });
});

// Rutas de la API
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/catequipos', catequiposRoutes);
app.use('/api/supplier', suppliers);
// app.use('/api/inventory', inventoryRoutes);

// Middlewares
app.use(logger)
app.use(errorHandler);

// Conexión a la base de datos al iniciar el servidor
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
    process.exit(1); // Sale si falla la conexión
  }
};

startServer();