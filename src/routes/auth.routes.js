import express from 'express';
import { login } from '../controllers/log/auth.controller.js';
// import validateHeaders from '../middleware/validateHeaders.js';

const router = express.Router();

// router.post('/', validateHeaders, createUsers);
router.post('/', login);

export default router;
