import express from 'express';
export const getAllTrains = express.Router();
import pool from './db.js'
const newPool = pool.apply();


getAllTrains.get('/getAllTrains', async (req, res) => {
    newPool.query("SELECT *, difficulty.difficulty FROM trains INNER JOIN difficulty ON trains.idDifficulty = difficulty.idDifficulty", (error, results) => {
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
