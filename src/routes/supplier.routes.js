import express from 'express';
import authenticate from '../middleware/authenticate.js';
import { getActiveSuppliers, getAllSuppliers } from '../controllers/suppliers/getSuppliers.controller.js';
import { updateSupplier } from '../controllers/suppliers/update.controller.js';
import { createSupplier } from '../controllers/suppliers/create.controller.js';

const router = express.Router();

router.get('/', authenticate, getActiveSuppliers);
router.get('/any', authenticate, getAllSuppliers);
router.put('/', authenticate, updateSupplier);
router.post('/', authenticate, createSupplier);

export default router;
