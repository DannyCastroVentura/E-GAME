import express from 'express';
export const getUsersTrains = express.Router();
import pool from './db.js'
const newPool = pool.apply();


getUsersTrains.get('/getUsersTrains', async (req, res) => {
    const email = req.query.email;
    newPool.query("SELECT * FROM users WHERE email = '" + email + "'", (error, results) => {
        if (error) {
            throw error;
        }
        if (results.rowCount !== 0) {
            newPool.query("SELECT *, userTrain.email, userTrain.idTrain, userTrain.started, trains.description, difficulty.difficulty \
                FROM userTrain INNER JOIN trains on userTrain.idTrain = trains.idTrain \
                INNER JOIN difficulty on trains.idDifficulty = difficulty.idDifficulty \
                WHERE email = '" + email + "' order by difficulty.difficulty", (error3, results3) => {
                if (error3) {
                    throw error3;
                }
                if (results3.rowCount !== 0) {
                    res.status(200).send({ "result": results3.rows });
                } else {
                    res.status(200).send({ "result": "[]" });
                }
            });
        } else {
            res.status(404).send({ "result": false });
        }
    });
});
