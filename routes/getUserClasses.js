import express from 'express';
export const getUserClasses = express.Router();
import pool from './db.js'
const newPool = pool.apply();


getUserClasses.get('/getUserClasses', async (req, res) => {
    newPool.query("SELECT userClasses.idClass as idClass, userClasses.name as name, userClasses.description, userClasses.healthBoost as healthBoost, userClasses.atackBoost as atackBoost, userClasses.atackSpeedBoost as atackSpeedBoost, userClasses.itemDiscoveryBoost as itemDiscoveryBoost, userClasses.starterChampion as starterChampion, champions.image FROM userClasses inner join champions on userClasses.starterChampion = champions.idChampion", (error, results) => {
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
