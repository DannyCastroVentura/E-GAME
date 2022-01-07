import dotenv from 'dotenv';
dotenv.config();
import express from 'express';
import jwt from 'jsonwebtoken';
export const decodeJwt = express.Router();
const jwt_secret = process.env.JWT_SECRET;

decodeJwt.post('/decodeJwt', async (req, res) => {
    const token = req.body.token;
    const decoded = jwt.verify(token, jwt_secret);
    const result = { 'result': true, decoded };
    res.status(200).json(result);
})
