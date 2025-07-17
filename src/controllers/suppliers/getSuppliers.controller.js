import sequelize from "../../config/db.js";

export const getAllSuppliers = async (req, res, next) => {
    try {
        const tokenUser = req.headers['authorization'];
        const listSuppliers = await sequelize.query('CALL stp_supplier_list(:tokenUser)', {
            replacements: {tokenUser}
        });
        res.json(listSuppliers)
    } catch (error) {
        next(error)
    }
}

export const getActiveSuppliers = async (req, res, next) => {
    try {
        const tokenUser = req.headers['authorization'];
        const getSupplierActive = await sequelize.query('CALL stp_supplier_list_active(:tokenUser)', {
            replacements: {tokenUser}
        });

        if (!getSupplierActive) {
        return res.status(404).json({ message: 'No se localizan los proveedores' });
        }

        res.json(getSupplierActive)
    } catch (error) {
        console.error('Error SQL :', error)
        next(error)
    }
}