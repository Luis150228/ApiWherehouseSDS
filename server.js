const app = express();
app.use(cors());
app.use(express.json());

// Inicializar
app.listen(3000, () => {
    console.log('API corriendo en puerto 3000');
  });

export default app;