import app from "../../server";
import { Usuario } from "../models/example.model";

// Endpoint de prueba
app.get('/usuarios', async (req, res) => {
    const usuarios = await Usuario.findAll();
    res.json(usuarios);
  });
  