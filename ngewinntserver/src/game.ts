import { randomInt } from "crypto";


export enum GameTeam {teamA, teamB, draw, noTeam};
export enum GameState {started, stopped};
enum GameWinDirection {top, bottom, left, right, topLeft, topRight, bottomLeft, bottomRight};

export class VierGewinntGame {
  columns: number;
  rows: number;
  winLevel: number;
  sectionTimeLimit: number;
  waitTimeSections: number;
  rounds: VierGewinntGameRound[];
  score: Map<GameTeam, number>;
  infos: Object;

  constructor(columns: number, rows: number, sectionTimeLimit: number, waitTimeSections: number, infos: Object){
    this.columns = columns;
    this.rows = rows;
    this.sectionTimeLimit = sectionTimeLimit;
    this.waitTimeSections = waitTimeSections;
    this.winLevel = 4;
    this.rounds = [];
    this.score = new Map<GameTeam, number>;
    this.score.set(GameTeam.teamA, 0);
    this.score.set(GameTeam.teamB, 0);
    this.infos = infos;
  }

  gameTick(){
    const currentRound = this.currentRound();
    if(currentRound != null){
        currentRound.gameTick();
    }
  }

  initNewRound(){
    this.rounds.push(new VierGewinntGameRound(this, this.rounds.length % 2 == 1 ? GameTeam.teamA : GameTeam.teamB));
  }

  startRound(){
    if(this.rounds.length < 1){
        return;
    }

    this.rounds[this.rounds.length -1].startRound();
  }

  vote(identifier: string, team: GameTeam, column: number){
    this.currentRound()?.vote(identifier, team, column);
  }

  currentRound(): VierGewinntGameRound | null {
    return this.rounds.length == 0 ? null : this.rounds[this.rounds.length -1];
  }

  gameDisplay(): Object{
    return {
        columns: this.columns,
        rows: this.rows,
        score: {0: this.score.get(GameTeam.teamA), 1: this.score.get(GameTeam.teamB)},
        currentRound: this.currentRound() == null ? null : this.currentRound()!.gameDisplay(),
        infos: this.infos
    };
  }
}

export class VierGewinntGameRound {
    game: VierGewinntGame;
    state: GameState;
    winner: GameTeam;
    beginner: GameTeam;

    gamefield: number[][];
    sections: VierGewinntGameRoundSection[];

    timeConsumed: number;
    pauseTimeLeft: number;

    constructor(game: VierGewinntGame, beginner: GameTeam){
        this.game = game;
        this.beginner = beginner;
        this.state = GameState.stopped;
        this.winner = GameTeam.noTeam;
        this.pauseTimeLeft = 0;

        this.gamefield = [];
        this.clearGamefield();
        this.sections = [];

        this.timeConsumed = 0;

        console.log("creating game round");
    }

    gameTick(){
        if(this.state == GameState.started){
            this.timeConsumed++;
        
        if(this.pauseTimeLeft > 0){
            this.pauseTimeLeft--;
        } else {
            if(this.sections.length == 0){
                this.sections.push(new VierGewinntGameRoundSection(this, this.beginner));
            } else {
                const currentSection = this.currentSection();
                if(currentSection?.started){
                currentSection!.gameTick();
                if(currentSection?.finished){
                    this.insertCoin(currentSection.votehighest(), currentSection.team);
                    const won = this.checkGameFieldisWon();
                    switch(won){
                        case GameTeam.teamA: {
                            console.log("teamA won");
                            this.game.score.set(GameTeam.teamA, this.game.score.get(GameTeam.teamA)!+1);
                            this.state = GameState.stopped;
                            this.winner = won;
                            break;
                        }
                        case GameTeam.teamB: {
                            console.log("teamB won");
                            this.game.score.set(GameTeam.teamB, this.game.score.get(GameTeam.teamB)!+1);
                            this.state = GameState.stopped;
                            this.winner = won;
                            break;
                        }
                        case GameTeam.draw: {
                            console.log("draw");
                            this.game.score.set(GameTeam.teamA, this.game.score.get(GameTeam.teamA)!+1);
                            this.game.score.set(GameTeam.teamB, this.game.score.get(GameTeam.teamB)!+1);
                            this.state = GameState.stopped;
                            this.winner = won;
                            break;
                        }
                        case GameTeam.noTeam: {
                            this.pauseTimeLeft = this.game.waitTimeSections;
                            const beginner = this.beginner == GameTeam.teamB ? this.sections.length % 2 == 1 ? GameTeam.teamA : GameTeam.teamB : this.sections.length % 2 == 0 ? GameTeam.teamA : GameTeam.teamB;
                            this.sections.push(new VierGewinntGameRoundSection(this, beginner ));
                            break;
                        }
                    }
                }
                } else {
                    currentSection!.started = true;
                }
            }
        }
        }
    }

    clearGamefield() {
        for(let columnnum = 0; columnnum < this.game.columns; columnnum++){
            this.gamefield[columnnum] = [];
            for(let rownum = 0; rownum < this.game.rows; rownum++){
                this.gamefield[columnnum][rownum] = GameTeam.noTeam;
            }   
        }
    }

    startRound(){
        this.pauseTimeLeft = this.game.waitTimeSections;
        this.state = GameState.started;
    }

    // Absolut ineffizient, aber was solls.
    testGameField(posCol: number, posRow: number, checksLeft: number, direction: GameWinDirection): boolean {
        let nextCol: number | undefined;
        let nextRow: number | undefined;
        switch(direction){
            case GameWinDirection.top:         { nextCol = posCol; nextRow = posRow + 1; break; }
            case GameWinDirection.bottom:      { nextCol = posCol; nextRow = posRow - 1; break; }
            case GameWinDirection.left:        { nextCol = posCol - 1; nextRow = posRow; break; }
            case GameWinDirection.right:       { nextCol = posCol + 1; nextRow = posRow; break; }
            case GameWinDirection.topLeft:     { nextCol = posCol - 1; nextRow = posRow + 1; break; }
            case GameWinDirection.topRight:    { nextCol = posCol + 1; nextRow = posRow + 1; break; }
            case GameWinDirection.bottomLeft:  { nextCol = posCol - 1; nextRow = posRow - 1; break; }
            case GameWinDirection.bottomRight: { nextCol = posCol + 1; nextRow = posRow - 1; break; }
        }

        if((nextCol < 0) || (nextRow < 0)) {
            return false;
        }

        if((nextCol >= this.game.columns) || (nextRow >= this.game.rows)) {
            return false;
        }

        if(this.gamefield[posCol][posRow] != this.gamefield[nextCol][nextRow]){
            return false;
        }

        if(checksLeft <= 1){
            return true;
        } else {
            return this.testGameField(nextCol, nextRow, checksLeft - 1, direction);
        }
    }

    checkGameFieldisWon(): GameTeam{
        if(this.possibleColumns().length == 0){
            return GameTeam.draw;
        }

        for(let columnnum = 0; columnnum < this.game.columns; columnnum++){
            //this.gamefield[columnnum] = [];
            for(let rownum = 0; rownum < this.game.rows; rownum++){
                for(let modeidx = 0; modeidx < 8; modeidx++){
                    let fieldval = this.gamefield[columnnum][rownum];
                    if((fieldval == GameTeam.teamA) || (fieldval == GameTeam.teamB)){
                        if(this.testGameField(columnnum, rownum, this.game.winLevel - 1, modeidx)){
                            return fieldval;
                        }
                    }
                }
            }   
        }
        return GameTeam.noTeam;
    }

    insertCoin(colPos: number, gameTeam: GameTeam){
        const possible = this.possibleColumns();
        if(!possible.includes(colPos)){
            return;
        }
        console.log("insert coin to '"+colPos+"' for '"+gameTeam+"'");
        
        for(let rowidx = 0; rowidx < this.game.rows; rowidx++){
            let fieldval = this.gamefield[colPos][rowidx];
            if((fieldval != GameTeam.teamA) && (fieldval != GameTeam.teamB)){
                this.gamefield[colPos][rowidx] = gameTeam;
                break;
            }
        }
    }

    possibleColumns(): number[]{
        let result: number[] = [];
        for(let colidx = 0; colidx < this.game.columns; colidx++){
            let fieldval = this.gamefield[colidx][this.game.rows-1];
            if((fieldval != GameTeam.teamA) && (fieldval != GameTeam.teamB)){
                result.push(colidx);
            }
        }
        return result;
    }

    vote(identifier: string, team: GameTeam, column: number){
        if(this.state == GameState.started){
            this.currentSection()?.vote(identifier, team, column);
        }
    }

    currentSection(): VierGewinntGameRoundSection | null {
        return this.sections.length == 0 ? null : this.sections[this.sections.length -1];
    }

    gameDisplay(): Object {
        return {
            state: this.state,
            winner: this.winner,
            gamefield: this.gamefield,
            timeConsumed: this.timeConsumed,
            currentSection: this.currentSection() == null ? null : this.currentSection()!.gameDisplay(),
        }
    }

}

export class VierGewinntGameRoundSection {
    round: VierGewinntGameRound;
    votes: Map<string, number>;
    possibleColumns: number[];
    team: GameTeam;
    timeLeft: number;
    started: boolean;
    finished: boolean;

    constructor(round: VierGewinntGameRound, team: GameTeam){
        this.round = round;
        this.team = team;
        this.votes = new Map<string, number>;
        this.possibleColumns = round.possibleColumns();
        this.timeLeft = round.game.sectionTimeLimit;
        this.started = false;
        this.finished = false;
    }

    gameTick(){
        if(this.started){
            this.timeLeft--;
            if(this.timeLeft == 0){
                this.finished = true;
            }
        }
    }

    vote(identifier: string, team: GameTeam, column: number){
        if(this.finished){
            return;
        }

        if(team != this.team){
            return false;
        }

        if(this.possibleColumns.includes(column)){
                this.votes.set(identifier, column);
        }
    }

    votehighest(): number{
        const vr = this.voteresult();
        let highest = 0;
        vr.forEach((val, idx) => {
            if(val > highest){
                highest = val;
            }
        });

        console.log("highest '"+highest+"'");

        const resultCanidates: number[] = [];
        vr.forEach((val, idx) => {
            if(val == highest){
                resultCanidates.push(idx);
            }
        });

        if(resultCanidates.length == 1){
            return resultCanidates[0];
        } else {
            return resultCanidates[randomInt(resultCanidates.length)];
        }
    }

    voteresult(): number[]{
        const result: number[] = [];
        for(let colidx = 0; colidx < this.round.game.columns; colidx++){
            result[colidx] = 0;
        }
        this.votes.forEach((val, key) => {
            result[val]++;
        });
        return result;
    }

    gameDisplay(): Object {
        return {
            team: this.team,
            timeLeft: this.timeLeft,
            started: this.started,
            finished: this.finished,
            possible: this.possibleColumns,
            vote: this.voteresult(),
        };
    }
}
