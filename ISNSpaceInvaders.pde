import processing.sound.*;    //Librairie permettant de jouer des sons

/*
NB : Les erreurs suivantes sont des erreurs générées par la librairie :
"ERROR: /node/free: Node id -1 out of range"
"ERROR: /node/free: Cannot free root node 0"
"ERROR: /node/set: Synth XXX not found"
*/

import controlP5.*;           //Librairie permettant l'ajout de barres glissantes
SoundFile explode;            //Déclaration des variables de son (Explosion)
SoundFile music;              //Musique de fond

int tVaisseau = 45;           //Taille des Objets
int tEnnemis = 40;

int eSpeed = 4;               //Vitesses ennemis et vaisseau
int vSpeed = 6;

int xVaisseau;                //Coordonnées du vaisseau
int yVaisseau;
int xs1,ys1,xs2,ys2,xs3,ys3;  //Coordonnées des sommets du vaisseau (en triangle) s1 = sommet gauche, s2 = sommet haut droit, s3 = sommet bas droit

ArrayList<Integer> xE = new ArrayList();  //Liste des coordonnées des ennemis
ArrayList<Integer> yE = new ArrayList();

boolean espace =  false;      //initialisation des touches du jeu (false = touche non appuyée)
boolean up=       false;
boolean down=     false;
boolean left=     false;
boolean right=    false;

int screen;                  //Ecran à afficher (0=Accueil, 1=Jeu, 2=Options, 3=Crédits, 4=Ecran de sortie

double aireT;                 //Aire du triangle

PFont titre, texte;           //Déclaration des polices d'écriture

PImage fondAccueil,fondJeu,asteroid , vaisseau;    //Déclaration des images

int playerScore=0;            //Score du joueur

ControlP5 cp5;                //Déclaration du controlleur (permetant la création d'une SlideBar)

float volumeM = 0.50;         //Valeur initiale en % du volume de la musique
float volumeE = 0.50;         //Valeur initiale en % du volume de l'explosion

int spawnRate = 5;            //Valeur initiale en % taux d'apparition maximum

color sliderActiveColor=#FF0000, sliderForegroundColor=#AA0000;         //Couleurs liées au sliderBar
color gameTitleColor=#FF0000, homeTextColor=#FF0000, gameTextColor=#FF0000, creditsTextColor=#FF0000, exitTextColor=#FF0000;    //Couleurs liées au texte dans les différents menus
color optionsBackButtonColor=#007FFF, creditsBackButtonColor=#FF0000, exitYesButtonColor=#FF0000, exitNoButtonColor=#FF0000;    //Couleurs liées au texte dans différents "boutons"
 
void setup(){
  size(800,600);
  frameRate(60);
  titre = createFont("PoliceTitre.ttf",1);    //Initialisation de la police utilisée pour les titres
  texte = createFont("PoliceTexte.ttf",1);    //Initialisation de la police utilisée pour le texte
  smooth();                                   //Rend les contours plus lisses
  
  xVaisseau = width>>1;                                                                                                             //En binaire : décalage à droite des chiffres de 1 (0101 -> 0010). Revient ici à diviser par 2^1  ==> Fludification des calculs
  yVaisseau = height>>1;                                                                                                            //Autre ex: 11010001>>2  -> 00110100 : division par 2^2=4. "left shift" & "right shift"
  aireT = triangleA(xVaisseau, yVaisseau,xVaisseau+tVaisseau, (yVaisseau-(tVaisseau>>1)), xVaisseau+tVaisseau, (yVaisseau+(tVaisseau>>1)));    //Calcul de l'aire du triangle
  
  screen = 0;                                 //Initialisation de l'écran initial à l'écran d'accueil
  
  explode = new SoundFile(this, "8BitExplosion.mp3");           //Variable qui correspond à un fichier son placé dans /data du dossier projet (son d'explosion)
  music = new SoundFile(this , "BackgroundMusic.mp3");          //Musique de fond
  music.amp((0.125*volumeM));                                   //Volume initial de la musique de fond (Volume max = 0.125, Volume initial = 0.125*0.5)
  music.loop();                                                 //Répétition en boucle de la musique
  explode.amp(0.05*volumeE);                                    //Volume initial d'explosion (Volume max = 0.05, Volume initial = 0.05*0.5)
  
  fondAccueil = loadImage("fondAccueil.jpg");                   //Chargement des images dans des variables
  fondJeu = loadImage("fondJeu.png");
  asteroid = loadImage("asteroid.png");
  vaisseau = loadImage("vaisseau.png");
  
   cp5 = new ControlP5(this);                                                        //Initialisation du controlleur
   cp5.setColorActive(sliderActiveColor).setColorForeground(sliderForegroundColor);  //Réglage de la couleur lors du mouse-over et couleur en règle générale des barres
   
    cp5.addSlider("Taille Enemis")                                                   //Initialisation des différentes barres avec leurs paramètres (Position, taille, valeurMin/Max, valeur initiale, visibilité)
      .setPosition(10,50)
      .setSize(550,40)
      .setRange(15,100)
      .setValue(tEnnemis)
      .setVisible(false);
      
   cp5.addSlider("Taille Vaisseau")
      .setPosition(10,170)
      .setSize(550,40)
      .setRange(15,100)
      .setValue(tVaisseau)
      .setVisible(false);
      
   cp5.addSlider("Vitesse Ennemis")
      .setPosition(10,250)
      .setSize(550,40)
      .setRange(1,20)
      .setValue(eSpeed)
      .setVisible(false);
      
   cp5.addSlider("Vitesse Vaisseau")
      .setPosition(10,300)
      .setSize(550,40)
      .setRange(1,20)
      .setValue(vSpeed)
      .setVisible(false);
      
   cp5.addSlider("Volume musique")
      .setPosition(10,350)
      .setSize(550,40)
      .setRange(0,100)
      .setValue(50)
      .setVisible(false);
      
   cp5.addSlider("Volume Explosion")
      .setPosition(10,400)
      .setSize(550,40)
      .setRange(0,100)
      .setValue(50) 
      .setVisible(false);
      
   cp5.addSlider("Chance d'apparation d'un ennemi")
      .setPosition(10,450)
      .setSize(550,40)
      .setRange(0,100)
      .setValue(spawnRate) 
      .setVisible(false);   
}

void draw(){
  switch(screen) {
   case 0: ecranAccueil();  break;    //Affichage de l'écran d'accueil
   case 1: ecranJeu();      break;    //Affichage de l'écran de jeu
   case 2: ecranOptions();  break;    //Affichage de l'écran des options   
   case 3: ecranCredits();  break;    //Affichage de l'écran des crédits 
   case 4: ecranSortie();   break;    //Affichage de l'écran de sortie
  }
}

//
// Définition de l'écran d'accueil
//

void ecranAccueil(){
  
  cursor();
  background(fondAccueil);
  noFill();
  stroke(0,0,0);
  rectMode(CENTER);
  textFont(titre,75);
  textAlign(CENTER);
  fill(gameTitleColor);
  text("ASTROBREAKER",width>>1,height/5);
  textFont(titre,28);
  noFill();
  
  if((mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height/3)+40 && mouseY>(height/3)-40)){       //Souris sur PLAY / JOUER
    fill(255,50); }                                                                                           //Remplissage (ou non) de la case avec blanc un peu transparent 
  else noFill();
  rect(width>>1,height/3,200,80);                                                                             //Réalisation de la case
   
  if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height>>1)+40 && mouseY>(height>>1)-40) {     //Souris sur Options
    fill(255,50); }                                                                                           //Remplissage (ou non) de la case avec blanc un peu transparent
  else noFill();
  rect(width>>1,height>>1,200,80);                                                                            //Réalisation de la case
  
  if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height*0.67)+40 && mouseY>(height*0.67)-40) { //Souris sur Copyrights
    fill(255,50); }                                                                                           //Remplissage (ou non) de la case avec blanc un peu transparent
  else noFill();
  rect(width>>1,height*0.67,200,80);                                                                          //Réalisation de la case
  
  if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height*0.84)+40 && mouseY>(height*0.84)-40) { //Souris sur Fin
    fill(255,50); }                                                                                           //Remplissage (ou non) de la case avec blanc un peu transparent
  else noFill();
  rect(width>>1,height*0.84,200,80);                                                                          //Réalisation de la case
  
  fill(homeTextColor);                                                                                        //Coloration du texte
  text("Play / Jouer",width>>1,(height/3)+10);                                                                //Ecriture du texte aux bons emplacements
  text("Options",width>>1,(height>>1)+10);
  text("Credits",width>>1,height*0.67+10);
  text("Exit / Quitter",width>>1,height*0.84+10);
}

//
//Définition de l'écran de Jeu
//

void ecranJeu(){
  background(fondJeu);                                 
  noCursor();
  if((int)random(0,100)<=spawnRate) ajouterEnnemis();  //Si la valeur aléatoire (entre 1 et 100) est inférieure à la variable, on fait apparaître un ennemi
  bougerEnnemi();                                      //Déplacement des ennemis
  bougerVaisseau();                                    //Déplacement du vaisseau
  collision();
  affichage();
  
  fill(gameTextColor);
  stroke(255,0,0);
  textFont(texte,20);                                  //Ecriture des différents éléments
  text("Space/Espace : Pause",width-100,20);
  String score = "Score : "+playerScore;
  textFont(texte,25);
  text(score,60,30);
  
  if(espace){                                          //Si on appuie sur espace, l'écran d'accueil est ouvert (mise en pause du jeu)
    screen=0;
  }
}

//
//Définition de l'écran des options
//

void ecranOptions(){
  background(fondAccueil);
  cp5.getController("Taille Enemis").setVisible(true);          //On affiche les barres définies dans le setup{}
  cp5.getController("Taille Vaisseau").setVisible(true);
  cp5.getController("Vitesse Ennemis").setVisible(true);
  cp5.getController("Vitesse Vaisseau").setVisible(true);
  cp5.getController("Volume musique").setVisible(true);
  cp5.getController("Volume Explosion").setVisible(true);
  cp5.getController("Chance d'apparation d'un ennemi").setVisible(true);
  
  AffOp();
 
  fill(optionsBackButtonColor);
  textFont(texte,25);
  text("Back / Retour",width>>1,height*0.9+10);
  if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height*0.9)+40 && mouseY>(height*0.9)-40) {  //Bouton retour à l'écran d'accueil (avec un remplissange semi-transparent au mouse-over)
    fill(255,50);
  }
  else noFill();
  rect(width>>1,height*0.9,200,80);
}

//
//Définition de l'actualisaiton dynamique du menu des options
//

void AffOp(){   //Ces paramètres sont mis à jour à chaque image tant que l'on est sur l'écran des options

  tEnnemis = (int)cp5.getController("Taille Enemis").getValue();    //Récupération de la valeur issue de la SlideBar
  tVaisseau = (int)cp5.getController("Taille Vaisseau").getValue();
  
  imageMode(CENTER);                                                //Affichage instantané d'un aperçu "en jeu" du paramètre réglé
  image(asteroid,725,70,tEnnemis,tEnnemis);
  image(vaisseau,725,190,tVaisseau,tVaisseau);
  
  volumeM=(cp5.getController("Volume musique").getValue())/100;    //Réglage du volume
  music.amp(0.125*volumeM);
  
  volumeE=(cp5.getController("Volume Explosion").getValue())/100;
  explode.amp(0.05*volumeE);
}

//
//Définition de l'écran des crédits
//

void ecranCredits(){
  background(fondJeu);
  textAlign(CENTER);
  textFont(titre,75);
  fill(creditsTextColor);
  text("Credits",width>>1,height/5);
  textFont(texte,30);
  text("blablablablablablablablablablablablablabla",width>>1,height/3);
  text("blablablablablablablablablablablablablabla",width>>1,height/3+40);
  text("blablablablablablablablablablablablablabla",width>>1,height/3+80);
  text("blablablablablablablablablablablablablabla",width>>1,height/3+120);
  text("blablablablablablablablablablablablablabla",width>>1,height/3+160);
  text("blablablablablablablablablablablablablabla",width>>1,height/3+200);
  fill(creditsBackButtonColor);
  text("Back / Retour",width>>1,height*0.9+10);
  if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height*0.9)+40 && mouseY>(height*0.9)-40) {   //Bouton Retour
    fill(255,50);
  }
  else noFill();
  rect(width>>1,height*0.9,200,80);
}

//
//Définition de l'écran de sortie
//

void ecranSortie(){
  background(fondAccueil);
  textAlign(CENTER);
  fill(exitTextColor);
  textFont(texte,30);
  text("Êtes-vous sûr de vouloir quitter ?",width>>1,height/3);
  
  if (mouseX<(width>>2)+100 && mouseX>(width>>2)-100 && mouseY<(height>>1)+40 && mouseY>(height>>1)-40) { //Case Yes/Oui
    fill(255,50); }
  else noFill();
  rect(width>>2,height>>1,200,80);
  
  if (mouseX<(width*0.75)+100 && mouseX>(width*0.75)-100 && mouseY<(height>>1)+40 && mouseY>(height>>1)-40) { //Case Non/No
    fill(255,50); }
  else noFill();
  rect(width*0.75,height>>1,200,80);
  
  textFont(texte,30);
  fill(exitYesButtonColor);
  text("Yes / Oui",width>>2,(height>>1)+10);
  fill(exitNoButtonColor);
  text("No / Non",width*0.75,(height>>1)+10);
}

//
// Utilisation de la souris
//

void mousePressed(){    //Au moment où le click souris est enfoncé
  if (screen == 0){     //Dans l'écran d'accueil
    if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height/3)+40 && mouseY>(height/3)-40)       screen=1;   // Click Souris sur Play/Jouer
    if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height>>1)+40 && mouseY>(height>>1)-40)     screen=2;   // Click Souris sur Options
    if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height*0.67)+40 && mouseY>(height*0.67)-40) screen=3;   // Click Souris sur Credits
    if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height*0.84)+40 && mouseY>(height*0.84)-40) screen=4;   // Click Souris sur Fin
  }
  if(screen == 2){      //Dans l'écran des options
    if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height*0.9)+40 && mouseY>(height*0.9)-40){      //Click sur le bouton retour -> masquage des barres
      cp5.getController("Taille Enemis").setVisible(false);
      cp5.getController("Taille Vaisseau").setVisible(false);
      cp5.getController("Vitesse Ennemis").setVisible(false);
      cp5.getController("Vitesse Vaisseau").setVisible(false);
      cp5.getController("Volume musique").setVisible(false);
      cp5.getController("Volume Explosion").setVisible(false);
      cp5.getController("Chance d'apparation d'un ennemi").setVisible(false);
      
      
      vSpeed =(int) cp5.getController("Vitesse Vaisseau").getValue();                                              //On récupère les valeurs, non mises à jour à chaque image, à la sortie du menu
      eSpeed =(int) cp5.getController("Vitesse Ennemis").getValue();
      spawnRate =(int) cp5.getController("Chance d'apparation d'un ennemi").getValue()/2;  
      
      aireT = triangleA(xVaisseau, yVaisseau,xVaisseau+tVaisseau, (yVaisseau-(tVaisseau>>1)), xVaisseau+tVaisseau, (yVaisseau+(tVaisseau>>1)));  //Mise à jour de l'aire du triangle (au cas où tVaisseau ou tEnnemis ont changé)
      screen=0;   //Retour à l'accueil
    }
  }
  if (screen == 3){ //Dans l'écran des crédits
    if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height*0.9)+40 && mouseY>(height*0.9)-40) screen=0;     //Retour à l'accueil lors du click sur Retour
  }
  if (screen == 4){ //Dans l'écran de sortie
    if (mouseX<(width*0.75)+100 && mouseX>(width*0.75)-100 && mouseY<(height>>1)+40 && mouseY>(height>>1)-40) screen=0;   //Retour à l'accueil lors du click sur No/Non
    if (mouseX<(width>>2)+100 && mouseX>(width>>2)-100 && mouseY<(height>>1)+40 && mouseY>(height>>1)-40) exit();         //Fermeture de la fenêtre lors du click sur Yes/Oui
  }
}

//
//Utilisation du clavier
//

void keyPressed(){  //Lorsque l'on appuie sur la touche, la variable correspondante passe à true
  switch(keyCode){
    case 32 : espace =   true; break;  //Espace
    case UP: up =        true; break;  //Flèches clavier
    case DOWN : down =   true; break;
    case LEFT : left =   true; break;
    case RIGHT : right = true; break;
    case 90: up=         true; break;  //z
    case 81: left=       true; break;  //q
    case 83: down=       true; break;  //s
    case 68: right=      true; break;  //d
 }
}
void keyReleased(){  //Lorsque l'on relâche la touche, la variable correspondante passe à false
   switch(keyCode){
    case 32 : espace =      false; break;  //Espace
    case UP : up =          false; break;  //Flèche clavier
    case DOWN : down =      false; break;
    case LEFT : left =      false; break;
    case RIGHT : right =    false; break;
    case 90: up=            false; break;  //z
    case 81: left=          false; break;  //q
    case 83: down=          false; break;  //s
    case 68: right=         false; break;  //d
  }  
}

void ajouterEnnemis(){  //Ajout des ennemis
  xE.add(0);            //A la coordonée x=0
  yE.add((int)(Math.random()*(height-tEnnemis))+(tEnnemis/2));  //A la coordonée tEnnemis < y < height-tEnnemis  (pour éviter les astéroïdes à moitié dans l'écran)
}

 void bougerEnnemi(){   //Mouvement des ennemis (on ajoute la vitesse (en pixel) à chaque appel de la fonction, à chaque frame, à chaque ennemi, sur la coordonée x)
  for(int i=0;i<xE.size();i++){
    xE.set(i,xE.get(i)+eSpeed);
  }
}

void bougerVaisseau(){  //Mouvement du vaisseau
  if(up && (ys2>0))        yVaisseau-=vSpeed;  //Mouvement vers le haut (on soustrait la vitesse (en pixel) sur y) ssi le vaisseau n'est pas sur le bord haut et que la touche "up" est enfoncée
  if(down && (ys3<height)) yVaisseau+=vSpeed;  //Mouvement vers le bas (on additionne la vitesse (en pixel) sur y) ssi le vaisseau n'est pas sur le bord bas et que la touche "down" est enfoncée
  if(left && (xs1>0))      xVaisseau-=vSpeed;  //Mouvement vers la gauche (on soustrait la vitesse (en pixel) sur x) ssi le vaisseau n'est pas sur le bord gauche et que la touche "left" est enfoncée
  if(right && (xs2<width)) xVaisseau+=vSpeed;  //Mouvement vers la droite (on additionne la vitesse (en pixel) sur x) ssi le vaisseau n'est pas sur le bord droit et que la touche "right" est enfoncée
    
  xs1=xVaisseau;        //Calcul des nouvelles coordonnées des sommets du triangle
  ys1=yVaisseau;        //s1 = sommet gauche, s2 = sommet haut droit, s3 = sommet bas droit
  xs2=xVaisseau+tVaisseau;
  ys2=yVaisseau-(tVaisseau>>1);
  xs3=xVaisseau+tVaisseau;
  ys3=yVaisseau+(tVaisseau>>1);
}

//
//Collision
//

void collision(){
  float x,y,r;
  r=tEnnemis>>1;
 
  for (int i=0 ; i<xE.size();i++) {
    x=xE.get(i);y=yE.get(i);
    if(x-tEnnemis>width){
      xE.remove(i);
      yE.remove(i);
    }
    else if ((y+r>yVaisseau-(tVaisseau>>1) && y-(tEnnemis>>1)<yVaisseau+(tVaisseau>>1)) && (x+(tEnnemis>>1)>xVaisseau && x-(tEnnemis>>1)<xVaisseau+tVaisseau)) { 
      if (colision(x,y,r)) {
        xE.remove(i);
        yE.remove(i);
        Sound();
        playerScore+=1;
      }  
    }    
  }
}

boolean colision(float x,float y ,float r){
  int xC,yC,xG,yG; // point sur le cercle de du vecteur centre gravité triangle centre cercle
  float longux,longuy,angle ,A1,A2,A3,AT;
  // centre de gravité du triangle
  xG = (xs1+xs2+xs3)/3;
  yG = (ys1+ys2+ys3)/3;    
  longux = xG-x;
  longuy = yG-y;
  angle  = atan2(longuy,longux);  
  //calcul du potentiel point de colision
  xC= int(x+cos(angle)*r);
  yC =int(y+sin(angle)*r);
  // calcul des 3 aires créées par le point potentiel de collision
  A1=triangleA(xC,yC,xs1,ys1,xs2,ys2);
  A2=triangleA(xC,yC,xs2,ys2,xs3,ys3);
  A3=triangleA(xC,yC,xs1,ys1,xs3,ys3);
   
  AT= A1+A2+A3;
  // la somme des 3 aires est égale alors le point est dans le triangle
  if (aireT==AT)                  return true;   
  else if(colC(xs1 ,ys1 , x,y,r)) return true;  
  else if(colC(xs2 ,ys2 , x,y,r)) return true;
  else if(colC(xs3 ,ys3 , x,y,r)) return true; 
  
  return false;
}

boolean colC(float xs,float ys,float xc,float yc,float r){// collision avec cercle et point sommet du triangle
  return (xs-xc)*(xs-xc)+(ys-yc)*(ys-yc)<= r*r;
 
}

float triangleA(int px1, int py1 , int px2 ,int py2 ,int px3 , int py3){ // calcul l'aire d'un triangle
 
  float A , ACx,ACy,ABx ,ABy;
  // A = 1/2 abs(AB ^ AC)
  
  ABx=px2-px1;
  ABy=py2-py1;
  ACx=px3-px1;
  ACy=py3-py1;
 
  A= 0.5*abs((ACx*ABy)-(ACy*ABx));
  return A;
}
   
void Sound(){ //Fonction appelée lors de chaque colision qui produit un son
    explode.play();
} 

void affichage(){
  int x,y;
 
  for(int i = 0;i<xE.size();i++){ // affiche chaque ennemi
    x = xE.get(i); y = yE.get(i);
    imageMode(CENTER);
    image(asteroid,x,y,tEnnemis,tEnnemis); 
  }
  imageMode(CORNER);
  image(vaisseau,xs1,ys1-tVaisseau/2,tVaisseau,tVaisseau);
}
