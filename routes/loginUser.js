import dotenv from 'dotenv';
dotenv.config();
import express from 'express';
import bcrypt from 'bcryptjs';
import pool from './db.js'
import jwt from 'jsonwebtoken';
export const loginUser = express.Router();
const newPool = pool.apply();
const jwt_secret = process.env.JWT_SECRET;

loginUser.post('/loginUser', async (req, res) => {
    const email = req.body.email;
    const password = req.body.password;
    const query = "SELECT * FROM users WHERE email = '" + email + "'";
    newPool.query(query, (error, results) => {
        if (error) {
            throw error
        }
        if (results.rowCount !== 0) {
            bcrypt.compare(password, results.rows[0].password, function (err, resultado) {
                if (resultado) {
                    const idClass = results.rows[0].idclass;
                    if (results.rows[0].idclass == null) {
                        const token = jwt.sign({
                            "name": results.rows[0].name,
                            "email": results.rows[0].email,
                            "gold": results.rows[0].gold,
                            "idClass": idClass
                        }, jwt_secret, { expiresIn: '5h' });
                        const result = { 'result': true, token: token, idClass: idClass };
                        res.status(200).json(result);
                    } else {
                        newPool.query("SELECT * FROM userClasses WHERE idclass = " + parseInt(results.rows[0].idclass), (error2, results2) => {
                            if (error2) {
                                throw error2
                            }
                            const token = jwt.sign({
                                "name": results.rows[0].name,
                                "email": results.rows[0].email,
                                "gold": results.rows[0].gold,
                                "idClass": idClass,
                                "healthBoost": results2.rows[0].healthboost,
                                "atackBoost": results2.rows[0].atackboost,
                                "atackSpeedBoost": results2.rows[0].atackspeedboost,                                
                                "itemDiscoveryBoost": results2.rows[0].itemdiscoveryboost
                            }, jwt_secret, { expiresIn: '5h' });
                            const result = { 'result': true, token: token, idClass: idClass };
                            res.status(200).json(result);
                        });
                    }
                } else {
                    const result = { 'result': false };
                    res.status(401).json(result);
                }
            });
        } else {
            const result = { 'result': false };
            res.status(404).json(result);
        }


    });
})
