program Serpent;
uses crt;
type coordonnee= record x, y: integer;
                 end;
     fruits= coordonnee;
     corps= array [1..1000] of coordonnee;
     situation= record img: char;
                       dX, dY: integer;
                end;
     top10= array [1..10] of record nom: string;
                                    points: integer;
                             end;
const ventre= 'O';
      mur= 'Û';
      fichier= 'score.t10';
var code, long, vitesse, point, i, X, Y: integer;
    origmode: word;
    touche, touche1, touche2, choix: char;
    condition, retard, pause: boolean;
    frt: fruits;
    cps: corps;
    sit: situation;
    topten: top10;
    F: text;
    lecture: string;

  function perdu(l: integer; c: corps): boolean;
  var X, Y, i: integer;
  begin
    i:= 1; X:= c[l].x; Y:= c[l].y;
    if (X<=8) or (X>=33) or (Y<=5) or (Y>=21) then perdu:= true
    else begin
      while ((c[i].x<>X) or (c[i].y<>Y)) and (i<l-1) do i:= i+1;
      perdu:= ((c[i].x=X) and (c[i].y=Y));
    end;
  end;

  procedure ecrireRecord(tt: top10);
  var i: integer;
      pts: string;
      trouve: boolean;
  begin
    textbackground(lightgray); textcolor(black); trouve:= false;
    for i:= 6 to 20 do begin
      gotoXY(9,i); write('                        '); delay(100);
    end;
    gotoXY(18,7); write('RECORD');
    for i:= 10 downto 1 do begin
      gotoXY(10,8+i);
      if (tt[i].points=point) and (tt[10].points<>point) and (not trouve) then begin
        textcolor(blink); write(tt[i].nom);
        textcolor(black); trouve:= true;
      end
      else write(tt[i].nom);
      str(tt[i].points,pts);
      gotoXY(31-length(pts),8+i); write(' ',pts);
      gotoXY(8,5); delay(100);
    end;
    textbackground(black); textcolor(white);
  end;

  procedure inscription(s: integer; var tt: top10);
  var i, j: integer;
  begin
    i:= 1;
    while (s<=tt[i].points) and (i<=10) do i:= i+1;
    for j:= 9 downto i do begin
      tt[j+1].nom:= tt[j].nom;
      tt[j+1].points:= tt[j].points;
    end;
    tt[i].points:= s;
    gotoXY(9,12); write('Votre nom :             ');
    gotoXY(9,13); write('                        ');
    repeat
      gotoXY(9,13); readln(tt[i].nom);
    until tt[i].nom<>'';
  end;

  procedure rejouer(var ch: char);
  begin
    gotoXY(13,12); write(' Rejouer ? o/n '); gotoXY(8,5);
    repeat ch:= readkey;
    until (upcase(ch)='O') or (upcase(ch)='N');
  end;

  procedure appat(l, p: integer; c: corps; var f: fruits);
  var X, Y, i: integer;
      confondu: boolean;
  begin
    X:= whereX; Y:= whereY;
    randomize;
    repeat
      confondu:= false; i:= 1;
      f.x:= random(24)+9; f.y:= random(15)+6;
      while ((f.x<>c[i].x) or (f.y<>c[i].y)) and (i<l) do i:= i+1;
      confondu:= (f.x=c[i].x) and (f.y=c[i].y);
    until not confondu;
    gotoXY(f.x,f.y);
    if p mod 100 = 90 then
    begin
      textcolor(random(14)+2+blink); write(#2);
    end
    else
    begin
      textcolor(random(14)+2); write(chr(random(4)+3));
    end;
    gotoXY(8,5); sound(440); delay(50); sound(660); delay(50); nosound;
    textcolor(white); gotoXY(X,Y);
  end;

  procedure youlose;
  var i: integer;
  begin
    textcolor(white); textbackground(black);
    gotoXY(13,12);
    if point>topten[1].points then begin
      textcolor(white+blink); write(' NOVEAU RECORD ');
      textcolor(white);
    end
    else write('VOUS AVEZ PERDU');
    gotoXY(8,5);
    i:= 1000;
    while i>=50 do begin
      sound(i); delay(25);
      sound(i+50); delay(25);
      nosound; i:= i-100;
    end;
    readln;
  end;

  procedure attente(v: integer);
  var X, Y: integer;
  begin
    X:= whereX; Y:= whereY;
    gotoXY(8,5);
    sound(1000); delay(10); nosound;
    delay(v);
    gotoXY(X,Y);
  end;

  procedure ecrirePoint(var p,v: integer);
  var X, Y: integer;
  begin
    X:= whereX; Y:= whereY;
    textbackground(black);
    gotoXY(35,4); write(p:5);
    if p>topten[1].points then begin
      gotoXY(1,4); write(p:5);
    end;
    gotoXY(X,Y); textbackground(blue);
    if p mod 100 = 0 then v:= (v*4) div 5;
  end;

  procedure tracer(var l, p, v: integer; var s: situation; var c: corps; var f: fruits; var r: boolean);
  begin
    gotoXY(whereX-1,whereY); write(ventre);
    with s do
    begin
      gotoXY(whereX+dX,whereY+dY); write(img);
    end;
    c[l].x:= whereX-1; c[l].y:= whereY;
    if (f.x=whereX-1) and (f.y=whereY) then
    begin
      r:= true; p:= p+10; appat(l,p,c,f); ecrirePoint(p,v);
    end;
  end;

  procedure detracer(var l: integer; var c: corps; var r: boolean);
  var X, Y, i: integer;
  begin
    if r then
    begin
      l:= l+1; r:= false;
    end
    else
      begin
      X:= whereX; Y:= whereY;
      gotoXY(c[1].x,c[1].y); write(' ');
      gotoXY(X,Y);
      for i:= 2 to l do
      begin
        c[i-1].x:= c[i].x; c[i-1].y:= c[i].y;
      end;
    end;
  end;

  procedure ecrireMenu;
  var X, Y: integer;
  begin
    X:= whereX; Y:= whereY;
    gotoXY(1,23); writeln('<ENTER> Commencer','<BACKSPACE> Pause':20);
    writeln('<ESCAPE> Sortir'); gotoXY(X,Y);
  end;

  procedure ecrireTitre;
  begin
    textcolor(blue);
    gotoXY(9,1); write('ษอออออออออออออออออออออป');
    gotoXY(1,2); write('RECORD','บ ':4);
    textcolor(white); write('LE SERPENT GOURMAND');
    textcolor(blue); write (' บ', 'POINTS':9);
    gotoXY(9,3); writeln('ศอออออออออออออออออออออผ');
    textcolor(white);
    gotoXY(1,4); write(topten[1].points:5);
  end;

Begin
  {$I-}
  assign(F, fichier);
  reset(F); close(F);
  {$I+}
  if IOResult<>0 then
    for i:= 1 to 10 do
      with topten[i] do begin
        nom:= '---'; points:= 0;
      end
  else
  begin
    assign(F, fichier);
    reset(F);
    for i:= 1 to 10 do begin
      readln(F, topten[i].nom);
      readln(F, lecture);
      val(lecture,topten[i].points,code);
    end;
    close(F);
  end;
  origmode:= lastmode;
  clrscr; textmode(1);
  ecrireTitre; ecrireMenu;
  textbackground(black); textcolor(white);
  for i:= 7 to 34 do
  begin
    gotoXY(i,4); write(#220);
    gotoXY(i,5); write(mur);
    gotoXY(i,21); write(mur);
    gotoXY(i,22); write(#223);
  end;
  for i:= 6 to 20 do
  begin
    gotoXY(7,i); write(mur,mur);
    gotoXY(33,i); write(mur,mur);
  end;
  repeat
    long:= 5; vitesse:= 500; point:= 0; retard:= false; pause:= false; choix:='n';
    with sit do
    begin
      img:= #16; dX:= 0; dY:= 0;
    end;
    for i:= 1 to long do
    begin
      cps[i].x:= i+8; cps[i].y:= 6;
    end;

    textbackground(blue);
    for i:= 6 to 20 do begin
      gotoXY(9,i); write('                        ');
      delay(100);
    end;
    gotoXY(cps[1].x,cps[1].y); write(ventre,ventre,ventre,ventre,#16);
    ecrirePoint(point,vitesse);
    gotoXY(whereX,whereY-1);
    repeat touche:= readkey;
    until (touche=#13) or (touche=#27);
    appat(long,point,cps,frt);
    gotoXY(whereX,whereY+1);
    if touche<>#27 then touche:= #77;
    repeat
      while (not KeyPressed) and (not perdu(long,cps)) and (touche<>#27) do
      begin
        if pause= true then
        begin
          X:= whereX; Y:= whereY;
          gotoXY(18,5);
          textbackground(white); textcolor(blink);
          write('PAUSE'); pause:= false;
          repeat touche:= readkey;
          until (touche= #32) or (touche= #27);
          textbackground(blue); textcolor(white);
          gotoXY(18,5); write(mur,mur,mur,mur,mur);
          gotoXY(X,Y);
        end;
        detracer(long,cps,retard);
        tracer(long,point,vitesse,sit,cps,frt,retard);
        attente(vitesse);
      end;
      if perdu(long,cps) then
      begin
        youlose;
        if topten[10].points<point then inscription(point,topten);
        textcolor(white);
        gotoXY(cps[long].x,cps[long].y); write(mur);
        ecrireRecord(topten);
        gotoXY(8,5); readkey;
        rejouer(choix); touche:= #27;
      end
      else if touche<>#27 then
      begin
        touche1:= touche;
        touche:= readkey;
        if touche= #0 then
        begin
          touche2:= readkey; touche:= touche1;
          condition:= (touche2=touche1);
          condition:= condition or ((touche1=#72) and (touche2=#80));
          condition:= condition or ((touche2=#72) and (touche1=#80));
          condition:= condition or ((touche1=#75) and (touche2=#77));
          condition:= condition or ((touche2=#75) and (touche1=#77));
          if not condition then
          begin
            touche:= touche2;
            case touche of #72: with sit do
                                begin
                                  img:= #30; dX:= -1; dY:= -1;
                                end;
                           #75: with sit do
                                begin
                                  img:= #17; dX:= -2; dY:= 0;
                                end;
                           #77: with sit do
                                begin
                                  img:= #16; dX:= 0; dY:= 0;
                                end;
                           #80: with sit do
                                begin
                                  img:= #31; dX:= -1; dY:= 1;
                                end;
            end;
          end;
        end
        else if touche= #32 then pause:= true;
      end;
    until touche= #27;
  until upcase(choix)='N';
  clrscr;
  textmode(origmode);
  assign(F, fichier); rewrite(F);
  for i:= 1 to 10 do
  begin
    writeln(F, topten[i].nom); writeln(F, topten[i].points);
  end;
  close(F);
End.