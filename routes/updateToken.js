import dotenv from 'dotenv';
dotenv.config();
import express from 'express';
import pool from './db.js'
import jwt from 'jsonwebtoken';
export const updateToken = express.Router();
const newPool = pool.apply();
const jwt_secret = process.env.JWT_SECRET;

updateToken.post('/updateToken', async (req, res) => {
    const email = req.body.email;
    const query = "SELECT users.name as name, users.email as email, users.gold as gold, users.idclass as idclass, userClasses.healthboost as healthboost, " +
     "userClasses.atackboost as atackboost, userClasses.atackSpeedBoost as atackSpeedBoost, userClasses.itemdiscoveryboost as itemdiscoveryboost " + 
     "FROM users INNER JOIN userClasses ON users.idclass = userClasses.idclass WHERE users.email = '" + email + "'";
    newPool.query(query, (error, results) => {
        if (error) {
            throw error
        }
        if (results.rowCount !== 0) {
            const idClass = results.rows[0].idclass;
            const token = jwt.sign({
                "name": results.rows[0].name,
                "email": results.rows[0].email,
                "gold": results.rows[0].gold,
                "idClass": idClass,
                "healthBoost": results.rows[0].healthboost,
                "atackBoost": results.rows[0].atackboost,
                "atackSpeedBoost": results.rows[0].atackspeedboost,
                "itemDiscoveryBoost": results.rows[0].itemdiscoveryboost
            }, jwt_secret, { expiresIn: '5h' });
            const result = { 'result': true, token: token, idClass: idClass };
            res.status(200).json(result);
        } else {
            const result = { 'result': false };
            res.status(404).json(result);
        }
    });
})
