import express from 'express';
export const addMissionsToThisUser = express.Router();
import pool from './db.js'
const newPool = pool.apply();


addMissionsToThisUser.post('/addMissionsToThisUser', async (req, res) => {
    const email = req.body.email;
    newPool.query("SELECT idMission FROM missions ORDER BY random() LIMIT 10;", async (error, results) => {
        if (error) {
            throw error;
        }
        if (results.rowCount !== 0) {
            let wait = true;
            results.rows.forEach((element, index) => {
                newPool.query("INSERT INTO userMission (email, idMission) VALUES ('" + email + "', " + parseInt(element.idmission) + ");", (error, results2) => {
                    if (error) {
                        throw error;
                    }
                });

                if (index == Object.keys(results.rows).length - 1) {
                    wait = false;
                }
            });
            
            const interval = await setInterval(function () {
                console.log(wait);
                if (wait == false) {
                    clearInterval(interval);
                    res.status(200).send({ "result": true });
                }
            }, 100);
        } else {
            res.status(200).send({ "result": [] });
        }
    });
});
