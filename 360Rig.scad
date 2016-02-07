use <gopro_mounts_mooncactus.scad>


/****************************
** GoPro Mounts parameters **
****************************/
gopro_connector_z = 14.7;
gopro_hole2base=10.85;

/*********************
** 360Rig Paramters **
*********************/
//Number of horizontal Cameras
N=5;
//ratio octagon/cube, sizes the corners
ratio = 12/5;
//the roundes of the face holes
faceR=10;
//the size of the border (x2)
B=gopro_connector_z*2;
//the maximum camera dimension 
MaxCamDim=80;
// total size of the rig (cube)
S=MaxCamDim+B;
//edje smoothness (0 to disable)
Smoothness=0;

module octahedron(size) {
    s=size/2;
      p=[
            [s,0,0],
            [0,s,0],
            [0,0,s],
            [-s,0,0],
            [0,-s,0],
            [0,0,-s],
        ];
       f=[
            [0,2,1],
            [3,2,4],
            [4,2,0],
            [0,1,5],
            [0,5,4],
            [3,1,2],
            [3,4,5],
            [5,1,3]
            
        ];
    polyhedron(p,f);
}

function inscribedSOct(a) = sqrt(6)*a/6;

module face(s, d, h) {
    hull(){
        for (p = [[-1,-1,0],[1,-1,0],[-1,1,0],[1,1,0]]){
            translate(p*(s/2-d))
                cylinder(r=d,h = h,center=true);
        }
    }
}

module faceO(n,S){
    faces=[
            [0,0,0],
            [0,270,0],
            [90,0,0],
            [270,0,0],
            [0,90,0],
            [180,0,0],
    ];
    
    rotate(faces[n-1]) translate([0,0,S/2]) children();
}

module tripodConnector(d1,h1,d2,h2){
    translate([0,0,-h2])
    rotate([0,0,30])
    union(){
        cylinder(d=d1,h=h1,$fn=6);
        cylinder(d=d2,h=h2);
    }
}

module goproConnector2(){
    translate([0,0,gopro_hole2base-0.2]) rotate([-90,0,90]) gopro_connector("double");
}

module goproConnector3(){
    gopro_connector("triple");
    translate([0,gopro_connector_z-1,0])
				cube([gopro_connector_z,B/4,gopro_connector_z], center=true);
}

module cornerO(){
       rotate([0,atan(sqrt(2)),45]) 
            children();
    for ( a = [
                [atan(sqrt(2)),0,-45],
                [atan(sqrt(2)),0,45],
                ] )
        rotate(a) 
                rotate([0,0,30]) children();
    for ( a = [
                [180-atan(sqrt(2)),0,-45],
                [180-atan(sqrt(2)),0,45],
                [-atan(sqrt(2)),0,45],
                ] )
        rotate(a) 
                rotate([0,0,-30]) children();
    for ( a = [
                [0,180-atan(sqrt(2)),45],
                [0,180-atan(sqrt(2)),180-45],
                ] )
        rotate(a) 
                rotate([0,0,-60]) children();
}

module frame(S,B,ratio){
difference(){
    intersection(){
        cube(S,center=true);
        octahedron(S*ratio);
    }
    for (a = [[0,0,0],[90,0,0],[0,90,0]]) {
        rotate(a) face(S-B,faceR,S+1);
    }
    
    //removing inner corners
    cb=15;
    cd=faceR;
    cornerO()
          translate([0,0,sqrt(3)*(S-B-cd/2.0)/2-cb])
                cylinder(d=cd,h=cb, $fn=3);
}
}

module edge(S,B,ratio,extra=0){
    intersection(){
        frame(S,B,ratio);
        translate([-extra,-extra,-S/2]) cube(S);
    }
}

function outerAngle()=270-360/N;

function apothem(n,s) = (s*cos(180/n))/(2*sin(180/n));

function edjeDesplacement(N,S) = apothem(N,sqrt(2)*S/2) ;

function tRatio(N,s) = apothem(N,sqrt(2)*s/2) - apothem(4,sqrt(2)*s/2);

function diagD(d) = sqrt(2)*d/2; 

module Nframe(N,S,B,ratio){
for (a = [0:360/N:360])
    rotate([0,0,a]) 
        translate(diagD(tRatio(N,S-B))*[1,1,0])
    edge(S,B,ratio,0);

}

difference(){
    if (Smoothness > 0) {
        ms=Smoothness;
        minkowski(){
            Nframe(N,S-ms,B-ms*2,ratio);
            sphere(d=ms,$fn=15);
        }
    }
    else {
        Nframe(N,S,B,ratio);
    }
    
    //hole for 1/4" nut for tripod compatibility
    translate(diagD(tRatio(N,S-B))*[1,1,0])
    rotate([0,180-atan(sqrt(2)),45]) 
        translate([0,0,inscribedSOct(S*ratio*sqrt(2)/2)])
            tripodConnector(13,20,6.5,22);
}

//connector for GoPro accessories
    translate(diagD(tRatio(N,S-B))*[1,1,0])
rotate([-atan(sqrt(2)),0,-45]) 
        translate([0,0,inscribedSOct(S*ratio*sqrt(2)/2)])
            goproConnector2();

//connectors on edges
for (a = [0:360/N:360]){
    rotate([0,0,a]) 
        translate(diagD(tRatio(N,S-B))*[1,1,0])
    faceO(5,S)
        translate([0,(S-B)/2-gopro_hole2base,-gopro_connector_z/2]) 
            rotate([0,90,0]) goproConnector3();
    
//Top and Bottom connectors
    for (z=[S/2,-S/2+B/2])
    rotate([0,0,outerAngle()/2-180])
    translate(diagD(tRatio(N,S-B/2))*[0,1,0])
translate([0,(S-B)/2-gopro_hole2base,-gopro_connector_z/2+z]) 
            rotate([0,90,0]) goproConnector3();
//TODO: fix debugging
    //Debugging: camera/case fitting
//    %faceO(n,S) cube([80,60,40],center=true);
//      %faceO(n,S) translate([30,15,-15]) rotate([0,-90,90]) import("GOPRO_HERO_3.stl");
}
