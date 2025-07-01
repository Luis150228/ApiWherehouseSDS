import sequelize from "../../config/db.js";

export const getCatequipos = async (req, res, next) => {
    try {
        const listEquipos = await sequelize.query('CALL stp_catEquiposList()');
        res.json(listEquipos)
    } catch (error) {
        next(error)
    }
}

export const getCatequipo = async (req, res, next) => {
    try {
        console.log(req)
        const idequipo = parseInt(req.params.id)
        console.log("Se enviara al SP", idequipo, typeof idequipo)
        const [getEquipo] = await sequelize.query('CALL stp_catEquipo(:idequipo)', {
            replacements: {idequipo}
        });

        if (!getEquipo) {
        return res.status(404).json({ message: 'Equipo no encontrado' });
        }

        res.json(getEquipo)
    } catch (error) {
        console.error('Error SQL :', error)
        next(error)
    }
}