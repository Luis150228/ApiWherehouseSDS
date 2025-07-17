import sequelize from '../../config/db.js';

export const createSupplier = async (req, res, next) => {
	try {
		const { proveedor, telefono, email, pers_contacto, estatus, observaciones } = req.body;
        const tokenUser = req.headers['authorization'];

		if (!proveedor || !telefono || !pers_contacto) {
			return res.status(400).json({
				message: 'Faltan parámetros obligatorios: nombre proveedor, telefono, email, persona de contacto y observaciones son requeridos',
			});
		}

		const [createSupplier] = await sequelize.query(
			'CALL stp_supplier_create(:proveedor, :telefono, :email, :pers_contacto, :estatus, :observaciones, :tokenUser)',
			{
				replacements: { proveedor, telefono, email, pers_contacto, estatus, observaciones, tokenUser },
			}
		);
		res.status(201).json({
			message: 'Proveedor creado correctamente',
			data: createSupplier,
		});
	} catch (error) {
		next(error);
	}
};