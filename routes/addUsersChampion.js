import express from 'express';
export const addUsersChampion = express.Router();
import pool from './db.js'
const newPool = pool.apply();


addUsersChampion.post('/addUsersChampion', async (req, res) => {
    const email = req.body.email;
    const idChampion = parseInt(req.body.idChampion);
    console.log(email, idChampion);
    const query1 = "SELECT * FROM users WHERE email = '" + email + "'";
    newPool.query(query1, (error, results) => {
        if (results.rowCount === 0) {
            const result = { 'result': false };
            res.status(404).json(result);
        } else {
            newPool.query("INSERT INTO usersChampion (email, idChampion) VALUES ('" + email + "', " + idChampion + ")", (error, results) => {
                if (error) {
                    throw error
                }
                const result = { 'result': true };
                res.status(200).json(result);
            });
        }
    });
});
