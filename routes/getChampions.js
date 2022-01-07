import express from 'express';
export const getChampions = express.Router();
import pool from './db.js'
const newPool = pool.apply();


getChampions.get('/getChampions', async (req, res) => {
    const idChampion = req.query.idChampion;
    newPool.query("SELECT * FROM champions INNER JOIN rarity on champions.rarity = rarity.idRarity WHERE idchampion = " + idChampion, (error, results) => {
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
