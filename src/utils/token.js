import jwt from 'jsonwebtoken';
import {v4 as uuidv4} from 'uuid'

const SECRET_KEY = process.env.JWT_SECRET || 'eutW@rehouse';

export const generateToken = (payload) => {
  return jwt.sign(payload, SECRET_KEY, { expiresIn: '6h', jwtid: uuidv4() });
};

export const verifyToken = (token) => {
  return jwt.verify(token, SECRET_KEY);
};