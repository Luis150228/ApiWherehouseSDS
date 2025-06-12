import sequelize from '../../config/db.js';

export const updateUsers = async (req, res, next) => {
    try {
    const {num_user, nombre} = req.body;
    const [updateUser] = await sequelize.query(
        'CALL stp_updateUser(:num_user, :nombre)',
        {
            replacements:{num_user, nombre}
        }
    );
    console.log(res)
    res.json({
        message: "Usuario Actualizado correctamente",
        data: updateUser
    })
  } catch (error) {
    next(error);
  }
};