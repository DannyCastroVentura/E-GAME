import express from 'express';
export const getUsersChampions = express.Router();
import pool from './db.js'
const newPool = pool.apply();

getUsersChampions.get('/getUsersChampions', async (req, res) => {
    const email = req.query.email;
    newPool.query("SELECT * FROM usersChampion WHERE email = '" + email + "'", async (error, results) => {
        if (error) {
            throw error;
        }
        if (results.rowCount !== 0) {
            const response = {};
            response.rows = [];
            let wait = true;
            results.rows.forEach(async (element, index) => {
                await newPool.query("SELECT champions.name as Chmpname, * FROM champions INNER JOIN rarity on champions.rarity = rarity.idRarity WHERE idchampion = " + element.idchampion, async (error, results2) => {
                    if (error) {
                        throw error;
                    }
                    if (results2.rowCount !== 0) {
                        element.champion = JSON.stringify(results2.rows);
                        delete element.idchampion;
                        delete element.email;
                        response.rows[index] = element;
                    } else {
                        res.status(200).send({ "result": [] });
                    }
                    if (index == Object.keys(results.rows).length - 1) {
                        wait = false;
                    }
                });
            });
            const interval = await setInterval(function () {
                if (wait == false) {
                    clearInterval(interval);
                    console.log(response);
                    res.status(200).send(response);
                }
            }, 10);
        } else {
            res.status(200).send({ "result": [] });
        }
    });
});
