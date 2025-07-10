import express from 'express';
import authenticate from '../middleware/authenticate.js';
import { getCatequipo, getCatequipos } from '../controllers/catalogoEquipos/getCatequipos.controller.js';
import { createCatEquipo } from '../controllers/catalogoEquipos/createCatequipos.controller.js';
import { updateCatEquipo } from '../controllers/catalogoEquipos/updateCatequipos.controller.js';

const router = express.Router();

router.get('/', authenticate,getCatequipos );
router.get('/:id', authenticate,getCatequipo );
router.post('/', authenticate, createCatEquipo);
router.put('/', authenticate, updateCatEquipo);

export default router