import express from 'express';
import authenticate from '../middleware/authenticate.js';
import { getCatequipo, getCatequipos } from '../controllers/catalogoEquipos/getCatequipos.controller.js';

const router = express.Router();

router.get('/', authenticate,getCatequipos );
router.get('/:id', authenticate,getCatequipo );

export default router