double missileRadius=1.0;
double missileMass=50;
double missileThrust=2500;
double missileStartSpeed=120;
double missileLifetime=120;
class MissileControllable extends Ship {
  Player controller;
  Body target;
  MissileControllable(double posX, double posY, double velX, double velY, int index, Player controller) {
    super(posX,posY,velX,velY,missileRadius,missileMass,controller.angle,"Missile("+setLength(controller.name,32-("Missile("+")").length()).trim()+")",missileLifetime,index,missileThrust);
    this.controller=controller;
    this.thrustDir=1;
    target=new Body(0,0,0,0,0,0,-1,0,-1);
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
    angle=controller.angle;
    double dirX;
    double dirY;
    if(target!=this&&bodies.contains(target)) {
      double rx=target.posX-posX;
      double ry=target.posY-posY;
      double dist=Math.sqrt(rx*rx+ry*ry);
      double vx=velX-target.velX;
      double vy=velY-target.velY;
      double va=(rx/dist*vx+ry/dist*vy);
      double vlx=vx-rx/dist*va;
      double vly=vy-ry/dist*va;
      double rvx=(2*radius/dt*rx/dist-vx)-512*vlx;
      double rvy=(2*radius/dt*ry/dist-vy)-512*vly;
      double rv=Math.sqrt(rvx*rvx+rvy*rvy);
      dirX=rvx/(rv+0.01);
      dirY=rvy/(rv+0.01);
    } else {
      dirX=Math.cos(angle);
      dirY=Math.sin(angle);
    }
    velX+=(forceX+(dirX*((thrustDir&1)-(thrustDir&4)/4)+dirY*((thrustDir&2)/2-(thrustDir&8)/8))*thrust)/mass*dt;
    velY+=(forceY+(dirY*((thrustDir&1)-(thrustDir&4)/4)-dirX*((thrustDir&2)/2-(thrustDir&8)/8))*thrust)/mass*dt;
  }
}
