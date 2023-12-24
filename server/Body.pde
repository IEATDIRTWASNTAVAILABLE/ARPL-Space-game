class Body {
  double posX;
  double posY;
  double velX;
  double velY;
  double radius;
  double mass;
  double lifetime;
  int clr;
  int index;
  Body(double posX, double posY, double velX, double velY, double radius, double mass, double lifetime, int clr, int index) {
    this.posX=posX;
    this.posY=posY;
    this.velX=velX;
    this.velY=velY;
    this.radius=radius;
    this.mass=mass;
    this.index=index;
    this.clr=clr;
    this.lifetime=lifetime;
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
        double force=g*mass*body.mass/distSq;//+4096.0/(1.0/mass+1.0/body.mass)*Math.min(dist-minDist,0.0);
        forceX+=force*dx/(dist);
        forceY+=force*dy/(dist);
      } else {
        forceX+=(Math.random()-0.5)*mass/dt*0.001;
        forceY+=(Math.random()-0.5)*mass/dt*0.001;
      }
    }
    velX+=forceX/mass*dt;
    velY+=forceY/mass*dt;
  }
  void updatePosition() {
    posX+=velX*dt;
    posY+=velY*dt;
  }
  void updateCollisions() {
    for(Body body : bodies) {
      if(body==this) {
        continue;
      }
      double dx=(body.posX-posX);
      double dy=(body.posY-posY);
      double distSq=dx*dx+dy*dy;
      double minDist=radius+body.radius;
      if(distSq<minDist*minDist&&distSq>0) {
        double dist=Math.sqrt(distSq);
        double rvx=body.velX-velX;
        double rvy=body.velY-velY;
        double cv=rvx*dx/dist+rvy*dy/dist;
        double force=0;
        if(cv<0) {
          double totalMass=body.mass+mass;
          force=cv*body.mass*mass/totalMass*1.5;
          velX+=force*dx/dist/mass;
          velY+=force*dy/dist/mass;
          body.velX+=-force*dx/dist/body.mass;
          body.velY+=-force*dy/dist/body.mass;
        //} else {
          //force=-1*body.mass*mass/(body.mass+mass);
          //velX+=force*dx/dist/mass;
          //velY+=force*dy/dist/mass;
          //body.velX+=-force*dx/dist/body.mass;
          //body.velY+=-force*dy/dist/body.mass;
          double offX=dx/dist*(dist-minDist)/totalMass;
          double offY=dy/dist*(dist-minDist)/totalMass;
          posX+=offX*body.mass;
          posY+=offY*body.mass;
          body.posX-=offX*mass;
          body.posY-=offY*mass;
        }
        if(ships.contains(this)&&killers.contains(body)&&this.lifetime!=0) {
          Ship ship=ships.get(ships.indexOf(this));
          ship.lifetime=0;
          body.lifetime=0;
          writeChat("[Server] "+setLength(ship.name,64-("[Server] "+" was killed").length()).trim()+" was killed");
        } else if((ships.contains(this)&&(Math.abs(force/mass)>50)&&this.lifetime!=0)||(ships.contains(body)&&(Math.abs(force/body.mass)>50)&&body.lifetime!=0)) {
          if(ships.contains(this)&&(Math.abs(force/mass)>50)&&this.lifetime!=0) {
            Ship ship=ships.get(ships.indexOf(this));
            ship.lifetime=0.0;
            writeChat("[Server] "+setLength(ship.name,64-("[Server] "+" crashed").length()).trim()+" crashed");
          }
          if(ships.contains(body)&&(Math.abs(force/body.mass)>50)&&body.lifetime!=0) {
            Ship ship=ships.get(ships.indexOf(body));
            ship.lifetime=0.0;
            writeChat("[Server] "+setLength(ship.name,64-("[Server] "+" crashed").length()).trim()+" crashed");
          }
        } else if(players.contains(this)&&(!players.contains(body))&&(rvx*rvx+rvy*rvy<10*10)) {
          Player ship=players.get(players.indexOf(this));
          double prevFuel=ship.fuel;
          ship.fuel=playerMaxFuel;
          ship.mass+=ship.fuel-prevFuel;
        }
      }
    }
  }
}
