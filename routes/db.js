import * as pg from 'pg';

const { Pool } = pg.default;

export default function pool (){
    return new Pool({
        user: 'postgres',
        host: 'localhost',
        database: 'egamedb',
        password: '123',
        port: 5433,
    })
}
