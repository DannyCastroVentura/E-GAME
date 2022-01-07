import dotenv from 'dotenv';
import express from 'express';
import bcrypt from 'bcryptjs';
import pool from './db.js'
const newPool = pool.apply();
export const registerUser = express.Router();
dotenv.config();
const saltRounds = parseInt(process.env.SALT_ROUNDS);

registerUser.post('/registerUser', async (req, res) => {
    const name = req.body.name;
    const email = req.body.email;
    const password = req.body.password;
    const query1 = "SELECT * FROM users WHERE email = '" + email + "'";
    newPool.query(query1, (error, results) => {
        if(results.rowCount !== 0){
            const result = {'result': false};
            res.status(409).json(result);
        }else{
            bcrypt.hash(password, saltRounds, function (err, hash) {
                if(err){
                    console.log(err);
                }
                const hashedPassword = hash;    
                const query2 = "INSERT INTO users (name, email, password) VALUES ('" + name + "', '" + email + "', '"+ hashedPassword + "')";
                newPool.query(query2, (error, results) => {
                    if (error) {
                        throw error
                    }
                    const result = {'result': true};
                    res.status(200).json(result);
                });
            });
        }        
    });
})
