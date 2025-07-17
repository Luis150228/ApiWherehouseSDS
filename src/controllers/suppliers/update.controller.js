import sequelize from "../../config/db.js";

export const updateSupplier = async (req, res, next)=>{
    try {
        const {id, proveedor, telefono, email, pers_contacto, estatus, observaciones} = req.body
        const tokenUser = req.headers['authorization'];

        if (!id || !proveedor || !telefono || !email || !pers_contacto) {
            return res.status(400).json({
				message: 'Faltan parámetros obligatorios: ID Proveedor, nombre proveedor, telefono, email, persona de contacto y observaciones, son requeridos',
			});
        }
        
        const [updateSupplier] = await sequelize.query(
			'CALL stp_supplier_update(:id, :proveedor, :telefono, :email, :pers_contacto, :estatus, :observaciones, :tokenUser)',
			{
				replacements: { id, proveedor, telefono, email, pers_contacto, estatus, observaciones, tokenUser},
			}
		);
		res.status(parseInt(updateSupplier['code'],10)).json({
			message: updateSupplier['response'],
			data: updateSupplier,
		});
        
    } catch (error) {
        next(error)
    }
}