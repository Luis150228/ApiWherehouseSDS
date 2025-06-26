import sequelize from '../../config/db.js';
import crypto from 'crypto';
import { generateToken } from '../../utils/token.js';

export const login = async (req, res, next) => {
  try {
    const { user, password } = req.body;

    if (!user || !password) {
      return res.status(400).json({ message: 'Usuario y contraseña son obligatorios' });
    }

    // Buscar usuario usando procedimiento almacenado
    const [usuario] = await sequelize.query('CALL stp_userLogin(:user)', {
      replacements: { user }
    });

    if (!usuario || !usuario.password) {
      return res.status(401).json({ error: 'Usuario no encontrado o sin contraseña' });
    }

    // Comparar SHA2-256 del password ingresado
    const hashedPassword = crypto.createHash('sha256').update(password).digest('hex');

    if (hashedPassword !== usuario.password) {
      return res.status(401).json({ error: 'Contraseña incorrecta' });
    }

    // Generar token y guardarlo
    const token = generateToken({ id: usuario.num_user, user: usuario.user });

    await sequelize.query('CALL stp_userSetToken(:num_user, :token)', {
      replacements: { num_user: usuario.num_user, token }
    });

    // res.json({ token, nombre: usuario.nombre, user: usuario.user });

    // res.cookie('token', token, {
    //   httpOnly: true,
    //   secure: process.env.NODE_ENV === 'production', // solo con HTTPS en producción
    //   sameSite: 'Strict',
    //   maxAge: 3 * 60 * 60 * 1000 // 3 horas
    // });

    // Puedes seguir enviando otros datos si quieres
    res.json({
      nombre: usuario.nombre,
      user: usuario.user,
      token: token,
      mensaje: 'Login exitoso'
    });

  } catch (error) {
    next(error);
  }
};