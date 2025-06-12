import express from 'express';
import { getUsers } from '../controllers/users/getUser.controller.js';
import { updateUsers } from '../controllers/users/updateUser.controller.js';

const router = express.Router();

router.get('/', getUsers);
router.put('/', updateUsers);

export default router;