import sequelize from '../../config/db.js';

export const getUserInfo = async (req, res, next) => {
  try {
    const num_user = req.user.id;

    const [info] = await sequelize.query('CALL userGetInfo(:num_user)', {
      replacements: { num_user }
    });

    if (!info) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }

    res.json(info);
  } catch (error) {
    next(error);
  }
};