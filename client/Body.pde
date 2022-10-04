class Body {
  double posX;
  double posY;
  double velX;
  double velY;
  double radius;
  double mass;
  int index;
  int clr;
  Body(double posX, double posY, double velX, double velY, double radius, double mass, int clr, int index) {
    this.posX=posX;
    this.posY=posY;
    this.velX=velX;
    this.velY=velY;
    this.radius=radius;
    this.mass=mass;
    this.index=index;
    this.clr=clr;
  }
  void updateVelocity(ArrayList<Body> bodies) {
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
        forceX+=force*dx/(dist);
        forceY+=force*dy/(dist);
      } else {
        forceX+=(Math.random()-0.5)*mass/dt*0.000001;
        forceY+=(Math.random()-0.5)*mass/dt*0.000001;
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
      if(distSq<=minDist*minDist&&distSq>0) {
        double dist=Math.sqrt(distSq);
        double rvx=body.velX-velX;
        double rvy=body.velY-velY;
        double cv=rvx*dx/dist+rvy*dy/dist;
        if(cv<0) {
          double force=cv*body.mass*mass/(body.mass+mass);
          velX+=force*dx/dist/mass*1.5;
          velY+=force*dy/dist/mass*1.5;
          body.velX+=-force*dx/dist/body.mass*1.5;
          body.velY+=-force*dy/dist/body.mass*1.5;
        } else if(cv>=0) {
          double force=-1*body.mass*mass/(body.mass+mass);
          velX+=force*dx/dist/mass;
          velY+=force*dy/dist/mass;
          body.velX+=-force*dx/dist/body.mass;
          body.velY+=-force*dy/dist/body.mass;
        }
      }
    }
  }
}
