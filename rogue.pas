uses crt;
const plusinv=3;
Type
  weapon=record
    hand: integer;  //1 - one-handed, 2 - two-handed
    maxdmg:integer;
    mindmg:integer;
    name:string;
  end;

  armor=record
    body:integer;   //2-shield, 3-boots, 4-legs, 5-chest, 6-arms, 7-head
    maxdef:integer;
    mindef:integer;
    name:string;
  end;

  consumable=record
    name:string;
    quan:integer;
  end;

var key: char;     //pressed key buffer
    xh,yh:integer; //floor related Xs/Ys
    f:text;        //level
    x,y:integer;   //character x/y
    gameover:boolean;  //hp=0 then gameover=true
    hp:integer;        //health points max=100 min=0
    namelvl:string;    //stage number converted to string
    filenum:integer;   //stage number as is in file
    level: array [0..1000,0..1000] of char;  //level loaded from file
    lvlvis: array [0..1000,0..1000] of boolean; //visible partsof level
    xmax,ymax:integer;  //resolution of the screen
    monstdet:array [1..1000,1..5] of integer;  //monster Xs/Ys list for fast random-step making and info finding 1-x 2-y 3-lowest possible attack 4-highest possible attack
    monstclo:array[1..1000,1..1000] of boolean;  //is there any monster around main char? fast find out!
    treasex:array [1..1000,1..1000] of boolean;  //is there any chest/treasure around me? fast find out!
    weap: array [1..1000] of weapon;        //random number of damage points taken from interval (mindmg;maxdmg) with each character's attack, name's random, weap[ID]
    arm:array [1..1000] of armor;           //random number of defense points taken from the interval (mindef;maxdef) with each monster's/boss's attack, defense absorbs damage dealt to the character, name's random, arm[ID]
    cons:array [1..1000] of consumable;     //list of consumables, they can be stacked (quan determines quantity in one stack), potions are pre-configured (e.g. small_potion=+5 HP), cons[ID]
    maxinv:integer;             //maximum items that can be put in inventory
    equip: array [1..7] of integer;  //1-right hand, 2-left hand, 3-boots, 4-legs, 5-chest, 6-arms, 7-head; ID determines what is worn, ID number is given when item is picked up, weapons and armor have different IDs

    //NO NEED TO HOLD MONSTER/BOSS/CHEST LOOT!!! IT'S STRENGTH IS LEVEL DEPENDENT AND RANDOM!!!!!
    //BOSSES HAVE HIGHER ATTACK THAN NORMAL MONSTERS, THAT IS THE ONLY DIFFERENCE, NO NEED TO HOLD THAT MONSTER ACTUALLY IS A BOSS!!

procedure roomchng(x1,y1:integer);
begin                                  //minesweeper algorythm + visible area drawing
    textbackground(blue);
    if not(lvlvis[x1,y1]) then begin
      lvlvis[x1,y1]:=true;
      gotoxy(x1,y1);
      write(level[x1,y1]);
      if (level[x1,y1]<>'x') and (not((level[x1,y1]=' ') and (((level[x1,y1+1]='x') and (level[x1,y1-1]='x')) or ((level[x1+1,y1]='x') and (level[x1-1,y1]='x'))))) then begin
        roomchng(x1+1,y1);
        roomchng(x1+1,y1+1);
        roomchng(x1,y1+1);
        roomchng(x1-1,y1+1);
        roomchng(x1-1,y1);
        roomchng(x1-1,y1-1);
        roomchng(x1,y1-1);
        roomchng(x1+1,y1-1);
      end;
    end;
end;

{procedure openinv;}  //menu for inventory!

begin
  clrscr;
  write('Your X resolution? ');
  readln(xmax);
  write('Your Y resolution? ');
  readln(ymax);
  cursoroff;
  gameover:=false;
  assign(f,'1.txt');
  reset(f);
  for yh:=1 to ymax-3 do begin
    for xh:=1 to xmax-1 do begin
      read(f,level[xh,yh]);
      if level[xh,yh]='S' then begin
        x:=xh+1;
        y:=yh;
        level[xh,yh]:=' ';
      end;
    end;
    readln(f,level[xmax,yh]);
    if level[xh,yh]='S' then begin
      x:=xh+1;
      y:=yh;
      level[xh,yh]:=' ';
    end;
  end;
  close(f);
  filenum:=1;
  clrscr;
  roomchng(x,y);
  gotoxy(x,y);
  write('@');
  repeat


    if level[x,y]='U' then begin                              //floor related things
      inc(filenum);                                  //up
      str(filenum,namelvl);
      Textbackground(black);
      clrscr;
      assign(f,namelvl+'.txt');
      reset(f);
      for yh:=1 to ymax-3 do begin
        for xh:=1 to xmax-1 do begin
          read(f,level[xh,yh]);
          if level[xh,yh]='D' then begin
            x:=xh+1;
            y:=yh;
          end;
          if level[xh,yh]='S' then level[xh,yh]:=' ';
        end;
        readln(f,level[xmax,yh]);
        if level[xh,yh]='S' then level[xh,yh]:=' ';
      end;
      close(f);
      For yh:=1 to ymax-3 do begin
        For xh:=1 to xmax do begin
          Lvlvis[xh,yh]:=false;
        End;
      End;
      roomchng(x,y);
      Gotoxy(x,y);
      Write('@');
    end;
    if level[x,y]='D' then begin                      //down
      dec(filenum);
      str(filenum,namelvl);
      Textbackground(black);
      clrscr;
      assign(f,namelvl+'.txt');
      reset(f);
      for yh:=1 to ymax-3 do begin
        for xh:=1 to xmax-1 do begin
          read(f,level[xh,yh]);
          if level[xh,yh]='U' then begin
            x:=xh+1;
            y:=yh;
            if level[xh,yh]='S' then level[xh,yh]:=' ';
          end;
        end;
        readln(f,level[xmax,yh]);
        if level[xh,yh]='S' then level[xh,yh]:=' ';
      end;
      close(f);
      For yh:=1 to ymax-3 do begin
        For xh:=1 to xmax do begin
          Lvlvis[xh,yh]:=false;
        End;
      End;
      roomchng(x,y);
      Gotoxy(x,y);
      Write('@');
    end;


    if keypressed then                                                                    //character action related things
    case readkey of
      'w':begin
        gotoxy(x,y);
        write(' ');
        if (level[x,y-1]=' ') or (level[x,y-1]='U') or (level[x,y-1]='D') then y:=y-1
        else begin                                                                              //monster hit, open chest






        end;
        if ((level[x-1,y]='x') and (level[x+1,y]='x') and (level[x,y]=' ')) or (lvlvis[x,y]=false) then  begin
          textbackground(black);
          clrscr;
          For yh:=1 to ymax-3 do begin
            For xh:=1 to xmax do begin
              Lvlvis[xh,yh]:=false;
            End;
          End;
          roomchng(x,y-1);
        end;
        gotoxy(x,y);
        write('@');
      end;
      'a':begin
        gotoxy(x,y);
        write(' ');
        if (level[x-1,y]=' ') or (level[x-1,y]='U') or (level[x-1,y]='D') then x:=x-1
        else begin                                                                         //monster hit, open chest






        end;
        if ((level[x,y+1]='x') and (level[x,y-1]='x') and (level[x,y]=' ')) or (lvlvis[x,y]=false) then begin
          textbackground(black);
          clrscr;
          For yh:=1 to ymax-3 do begin
            For xh:=1 to xmax do begin
              Lvlvis[xh,yh]:=false;
            End;
          End;
          roomchng(x-1,y);
        end;
        gotoxy(x,y);
        write('@');
      end;
      's':begin
        gotoxy(x,y);
        write(' ');
        if (level[x,y+1]=' ') or (level[x,y+1]='U') or (level[x,y+1]='D') then y:=y+1
        else begin                                                                               //monster hit, open chest






        end;
        if ((level[x-1,y]='x') and (level[x+1,y]='x') and (level[x,y]=' ')) or (lvlvis[x,y]=false) then begin
          textbackground(black);
          clrscr;
          For yh:=1 to ymax-3 do begin
            For xh:=1 to xmax do begin
              Lvlvis[xh,yh]:=false;
            End;
          End;
          roomchng(x,y+1);
        end;
        gotoxy(x,y);
        write('@');
      end;
      'd':begin
        gotoxy(x,y);
        write(' ');
        if (level[x+1,y]=' ') or (level[x+1,y]='U') or (level[x+1,y]='D') then x:=x+1
        else begin                                                                         //monster hit, open chest






        end;
        if ((level[x,y+1]='x') and (level[x,y-1]='x') and (level[x,y]=' ')) or (lvlvis[x,y]=false) then begin
          textbackground(black);
          clrscr;
          For yh:=1 to ymax-3 do begin
            For xh:=1 to xmax do begin
              Lvlvis[xh,yh]:=false;
            End;
          End;
          roomchng(x+1,y);
        end;

                                                                      //monster/boss action related things


        gotoxy(x,y);                                                  //monster/boss and character draw
        write('@');


      end;
    end;
  until gameover;
end.
