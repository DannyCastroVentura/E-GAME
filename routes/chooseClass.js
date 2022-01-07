import express from 'express';
import pool from './db.js'
const newPool = pool.apply();
export const chooseClass = express.Router();

chooseClass.post('/chooseClass', async (req, res) => {
    const email = req.body.email;
    const idClass = parseInt(req.body.idClass);
    const query1 = "SELECT * FROM users WHERE email = '" + email + "'";
    newPool.query(query1, (error, results) => {
        if (results.rowCount === 0) {
            const result = { 'result': false };
            res.status(404).json(result);
        } else {
            const query2 = "UPDATE users SET idclass = " + idClass + " WHERE email = '" + email + "'";
            newPool.query(query2, (error, results) => {
                if (error) {
                    throw error
                }
                const result = { 'result': true };
                res.status(200).json(result);
            });
        }
    });
})
