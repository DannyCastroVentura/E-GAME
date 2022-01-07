import express from 'express';
export const getAllMissions = express.Router();
import pool from './db.js'
const newPool = pool.apply();


getAllMissions.get('/getAllMissions', async (req, res) => {
    newPool.query("SELECT * FROM missions", (error, results) => {
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
