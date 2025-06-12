const logger = (req, res, next) => {
    console.log(`🟢 ${req.method} ${req.originalUrl}`);
    console.log('Body:', req.body);
    console.log('Params:', req.params);
    console.log('Query:', req.query);
    next(); // Sigue al siguiente middleware o controller
  };
  
  export default logger;