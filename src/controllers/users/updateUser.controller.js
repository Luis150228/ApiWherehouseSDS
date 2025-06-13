import sequelize from '../../config/db.js';

export const updateUsers = async (req, res, next) => {
	try {
		const { num_user, nombre } = req.body;
		if (!num_user || !nombre) {
			return res.status(400).json({
				message: 'Faltan parámetros obligatorios: user, nombre son requeridos',
			});
		}
		const [updateUser] = await sequelize.query('CALL stp_usersUpdate(:num_user, :nombre)', {
			replacements: { num_user, nombre },
		});
		console.log(res);
		res.status(200).json({
			message: 'Usuario Actualizado correctamente',
			data: updateUser,
		});
	} catch (error) {
		next(error);
	}
};
