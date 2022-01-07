import express from 'express';
export const getUsersMissions = express.Router();
import pool from './db.js'
const newPool = pool.apply();


getUsersMissions.get('/getUsersMissions', async (req, res) => {
    const email = req.query.email;
    newPool.query("SELECT * FROM users WHERE email = '" + email + "'", (error, results) => {
        if (error) {
            throw error;
        }
        if (results.rowCount !== 0) {
            newPool.query("DELETE FROM userMission WHERE received < (NOW() - interval '1 day') and started = FALSE", (error2, results2) => {
                if (error2) {
                    throw error2;
                }
                newPool.query("SELECT *, userMission.email, userMission.idMission, userMission.received, userMission.started, missions.description, difficulty.difficulty \
                FROM userMission INNER JOIN missions on userMission.idMission = missions.idMission \
                INNER JOIN difficulty on missions.idDifficulty = difficulty.idDifficulty \
                WHERE email = '" + email + "' order by difficulty.difficulty", (error3, results3) => {
                    if (error3) {
                        throw error3;
                    }
                    if (results3.rowCount !== 0) {
                        res.status(200).send({ "result": results3.rows });
                    }else {
                        res.status(200).send({ "result": "[]" });
                    }
                });
            });            
        } else {
            res.status(404).send({ "result": false });
        }
    });
});
