import express from 'express';
import { getUsers } from '../controllers/users/getUser.controller.js';
import { updateUsers } from '../controllers/users/updateUser.controller.js';
import validateHeaders from '../middleware/validateHeaders.js';
import { createUsers } from '../controllers/users/create.controller.js';

const router = express.Router();

router.get('/', validateHeaders, getUsers);
router.put('/', validateHeaders, updateUsers);
router.post('/', validateHeaders, createUsers);

export default router;
