import sequelize from "../../config/db.js";

export const updateCatEquipo = async (req, res, next)=>{
    try {
        const {id, grupo, tipo_equipo, marca, description, modelo, codigoBarras, imagen, estatus} = req.body
        const tokenUser = req.headers['authorization'];

        if (!id || !grupo || !tipo_equipo || !marca || !description || !modelo || !estatus) {
            return res.status(400).json({
				message: 'Faltan parámetros obligatorios: id, grupo, tipo de equipo, marca, descripcion, estatus y modelo, son requeridos',
			});
        }
        
        const [updateEquipo] = await sequelize.query(
			'CALL stp_catEquipoUpdate(:id, :grupo, :tipo_equipo, :marca, :description, :modelo, :codigoBarras, :imagen, :estatus, :tokenUser)',
			{
				replacements: { id, grupo, tipo_equipo, marca, description, modelo, codigoBarras, imagen, estatus, tokenUser},
			}
		);
		res.status(parseInt(updateEquipo['code'],10)).json({
			message: updateEquipo['response'],
			data: updateEquipo,
		});
        
    } catch (error) {
        next(error)
    }
}