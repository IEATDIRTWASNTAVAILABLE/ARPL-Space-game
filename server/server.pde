import processing.net.*;
import java.util.*;
import java.nio.*;
ArrayList<Body> bodies=new ArrayList<Body>();
ArrayList<Body> planets=new ArrayList<Body>();
ArrayList<Body> spawns=new ArrayList<Body>();
ArrayList<Body> killers=new ArrayList<Body>();
ArrayList<Player> players=new ArrayList<Player>();
ArrayList<Ship> ships=new ArrayList<Ship>();
ArrayList<MissileControllable> missiles=new ArrayList<MissileControllable>();
Server server;
ArrayList<Client> disconnectList=new ArrayList<Client>();
double dt=1.0/240.0;
double g=0.001;
int num=0;
String setLength(String text, int len) {
    return String.format("%-" + len + "." + len + "s", text);
}
Body addPlanet(double x, double y, double vx, double vy, double r, double m, double lt, int clr) {
  Body b=new Body(x,y,vx,vy,r,m,lt,clr,num);
  num++;
  bodies.add(b);
  planets.add(b);
  spawns.add(b);
  return b;
}
Body addStar(double x, double y, double vx, double vy, double r, double m, double lt, int clr) {
  Body b=new Body(x,y,vx,vy,r,m,lt,clr,num);
  num++;
  bodies.add(b);
  planets.add(b);
  return b;
}
void orbit(Body planet, Body moon, double dir) {
  double dx=planet.posX-moon.posX;
  double dy=planet.posY-moon.posY;
  double distSq=dx*dx+dy*dy;
  double dist=Math.sqrt(distSq);
  double v=Math.sqrt(g*(planet.mass+moon.mass)/dist);
  double vx=-v*dy/dist*dir;
  double vy=v*dx/dist*dir;
  moon.velX=planet.velX+vx;
  moon.velY=planet.velY+vy;
}
void orbitSEM(Body planet, Body moon, double sma, double ecc, double M, double argP, double dir) {
  double slr=sma*(1-ecc*ecc);
  double gm=g*(planet.mass+moon.mass);
  double r=slr/(1+ecc*Math.cos(M));
  double rx=r*Math.cos(M+argP);
  double ry=r*Math.sin(M+argP);
  double vt=Math.sqrt(gm/slr)*(1+ecc*Math.cos(M));
  double vr=Math.sqrt(gm/slr)*ecc*Math.sin(M);
  double vx=(vr*Math.cos(M+argP)-vt*Math.sin(M+argP))*dir;
  double vy=(vt*Math.cos(M+argP)+vr*Math.sin(M+argP))*dir;
  moon.posX=planet.posX+rx;
  moon.posY=planet.posY+ry;
  moon.velX=planet.velX+vx;
  moon.velY=planet.velY+vy;
}
void orbitAEM(Body planet, Body moon, double apo, double ecc, double M, double argP, double dir) {
  orbitSEM(planet,moon,apo/(1+ecc),ecc,M,argP,dir);
}
void orbitPEM(Body planet, Body moon, double peri, double ecc, double M, double argP, double dir) {
  orbitSEM(planet,moon,peri/(1-ecc),ecc,M,argP,dir);
}
void orbitPAM(Body planet, Body moon, double peri, double apo, double M, double argP, double dir) {
  orbitSEM(planet,moon,(apo+peri)/2.0,(apo-peri)/(apo+peri),M,argP,dir);
}
void orbitTEM(Body planet, Body moon, double period, double ecc, double M, double argP, double dir) {
  orbitSEM(planet,moon,Math.cbrt(g*(planet.mass+moon.mass)*period*period/(4*Math.PI*Math.PI)),ecc,M,argP,dir);
}
void writeChat(String msg) {
  chat.add(setLength(msg,128));
}
double scale=1;
void setup() {
  server=new Server(this,42069);
  //Body star=addStar(0,0,0,0,200,2000000000000d,-1);
  //Body p1=addPlanet(7500,0,0,0,30,100000000d,-1);
  //orbit(star,p1,1.0);
  //Body p2=addPlanet(p1.posX+80,0,0,0,10,10000000d,-1);
  //orbit(p1,p2,1.0);
  //Body p3=addStar(7500/Math.pow(4,1/1.5),0,0,0,50,500000000d,-1);
  //orbit(star,p3,1.0);
  //Body p4=addStar(7500*Math.pow(2,1/1.5),0,0,0,100,3000000000d,-1);
  //orbit(star,p4,1.0);
  //Body p5=addPlanet(0,0,0,0,7.5,2500000d,-1);//225
  //Body p6=addPlanet(0,0,0,0,12.5,10000000d,-1);
  //Body p7=addStar(p6.posX+20,0,0,0,2.5,100000d,-1);
  //orbitTEM(p4,p5,15,0,0,0,1);
  //orbitTEM(p4,p6,30,0,0,0,1);
  //orbitSEM(p6,p7,20,0,0,0,-1);
  //Body p8=addStar(600,0,0,0,25,100000000d,-1);
  //orbitPAM(star,p8,600,17000,Math.PI*0.8,-Math.PI*0.04,1);
  
  //Body star=addStar(0,0,0,0,500*scale,500000000000d*scale*scale,-1,color(255,255,127));
  //Body p1=addStar(0,0,0,0,10*scale,3000000d*scale*scale,-1,color(159,127,63));
  //Body p2=addPlanet(0,0,0,0,20*scale,12500000d*scale*scale,-1,color(239,223,191));
  //orbitTEM(star,p1,42,0.3,Math.PI,Math.PI*0.4,-1.0);
  //orbitTEM(star,p2,42*2,0.0,Math.PI*0.4,0,-1.0);
  //Body p3=addPlanet(0,0,0,0,25*scale,12500000d*scale*scale,-1,color(63,127,255));
  //Body p4=addPlanet(0,0,0,0,5*scale,400000d*scale*scale,-1,color(127,111,95));
  //orbitTEM(star,p3,42*4,0.1,0,Math.PI*0.9,-1.0);
  //orbitSEM(p3,p4,50*scale,0,0,0,-1.0);
  //Body p5=addStar(0,0,0,0,75*scale,500000000d*scale*scale,-1,color(239,191,159));
  //Body p6=addPlanet(0,0,0,0,10*scale,2000000d*scale*scale,-1,color(127,127,127));//225
  //Body p7=addPlanet(0,0,0,0,15*scale,6000000d*scale*scale,-1,color(127,127,127));
  //Body p8=addStar(0,0,0,0,2.5,100000d,-1,color(127,127,127));
  //orbitTEM(star,p5,42*8,0.0,0,0,-1.0);
  //orbitTEM(p5,p6,20,0,0,0,1);
  //orbitTEM(p5,p7,40,0,0,0,1);
  //orbitSEM(p7,p8,20,0,0,0,-1);
  
  //Body Earth=addPlanet(0,0,0,0,500,50000000000d,-1,color(191,223,127));
  
  Body star=addStar(0,0,0,0,2500,200d*2500d*2500d/g,-1,color(255,239,191));
  Body p1=addPlanet(0,0,0,0,400,40d*400d*400d/g,-1,color(111,159,127));
  Body p2=addStar(0,0,0,0,100,10d*100d*100d/g,-1,color(95,95,95));
  Body SS1=addStar(0,0,0,0,2d,1d*2d*2d/g,-1,color(191,191,191));
  Body p3=addStar(0,0,0,0,250,15d*250d*250d/g,-1,color(191,159,143));
  orbitSEM(star,p1,30000,0,0,0,-1);
  orbitSEM(p1,p2,1200,0,0,0,-1);
  orbitSEM(p1,SS1,p1.radius+50,0,0,0,-1);
  orbitSEM(star,p3,18000,0.15,0,0,-1);
  
  //Body p1=addPlanet(0,0,0,0,60000,20d*60000d*60000d/g,-1,color(63,191,127));
  frameRate(60.0);
}
double bulletSpeed=480d;
double bulletRadius=0.25d;
double bulletMass=1d;
double bulletLifetime=15d;
double bulletSpread=2d;
int j=0;
ArrayList<String> chat=new ArrayList<String>();
void draw() {
  while(true) {
    Client thisClient=server.available();
    if(thisClient==null) {
      break;
    }
    byte[] data = thisClient.readBytes();
    ByteBuffer dataBuffer=ByteBuffer.wrap(data);
    Player player=null;
    for(Player testPlayer : players) {
      if(testPlayer.id==thisClient) {
        player=testPlayer;
        break;
      }
    }
    int i=0;
    while(i<data.length) {
      if(data[i]==1) {
        if(player!=null) {
          server.disconnect(thisClient);
          break;
        } else {
          String name=(new String(subset(data,i+1,32))).trim();
          if(name.length()==0) {
            name="Unnamed";
          }
          name=setLength(name,32);
          println(name);
          println(thisClient.ip());
          player=new Player(name,thisClient,num);
          player.respawn(spawns);
          players.add(player);
          ships.add(player);
          bodies.add(player);
          ByteBuffer dataReturn=ByteBuffer.allocate(5);
          dataReturn.put((byte)0).putInt(num);
          //println(Arrays.toString(dataReturn.array()));
          thisClient.write(dataReturn.array());
          writeChat("[Server] <"+setLength(player.name,128-("[Server] <"+"> has joined").length()).trim()+"> has joined");
          num++;
        }
        i+=33;
      } else if(data[i]==2&&player!=null) {
        byte moveCode=data[i+1];
        player.angle=dataBuffer.getDouble(i+6);
        player.selection=dataBuffer.getInt(i+2);
        double dirX=Math.cos(player.angle);
        double dirY=Math.sin(player.angle);
        player.thrustDir=moveCode;
        if((moveCode&16)>0&&player.bulletTime<millis()) {
          Body bullet = new Body(player.posX+dirX*(player.radius*2+bulletRadius),player.posY+dirY*(player.radius*2+bulletRadius),dirX*bulletSpeed+player.velX+(1-2*Math.random())*bulletSpread,dirY*bulletSpeed+player.velY+(1-2*Math.random())*bulletSpread,bulletRadius,bulletMass,bulletLifetime,color(255),num);
          num++;
          bodies.add(bullet);
          planets.add(bullet);
          killers.add(bullet);
          player.bulletTime=millis()+200;
        }
        if((moveCode&32)>0&&player.missileCTime<millis()) {
          MissileControllable missile = new MissileControllable(player.posX+dirX*(player.radius*2+missileRadius),player.posY+dirY*(player.radius*2+missileRadius),dirX*missileStartSpeed+player.velX,dirY*missileStartSpeed+player.velY,num,player);
          num++;
          bodies.add(missile);
          ships.add(missile);
          missiles.add(missile);
          killers.add(missile);
          player.missileCTime=millis()+10000;
        }
        if((moveCode&64)>0) {
          if((moveCode&128)>0) {
            for(MissileControllable missile : missiles) {
              if(missile.controller==player) {
                missile.target=missile;
              }
            }
          } else {
            for(MissileControllable missile : missiles) {
              if(missile.controller==player&&((!bodies.contains(missile.target))||missile.target==missile)) {
                for(Body body : bodies) {
                  if(body.index==player.selection) {
                    missile.target=body;
                    break;
                  }
                }
              }
            }
          }
        }
        i+=14;
      } else if(data[i]==3&&player!=null) {
        writeChat("<"+player.name.trim()+"> "+new String(subset(data,i+1,128)));
        i+=129;
      } else {
        break;
      }
    }
  }
  double centerPosX=0;
  double centerPosY=0;
  double centerVelX=0;
  double centerVelY=0;
  double totalMass=0;
  for(float i=0;i<1/60.0;i+=dt) {
    for(Body body : bodies) {
      body.updateVelocity();
      centerPosX+=body.posX*body.mass;
      centerPosY+=body.posY*body.mass;
      centerVelX+=body.velX*body.mass;
      centerVelY+=body.velY*body.mass;
      totalMass+=body.mass;
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
    for (Iterator<Body> iter = bodies.iterator(); iter.hasNext(); ) {
      Body body = iter.next();
      if(body.lifetime<=0&&body.lifetime>-1) {
        if(players.contains(body)) {
          Player player=players.get(players.indexOf(body));
          player.respawn(spawns);
          player.deathcount++;
        } else {
          iter.remove();
          planets.remove(body);
          spawns.remove(body);
          players.remove(body);
          ships.remove(body);
          killers.remove(body);
          missiles.remove(body);
        }
      } else if(body.lifetime>0){
        body.lifetime-=dt;
      }
    }
  }
  for(Client client : disconnectList) {
    for(Player player : players) {
      if(player.id==client) {
        players.remove(player);
        bodies.remove(player);
        ships.remove(player);
        writeChat("[Server] <"+setLength(player.name,64-("[Server] <"+"> has left").length()).trim()+"> has left");
        break;
      }
    }
  }
  if(j%4==0) {
    int planetBytes=planets.size()*56;
    int shipBytes=ships.size()*109;
    int chatBytes=chat.size()*128;
    int scoreBytes=players.size()*8;
    int byteCount=37+planetBytes+shipBytes+chatBytes+scoreBytes;
    ByteBuffer simData=ByteBuffer.allocate(byteCount);
    simData.put((byte)1).putInt(byteCount).putDouble(g).putDouble(dt).putInt(planetBytes);
    for(Body body : planets) {
      simData.putDouble(body.posX).putDouble(body.posY).putDouble(body.velX).putDouble(body.velY).putDouble(body.radius).putDouble(body.mass).putInt(body.clr).putInt(body.index);
    }
    simData.putInt(shipBytes);
    for(Ship body : ships) {
      simData.putDouble(body.posX).putDouble(body.posY).putDouble(body.velX).putDouble(body.velY).putDouble(body.radius).putDouble(body.mass).putInt(body.index).putDouble(body.angle).putDouble(body.thrust).putDouble(body.fuel).put(body.thrustDir).put(setLength(body.name,32).getBytes());
    }
    simData.putInt(chatBytes);
    for(String str : chat) {
      simData.put(str.getBytes());
    }
    simData.putInt(scoreBytes);
    for(Player player : players) {
      simData.putInt(player.index).putInt(player.deathcount);
    }
    server.write(simData.array());
    j=0;
    chat.clear();
  }
  j++;
}
void disconnectEvent(Client client) {
  disconnectList.add(client);
}
