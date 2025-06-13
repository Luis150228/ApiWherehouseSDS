import sequelize from '../../config/db.js';

export const createUsers = async (req, res, next) => {
	try {
		const { user, nombre, ubicacion, tipo_almacen, nivel, ctrl_acceso, puesto, password, estatus } = req.body;

		if (!user || !nombre || !password) {
			return res.status(400).json({
				message: 'Faltan parámetros obligatorios: user, nombre y password son requeridos',
			});
		}

		const [createUser] = await sequelize.query(
			'CALL stp_usersCreate(:user, :nombre, :ubicacion, :tipo_almacen, :nivel, :ctrl_acceso, :puesto, :password, :estatus)',
			{
				replacements: { user, nombre, ubicacion, tipo_almacen, nivel, ctrl_acceso, puesto, password, estatus },
			}
		);
		console.log(res);
		res.status(201).json({
			message: 'Usuario creado correctamente',
			data: createUser,
		});
	} catch (error) {
		next(error);
	}
};
