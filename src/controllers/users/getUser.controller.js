import sequelize from '../../config/db.js';

export const getUsers = async (req, res, next) => {
	try {
		const users = await sequelize.query('CALL stp_usersList()');
		res.json(users);
	} catch (error) {
		next(error);
	}
};
