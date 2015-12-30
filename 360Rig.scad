use <gopro_mounts_mooncactus.scad>


ratio = 12/5;
B=14.7*2;
MaxCamDim=90;
S=MaxCamDim+B;

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
function sq(a)= a*a;
function rhyp(r,h) = sqrt(sq(r)-sq(h));
function hyp(r,h) = sqrt(sq(r)+sq(h));

function inscribedSOct(a) = sqrt(6)*a/6;

module face(cube_size, res, ratio = ratio, h) {
    intersection(){
        cube([cube_size,cube_size,h], center=true);
        cylinder(r=rhyp(ratio*cube_size,cube_size/2),h = h,center=true,$fn=res);
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
    union(){
        cylinder(d=d1,h=h1,$fn=6);
        cylinder(d=d2,h=h2);
    }
}

module goproConnector(){
    translate([0,0,10.85]) rotate([-90,0,90]) gopro_connector("double");
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
        rotate(a) face(S-B,100,7/9,S+1);
    }
    
    //removing inner corners
    cb=15;
    cd=rhyp(7/9*(S-B),(S-B)/2)/2;
    echo(cd);
    cornerO()
          translate([0,0,sqrt(3)*(S-B-cd/3)/2-cb])
                cylinder(d=cd,h=cb, $fn=3);
}
}


difference(){
    frame(S,B,ratio);
    
    //hole for 1/4" nut for tripod compatibility
    rotate([180-atan(sqrt(2)),0,-45]) 
        translate([0,0,inscribedSOct(S*ratio*sqrt(2)/2)])
            tripodConnector(13,20,6.5,22);
}

//connector for GoPro accessories
rotate([-atan(sqrt(2)),0,-45]) 
        translate([0,0,inscribedSOct(S*ratio*sqrt(2)/2)])
            goproConnector();
for (n=[1:6]){
    faceO(n,S)
        translate([0,(S-B)/2-10.85,-7.35]) rotate([0,90,0]) gopro_connector("triple");
    //Debugging: camera/case fitting
//    %faceO(n,S) cube([80,60,40],center=true);
//      %faceO(n,S) translate([30,20,-10]) rotate([0,-90,90]) import("GOPRO_HERO_3.stl");
}