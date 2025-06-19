import express from 'express';
import { getUsers } from '../controllers/users/getUser.controller.js';
import { updateUsers } from '../controllers/users/updateUser.controller.js';
import validateHeaders from '../middleware/validateHeaders.js';
import authenticate from '../middleware/authenticate.js';
import { createUsers } from '../controllers/users/create.controller.js';
import { getUserInfo } from '../controllers/users/getUserInfo.controller.js';

const router = express.Router();

router.get('/', authenticate, getUsers);
router.get('/info', authenticate, getUserInfo);
router.put('/', authenticate, updateUsers);
router.post('/', authenticate, createUsers);

export default router;
