ALTER SYSTEM SET max_connections TO '100000';

CREATE DATABASE egamedb;

\c egamedb;

/*tables*/
CREATE TABLE IF NOT EXISTS difficulty(
    idDifficulty SERIAL PRIMARY KEY NOT NULL,
    difficulty SMALLINT NOT NULL,    
    earnings NUMERIC NOT NULL,
    duration SMALLINT GENERATED ALWAYS AS ( 2 * difficulty ) STORED
);

CREATE TABLE IF NOT EXISTS missions(
    idMission SERIAL PRIMARY KEY NOT NULL,
    description VARCHAR(100) NOT NULL,
    idDifficulty SMALLINT NOT NULL,
    FOREIGN KEY (idDifficulty)
    REFERENCES difficulty (idDifficulty)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS trains(
    idTrain SERIAL PRIMARY KEY NOT NULL,
    description VARCHAR(100) NOT NULL,
    idDifficulty SMALLINT NOT NULL,
    FOREIGN KEY (idDifficulty)
    REFERENCES difficulty (idDifficulty)
    ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS rarity(
    idRarity SERIAL PRIMARY KEY NOT NULL,
    name VARCHAR(10) NOT NULL,
    perLevelHealth FLOAT NOT NULL,
    perLevelAtack FLOAT NOT NULL,
    perLevelAtackSpeed FLOAT NOT NULL
);

CREATE TABLE IF NOT EXISTS champions(
    idChampion SERIAL PRIMARY KEY NOT NULL,
    name VARCHAR(50) NOT NULL,
    baseHealth float NOT NULL,
    baseAtack float NOT NULL,
    baseAtackSpeed float NOT NULL,
    rarity SMALLINT NOT NULL,
    image VARCHAR(200) NOT NULL,
    FOREIGN KEY (rarity) REFERENCES rarity(idRarity) 
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS userClasses(
    idClass SERIAL PRIMARY KEY NOT NULL,
    name VARCHAR(10),
    description VARCHAR(100),
    healthBoost FLOAT DEFAULT 1,
    atackBoost FLOAT DEFAULT 1,
    atackSpeedBoost FLOAT DEFAULT 1,
    itemDiscoveryBoost FLOAT DEFAULT 1,
    starterChampion INTEGER 
    REFERENCES champions (idChampion)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS users(
    name VARCHAR(50) NOT NULL,
    email VARCHAR(50) PRIMARY KEY NOT NULL,
    password VARCHAR(100) NOT NULL,
    gold BIGINT DEFAULT 0,
    idClass INTEGER
    REFERENCES userClasses (idClass)
);

CREATE TABLE IF NOT EXISTS usersChampion(
    email VARCHAR(50) NOT NULL,
    idChampion INTEGER NOT NULL,
    level SMALLINT DEFAULT 1,
    needeXp FLOAT GENERATED ALWAYS AS ( 100 * ( 1.1^level ) ) STORED,
    actualXp FLOAT DEFAULT 0,
    FOREIGN KEY (idChampion) REFERENCES champions(idChampion) 
    ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (email) REFERENCES users(email) 
    ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (email, idChampion)
);

CREATE TABLE IF NOT EXISTS userMission(
    email VARCHAR(50) NOT NULL,
    idMission INTEGER NOT NULL,
    gold INTEGER,
    xp INTEGER,
    received TIMESTAMP NOT NULL DEFAULT now(),
    started BOOLEAN NOT NULL DEFAULT FALSE,
    timeStarted TIMESTAMP,
    idChampion INTEGER,
    FOREIGN KEY (idChampion, email) REFERENCES usersChampion (idChampion, email)
    ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (email) REFERENCES users (email) 
    ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (idMission) REFERENCES missions (idMission) 
    ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (email, idMission, received)
);

CREATE TABLE IF NOT EXISTS userTrain(
    email VARCHAR(50) NOT NULL,
    idTrain INTEGER NOT NULL,
    idChampion INTEGER,
    xp NUMERIC,
    started BOOLEAN NOT NULL DEFAULT FALSE,
    timeStarted TIMESTAMP,
    FOREIGN KEY (idChampion, email) REFERENCES usersChampion (idChampion, email)
    ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (email) REFERENCES users(email) 
    ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (idTrain) REFERENCES trains(idTrain) 
    ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (email, idTrain)
);


CREATE TABLE IF NOT EXISTS usersDeck(
    idUsersDeck SERIAL PRIMARY KEY NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
    FOREIGN KEY (email) REFERENCES users(email) 
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS usersDeckchampions(
    idUsersDeckchampions SERIAL PRIMARY KEY NOT NULL,
    idUsersDeck INTEGER NOT NULL,    
    FOREIGN KEY (idUsersDeck) REFERENCES usersDeck(idUsersDeck) 
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS perLevelUpgrade(
    idPerLevelUpgrade SERIAL PRIMARY KEY NOT NULL,
    idRarity INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (idRarity) REFERENCES rarity(idRarity)
    ON UPDATE CASCADE ON DELETE CASCADE
);


/*procedures*/
CREATE OR REPLACE FUNCTION updateEarningsOnMissions() RETURNS TRIGGER AS $$
DECLARE
BEGIN
    UPDATE userMission
        SET gold = (random() * difficulty.earnings + 1)
            FROM difficulty 
                JOIN missions
                    ON difficulty.idDifficulty = missions.idDifficulty
                        WHERE userMission.idMission = missions.idMission;

                    
    UPDATE userMission
        SET xp = (difficulty.earnings - userMission.gold)
            FROM difficulty 
                JOIN missions
                    ON difficulty.idDifficulty = missions.idDifficulty
                        WHERE userMission.idMission = missions.idMission;
    RETURN new;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION updateEarningsOnTrains() RETURNS TRIGGER AS $$
DECLARE
BEGIN
    UPDATE userTrain
        SET xp = difficulty.earnings
            FROM difficulty
                JOIN trains
                    ON difficulty.idDifficulty = trains.idDifficulty
                        WHERE userTrain.idTrain = trains.idTrain;
    RETURN new;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION updateTimeStartedOnStartMission() RETURNS TRIGGER AS $$
DECLARE
BEGIN
    IF new.started = TRUE and old.started = FALSE THEN
        UPDATE userMission
            SET timeStarted = NOW()
                WHERE email = new.email and idMission = new.idMission;
    END IF;
    RETURN new;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION updateTimeStartedOnStartTrain() RETURNS TRIGGER AS $$
DECLARE
BEGIN
    IF new.started = TRUE and old.started = FALSE THEN
        UPDATE userTrain
            SET timeStarted = NOW()
                WHERE email = new.email and idTrain = new.idTrain;
    END IF;
    RETURN new;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION insertUserTrainsForEachUserOnUserRegister() RETURNS TRIGGER AS $$
DECLARE
BEGIN
    INSERT INTO userTrain (email, idTrain)
        VALUES (new.email, 1);
    INSERT INTO userTrain (email, idTrain)
        VALUES (new.email, 2);
    INSERT INTO userTrain (email, idTrain)
        VALUES (new.email, 3);
    INSERT INTO userTrain (email, idTrain)
        VALUES (new.email, 4);
    INSERT INTO userTrain (email, idTrain)
        VALUES (new.email, 5);
    RETURN new;
END;
$$ language plpgsql;


/*triggers*/
CREATE TRIGGER trig_updateEarningsOnMissions
    AFTER INSERT ON userMission
        FOR EACH ROW
            EXECUTE PROCEDURE updateEarningsOnMissions();

     
CREATE TRIGGER trig_updateEarningsOnTrains
    AFTER INSERT ON userTrain
        FOR EACH ROW
            EXECUTE PROCEDURE updateEarningsOnTrains();


CREATE TRIGGER trig_updateTimeStartedOnStartMission
    AFTER INSERT OR UPDATE ON userMission
        FOR EACH ROW
            EXECUTE PROCEDURE updateTimeStartedOnStartMission();
            
CREATE TRIGGER trig_updateTimeStartedOnStartTrain
    AFTER INSERT OR UPDATE ON userTrain
        FOR EACH ROW
            EXECUTE PROCEDURE updateTimeStartedOnStartTrain();

CREATE TRIGGER trig_insertUserTrainsForEachUserOnUserRegister
    AFTER INSERT ON users
        FOR EACH ROW
            EXECUTE PROCEDURE insertUserTrainsForEachUserOnUserRegister();

/*rarity*/
INSERT INTO rarity (name, perLevelHealth, perLevelAtack, perLevelAtackSpeed) VALUES ('common', 20, 2, 0.01);
INSERT INTO rarity (name, perLevelHealth, perLevelAtack, perLevelAtackSpeed) VALUES ('uncommon', 25, 2.5, 0.02);
INSERT INTO rarity (name, perLevelHealth, perLevelAtack, perLevelAtackSpeed) VALUES ('rare', 30, 3, 0.03);
INSERT INTO rarity (name, perLevelHealth, perLevelAtack, perLevelAtackSpeed) VALUES ('epic', 35, 3.5, 0.04);
INSERT INTO rarity (name, perLevelHealth, perLevelAtack, perLevelAtackSpeed) VALUES ('legendary', 40, 4, 0.05);
INSERT INTO rarity (name, perLevelHealth, perLevelAtack, perLevelAtackSpeed) VALUES ('mythic', 50, 5, 0.06);


/*champions*/
/*COMMON*/
INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Unarmed henchman', 200, 12, 1.5, 1, './img/champions/sem_bg/capanga-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Axes henchman', 135, 35, 0.7, 1, './img/champions/sem_bg/capanga_com_machados-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Karate henchman', 150, 25, 1, 1, './img/champions/sem_bg/capanga_karateca-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Knife henchman', 150, 20, 1.5, 1, './img/champions/sem_bg/capanga_com_faca-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Baseball henchman', 175, 25, 1, 1, './img/champions/sem_bg/capanga_com_taco_de_basebol-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Bat henchman', 175, 20, 1.2, 1, './img/champions/sem_bg/capanga_com_bastao-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Machete henchman', 165, 27, 1, 1, './img/champions/sem_bg/capanga_com_machete-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Knife Goblin', 120, 15, 2, 1, './img/champions/sem_bg/little_goblin-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Bat', 150, 8, 3, 1, './img/champions/sem_bg/bat-removebg-preview.png');



/*UNCOMMON*/
INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Dual pistols henchman', 150, 40, 1, 2, './img/champions/sem_bg/capanga_com_dual_pistols-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Camouflaged troop', 300, 20, 1, 2, './img/champions/sem_bg/camuflado-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Dark spy', 100, 50, 1, 2, './img/champions/sem_bg/espiao-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Spider', 200, 30, 1.2, 2, './img/champions/sem_bg/aranha-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Ogre', 400, 10, 1, 2, './img/champions/sem_bg/ogre-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Scythe henchman', 175, 35, 1, 2, './img/champions/sem_bg/foice-removebg-preview.png');



/*RARE*/
INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Lion', 300, 40, 1, 3, './img/champions/sem_bg/leao-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Sniper', 175, 100, 0.5, 3, './img/champions/sem_bg/sniper-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Machine gun troop', 300, 15, 2, 3, './img/champions/sem_bg/tropa_com_arma-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Katana troop', 250, 50, 1, 3, './img/champions/sem_bg/swordsman-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Robot', 200, 60, 1, 3, './img/champions/sem_bg/robo-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Giant', 500, 20, 0.7, 3, './img/champions/sem_bg/giant-removebg-preview.png');


/*EPIC*/
INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Greatsword master', 500, 60, 0.7, 4, './img/champions/sem_bg/bigsword-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Xaulin master', 450, 50, 1.2, 4, './img/champions/sem_bg/xauling-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Ninja', 400, 70, 1, 4, './img/champions/sem_bg/ninja-removebg-preview.png');


/*LEGENDARY*/
INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Air bender', 400, 70, 1.5, 5, './img/champions/sem_bg/air_bender-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Force master', 600, 100, 1, 5, './img/champions/sem_bg/darkveider-removebg-preview.png');

INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Force master', 500, 60, 1.2, 5, './img/champions/sem_bg/eletrico-removebg-preview.png');


/*MYTHIC*/
INSERT INTO champions (name, baseHealth, baseAtack, baseAtackSpeed, rarity, image) 
VALUES ('Fallen Angel', 800, 120, 1, 6, './img/champions/sem_bg/anjo-removebg-preview.png');




/*userClasses*/
INSERT INTO userClasses (name, description, healthBoost, starterChampion) VALUES ('Knight', '+ 20% of HP (health points) in every champion you possess', 1.2, 1);
INSERT INTO userClasses (name, description, atackBoost, starterChampion) VALUES ('Barbarian', '+ 20% of AD (atack damage) in every champion you possess', 1.2, 2);
INSERT INTO userClasses (name, description, healthBoost, atackBoost, starterChampion) VALUES ('Fighter', '+ 10% of HP and AD in every champion you possess', 1.1, 1.1, 3);
INSERT INTO userClasses (name, description, atackSpeedBoost, starterChampion) VALUES ('Thief', '+ 20% of AS (atack speed) in every champion you possess', 1.2, 4);
INSERT INTO userClasses (name, description, itemDiscoveryBoost, starterChampion) VALUES ('Scout', '+ 20% of ID (item discovery)', 1.2, 5);
INSERT INTO userClasses (name, description, healthBoost, atackBoost, atackSpeedBoost, itemDiscoveryBoost, starterChampion) VALUES ('Hibrid', '+ 5% of HP, AD, and AS in every champion you possess and + 5% of ID', 1.05, 1.05, 1.05, 1.05, 6);

/*difficulty*/
INSERT INTO difficulty(earnings, difficulty) VALUES (100, 1);
INSERT INTO difficulty(earnings, difficulty) VALUES (150, 2);
INSERT INTO difficulty(earnings, difficulty) VALUES (225, 3);
INSERT INTO difficulty(earnings, difficulty) VALUES (350, 4);
INSERT INTO difficulty(earnings, difficulty) VALUES (525, 5);
INSERT INTO difficulty(earnings, difficulty) VALUES (800, 6);
INSERT INTO difficulty(earnings, difficulty) VALUES (1200, 7);
INSERT INTO difficulty(earnings, difficulty) VALUES (1600, 8);
INSERT INTO difficulty(earnings, difficulty) VALUES (2400, 9);
INSERT INTO difficulty(earnings, difficulty) VALUES (3600, 10);
INSERT INTO difficulty(earnings, difficulty) VALUES (5400, 11);
INSERT INTO difficulty(earnings, difficulty) VALUES (8100, 12);
INSERT INTO difficulty(earnings, difficulty) VALUES (12150, 13);
INSERT INTO difficulty(earnings, difficulty) VALUES (18250, 14);
INSERT INTO difficulty(earnings, difficulty) VALUES (27350, 15);



/*Missions*/
INSERT INTO missions (description, idDifficulty) VALUES ('Kill some slimes', 1);
INSERT INTO missions (description, idDifficulty) VALUES ('Kill a big slime', 1);
INSERT INTO missions (description, idDifficulty) VALUES ('Work in local village', 1);
INSERT INTO missions (description, idDifficulty) VALUES ('Hunt small wild boars', 1);
INSERT INTO missions (description, idDifficulty) VALUES ('Helping citizens with household chores', 1);
INSERT INTO missions (description, idDifficulty) VALUES ('Go fishing', 1);
INSERT INTO missions (description, idDifficulty) VALUES ('Work for thiefs', 1);
INSERT INTO missions (description, idDifficulty) VALUES ('Help the local police', 1);
INSERT INTO missions (description, idDifficulty) VALUES ('Hunt a big wild boar', 2);
INSERT INTO missions (description, idDifficulty) VALUES ('Murder a corrupt politician', 2);
INSERT INTO missions (description, idDifficulty) VALUES ('Go in a fishing tournament', 2);
INSERT INTO missions (description, idDifficulty) VALUES ('Work for pirates', 2);
INSERT INTO missions (description, idDifficulty) VALUES ('Arrest a thief', 2);
INSERT INTO missions (description, idDifficulty) VALUES ('Explore some mines', 2);
INSERT INTO missions (description, idDifficulty) VALUES ('Accompany a hunter to hunt down some beasts.', 2);
INSERT INTO missions (description, idDifficulty) VALUES ('Teach others how to do fishing', 3);
INSERT INTO missions (description, idDifficulty) VALUES ('Help a detective', 3);
INSERT INTO missions (description, idDifficulty) VALUES ('Steal some jewelry', 3);
INSERT INTO missions (description, idDifficulty) VALUES ('Hunt a bear', 3);
INSERT INTO missions (description, idDifficulty) VALUES ('Arrest a pirate', 3);
INSERT INTO missions (description, idDifficulty) VALUES ('Kill a mad goblin', 3);
INSERT INTO missions (description, idDifficulty) VALUES ('Sabotage the thieves headquarters', 3);
INSERT INTO missions (description, idDifficulty) VALUES ('Teach children some self-defense techniques', 3);
INSERT INTO missions (description, idDifficulty) VALUES ('Protect citizens from a gang of ruffians', 3);
INSERT INTO missions (description, idDifficulty) VALUES ('Murder an inexperienced assassin', 3);
INSERT INTO missions (description, idDifficulty) VALUES ('Accompany a hunter to hunt down some wild beasts.', 4);
INSERT INTO missions (description, idDifficulty) VALUES ('Sabotage a pirates headquarters', 4);
INSERT INTO missions (description, idDifficulty) VALUES ('Protect believers on their journey', 4);
INSERT INTO missions (description, idDifficulty) VALUES ('Help some adventures to rescue a friend', 4);
INSERT INTO missions (description, idDifficulty) VALUES ('Explore goblin dungeons', 5);
INSERT INTO missions (description, idDifficulty) VALUES ('Murder an assassin', 5);
INSERT INTO missions (description, idDifficulty) VALUES ('Hunt a rare beast', 5);
INSERT INTO missions (description, idDifficulty) VALUES ('Kidnap an assassin for information', 5);
INSERT INTO missions (description, idDifficulty) VALUES ('Fight in a tournament', 6);
INSERT INTO missions (description, idDifficulty) VALUES ('Burn a small village', 6);
INSERT INTO missions (description, idDifficulty) VALUES ('Explore spider dungeons', 6);
INSERT INTO missions (description, idDifficulty) VALUES ('Murder a head assassin', 7);
INSERT INTO missions (description, idDifficulty) VALUES ('Kill a giant', 7);
INSERT INTO missions (description, idDifficulty) VALUES ('Hunt a warewolf', 7);
INSERT INTO missions (description, idDifficulty) VALUES ('Protect a citizen from an onslaught of assassins', 7);
INSERT INTO missions (description, idDifficulty) VALUES ('Hunt an epic beast', 8);
INSERT INTO missions (description, idDifficulty) VALUES ('Murder an assassin chief', 9);
INSERT INTO missions (description, idDifficulty) VALUES ('Purge documents from a giants village', 9);
INSERT INTO missions (description, idDifficulty) VALUES ('Go to war', 10);
INSERT INTO missions (description, idDifficulty) VALUES ('Discover a werewolf nest ', 10);
INSERT INTO missions (description, idDifficulty) VALUES ('Discover a vampire nest ', 10);
INSERT INTO missions (description, idDifficulty) VALUES ('Steal vampires plans', 11);
INSERT INTO missions (description, idDifficulty) VALUES ('Hunt a legendary beast', 11);
INSERT INTO missions (description, idDifficulty) VALUES ('Hunt a vampire', 11);
INSERT INTO missions (description, idDifficulty) VALUES ('Protect a citizen from an onslaught of giants', 11);
INSERT INTO missions (description, idDifficulty) VALUES ('Steal demons plans from the underworld', 12);
INSERT INTO missions (description, idDifficulty) VALUES ('Steal angels plans', 13);
INSERT INTO missions (description, idDifficulty) VALUES ('Steal demons plans', 13);
INSERT INTO missions (description, idDifficulty) VALUES ('Hunt a mythic beast', 14);
INSERT INTO missions (description, idDifficulty) VALUES ('Kill a dragon', 14);
INSERT INTO missions (description, idDifficulty) VALUES ('Kill some angels', 15);
INSERT INTO missions (description, idDifficulty) VALUES ('Kill some demons', 15);
INSERT INTO missions (description, idDifficulty) VALUES ('Rescue an important wizard from the underworld', 15);


INSERT INTO trains(description, idDifficulty) VALUES ('Resistance training', 1);
INSERT INTO trains(description, idDifficulty) VALUES ('Strength training', 2);
INSERT INTO trains(description, idDifficulty) VALUES ('Weight training', 3);
INSERT INTO trains(description, idDifficulty) VALUES ('Combat training', 4);
INSERT INTO trains(description, idDifficulty) VALUES ('Full training', 7);

