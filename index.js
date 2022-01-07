import express from 'express';
import bodyParser from 'body-parser';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

//routes
import { getUsers } from './routes/getUsers.js';
import { getChampions } from "./routes/getChampions.js";
import { getUserClasses } from './routes/getUserClasses.js';
import { getUsersChampions } from './routes/getUsersChampions.js';
import { getAllMissions } from './routes/getAllMissions.js';
import { get10RandomMissions } from './routes/get10RandomMissions.js';
import { getUsersMissions } from './routes/getUsersMissions.js';
import { getAllTrains } from './routes/getAllTrains.js';
import { registerUser } from "./routes/registerUser.js";
import { loginUser } from "./routes/loginUser.js";
import { decodeJwt } from "./routes/decodeJwt.js";
import { updateToken } from "./routes/updateToken.js";
import { chooseClass } from "./routes/chooseClass.js";
import { addUsersChampion } from './routes/addUsersChampion.js';
import { addMissionsToThisUser } from './routes/addMissionsToThisUser.js';
import { startMission } from './routes/startMission.js';
import { startTrain } from './routes/startTrain.js';
import { getUsersTrains } from './routes/getUsersTrains.js';


const app = express();
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const PORT = 5001;
app.use(express.static(path.join(__dirname, '/public')));
app.use(bodyParser.urlencoded({ extended: false }));
app.use(express.json());
app.listen(PORT, () => console.log("Listening in port " + PORT));

//routes
app.get("/getUsers", getUsers);
app.get("/getChampions", getChampions);
app.get("/getUserClasses", getUserClasses);
app.get("/getUsersChampions", getUsersChampions);
app.get("/getAllMissions", getAllMissions);
app.get("/getAllTrains", getAllTrains);
app.get("/get10RandomMissions", get10RandomMissions);
app.get("/getUsersMissions", getUsersMissions);
app.get("/getUsersTrains", getUsersTrains);
app.post("/registerUser", registerUser);
app.post("/loginUser", loginUser);
app.post("/decodeJwt", decodeJwt);
app.post("/updateToken", updateToken);
app.post("/chooseClass", chooseClass);
app.post("/addUsersChampion", addUsersChampion);
app.post("/addMissionsToThisUser", addMissionsToThisUser);
app.post("/startMission", startMission);
app.post("/startTrain", startTrain);

