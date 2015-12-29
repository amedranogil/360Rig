use <gopro_mounts_mooncactus.scad>


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

module orthogonalO(s){
    faceO(1,s)
        children();
    faceO(6,s)
        rotate([0,0,180]) 
        children();
    faceO(2,s)
        rotate([0,0,90]) 
        children();
    faceO(5,s)
        rotate([0,0,-90]) 
        children();
    faceO(3,s)
        rotate([0,0,90]) 
        children();
    faceO(4,s)
        rotate([0,0,90]) 
        children();
}
s=40;

module cFace() {
    translate([-5,0,0]) scale([1,0.7,1]) cylinder(d=5,h=1,$fn=3);
    translate([s/2-18/2,0,10.3]) rotate([-90,0,0]) gopro_connector("triple");
    %translate([s/2-18/2,0,10.3+40]) cube([40,80,60],center=true);
}
    


orthogonalO(s)
    cFace();
cube(s-1,center=true);


