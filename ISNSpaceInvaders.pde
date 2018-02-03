import processing.sound.*;
import controlP5.*;
SoundFile explode;
SoundFile music;
// taille des Objets
int tVaisseau = 40;
int tEnnemis = 30;
//vitesse ennemis +vaisseau
int eSpeed = 4;
int vSpeed = 6;
// coordonnées vaisseau
int xVaisseau;
int yVaisseau;
int xs1,ys1,xs2,ys2,xs3,ys3;
// positions ennemies
ArrayList<Integer> xE = new ArrayList();
ArrayList<Integer> yE = new ArrayList();
// touches du jeu
boolean espace = false;
boolean up=   false;
boolean down= false;
boolean left= false;
boolean right=false;
// mode de jeu
int screen ;
// aire triangle
double aireT;
//Police d'écriture
PFont titre, texte;
//Images
PImage fondAccueil,fondJeu,asteroid , vaisseau;
//Score du joueur
int playerScore=0;
// menu option
ControlP5 cp5;
//
float volumeM =0.05;
float volumeE = 0.025;
//
int dropRate = 5;

 
void setup(){
  size(800,600);
  frameRate(60);
  titre = createFont("PoliceTitre.ttf",1);
  texte = createFont("PoliceTexte.ttf",1);
  smooth();
  xVaisseau = width>>1;  
  yVaisseau = height>>1;
  
  screen = 0;
  aireT = triangleA(xVaisseau, yVaisseau,xVaisseau+tVaisseau, (yVaisseau-(tVaisseau>>1)), xVaisseau+tVaisseau, (yVaisseau+(tVaisseau>>1)));
  explode = new SoundFile(this, "8BitExplosion.mp3"); //Variable qui correspond à un fichier son placé dans /data du dossier projet
  music = new SoundFile(this , "BackgroundMusic.mp3");
  music.amp(volumeM);
  music.loop();
  
  fondAccueil = loadImage("fondAccueil.jpg");
  fondJeu = loadImage("fondJeu.png");
  asteroid = loadImage("asteroid.png");
  vaisseau = loadImage("vaisseau.png");
  ////////
   cp5 = new ControlP5(this);
   cp5.setColorActive(0xffff0000).setColorForeground(0xffaa0000);
   
    cp5.addSlider("Taille Enemis")
      .setPosition(10,50)
      .setSize(550,40)
      .setRange(15,100)
      .setValue(tEnnemis)
      .setId(1)
      .setVisible(false);
      
   cp5.addSlider("Taille Vaisseau")
      .setPosition(10,170)
      .setSize(550,40)
      .setRange(15,100)
      .setValue(tVaisseau)
      .setId(2)
      .setVisible(false);
      
   cp5.addSlider("Vitesse Ennemis")
      .setPosition(10,250)
      .setSize(550,40)
      .setRange(1,20)
      .setValue(eSpeed)
      .setId(3)
      .setVisible(false);
      
   cp5.addSlider("Vitesse Vaisseau")
      .setPosition(10,300)
      .setSize(550,40)
      .setRange(1,20)
      .setValue(vSpeed)
      .setId(4)
      .setVisible(false);
      
   cp5.addSlider("Volume musique")
      .setPosition(10,350)
      .setSize(550,40)
      .setRange(0,100)
      .setValue(volumeM*100)
      .setId(5)
      .setVisible(false);
      
   cp5.addSlider("Volume Explosion")
      .setPosition(10,400)
      .setSize(550,40)
      .setRange(0,100)
      .setValue(volumeE*100)
      .setId(6) 
      .setVisible(false);
      
   cp5.addSlider("Chance d'apparation d'un ennemi")
      .setPosition(10,450)
      .setSize(550,40)
      .setRange(0,100)
      .setValue(dropRate)
      .setId(6) 
      .setVisible(false);
   //////
   
}

//
// Fonction d'affichage
//
void AffOp()
{
  int tE,tV;
  tE = (int)cp5.getController("Taille Enemis").getValue();
  tV = (int)cp5.getController("Taille Vaisseau").getValue();
  
  imageMode(CENTER); 
  image(asteroid,725,70,tE,tE);
  image(vaisseau,725,180,tV,tV);
   
}

void ecranOptions(){
  background(fondAccueil);
  fill(255,0,0);
    
   cp5.getController("Taille Enemis").setVisible(true);
   cp5.getController("Taille Vaisseau").setVisible(true);
   cp5.getController("Vitesse Ennemis").setVisible(true);
   cp5.getController("Vitesse Vaisseau").setVisible(true);
   cp5.getController("Volume musique").setVisible(true);
   cp5.getController("Volume Explosion").setVisible(true);
   cp5.getController("Chance d'apparation d'un ennemi").setVisible(true);
  textFont(titre,25);
  AffOp();
  text("Back / Retour",width>>1,height*0.9+10);
  if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height*0.9)+40 && mouseY>(height*0.9)-40) { // Retour
    fill(255,50);
  }
  else noFill();
  rect(width>>1,height*0.9,200,80);


}
void draw(){
  switch(screen) {
    case 0: ecranAccueil(); cursor(); break;  // Affichage Ecran Accueil
    case 1: background(fondJeu);              // Passage en mode Jeu                    
            noCursor();
            if((int)random(0,100)<=dropRate) ajouterEnnemis();
            bougerEnnemi();
            bougerVaisseau();
            collision();
            affichage();
            textFont(texte,20);
            text("Space/Espace : Pause",width-140,20);
            String score = "Score : "+playerScore;
            text(score,40,20);
            if(espace){
              screen=0;
            }
            break;
   case 2: ecranOptions(); break;             // Ecran Options     
   case 3: ecranCopyrights(); break;          // Ecran Copyrights      
   case 4: ecranSortie(); break;
  }
}

//
// Utilisation de la souris ecran d'accueil
//
void mousePressed(){
  if (screen == 0){ // Ecran Accueil
   if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height/3)+40 && mouseY>(height/3)-40) screen=1; //Click Souris sur Play/Jouer
   if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height>>1)+40 && mouseY>(height>>1)-40) screen=2; // Click Souris sur Options
   if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height*0.67)+40 && mouseY>(height*0.67)-40) screen=3; // Click Souris sur Copyrights
   if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height*0.84)+40 && mouseY>(height*0.84)-40) screen=4; // Click Souris sur Fin
  }
  if(screen == 2){ // Ecran Options
    if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height*0.9)+40 && mouseY>(height*0.9)-40){
      cp5.getController("Taille Enemis").setVisible(false);
      cp5.getController("Taille Vaisseau").setVisible(false);
      cp5.getController("Vitesse Ennemis").setVisible(false);
      cp5.getController("Vitesse Vaisseau").setVisible(false);
      cp5.getController("Volume musique").setVisible(false);
      cp5.getController("Volume Explosion").setVisible(false);
      cp5.getController("Chance d'apparation d'un ennemi").setVisible(false);
      
      tEnnemis =(int) cp5.getController("Taille Enemis").getValue();
      tVaisseau = (int) cp5.getController("Taille Vaisseau").getValue();
      vSpeed =(int) cp5.getController("Vitesse Vaisseau").getValue();
      eSpeed =(int) cp5.getController("Vitesse Ennemis").getValue();
      dropRate =(int) cp5.getController("Chance d'apparation d'un ennemi").getValue()/2;  
      volumeE=cp5.getController("Volume Explosion").getValue()/100;
      volumeM=cp5.getController("Volume musique").getValue()/100;
     
      aireT = triangleA(xVaisseau, yVaisseau,xVaisseau+tVaisseau, (yVaisseau-(tVaisseau>>1)), xVaisseau+tVaisseau, (yVaisseau+(tVaisseau>>1)));
      music.amp(volumeM);
      explode.amp(volumeE);
      
      
      screen=0;
    }
  }
  if (screen == 3){ // Ecran Copyrights
    if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height*0.9)+40 && mouseY>(height*0.9)-40) screen=0; //Retour Accueil
  }
  if (screen == 4){ // Ecran Leave
    if (mouseX<(width*0.75)+100 && mouseX>(width*0.75)-100 && mouseY<(height>>1)+40 && mouseY>(height>>1)-40) screen=0; //Retour Accueil
    if (mouseX<(width>>2)+100 && mouseX>(width>>2)-100 && mouseY<(height>>1)+40 && mouseY>(height>>1)-40) exit();
  }
}

//
// Définition Ecran accueil
//
void ecranAccueil(){
  
  background(fondAccueil);
  noFill();
  stroke(0,0,0);
  rectMode(CENTER);
  textFont(titre,75);
  textAlign(CENTER);
  fill(255,0,0);
  text("ASTROBREAKER",width>>1,height/5);
  textFont(titre,28);
  noFill();
  if( (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height/3)+40 && mouseY>(height/3)-40) ){ //Souris sur PLAY / JOUER
   fill(255,50);
  } else noFill();
  rect(width>>1,height/3,200,80);
  fill(255,0,0);
  text("PLAY / JOUER",width>>1,(height/3)+10); 
  if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height>>1)+40 && mouseY>(height>>1)-40) { // Souris sur Options
  fill(255,50);
  } else noFill();
  rect(width>>1,height>>1,200,80);
  fill(255,0,0);
  text("Options",width>>1,(height>>1)+10);
  if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height*0.67)+40 && mouseY>(height*0.67)-40) { // Copyrights
  fill(255,50);
  } else noFill();
  rect(width>>1,height*0.67,200,80);
  fill(255,0,0);
  text("Copyrights",width>>1,height*0.67+10);
  if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height*0.84)+40 && mouseY>(height*0.84)-40) { // Fin
  fill(255,50);
  } else noFill();
  rect(width>>1,height*0.84,200,80);
  fill(255,0,0);
  text("Exit / Quitter",width>>1,height*0.84+10);
}
void ajouterEnnemis(){
  xE.add(0);
  yE.add((int)(Math.random()*(height-tEnnemis))+(tEnnemis/2));  
}

 void bougerEnnemi(){
  for(int i=0;i<xE.size();i++){
    xE.set(i,xE.get(i)+eSpeed);
  }
}



void ecranCopyrights(){
  background(fondJeu);
  textAlign(CENTER);
  textFont(titre,75);
  fill(255,0,0);
  text("Copyrights",width>>1,height/5);
  textFont(texte,30);
  text("blablablablablablablablablablablablablabla",width>>1,height/3);
  text("blablablablablablablablablablablablablabla",width>>1,height/3+40);
  text("blablablablablablablablablablablablablabla",width>>1,height/3+80);
  text("blablablablablablablablablablablablablabla",width>>1,height/3+120);
  text("blablablablablablablablablablablablablabla",width>>1,height/3+160);
  text("blablablablablablablablablablablablablabla",width>>1,height/3+200);
  text("Back / Retour",width>>1,height*0.9+10);
  if (mouseX<(width>>1)+100 && mouseX>(width>>1)-100 && mouseY<(height*0.9)+40 && mouseY>(height*0.9)-40) { // Retour
    fill(255,50);
  }
  else noFill();
  rect(width>>1,height*0.9,200,80);
}

void ecranSortie(){
  background(fondAccueil);
  textAlign(CENTER);
  fill(255,0,0);
  textFont(texte,30);
  text("Êtes-vous sûr de vouloir quitter ?",width>>1,height/3);
  if (mouseX<(width>>2)+100 && mouseX>(width>>2)-100 && mouseY<(height>>1)+40 && mouseY>(height>>1)-40) { // Retour
    fill(255,50);
  }
  else noFill();
  rect(width>>2,height>>1,200,80);
  if (mouseX<(width*0.75)+100 && mouseX>(width*0.75)-100 && mouseY<(height>>1)+40 && mouseY>(height>>1)-40) { // Retour
    fill(255,50);
  }
  else noFill();
  rect(width*0.75,height>>1,200,80);
  textFont(texte,30);
  fill(255,0,0);
  text("Yes / Oui",width>>2,(height>>1)+10);
  text("No / Non",width*0.75,(height>>1)+10);
  
}

void bougerVaisseau(){
  if(up && (ys2>0))        yVaisseau-=vSpeed;
  if(down && (ys3<height)) yVaisseau+=vSpeed;
  if(left && (xs1>0))      xVaisseau-=vSpeed;
  if(right && (xs2<width)) xVaisseau+=vSpeed;
    
    // nouveau sommet triangle
  xs1=xVaisseau;
  ys1=yVaisseau;
  xs2=xVaisseau+tVaisseau;
  ys2=yVaisseau-(tVaisseau>>1);
  xs3=xVaisseau+tVaisseau;
  ys3=yVaisseau+(tVaisseau>>1);
}

void keyPressed(){
  switch(keyCode){
    case 32 : espace = true; break;
    case UP: up =        true; break;
    case DOWN : down =   true; break;
    case LEFT : left =   true; break;
    case RIGHT : right = true; break;
    case 90: up=          true; break;//z
    case 81: left=          true; break;//q
    case 83: down=          true; break;//s
    case 68: right=          true; break;//d
 }
}
void keyReleased(){
   switch(keyCode){
    case 32 : espace =      false; break;
    case UP : up =          false; break;
    case DOWN : down =      false; break;
    case LEFT : left =      false; break;
    case RIGHT : right =    false; break;
    case 90: up=            false; break;//z
    case 81: left=          false; break;//q
    case 83: down=          false; break;//s
    case 68: right=         false; break;//d
  }  
}

void Sound(){ //Fonction appelée lors de chaque colision qui produit un son
    explode.amp(volumeE);
    explode.play();
}

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
 
float triangleA(int px1, int py1 , int px2 ,int py2 ,int px3 , int py3){ // calcul l'aire d'un triangle
 
  float A , longA,longB,longC ,longD;
  // A = 1/2||AB vectoriel AC||
  longA=px1-px3;
  longB=py1-py3;
  longC=px2-px3;
  longD=py2-py3;
 
  A= 0.5*abs((longA*longD)-(longB*longC));
  return A;
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
 
void affichage(){
  int x,y;
 
  for(int i = 0;i<xE.size();i++){ // affiche chaque ennemi
    x = xE.get(i); y = yE.get(i);
    fill(255);
    stroke(0);
    imageMode(CENTER);
    image(asteroid,x,y,tEnnemis,tEnnemis);
    
    
   
  }
  fill(255,0,0);
  stroke(255,0,0);
  imageMode(CORNER);
  image(vaisseau,xs1,ys1-tVaisseau/2,tVaisseau,tVaisseau);
}
