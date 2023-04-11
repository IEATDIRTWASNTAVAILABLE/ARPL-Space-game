double playerRadius=0.5;
double playerDryMass=50;
double playerThrust=2500;
double playerIsp=360;
double playerMaxFuel=20;
class Player extends Ship {
  Client id;
  double bulletTime;
  double missileCTime;
  double missileHTime;
  int selection;
  int deathcount;
  Player(String name, Client id, int index) {
    super(0,0,0,0,playerRadius,playerDryMass+playerMaxFuel,0,name,-1,index,playerThrust);
    this.id=id;
    this.bulletTime=millis();
    this.missileCTime=millis();
    this.missileHTime=millis();
    fuel=playerMaxFuel;
    selection=-1;
    deathcount=0;
  }
  void updateVelocity() {
    double forceX=0.0;
    double forceY=0.0;
    for(Body body : bodies) {
      if(body==this) {
        continue;
      }
      double dx=(body.posX-posX);
      double dy=(body.posY-posY);
      double distSq=dx*dx+dy*dy;
      if(distSq>0) {
        double dist=Math.sqrt(distSq);
        double force=g*mass*body.mass/distSq;
        double forceNear=g*mass*body.mass/((dist-radius)*(dist-radius));
        double forceFar=g*mass*body.mass/((dist+radius)*(dist+radius));
        if(Math.abs(forceNear-forceFar)>100*mass&&(lifetime>1||lifetime<0)) {
          lifetime=1;
          writeChat("[Server] "+setLength(name,64-("[Server] "+" got torn apart by tidal forces").length()).trim()+" got torn apart by tidal forces");
          break;
        }
        forceX+=force*dx/(dist);
        forceY+=force*dy/(dist);
      } else {
        forceX+=(Math.random()-0.5)*mass/dt*0.000001;
        forceY+=(Math.random()-0.5)*mass/dt*0.000001;
      }
    }
    double dirX=Math.cos(angle);
    double dirY=Math.sin(angle);
    velX+=forceX/mass*dt;
    velY+=forceY/mass*dt;
    double prevFuel=fuel;
    //if(fuel>=thrust/playerIsp*dt) {
    //  velX+=(dirX*((thrustDir&1)-(thrustDir&4)/4)+dirY*((thrustDir&2)/2-(thrustDir&8)/8))*thrust/mass*dt;
    //  velY+=(dirY*((thrustDir&1)-(thrustDir&4)/4)-dirX*((thrustDir&2)/2-(thrustDir&8)/8))*thrust/mass*dt;
    //  fuel-=((thrustDir&1)+(thrustDir&2)/2+(thrustDir&4)/4+(thrustDir&8)/8)*thrust/playerIsp*dt;
    //} else {
    //  velX+=(dirX*((thrustDir&1)-(thrustDir&4)/4)+dirY*((thrustDir&2)/2-(thrustDir&8)/8))*thrust/mass/10*dt;
    //  velY+=(dirY*((thrustDir&1)-(thrustDir&4)/4)-dirX*((thrustDir&2)/2-(thrustDir&8)/8))*thrust/mass/10*dt;
    //}
    if((thrustDir&128)>0&&fuel>=thrust/playerIsp*dt) {
      velX+=(dirX*((thrustDir&1)-(thrustDir&4)/4)+dirY*((thrustDir&2)/2-(thrustDir&8)/8))*thrust/mass*dt;
      velY+=(dirY*((thrustDir&1)-(thrustDir&4)/4)-dirX*((thrustDir&2)/2-(thrustDir&8)/8))*thrust/mass*dt;
      fuel-=((thrustDir&1)+(thrustDir&2)/2+(thrustDir&4)/4+(thrustDir&8)/8)*thrust/playerIsp*dt;
    }
    velX+=(dirX*((thrustDir&1)-(thrustDir&4)/4)+dirY*((thrustDir&2)/2-(thrustDir&8)/8))*thrust/mass/64*dt;
    velY+=(dirY*((thrustDir&1)-(thrustDir&4)/4)-dirX*((thrustDir&2)/2-(thrustDir&8)/8))*thrust/mass/64*dt;
    fuel=Math.max(Math.min(fuel,playerMaxFuel),0d);
    mass+=fuel-prevFuel;
    //if(posX*posX+posY*posY>30000d*30000d) {
    //  lifetime=0;
    //  writeChat("[Server] "+setLength(name,64-("[Server] "+" went outside the map").length()).trim()+" went outside the map");
    //}
  }
  void respawn(ArrayList<Body> spawnpoints) {
    if(bodies.size()>0) {
      int rand=floor(random(0,spawnpoints.size()));
      Body randbody=spawnpoints.get(rand);
      angle=random(0,TAU);
      double rx=Math.cos(angle)*(randbody.radius+radius);
      double ry=Math.sin(angle)*(randbody.radius+radius);
      posX=randbody.posX+rx;
      posY=randbody.posY+ry;
      velX=randbody.velX;
      velY=randbody.velY;
      fuel=playerMaxFuel;
      mass=playerMaxFuel+playerDryMass;
      lifetime=-1;
    }
  }
}
