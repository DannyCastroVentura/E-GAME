import express from 'express';
import pool from './db.js'
const newPool = pool.apply();
export const startTrain = express.Router();

startTrain.post('/startTrain', async (req, res) => {
    const email = req.body.email;
    const idTrain = parseInt(req.body.idTrain);
    const idChampion = parseInt(req.body.idChampion);
    const query1 = "SELECT * FROM users WHERE email = '" + email + "'";
    newPool.query(query1, (error, results) => {
        if (results.rowCount === 0) {
            const result = { 'result': false };
            res.status(404).json(result);
        } else {
            const query2 = "UPDATE userTrain SET idChampion = " + idChampion + ", started = TRUE WHERE email = '" + email + "' and idTrain = " + idTrain;
            newPool.query(query2, (error, results) => {
                if (error) {
                    throw error
                }
                res.status(200).json({ 'result': true });
            });
        }
    });
})
