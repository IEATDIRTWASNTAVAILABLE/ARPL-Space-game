double playerRadius=0.5;
double playerMass=10;
class Ship extends Body {
  String name;
  double angle;
  double thrust;
  byte thrustDir;
  double fuel;
  Ship(String name, int id) {
    super(0,0,0,0,playerRadius,playerMass,0,id);
    this.name=name;
  }
  Ship(double posX, double posY, double velX, double velY, double radius, double mass, int index, double angle, double thrust, double fuel, byte thrustDir, String name) {
    super(posX,posY,velX,velY,radius,mass,0,index);
    this.angle=angle;
    this.name=name;
    this.index=index;
    this.thrust=thrust;
    this.thrustDir=thrustDir;
    this.fuel=fuel;
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
