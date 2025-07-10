import sequelize from "../../config/db.js";

export const createCatEquipo = async (req, res, next)=>{
    try {
        const {grupo, tipo_equipo, marca, description, modelo, imagen} = req.body
        const tokenUser = req.headers['authorization'];

        if (!grupo || !tipo_equipo || !marca || !description || !modelo) {
            return res.status(400).json({
				message: 'Faltan parámetros obligatorios: grupo, tipo de equipo, marca, descripcion y modelo, son requeridos',
			});
        }
        
        const [createEquipo] = await sequelize.query(
			'CALL stp_catEquipoCreate(:grupo, :tipo_equipo, :marca, :description, :modelo, :imagen, :tokenUser)',
			{
				replacements: { grupo, tipo_equipo, marca, description, modelo, imagen, tokenUser},
			}
		);
		console.log(res);
		res.status(parseInt(createEquipo['code'],10)).json({
			message: createEquipo['response'],
			data: createEquipo,
		});
        
    } catch (error) {
        next(error)
    }
}