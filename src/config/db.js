import { Sequelize } from "sequelize";
import dotenv from "dotenv";

dotenv.config();

const sequelize = new Sequelize(process.env.DB,process.env.USER, process.env.PASS,{
    host: process.env.HOST,
    dialect: 'mariadb',
    logging: false,
});

export default sequelize