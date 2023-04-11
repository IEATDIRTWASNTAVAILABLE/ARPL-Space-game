abstract class Ship extends Body {
  double angle;
  double thrust;
  String name;
  byte thrustDir;
  double fuel;
  Ship(double x, double y, double vx, double vy, double r, double m, double angle, String name, double lt, int index, double thrust) {
    super(x,y,vx,vy,r,m,lt,0,index);
    this.angle=angle;
    this.name=name;
    this.thrustDir=0;
    this.thrust=thrust;
    this.fuel=0;
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
    velX+=(forceX+(dirX*((thrustDir&1)-(thrustDir&4)/4)+dirY*((thrustDir&2)/2-(thrustDir&8)/8))*thrust)/mass*dt;
    velY+=(forceY+(dirY*((thrustDir&1)-(thrustDir&4)/4)-dirX*((thrustDir&2)/2-(thrustDir&8)/8))*thrust)/mass*dt;
  }
}
