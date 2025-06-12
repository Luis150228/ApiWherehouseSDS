import { Sequelize } from "sequelize";
import dotenv from "dotenv";

dotenv.config();

if(!process.env.DB_NAME || !process.env.DB_USER || !process.env.DB_PASS || !process.env.DB_HOST){
    throw new Error("Faltan variables de entorno para la conexion con la base de datos")
}

const sequelize = new Sequelize(
    process.env.DB_NAME,
    process.env.DB_USER,
    process.env.DB_PASS,{
    host: process.env.DB_HOST,
    port:process.env.DB_PORT,
    dialect: 'mysql',
    logging: false,
});

export default sequelize