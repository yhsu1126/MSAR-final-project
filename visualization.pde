import ddf.minim.*;
import ddf.minim.analysis.*;
import java.util.*;
int density = 1;
int start = 0;
class fadeLine
{
  public float x,y;
  public int alpha;
  public float fill_color;
  fadeLine(float x,float y, float c, int a)
  {
    this.x = x;
    this.y = y;
    this.fill_color = c;
    this.alpha = a;
  }
}
class polygon
{
   public float[] xlist,ylist;
   public int alpha;
   public int ptr;
   polygon(int a,int size)
   {
     this.alpha = a;
     xlist = new float[size];
     ylist = new float[size];
     ptr = 0;
   }
   public void addVertex(float x,float y)
   {
     xlist[ptr] = x;
     ylist[ptr] = y;
     ptr = ptr + 1;
   }
}
Minim minim;
AudioPlayer player;
AudioMetaData meta;
BeatDetect beat;
int  r = 300;
float rad = 0;
float radMax,radMin;
int time;
float scaling;
float bound,bound2;
int song_length;
PImage background;
LinkedList[] manager;
boolean firstTime = true;
LinkedList pManager;
int[] count;
void setup()
{
  //size(displayWidth, displayHeight);
  size(1600, 900);
  //fullScreen();
  smooth();
  minim = new Minim(this);
  selectInput("Select a music to play:", "folderSelected");
  background = loadImage("temp.jpg");
  float scale=(float)(width)/(float)(background.width);
  background.resize((int)Math.ceil(background.width*scale),(int)(Math.ceil(background.height*scale)));
  r = height*3/8;
  radMax = height/8;
  scaling = radMax;
  radMin = radMax*9/10;
  bound = radMin + (radMax - radMin)*50/100;
  bound2 = radMin + (radMax - radMin)*90/100;
}
void draw()
{ 
  int i;
  try
  {
    beat.detect(player.mix);
    //fill(#1A1F18, 20);
    int bsize = player.bufferSize();
    float max=0;
    for (i = 0; i < bsize ; i+=density)
    {
      max = max > player.left.get(i)*100?max:player.left.get(i)*100;
    }
    float filled = map(max,0,100,50,255);
    float polygon_f = map(max,0,100,0,255);
    fill(filled,100);
    noStroke();
    //rect(0, 0, width, height);
    image(background,0,0);
    translate(width/2, height/2);
    noFill();
    stroke(-1, 50);
    strokeWeight(2);
    fadeLine tmp;
    polygon p = new polygon((int)polygon_f, bsize );
    for ( i = 0; i < bsize; i+=density)
    {
      float x2 = (r + player.left.get(i)*scaling)*cos(i*2*PI/bsize);
      float y2 = (r + player.left.get(i)*scaling)*sin(i*2*PI/bsize);
      //max = max > player.left.get(i)*100?max:player.left.get(i)*100;
      count[i]=0;
      //stroke(filled);
      //line(x, y, x2, y2);
      p.addVertex(x2,y2);
      tmp = new fadeLine(x2,y2,filled,150);
      manager[i].addLast(tmp);
    }
    pManager.addLast(p);
    float rad = map((int)(max),0,100,radMin,radMax);
    for( i = 0;i<bsize;i+=density)
    {
      ListIterator<fadeLine> ptr = manager[i].listIterator();
      float x = (r)*cos(i*2*PI/bsize);
      float y = (r)*sin(i*2*PI/bsize);
      while(ptr.hasNext())
      {
         tmp = ptr.next();
         stroke(tmp.fill_color,tmp.alpha);
         line(x,y,tmp.x,tmp.y);
         if(rad > bound2){
           tmp.alpha = tmp.alpha - 50;
          }
          else if(rad > bound){
            tmp.alpha = tmp.alpha - 20;
          }
          else{
            tmp.alpha = tmp.alpha - 15;
          }
         if(tmp.alpha<0)
         {
            count[i]=count[i]+1;
         }
      }
    }
    for( i = 0;i<bsize ;i+=density)
    {
      while(count[i]>0)
      {
         manager[i].removeFirst();
         count[i]=count[i]-1;
      }
    }
    noStroke();
    //fill(150, 100);
    //fill(filled,100);
    if(beat.isOnset())
    {
      fill(255,100);
      ellipse(0,0,2*rad,2*rad);
    }
    else
    {
      fill(150,100);
      ellipse(0,0,2*radMin,2*radMin  );
    }
    noFill();
    ListIterator<polygon> j = pManager.listIterator();
    int pcount = 0;
    while(j.hasNext())
    {
      polygon tp = j.next();
      stroke(255,0,0,tp.alpha);
      strokeWeight(2);
      beginShape();
       for(i = 0; i < tp.ptr ;i += 5)
       {
         vertex(tp.xlist[i],tp.ylist[i]);
       }
      endShape(CLOSE);
      tp.alpha = tp.alpha -100;
      if(tp.alpha <0)
      {
        pcount = pcount +1;
      }
    }
    while(pcount > 0)
    {
      pManager.removeFirst();
      pcount = pcount -1;
    }
  }
  catch (Exception e)
  {
     image(background,0,0);
     translate(width/2, height/2);
     noFill();
     stroke(-1, 50);
     int bsize = 1024;
     for (i = 0; i < bsize - 1; i+=density)
     {
      float x = (r)*cos(i*2*PI/bsize);
      float y = (r)*sin(i*2*PI/bsize);
      float x2 = (r)*cos(i*2*PI/bsize);
      float y2 = (r)*sin(i*2*PI/bsize);
      //max = max > player.left.get(i)*100?max:player.left.get(i)*100;
      stroke(50);
      line(x, y, x2, y2);
     }
     noStroke();
     fill(150,100);
     ellipse(0,0,180,180);
  }
}

//
/*boolean sketchFullScreen() {
  return false;
}*/

void keyPressed() {
  if(key==' ')
  {
   exit();
  }
  if(key=='s')
  {
    //saveFrame("###.jpeg");
    try
    {
      player.pause();
    }
    catch(Exception e)
    {
       ;
    }
    selectInput("Select a folder to process:", "folderSelected");
  }
  if(key=='p')
  {
    if(player.isPlaying())
    {
       player.pause();
    }
    else
    {
       player.play();
    }
  }
}

void folderSelected(File selection) {
  if(firstTime){
    firstTime = false;
  }
  else{
    player.close();
  }
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    player = minim.loadFile(selection.getAbsolutePath());
    meta = player.getMetaData();
    beat = new BeatDetect();
    //beat.detectMode(BeatDetect.SOUND_ENERGY);
    //beat.setSensitivity(1);
    time = meta.length();
    song_length = meta.length();
    manager = new LinkedList[player.bufferSize()];
    pManager=new LinkedList<polygon>();
    for(int i = 0;i< player.bufferSize();i+=density)
    {
       manager[i]=new LinkedList<fadeLine>();
    }
    count = new int[player.bufferSize()];
    player.loop();
  }
}