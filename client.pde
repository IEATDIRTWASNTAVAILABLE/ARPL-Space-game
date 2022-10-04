import processing.net.*;
import java.util.*;
import java.nio.*;
Client me;
ArrayList<Ship> players=new ArrayList<Ship>();
ArrayList<Body> bodies=new ArrayList<Body>();
ArrayList<Body> planets=new ArrayList<Body>();
ArrayList<String> chat=new ArrayList<String>();
ArrayList<Score> scores=new ArrayList<Score>();
boolean[] keys=new boolean[65536];
boolean[] Skeys=new boolean[65536];
//PVector[] stars1=new PVector[1024];
//PVector[] stars2=new PVector[512];
//PVector[] stars3=new PVector[256];
double g=0.001;
double dt=1/240.0;
int myID=-1;
Ship myPlayer;
int selected=-1;
int followID=-1;
Body follow;
//PShader shader;
PImage dotsImg;
int dotCount = 256;
PVector[] dots = new PVector[dotCount];
PVector pos = new PVector(0,0);
String setLength(String text, int len) {
    return String.format("%-" + len + "." + len + "s", text);
}
float mod(float x, float y) {
    float result = x % y;
    if (result < 0)
    {
        result += y;
    }
    return result;
}
void setup() {
  size(1600,900,P2D);
  colorMode(RGB);
  //shader = loadShader("frag.glsl");
  //noLoop();
  for(int i=0;i<dotCount;i++) {
    dots[i] = new PVector(random(256),random(256),(floor(random(3))/2.0+1.0)*2.0);
  }
  dotsImg = createImage(min((dotCount*3),16384),(dotCount*3)/16384+1,ARGB);
  print(dotsImg.width+" "+dotsImg.height);
  dotsImg.loadPixels();
  for(int i=0;i<dotCount;i++) {
    dotsImg.pixels[i*3+0] = color(floor(mod(dots[i].x*256*256*256,256)),floor(mod(dots[i].x*256*256,256)),floor(mod(dots[i].x*256,256)),floor(mod(dots[i].x,256)));
    dotsImg.pixels[i*3+1] = color(floor(mod(dots[i].y*256*256*256,256)),floor(mod(dots[i].y*256*256,256)),floor(mod(dots[i].y*256,256)),floor(mod(dots[i].y,256)));
    dotsImg.pixels[i*3+2] = color(floor(mod(dots[i].z*256*256*256,256)),floor(mod(dots[i].z*256*256,256)),floor(mod(dots[i].z*256,256)),floor(mod(dots[i].z,256)));
  }
  dotsImg.updatePixels();
  String[] config=loadStrings("config.txt");
  String[] adress=split(config[0],":");
  String name=config[1].substring(0, Math.min(config[1].length(), 32));
  me=new Client(this,adress[0],Integer.parseInt(adress[1]));
  if(!me.active()) {
    System.exit(0);
  }
  ByteBuffer connectData=ByteBuffer.allocate(33);
  connectData.put((byte)1).put(setLength(name,32).getBytes());
  me.write(connectData.array());
  delay(1000);
  if(!me.active()) {
    System.exit(0);
  }
  byte[] data=me.readBytes();
  ByteBuffer dataBuffer=ByteBuffer.wrap(data);
  int i=0;
  while(i<data.length) {
    if(data[i]==0) {
      myID=dataBuffer.getInt(i+1);
      selected=myID;
      followID=myID;
      break;
    } else if(data[i]==1) {
      i+=dataBuffer.getInt(i+1);
    } else {
      i++;
    }
  }
  if(myID<0) {
    System.exit(0);
  }
  frameRate(60.0);
  //for(int j=0;j<stars1.length;j++) {
  //  stars1[j]=new PVector(random(0,2*width),random(0,2*height));
  //}
  //for(int j=0;j<stars2.length;j++) {
  //  stars2[j]=new PVector(random(0,2*width),random(0,2*height));
  //}
  //for(int j=0;j<stars3.length;j++) {
  //  stars3[j]=new PVector(random(0,2*width),random(0,2*height));
  //}
}
void itext(String t, double info, String unit, float textX, float textY) {
  text(t+Math.floor(1000*info)/1000+unit,textX,textY);
}
boolean chatting=false;
double zoom=1.0;
//byte[] data=new byte[65536];
void draw() {
  //int dataLength=me.readBytes(data);
  //if(dataLength>0) {
    
  byte[] data=me.readBytes();
  me.clear();
  if(data!=null&&data.length>0&&data[0]==1) {
    ByteBuffer dataBuffer=ByteBuffer.wrap(data);
    int i=1;
    players.clear();
    bodies.clear();
    planets.clear();
    scores.clear();
    g=dataBuffer.getDouble(i);
    i+=8;
    dt=dataBuffer.getDouble(i);
    i+=8;
    int planetBytes=dataBuffer.getInt(i);
    i+=4;
    int j=i;
    while(i-j<=planetBytes-56&&i<=data.length-56) {
      Body planet=new Body(dataBuffer.getDouble(i),dataBuffer.getDouble(i+8),dataBuffer.getDouble(i+16),dataBuffer.getDouble(i+24),dataBuffer.getDouble(i+32),dataBuffer.getDouble(i+40),dataBuffer.getInt(i+48),dataBuffer.getInt(i+52));
      bodies.add(planet);
      planets.add(planet);
      i+=56;
    }
    int shipBytes=dataBuffer.getInt(i);
    i+=4;
    j=i;
    while(i-j<=shipBytes-109&&i<=data.length-109) {
      Ship player=new Ship(dataBuffer.getDouble(i),dataBuffer.getDouble(i+8),dataBuffer.getDouble(i+16),dataBuffer.getDouble(i+24),dataBuffer.getDouble(i+32),dataBuffer.getDouble(i+40),dataBuffer.getInt(i+48),dataBuffer.getDouble(i+52),dataBuffer.getDouble(i+60),dataBuffer.getDouble(i+68),dataBuffer.get(i+76),(new String(subset(data,i+77,32))).trim());
      bodies.add(player);
      players.add(player);
      i+=109;
    }
    int chatBytes=dataBuffer.getInt(i);
    i+=4;
    j=i;
    while(i-j<=chatBytes-128&&i<=data.length-128) {
      chat.add(0,(new String(subset(data,i,128))).trim());
      if(chat.size()>8) {
        chat.remove(8);
      }
      i+=128;
    }
    int scoreBytes=dataBuffer.getInt(i);
    i+=4;
    j=i;
    while(i-j<=scoreBytes-8&&i<=data.length-8) {
      scores.add(new Score(dataBuffer.getInt(i),dataBuffer.getInt(i+4)));
      i+=8;
    }
  }
  double centerPosX=0;
  double centerPosY=0;
  double centerVelX=0;
  double centerVelY=0;
  double totalMass=0;
  for(float i=0;i<1.0/60.0;i+=dt) {
    for(Body body : bodies) {
      body.updateVelocity(bodies);
      centerPosX+=body.posX*body.mass;
      centerPosY+=body.posY*body.mass;
      centerVelX+=body.velX*body.mass;
      centerVelY+=body.velY*body.mass;
      totalMass+=body.mass;
      if(body.index==followID) {
        follow=body;
      }
    }
    for(Body body : bodies) {
      body.updatePosition();
      body.posX-=centerPosX/totalMass;
      body.posY-=centerPosY/totalMass;
      body.velX-=centerVelX/totalMass;
      body.velY-=centerVelY/totalMass;
    }
    for(Body body : bodies) {
      body.updateCollisions();
    }
  }
  for(Ship player : players) {
    if(player.index==myID) {
      myPlayer=player;
      myPlayer.angle = Math.atan2(mouseY-height/2,mouseX-width/2);
    }
  }
  background(0);
  if(myPlayer!=null) {
    double posX=follow.posX;
    double posY=follow.posY;
    //shader(shader);
    //shader.set("dotCount",dotCount);
    //shader.set("zoom",(float)zoom);
    //shader.set("ratio",float(width)/float(height));
    //shader.set("dotsTexture",dotsImg);
    //shader.set("pos",(float)(posX/height),(float)(posY/height));
    //rect(0,0,width,height);
    //resetShader();
    Body selectedBody=new Body(0,0,0,0,0,0,0,-1);
    for(Body planet : planets) {
      double rx=planet.posX-posX;
      double ry=planet.posY-posY;
      float x=(float)(rx*zoom)+width/2;
      float y=(float)(ry*zoom)+height/2;
      float r=(float)(planet.radius*zoom);
      fill((color)planet.clr);
      //fill(255);
      noStroke();
      circle(x,y,2*r);
      circle(x,y,2.5);
      if(planet.index==selected) {
        noFill();
        stroke(255,255,0);
        rect(x-max(r*1.25,2.5),y-max(r*1.25,2.5),max(2.5*r,5),max(2.5*r,5));
        selectedBody=planet;
      }
    }
    for(Ship player : players) {
      double rx=player.posX-posX;
      double ry=player.posY-posY;
      float x=(float)(rx*zoom)+width/2;
      float y=(float)(ry*zoom)+height/2;
      float r=(float)(player.radius*zoom);
      double dirX=Math.cos(player.angle);
      double dirY=Math.sin(player.angle);
      noStroke();
      if((player.thrustDir&1)>0) {
        fill(255,127,0,255);
        float v1x=(float)((rx-(dirY/2.5)*player.radius)*zoom);
        float v1y=(float)((ry+(dirX/2.5)*player.radius)*zoom);
        float v2x=(float)((rx-dirX*player.radius*12*random(0.98,1.02))*zoom);
        float v2y=(float)((ry-dirY*player.radius*12*random(0.98,1.02))*zoom);
        float v3x=(float)((rx+(dirY/2.5)*player.radius)*zoom);
        float v3y=(float)((ry-(dirX/2.5)*player.radius)*zoom);
        beginShape();
          vertex(v1x+width/2.0,v1y+height/2.0);
          vertex(v2x+width/2.0,v2y+height/2.0);
          vertex(v3x+width/2.0,v3y+height/2.0);
        endShape(CLOSE);
      }
      if((player.thrustDir&2)>0) {
        fill(255,127,0,255);
        float v1x=(float)((rx+(dirX/2.5)*player.radius)*zoom);
        float v1y=(float)((ry+(dirY/2.5)*player.radius)*zoom);
        float v2x=(float)((rx-dirY*player.radius*12*random(0.98,1.02))*zoom);
        float v2y=(float)((ry+dirX*player.radius*12*random(0.98,1.02))*zoom);
        float v3x=(float)((rx-(dirX/2.5)*player.radius)*zoom);
        float v3y=(float)((ry-(dirY/2.5)*player.radius)*zoom);
        beginShape();
          vertex(v1x+width/2.0,v1y+height/2.0);
          vertex(v2x+width/2.0,v2y+height/2.0);
          vertex(v3x+width/2.0,v3y+height/2.0);
        endShape(CLOSE);
      }
      if((player.thrustDir&4)>0) {
        fill(255,127,0,255);
        float v1x=(float)((rx-(dirY/2.5)*player.radius)*zoom);
        float v1y=(float)((ry+(dirX/2.5)*player.radius)*zoom);
        float v2x=(float)((rx+dirX*player.radius*12*random(0.98,1.02))*zoom);
        float v2y=(float)((ry+dirY*player.radius*12*random(0.98,1.02))*zoom);
        float v3x=(float)((rx+(dirY/2.5)*player.radius)*zoom);
        float v3y=(float)((ry-(dirX/2.5)*player.radius)*zoom);
        beginShape();
          vertex(v1x+width/2.0,v1y+height/2.0);
          vertex(v2x+width/2.0,v2y+height/2.0);
          vertex(v3x+width/2.0,v3y+height/2.0);
        endShape(CLOSE);
      }
      if((player.thrustDir&8)>0) {
        fill(255,127,0,255);
        float v1x=(float)((rx+(dirX/2.5)*player.radius)*zoom);
        float v1y=(float)((ry+(dirY/2.5)*player.radius)*zoom);
        float v2x=(float)((rx+dirY*player.radius*12*random(0.98,1.02))*zoom);
        float v2y=(float)((ry-dirX*player.radius*12*random(0.98,1.02))*zoom);
        float v3x=(float)((rx-(dirX/2.5)*player.radius)*zoom);
        float v3y=(float)((ry-(dirY/2.5)*player.radius)*zoom);
        beginShape();
          vertex(v1x+width/2.0,v1y+height/2.0);
          vertex(v2x+width/2.0,v2y+height/2.0);
          vertex(v3x+width/2.0,v3y+height/2.0);
        endShape(CLOSE);
      }
      if(player.index==myID) {
        fill(0,255,255);
      } else {
        fill(255,0,0);
      }
      beginShape();
      vertex((float)((rx-(dirX+dirY)*player.radius*0.7071)*zoom)+width/2.0,(float)((ry-(dirY-dirX)*player.radius*0.7071)*zoom)+height/2.0);
      vertex((float)((rx+dirX*player.radius)*zoom)+width/2.0,(float)((ry+dirY*player.radius)*zoom)+height/2.0);
      vertex((float)((rx-(dirX-dirY)*player.radius*0.7071)*zoom)+width/2.0,(float)((ry-(dirY+dirX)*player.radius*0.7071)*zoom)+height/2.0);
      endShape(CLOSE);
      circle(x,y,2.5);
      fill(255);
      textSize(12);
      text(player.name,x-player.name.length()*3,y-r-5);
      if(player.index==selected) {
        noFill();
        stroke(255,0,0);
        rect(x-max(r*1.25,2.5),y-max(r*1.25,2.5),max(2.5*r,5),max(2.5*r,5));
        selectedBody=player;
      }
    }
    for(Body planet : bodies) {
      double rx=planet.posX-selectedBody.posX;
      double ry=planet.posY-selectedBody.posY;
      double vx=(planet.velX-selectedBody.velX);
      double vy=(planet.velY-selectedBody.velY);
      double v=Math.sqrt(vx*vx+vy*vy);
      double dist=Math.sqrt(rx*rx+ry*ry);
      double gm=(selectedBody.mass+planet.mass)*g;
      double sma=1/(2/dist-v*v/gm);
      double Ex=((v*v-gm/dist)*rx-(rx*vx+ry*vy)*vx)/gm;
      double Ey=((v*v-gm/dist)*ry-(rx*vx+ry*vy)*vy)/gm;
      double E=Math.sqrt(Ex*Ex+Ey*Ey);
      double argP=Math.atan2(Ey,-Ex);
      double maxTheta=Math.acos(-Math.min(1/E,1));
      double dTheta=1/180d;
      double R=sma*(1-E*E)/(1-E*Math.cos(Math.PI-maxTheta));
      if(E<1&&planet.mass>=10) {
        double startX=R*Math.cos(Math.PI-maxTheta-argP)+selectedBody.posX-posX;
        double startY=R*Math.sin(Math.PI-maxTheta-argP)+selectedBody.posY-posY;
        double dotX=startX;
        double dotY=startY;
        stroke(red((color)planet.clr),green((color)planet.clr),blue((color)planet.clr),63);
        if(planet==myPlayer) {
          stroke(0,255,255,127);
        } else if(players.contains(planet)) {
          stroke(255,0,0,127);
        }
        for(double theta=Math.PI-maxTheta-argP;theta<Math.PI+maxTheta-argP+dTheta;theta+=dTheta) {
          R=sma*(1-E*E)/(1-E*Math.cos(theta+argP));
          double Rx=R*Math.cos(theta)+selectedBody.posX-posX;
          double Ry=R*Math.sin(theta)+selectedBody.posY-posY;
          line((float)(Rx*zoom)+width/2,(float)(Ry*zoom)+height/2,(float)(dotX*zoom)+width/2,(float)(dotY*zoom)+height/2);
          dotX=Rx;
          dotY=Ry;
        }
      }
      if(planet==follow) {
      textSize(20);
      fill(255);
      noStroke();
      double va=(rx/dist*vx+ry/dist*vy);
      double vlx=vx-rx/dist*va;
      double vly=vy-ry/dist*va;
      double vl=Math.sqrt(vlx*vlx+vly*vly);
      int tY=0;
      int tX=8;
      itext("rvelX: ",vx,"m/s",tX,tY+=24);
      itext("rvelY: ",vy,"m/s",tX,tY+=24);
      itext("vel total: ",v,"m/s",tX,tY+=24);
      itext("vel away: ",va,"m/s",tX,tY+=24);
      itext("vel lateral: ",vl,"m/s",tX,tY+=24);
      itext("orbital vel: ",Math.sqrt(gm/dist),"m/s",tX,tY+=24);
      tY+=24;
      itext("rposX: ",rx,"m",tX,tY+=24);
      itext("rposY: ",ry,"m",tX,tY+=24);
      itext("dist: ",dist,"m",tX,tY+=24);
      itext("dist surface: ",dist-selectedBody.radius,"m",tX,tY+=24);
      tY+=24;
      itext("gravity: ",gm/(dist*dist),"m/s^2",tX,tY+=24);
      itext("surface gravity: ",gm/(selectedBody.radius*selectedBody.radius),"m/s^2",tX,tY+=24);
      itext("tidal forces: ",gm/(dist*dist*dist),"m/s^2/m",tX,tY+=24);
      tY+=24;
      //tY=0;
      //tX+=320;
      itext("semi-major axis: ",sma,"m",tX,tY+=24);
      itext("eccentricity: ",E,"",tX,tY+=24);
      itext("periapsis(ASL): ",(sma*(1-E)-selectedBody.radius),"m",tX,tY+=24);
      itext("apoapsis(ASL): ",(sma*(1+E)-selectedBody.radius),"m",tX,tY+=24);
      itext("argument of periapsis: ",(360+argP/Math.PI*180.0)%360-180,"°",tX,tY+=24);
      double T=Math.PI-(argP+Math.atan2(posY-selectedBody.posY,posX-selectedBody.posX)+2*Math.PI)%(2*Math.PI);
      double M=Math.atan2(-Math.sqrt(1-E*E)*Math.sin(T),-(E+Math.cos(T)))+Math.PI-E*Math.sqrt(1-E*E)*Math.sin(T)/(1+E*Math.cos(T));
      double To=sma*Math.sqrt(sma/gm);
      itext("true anomaly: ",T/Math.PI*180.0,"°",tX,tY+=24);
      itext("orbital period: ",2*Math.PI*To,"s",tX,tY+=24);
      itext("time until peri: ",To*((2*Math.PI-M)%(2*Math.PI)),"s",tX,tY+=24);
      itext("time until apo: ",To*((3*Math.PI-M)%(2*Math.PI)),"s",tX,tY+=24);
      tY+=24;
      itext("fuel: ",myPlayer.fuel,"kg",tX,tY+=24);
      itext("thrust(booster): ",myPlayer.thrust/myPlayer.mass,"m/s^2",tX,tY+=24);
      double apoX=Math.cos(argP)*sma*(1+E)+selectedBody.posX;
      double apoY=-Math.sin(argP)*sma*(1+E)+selectedBody.posY;
      double periX=-Math.cos(argP)*sma*(1-E)+selectedBody.posX;
      double periY=Math.sin(argP)*sma*(1-E)+selectedBody.posY;
      //line((float)((apoX-posX)*zoom)+width/2,(float)((apoY-posY)*zoom)+height/2,(float)((periX-posX)*zoom)+width/2,(float)((periY-posY)*zoom)+height/2);
      if(E<1) {
        fill(255,255,255);
        circle((float)((selectedBody.posX-posX)*zoom)+width/2,(float)((selectedBody.posY-posY)*zoom)+height/2,2.5);
        fill(255,127,0);
        circle((float)((periX-posX)*zoom)+width/2,(float)((periY-posY)*zoom)+height/2,2.5);
        fill(0,255,127);
        circle((float)((apoX-posX)*zoom)+width/2,(float)((apoY-posY)*zoom)+height/2,2.5);
      }
      fill(255,255,255);
      tY=0;
      for(Score score : scores) {
        for(Ship player : players) {
          if(player.index==score.index) {
            text(player.name.trim()+" "+score.score,width/2,tY+=24);
          }
        }
      }
      stroke(0,0,255);
      line(width/2,height/2,(float)(width/2+vx/v*height/6),(float)(height/2+vy/v*height/6));
      stroke(255,0,0);
      line(width/2,height/2,(float)(width/2-rx/dist*height/6),(float)(height/2-ry/dist*height/6));
      stroke(0,255,255);
      line(width/2,height/2,(float)(width/2+Math.cos(myPlayer.angle)*height/6),(float)(height/2+Math.sin(myPlayer.angle)*height/6));
      }
    }
    byte moveCode=byte(((int(keys['w'])*1+int(keys['a'])*2+int(keys['s'])*4+int(keys['d'])*8+int(keys['h'])*64)*int(!chatting)+int(mousePressed&&(mouseButton==LEFT))*16+int(mousePressed&&(mouseButton==RIGHT))*32));
    ByteBuffer dataSend=ByteBuffer.allocate(14);
    dataSend.put((byte)2).put(moveCode).putInt(selected).putDouble(Math.atan2(mouseY-height/2,mouseX-width/2));
    me.write(dataSend.array());
  } else {
    textSize(20);
    fill(255);
    int tY=0;
    text("Player not found",8,tY+=24);
    text("Player index: "+myID,8,tY+=24);
    text("Object count: "+bodies.size(),8,tY+=24);
  }
  textSize(20);
  fill(255);
  int y=height-8;
  if(chatting) {
    text("> "+msg+"|",8,y);
  }
  y-=24;
  for(String str : chat) {
    text(str,8,y);
    y-=24;
  }
}
void mouseWheel(MouseEvent e) {
  int count=e.getCount();
  zoom=Math.max(zoom*(1.0-count/10.0),0.0001);
}
String msg="";
void keyPressed() {
  if(key==CODED) {
    Skeys[keyCode]=true;
  } else {
    keys[key]=true;
    if(chatting) {
      if(key==ENTER) {
        if(msg.length()>0) {
          ByteBuffer dataSend=ByteBuffer.allocate(129);
          dataSend.put((byte)3).put(setLength(msg,128).getBytes());
          me.write(dataSend.array());
          msg="";
        }
        chatting=false;
      } else if(key==BACKSPACE) {
        msg=msg.substring(0,max(msg.length()-1,0));
      } else {
        msg+=key;
      }
    } else {
      if(key==TAB) {
        double minDist=-1;
        for(Body body : bodies) {
          double rx=(body.posX-follow.posX)-(mouseX-width/2)/zoom;
          double ry=(body.posY-follow.posY)-(mouseY-height/2)/zoom;
          double dist=rx*rx+ry*ry;
          if(dist<minDist||minDist<0) {
            minDist=dist;
            selected=body.index;
          }
        }
        if(minDist*zoom*zoom>192*192) {
          selected=-1;
        }
      } else if(key=='r') {
        followID=myID;
      } else if(key=='f') {
        double minDist=-1;
        for(Body body : bodies) {
          double rx=(body.posX-follow.posX)-(mouseX-width/2)/zoom;
          double ry=(body.posY-follow.posY)-(mouseY-height/2)/zoom;
          double dist=rx*rx+ry*ry;
          if(dist<minDist||minDist<0) {
            minDist=dist;
            followID=body.index;
          }
        }
      } else if(key==ENTER) {
        chatting=true;
      }
    }
  }
}
void keyReleased() {
  if(key==CODED) {
    Skeys[keyCode]=false;
  } else {
    keys[key]=false;
  }
}
