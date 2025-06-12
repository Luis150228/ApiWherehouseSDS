const errorHandler = (err, req, res, next) => {
  console.error(err); // Log interno

  res.status(500).json({
    message: 'Ocurrió un error en el servidor',
    error: err.message
  });
};

export default errorHandler;