import express from 'express';
export const getUsers = express.Router();
import pool from './db.js'
const newPool = pool.apply();


getUsers.get('/getUsers', async (req, res) => {
    const email = req.query.email;
    newPool.query("SELECT * FROM users WHERE email = '" + email + "'", (error, results) => {
        if (error) {
            throw error;
        }
        if (results.rowCount !== 0) {
            res.status(200).send({ "result": results.rows });
        } else {
            res.status(200).send({ "result": [] });
        }
    });
});
