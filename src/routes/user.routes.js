import express from 'express';
import { getUsers } from '../controllers/users/getUser.controller.js';
import { updateUsers } from '../controllers/users/updateUser.controller.js';
import validateHeaders from '../middleware/validateHeaders.js';

const router = express.Router();

router.get('/', validateHeaders, getUsers);
router.put('/', validateHeaders, updateUsers);

export default router;
