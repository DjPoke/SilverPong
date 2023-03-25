// SilverPong
// by retro-Bruno
// [c)2013-2020
// https://retro-bruno.fr


// montrer les erreurs
SetErrorMode(2)

// constantes
#Constant FPS = 30
#Constant Noise1Volume = 40

#Constant NOCONTROL = 0
#Constant KEYBOARDCONTROL = 1
#Constant JOYSTICKCONTROL = 2
#Constant MOUSECONTROL = 3

//
global control = NOCONTROL

// pixel art
SetDefaultMagFilter(0)
SetDefaultMinFilter(0)

// importer les médias
mus = LoadMusicOGG("music.ogg")
reb = LoadSound("rebond.wav")
people = LoadSound("foule.wav")
ready = LoadSound("ready.wav")
go = LoadSound("go.wav")
youwin = LoadSound("youwin.wav")
youloosed = LoadSound("youloosed.wav")
noise1 = LoadSound("noise1.wav")
itimg = LoadImage("intro.jpg")
bgimg = LoadImage("background.jpg")
bhimg = LoadImage("barreh.jpg")
bbimg = LoadImage("barreb.jpg")
btgimg = LoadImage("batteg.png")
btdimg = LoadImage("batted.png")
ballimg = LoadImage("balle.png")
smokeimg = LoadImage("fumee.png")

colimg = CreateImageColor(255, 255, 0, 100)
batteimg = CreateImageColor(255, 255, 255, 70)

// propriétés de la fenêtre
SetWindowTitle("SilverPong")
SetWindowSize(800, 600, 1)
SetWindowAllowResize(0)

// propriétés d'affichage
SetVirtualResolution(800, 600)
SetOrientationAllowed(0, 0, 1, 1)
SetSyncRate(FPS, 0)
SetScissor(0,0,800, 600)
UseNewDefaultFonts(1)

SetRawMouseVisible(0)

it = CreateSprite(itimg)
bg = CreateSprite(bgimg)
bh = CreateSprite(bhimg)
bb = CreateSprite(bbimg)
btg = CreateSprite(btgimg)
btd = CreateSprite(btdimg)
ball = CreateSprite(ballimg)
smoke = CreateSprite(smokeimg)

SetSpriteDepth(it, 4)
SetSpriteDepth(bg, 50)

// création d'un sprite de rebond sur la barre du haut
bhrebond = CreateSprite(colimg)
SetSpriteSize(bhrebond, 800, 15)

// création d'un sprite de rebond sur la barre du bas
// il s'agit d'un effet graphique simple, en transparence,
// qui se déclanche lors d'un rebond
bbrebond = CloneSprite(bhrebond)

// création d'un sprite de rebond pour la balle
ballerebond = CreateSprite(ballimg)
SetSpriteColor(ballerebond, 255, 255, 0, 170)

// création d'un sprite de rebond pour les battes
batterebondg = CreateSprite(batteimg)
SetSpriteSize(batterebondg, 25, 100)
batterebondd = CloneSprite(batterebondg)

SetSpriteVisible(bg, 0)
SetSpriteVisible(btg, 0)
SetSpriteVisible(btd, 0)
SetSpriteVisible(bh, 0)
SetSpriteVisible(bb, 0)
SetSpriteVisible(ball, 0)
SetSpriteVisible(smoke, 0)
SetSpriteVisible(ballerebond, 0)
SetSpriteVisible(bhrebond, 0)
SetSpriteVisible(bbrebond, 0)
SetSpriteVisible(batterebondg, 0)
SetSpriteVisible(batterebondd, 0)

// les sprites des chiffres sont placés dans l'executable
Dim chiffreimg[9]
chiffreimg[0] = LoadImage("0.png")
chiffreimg[1] = LoadImage("1.png")
chiffreimg[2] = LoadImage("2.png")
chiffreimg[3] = LoadImage("3.png")
chiffreimg[4] = LoadImage("4.png")
chiffreimg[5] = LoadImage("5.png")
chiffreimg[6] = LoadImage("6.png")
chiffreimg[7] = LoadImage("7.png")
chiffreimg[8] = LoadImage("8.png")
chiffreimg[9] = LoadImage("9.png")

Dim chiffre[9, 2]

for i = 0 to 9
	chiffre[i, 1] = CreateSprite(chiffreimg[i])
	chiffre[i, 2] = CreateSprite(chiffreimg[i])
	SetSpriteVisible(chiffre[i, 1], 0)
	SetSpriteVisible(chiffre[i, 2], 0)
next

// et le symbole du tiret...
trimg = LoadImage("tiret.png")
tr = CreateSprite(trimg)
SetSpriteVisible(tr, 0)

#Constant MIN_BALL_SPEED = 16.0
#Constant MAX_BALL_SPEED = 24.0

ballangle as float
ballspeed as float

#Constant MIN_BATTE_SPEED = 20
#Constant MAX_BATTE_SPEED = 25

smoky1 = 0
smoky2 = 0

bdistx as float = 0.00
bdisty as float = 0.00

//
CompleteRawJoystickDetection()

// on joue la musique
SetMusicVolumeOGG(mus, 50)
PlayMusicOGG(mus, 1)

// jouer l'introduction
Gosub NewGame

// montrer les sprites
SetSpriteVisible(bg, 1)
SetSpriteVisible(btg, 1)
SetSpriteVisible(btd, 1)
SetSpriteVisible(bh, 1)
SetSpriteVisible(bb, 1)
SetSpriteVisible(ball, 1)

// boucle de jeu
Do

  If GetRawKeyPressed(27) = 1
	quit = 1
  EndIf
  
  If quit = 1
    exit
  EndIf
  
  t = GetMilliseconds()
  
  // victoire
  If won = 1
    Gosub NewLevel
  EndIf
  
  // afficher le background
  SetSpritePosition(bg, 0, 0)
  SetSpritePosition(bh, 0, 0)
  SetSpritePosition(bb, 0, 585)

  SetSpriteVisible(bhrebond, 0)
  SetSpriteVisible(bbrebond, 0)
  SetSpritePosition(bhrebond, 0, 0)
  SetSpritePosition(bbrebond, 0, 585)
  
  // et éventuellement de ses effets
  If rebondbh > 0
  	SetSpriteVisible(bhrebond, 1)
    dec rebondbh
  EndIf
  
  If rebondbb > 0
  	SetSpriteVisible(bbrebond, 1)
    dec rebondbb
  EndIf
  
  if GetParticlesExists(smoky1) = 1
	UpdateParticles(smoky1, 0.1)
  endif

  if GetParticlesExists(smoky2) = 1
	UpdateParticles(smoky2, 0.1)
  endif

  if GetParticlesExists(smoky3) = 1
	UpdateParticles(smoky3, 0.1)
  endif

  if GetParticlesExists(smoky4) = 1
	UpdateParticles(smoky4, 0.1)
  endif

  if GetParticlesExists(ballparticle) = 1
	SetParticlesPosition(ballparticle, bx + 10, by + 10)
	UpdateParticles(ballparticle, 0.1)
  endif
  
  SetSpritePosition(btg, bgx, bgy)
  SetSpritePosition(btd, bdx, bdy)
  SetSpritePosition(ball, bx, by)

  SetSpritePosition(ballerebond, bx, by)
  SetSpriteVisible(ballerebond, 0)
  
  SetSpritePosition(batterebondg, bgx, bgy)
  SetSpritePosition(batterebondd, bdx, bdy)
  SetSpriteVisible(batterebondg, 0)
  SetSpriteVisible(batterebondd, 0)

  If rebondballe > 0
	SetSpriteVisible(ballerebond, 1)
    dec rebondballe
  EndIf
  
  If rebondbg > 0
	SetSpriteVisible(batterebondg, 1)
    dec rebondbg
  EndIf
  
  If rebondbd > 0
	SetSpriteVisible(batterebondd, 1)
    dec rebondbd
  EndIf
  
  // si victoire d'une manche
  If won = 1
    // montrer les scores
    Gosub ShowScores
        
    Sync()
    
    // si la partie n'est pas finie
    If pts1 < 9 And pts2 < 9
      PlaySound(ready)
      ballparticle = CreateParticles(bx + 10, by + 10)
      SetParticlesDepth(ballparticle, 20)
      SetParticlesSize(ballparticle, 40)
      SetParticlesImage(ballparticle, smoke)
      SetParticlesFrequency(ballparticle, 4)
      SetParticlesLife(ballparticle, 1.6)
      AddParticlesColorKeyFrame(ballparticle, 0.0, 255, 255, 160, 50)
      AddParticlesScaleKeyFrame(ballparticle, 0.0, 0.2)
      AddParticlesScaleKeyFrame(ballparticle, 0.2, 0.4)
      AddParticlesScaleKeyFrame(ballparticle, 0.4, 0.6)
      AddParticlesScaleKeyFrame(ballparticle, 0.6, 0.8)
      AddParticlesScaleKeyFrame(ballparticle, 0.8, 1.0)
    // sinon...  
    Else
      // victoire du joueur
      If pts1 = 9
        PlaySound(youwin)
      // défaite du joueur
      Else
        PlaySound(youloosed)
      EndIf
    EndIf
    
    // attendre 4 secondes (ESC pour quitter)
    t2 = GetMilliseconds()
    While GetMilliseconds() - t2 <= 4000
      If GetRawKeyPressed(27) = 1
      	quit = 1
      	exit
      EndIf
    EndWhile
    
    // si il y a un gagnant...
    If pts1 = 9 Or pts2 = 9
      // jouer l'introduction
      Gosub NewGame
    // sinon...
    Else
      // on continue la partie !
      PlaySound(go)
      won = 0
      ballspeed = MIN_BALL_SPEED
      SetRawMousePosition(0, 300)
    EndIf
  // si pas de victoire d'une manche, on affiche et on joue
  Else
  	SetSpriteVisible(chiffre[pts1, 1], 0)
	SetSpriteVisible(tr, 0)
	SetSpriteVisible(chiffre[pts2, 2], 0)
  EndIf
    
  // jeu au joystick
  jdir = 0
  
  if GetRawJoystickExists(1) = 1 and control = JOYSTICKCONTROL
	jdir = GetRawJoystickY(1)
 	If jdir = -1
 		dec bgy, 20
   	EndIf
   	If jdir = 1
    		inc bgy, 20
   	EndIf
  endif  
  
  // jeu au clavier
  if jdir = 0 and control = KEYBOARDCONTROL
	  If GetRawKeyState(38) = 1 And jdir = 0
 	  	dec bgy, 20
  	    jdir = -1
  	  EndIf
  	  If GetRawKeyState(40) = 1 And jdir = 0
	    inc bgy, 20
    	    jdir = 1
	 EndIf
  endif
  
  // jeu à la souris
  If jdir = 0 and control = MOUSECONTROL
  	mousey = GetRawMouseY() - 50
  	dist = mousey - bgy
  	if dist < 0
  		jdir = -1
	elseif dist > 0
  		jdir = 1
  	endif
  	inc bgy, dist
  Endif
  
  SetSpritePosition(btg, bgx, bgy)
  
  // la batte CPU suit la balle
  If bx > 300
    If (bdy + 50) < by
      inc bdy, min((Random(MAX_BATTE_SPEED * 100, MIN_BATTE_SPEED * 100) / 100.0), by - (bdy + 50))
    EndIf
    If (bdy + 50) > by
      dec bdy, min((Random(MAX_BATTE_SPEED * 100, MIN_BATTE_SPEED * 100) / 100.0), (bdy + 50) - by)
    EndIf
  Else
    If bdy < 300 - 50
      inc bdy, 10
      If bdy > 300 - 50 : bdy = 300 - 50 : EndIf
    ElseIf bdy > 300 - 50
      dec bdy, 10
      If bdy < 300 - 50 : bdy = 300 - 50 : EndIf
    EndIf
  EndIf
  
  SetSpritePosition(btd, bdx, bdy)

  // rebond de la batte gauche contre le bord du haut
  If GetSpriteCollision(btg, bh) = 1
    bgy = 15
    If smoky1 = 0
      smoky1 = CreateParticles(bgx + 12, bgy + 50)
      SetParticlesDepth(smoky1, 20)
      SetParticlesSize(smoky1, 80)
      SetParticlesImage(smoky1, smoke)
      SetParticlesFrequency(smoky1, 4)
      SetParticlesLife(smoky1, 12.8)
      AddParticlesColorKeyFrame(smoky1, 0.0, 0, 255, 255, 40)
      AddParticlesScaleKeyFrame(smoky1, 0.0, 0.2)
      AddParticlesScaleKeyFrame(smoky1, 0.1, 0.5)
      AddParticlesScaleKeyFrame(smoky1, 0.2, 1.0)
      AddParticlesScaleKeyFrame(smoky1, 0.3, 1.9)
      AddParticlesScaleKeyFrame(smoky1, 0.4, 3.0)
      tsmoke1 = GetMilliseconds()
      PlaySound(noise1, Noise1Volume)
      rebondbh = 2
      rebondbg = 2
    EndIf
  EndIf
  
  // rebond de la batte gauche contre le bord du bas
  If GetSpriteCollision(btg, bb) = 1
    bgy = 485
    If smoky2 = 0
      smoky2 = CreateParticles(bgx + 12, bgy + 50)
      SetParticlesDepth(smoky2, 20)
      SetParticlesSize(smoky2, 80)
      SetParticlesImage(smoky2, smoke)
      SetParticlesFrequency(smoky2, 4)
      SetParticlesLife(smoky2, 12.8)
      AddParticlesColorKeyFrame(smoky2, 0.0, 0, 255, 255, 40)
      AddParticlesScaleKeyFrame(smoky2, 0.0, 0.2)
      AddParticlesScaleKeyFrame(smoky2, 0.1, 0.5)
      AddParticlesScaleKeyFrame(smoky2, 0.2, 1.0)
      AddParticlesScaleKeyFrame(smoky2, 0.3, 1.9)
      AddParticlesScaleKeyFrame(smoky2, 0.4, 3.0)
      tsmoke2 = GetMilliseconds()
      PlaySound(noise1, Noise1Volume)
      rebondbb = 2
      rebondbg = 2
    EndIf
  EndIf
  
  // rebond de la batte droite contre le bord du haut
  If GetSpriteCollision(btd, bh) = 1
    bdy = 16
    If smoky3 = 0
      smoky3 = CreateParticles(bdx + 12, bdy + 50)
      SetParticlesDepth(smoky3, 20)
      SetParticlesSize(smoky3, 80)
      SetParticlesImage(smoky3, smoke)
      SetParticlesFrequency(smoky3, 4)
      SetParticlesLife(smoky3, 12.8)
      AddParticlesColorKeyFrame(smoky3, 0.0, 0, 255, 255, 40)
      AddParticlesScaleKeyFrame(smoky3, 0.0, 0.2)
      AddParticlesScaleKeyFrame(smoky3, 0.1, 0.5)
      AddParticlesScaleKeyFrame(smoky3, 0.2, 1.0)
      AddParticlesScaleKeyFrame(smoky3, 0.3, 1.9)
      AddParticlesScaleKeyFrame(smoky3, 0.4, 3.0)
      tsmoke3 = GetMilliseconds()
      PlaySound(noise1, Noise1Volume)
      rebondbh = 2
      rebondbd = 2
    EndIf
  EndIf
  
  // rebond de la batte droite contre le bord du bas
  If GetSpriteCollision(btd, bb) = 1
    bdy = 484
    If smoky4 = 0
      smoky4 = CreateParticles(bdx + 12, bdy + 50)
      SetParticlesDepth(smoky4, 20)
      SetParticlesSize(smoky4, 80)
      SetParticlesImage(smoky4, smoke)
      SetParticlesFrequency(smoky4, 4)
      SetParticlesLife(smoky4, 12.8)
      AddParticlesColorKeyFrame(smoky4, 0.0, 0, 255, 255, 40)
      AddParticlesScaleKeyFrame(smoky4, 0.0, 0.2)
      AddParticlesScaleKeyFrame(smoky4, 0.1, 0.5)
      AddParticlesScaleKeyFrame(smoky4, 0.2, 1.0)
      AddParticlesScaleKeyFrame(smoky4, 0.3, 1.9)
      AddParticlesScaleKeyFrame(smoky4, 0.4, 3.0)
      tsmoke4 = GetMilliseconds()
      PlaySound(noise1, Noise1Volume)
      rebondbb = 2
      rebondbd = 1
    EndIf
  EndIf
  
  SetSpritePosition(btg, bgx, bgy)
  SetSpritePosition(btd, bdx, bdy)
  
  // supprimer des effets de fumée
  millisecs = GetMilliseconds()
  If smoky1 > 0 And millisecs - tsmoke1 > 200
    DeleteParticles(smoky1)
    smoky1 = 0
  EndIf
  If smoky2 > 0 And millisecs - tsmoke2 > 200
    DeleteParticles(smoky2)
    smoky2 = 0
  EndIf
  If smoky3 > 0 And millisecs - tsmoke3 > 200
    DeleteParticles(smoky3)
    smoky3 = 0
  EndIf
  If smoky4 > 0 And millisecs - tsmoke4 > 200
    DeleteParticles(smoky4)
    smoky4 = 0
  EndIf

  oldbx = bx
  oldby = by
  
  If bx > -25 And bx < 800
    inc bx, (ballspeed * Cos(ballangle))
    inc by, (ballspeed * Sin(ballangle))
    If ballspeed < MAX_BALL_SPEED
      inc ballspeed, 0.01
    EndIf
  EndIf
  
  SetSpritePosition(ball, bx, by)
  
  // l'adversaire marque un point
  If bx <= -25
    PlaySound(people)
    inc pts2
    won = 1
    DeleteParticles(smoky1)
    DeleteParticles(smoky2)
    DeleteParticles(smoky3)
    DeleteParticles(smoky4)
    DeleteParticles(ballparticle)
    rebondbh = 0
    rebondbb = 0
    rebondballe = 0
    rebondbg = 0
    rebondbd = 0
  EndIf
  
  // le joueur marque un point
  If bx >= 800
    PlaySound(people)
    inc pts1
    won = 1
    DeleteParticles(smoky1)
    DeleteParticles(smoky2)
    DeleteParticles(smoky3)
    DeleteParticles(smoky4)
    DeleteParticles(ballparticle)
  EndIf
  
  // la balle rebondit sur la barre du haut
  If GetSpriteCollision(ball, bh) = 1
    bx = oldbx
    by = oldby
    bdistx = 0.00
    bdisty = 0.00
    While Floor((by * 1.0) + bdisty) > 15
      inc bdistx, Cos(ballangle)
      inc bdisty, Sin(ballangle)
    EndWhile
    bx = Floor((bx * 1.0) + bdistx)
    by = Floor((by * 1.0) + bdisty)
    ballangle = (360 - ballangle)
    PlaySound(reb)
    rebondbh = 2
    rebondballe = 2
  EndIf
  
  // la balle rebondit sur la barre du bas
  If GetSpriteCollision(ball, bb) = 1
    bx = oldbx
    by = oldby
    bdistx = 0.00
    bdisty = 0.00
    While Floor((by * 1.0) + bdisty) < 560
      inc bdistx, Cos(ballangle)
      inc bdisty, Sin(ballangle)
    EndWhile
    bx = Floor((bx * 1.0) + bdistx)
    by = Floor((by * 1.0) + bdisty)
    ballangle = (360 - ballangle)
    PlaySound(reb)
    rebondbb = 2
    rebondballe = 2
  EndIf
  
  SetSpritePosition(ball, bx, by)
  
  // la balle rebondit sur la batte de gauche
  If GetSpriteCollision(ball, btg) = 1
    If by <= bgy + 38
      ballangle = 360 - (bgy + 38 - by) - Random(0, 10)
    Else
      ballangle = (by - 38 - bgy) + Random(0, 10)
    EndIf
    bx = oldbx
    by = oldby
    If bx < 26
      bx = 26
    EndIf
    PlaySound(reb)
    rebondbg = 2
    rebondballe = 2
  EndIf
  
  // la balle rebondit sur la batte de droite
  If GetSpriteCollision(ball, btd) = 1
    If by <= bdy + 38
      ballangle = 180 + (bdy + 38 - by) + Random(0, 10)
    Else
      ballangle = 180 - (by - 38 - bdy) - Random(0, 10)
    EndIf
    bx = oldbx
    by = oldby
    If bx > 749
      bx = 749
    EndIf
    PlaySound(reb)
    rebondbd = 2
    rebondballe = 2
  EndIf
  
  // ajuster l'angle
  While ballangle < 0.00
    inc ballangle, 360.00
  EndWhile
  While ballangle >= 360.00
    dec ballangle, 360.00
  EndWhile
  
  SetSpritePosition(ball, bx, by)

  
  If (Floor(ballangle) >= 0 And Floor(ballangle) < 10)
    inc ballangle, 20
  EndIf
  If (Floor(ballangle) > 85 And Floor(ballangle) < 95)
    inc ballangle, 20
  EndIf
  If (Floor(ballangle) > 175 And Floor(ballangle) < 185)
    inc ballangle, 20
  EndIf
  If (Floor(ballangle) > 265 And Floor(ballangle) < 275)
    inc ballangle, 20
  EndIf
  If (Floor(ballangle) > 350 And Floor(ballangle) <= 360)
    ballangle = Mod(ballangle + 20, 360) 
  EndIf

  Sync()
    
Loop

End

// procedures
//
// nouvelle manche
NewLevel:

SetRandomSeed(GetMilliseconds())

bgx = 0
bgy = 250

bdx = 775
bdy = 250

bx = 388
by = 288
ballangle = (Random(0, 44) - 22) + (Random(0, 1) * 180)
ballspeed = 0

rebondbh = 0
rebondbb = 0
rebondballe = 0
rebondbg = 0
rebondbd = 0

Return

// nouvelle partie, introduction
NewGame:

SetSpriteVisible(bg, 0)
SetSpriteVisible(btg, 0)
SetSpriteVisible(btd, 0)
SetSpriteVisible(bh, 0)
SetSpriteVisible(bb, 0)
SetSpriteVisible(ball, 0)
SetSpriteVisible(ballerebond, 0)
SetSpriteVisible(bhrebond, 0)
SetSpriteVisible(bbrebond, 0)
SetSpriteVisible(batterebondg, 0)
SetSpriteVisible(batterebondd, 0)

for i = 0 to 9
	SetSpriteVisible(chiffre[i, 1], 0)
	SetSpriteVisible(chiffre[i, 2], 0)
next

SetSpriteVisible(tr, 0)

SetSpritePosition(it, 0, 0)
SetSpriteVisible(it, 1)

control = NOCONTROL
joybut = 0

Do
  if GetRawJoystickExists(1) = 1
	If GetRawJoystickButtonState(1, 1) = 1
   		joybut = 1
  	EndIf
  endif
  
  If GetRawKeyPressed(27) = 1
    quit = 1
    Return
  EndIf
  
  if GetRawKeyPressed(13) = 1
	control = KEYBOARDCONTROL
	exit
  elseif GetRawMouseLeftPressed() = 1
	control = MOUSECONTROL
	exit
  elseif joybut = 1
	control = JOYSTICKCONTROL
	exit
  endif
  
  Sync()

Loop

SetRandomSeed(GetMilliseconds())

pts1 = 0
pts2 = 0

won = 1

SetSpriteVisible(it, 0)

SetSpriteVisible(bg, 1)
SetSpriteVisible(btg, 1)
SetSpriteVisible(btd, 1)
SetSpriteVisible(bh, 1)
SetSpriteVisible(bb, 1)
SetSpriteVisible(ball, 1)

Return

// montrer les scores
ShowScores:

SetSpritePosition(chiffre[pts1, 1], 250, 40)
SetSpritePosition(tr, 350, 40)
SetSpritePosition(chiffre[pts2, 2], 450, 40)

SetSpriteVisible(chiffre[pts1, 1], 1)
SetSpriteVisible(tr, 1)
SetSpriteVisible(chiffre[pts2, 2], 1)

Return

// renvoyer le minimum de deux nombres
Function min(a as float, b as float)
  If a < b
    ExitFunction a
  EndIf
EndFunction b
