import express from 'express';
export const get10RandomMissions = express.Router();
import pool from './db.js'
const newPool = pool.apply();


get10RandomMissions.get('/get10RandomMissions', async (req, res) => {
    newPool.query("SELECT * FROM missions ORDER BY random() LIMIT 10;", (error, results) => {
        if (error) {
            throw error;
        }
        if (results.rowCount !== 0) {
            results.rows.sort(function(a, b) {
                return a.difficulty - b.difficulty;
             });
            res.status(200).send({ "result": results.rows });
        } else {
            res.status(200).send({ "result": [] });
        }
    });
});
