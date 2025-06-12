import { DataTypes } from 'sequelize';
import sequelize from '../config/db';

// Modelo ejemplo
export const Usuario = sequelize.define('Usuario', {
    nombre: DataTypes.STRING,
    email: DataTypes.STRING
  });