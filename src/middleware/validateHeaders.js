// src/middleware/validateHeaders.js

const validateHeaders = (req, res, next) => {
	const token = req.headers['token'];
	const dateSend = req.headers['date-send'];

	if (!token || !dateSend) {
		return res.status(400).json({
			message: 'Faltan headers obligatorios: token y date-send',
		});
	}

	// Si quieres, puedes agregar validación adicional aquí:
	// Ejemplo:
	// if (token !== '12345') { ... }

	next();
};

export default validateHeaders;
