import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import sequelize from './src/config/db.js';
import errorHandler from './src/middleware/errorHandler.js';

// Importamos las rutas
import userRoutes from './src/routes/user.routes.js';
// import inventoryRoutes from './src/routes/inventory.routes.js';

// Configuramos las variables de entorno
dotenv.config();

// Inicializamos Express
const app = express();

// Middlewares globales
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

// Health check route
app.get('/health', (req, res) => {
  res.json({ status: 'API Running', version: '1.0.0' });
});

// Rutas de la API
app.use('/api/users', userRoutes);
// app.use('/api/inventory', inventoryRoutes);

// Middleware de manejo de errores
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