import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import {GameTeam, GameState, VierGewinntGame} from './game';

const app: Express = express();
const port = 4001;

const games: VierGewinntGame[] = []; 

const gameTicker = setInterval(() => {
    for(let gameIdx = 0; gameIdx < games.length; gameIdx++){
        games[gameIdx].gameTick();
    }
}, 1000);

games.push(new VierGewinntGame(7, 6, 15, 1, {'phoneRed': '+49 1234 5678 - 1', 'phoneBlue': '+49 1234 5678 - 2'}));

app.use(cors({
    origin: '*'
}));

app.use((req: Request, res: Response, next: NextFunction) => {
  console.log(req.originalUrl);
  next();
});

// Webclient (Flutterprojekt) bereitstellen
app.use('/client',express.static('htmlclient'));


app.get('/', (req: Request, res: Response) => {
  res.send('Gameserver');
});

// Infos holen
app.get<{ gameid: number }>('/game/:gameid', (req, res: Response) => {
  res.json(games[req.params.gameid].gameDisplay());
});

// Abstimmen
app.get<{ gameid: number, team: string, ident: string, col: string }>('/game/:gameid/vote/:team/:ident/:col', (req, res: Response) => {
    games[req.params.gameid].vote(req.params.ident, parseInt(req.params.team), parseInt(req.params.col)-1);
    res.json({error:false});
});

// Runde starten
app.get<{ gameid: number }>('/game/:gameid/start', (req, res: Response) => {
    const game = games[req.params.gameid];
    game.initNewRound();
    game.startRound();
    res.json(game.gameDisplay());
});

// Rundenlänge festlegen
app.get<{ gameid: number, interval: string }>('/game/:gameid/time/:interval', (req, res: Response) => {
    const game = games[req.params.gameid];
    game.sectionTimeLimit = parseInt(req.params.interval);
    res.json(game.gameDisplay());
});

// Debugview
app.get<{ gameid: number }>('/game/:gameid/view', (req, res: Response) => {
    const round = games[req.params.gameid].currentRound();

    if(round != null){

        let outstr = "";
        
        outstr += "<table border=\"1\">";
        for(let rowidx = round.game.rows -1; rowidx >= 0; rowidx--){
            outstr += "<tr>";
            for(let colidx = 0; colidx < round.game.columns; colidx++){
                outstr += "<td>";
                switch(round.gamefield[colidx][rowidx]){
                    case GameTeam.teamA: { outstr += "<font color=\"red\">X</font>"; break;}
                    case GameTeam.teamB: { outstr += "<font color=\"blue\">O</font>"; break;}
                    case GameTeam.noTeam: { outstr += "<font color=\"white\">N</font>"; break;}
                }
                outstr += "</td>";
            }
            outstr += "</tr>";
        }
        outstr += "</table>";
        res.send(outstr);
    } else {
        res.send("no round");
    }
});


app.listen(port, () => {
  console.log(`⚡️[server]: Server is running at Port ${port}`);
});