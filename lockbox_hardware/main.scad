// Measurements in mm

board_width = 26;
board_length = 50;
pins_width = 3;
full_pin_height = 25;
cable_management_height = 10;

servo_width = 23;
servo_height = 32;
servo_thickness = 12.5;
servo_wings_width = 32.5;
servo_wings_offset = 16.5;
servo_wings_thickness = 2;
cam_bridge_height = 1.8;

cam_height = 1.5;

// Other constants

inner_wall_thickness = 1.2;
outer_wall_thickness = 1.8;

lid_thickness = 1.8;
lid_box_tolerance = 0.3;
lid_height = servo_height-(servo_wings_offset-servo_wings_thickness)-lid_box_tolerance;

layer_height = 0.32;
bridging_tolerance = 0.8;

// inter-component calculations

box_size_x = outer_wall_thickness * 2 + board_width;
box_size_z = outer_wall_thickness * 2 + full_pin_height;
box_size_y = outer_wall_thickness + servo_height+board_length;

lid_body_x = box_size_x + 2 * lid_thickness;
lid_body_y = lid_height;
lid_body_z = box_size_z + 3 * lid_thickness;

lid_body_hollow_x = box_size_x + lid_box_tolerance * 2;
lid_body_hollow_y = lid_height - lid_thickness;
lid_body_hollow_z = box_size_z + 2 * lid_box_tolerance;

// Logo placement
logo_width = 6;
logo_up = 10;
logo_in = 8;

// todo: calc openign for cam
cam_slot_size = 16;

// Generation constants

MODELVER = "000000";

FN = 32;

// Start of code

$fn=FN;
model_version = MODELVER;
make();

// Preview inside OpenSCAD editor

module make() {
    box();
    translate([0,-30,0])
    translate([0, -lid_thickness, -lid_thickness-lid_box_tolerance])
        lid();
}

// Make targets
// Rotates so they're the right way around for printing

module box_model() // make me
{
    rotate([-90,0,0]) box();
}
module lid_model() // make me
{
    rotate([90,0,0]) lid();
}
module servo_fit_model() // make me
{
    rotate([-90,0,0]) 
    intersection()
    {
        box();
        translate([-box_size_x/2, -cam_bridge_height, 0])
            cube([box_size_x, lid_height+lid_thickness+lid_box_tolerance+cam_bridge_height, box_size_z]);
    }
}

module versiontext()
{
    linear_extrude(layer_height)
    translate([-8,5,0])
        union(){
        translate([-5,0,0])
            text(text="V  ", size = 4, font="Liberation:style=Narrow");
        text(text=model_version, size = 4, font="Liberation:style=Narrow");
        }
}

module box()
{
    union()
    {
        difference()
        {
            union()
            {
                // Main chunk
                translate([-0.5*box_size_x, 0, 0])
                    cube([box_size_x, box_size_y, box_size_z]);
                // Cam bridge
                translate([-0.5*box_size_x, -cam_bridge_height, 0])
                    cube([box_size_x, cam_bridge_height, outer_wall_thickness]);
                // Bulk for aesthetics
                bulk_length = box_size_y - lid_height + lid_thickness - lid_box_tolerance;
                translate([0, box_size_y-bulk_length, 0])
                    translate([-lid_body_x/2, 0, -lid_thickness*2-lid_box_tolerance])
                    cube([lid_body_x, bulk_length, lid_body_z]);
            }
            // Slits for pins
            // todo: fix to proper width for if box becomes larger than board width
            for (i = [-1, 1])
                translate([i*((box_size_x-(outer_wall_thickness*2))/2 - pins_width/2), 0, 0])
                translate([-0.5*pins_width, 0, outer_wall_thickness])
                    cube([pins_width, box_size_y-outer_wall_thickness, box_size_z-2*outer_wall_thickness]);
            // Room for key
            translate([-(box_size_x-(pins_width*2+outer_wall_thickness*2+inner_wall_thickness*2))/2, 0, outer_wall_thickness+inner_wall_thickness+servo_thickness])
                cube([box_size_x-(pins_width*2+outer_wall_thickness*2+inner_wall_thickness*2), box_size_y-outer_wall_thickness, box_size_z-outer_wall_thickness*2-inner_wall_thickness-servo_thickness]);
            // Room for board, servo
            translate([-(box_size_x-(outer_wall_thickness*2))/2, 0, outer_wall_thickness])
                cube([box_size_x-(outer_wall_thickness*2), box_size_y-outer_wall_thickness, servo_thickness]);
            // Slits for servo wings
            non_wings_len = outer_wall_thickness+board_length+servo_wings_offset;
            wings_len = box_size_y - non_wings_len;
            translate([-(box_size_x)/2, 0, outer_wall_thickness])
                cube([box_size_x, wings_len, servo_thickness]);
            // Cam opening
            translate([-cam_slot_size/2, -bridging_tolerance, 0])
                cube([cam_slot_size, cam_height+bridging_tolerance, outer_wall_thickness]);
            // Power wires opening
            translate([(box_size_x/2)-pins_width-outer_wall_thickness,box_size_y-outer_wall_thickness,box_size_z-outer_wall_thickness-pins_width*2])
                cube([pins_width, outer_wall_thickness, pins_width*2]);
            // Version text
            translate([0,box_size_y-layer_height,0])
            rotate([90,0,180])
                versiontext();
            // Logo
            translate([logo_in,box_size_y-layer_height,logo_up])
            rotate([90,0,180])
                scale([logo_width/64,logo_width/64,1])
                linear_extrude(layer_height)
                import("logo.svg");
        }
        // Pins to keep servo in place
        for (i = [-1,1])
        {
            non_wings_len = outer_wall_thickness+board_length+servo_wings_offset;
            wings_len = box_size_y - non_wings_len;
            translate([i*(box_size_x/2)-i*outer_wall_thickness/2,
                wings_len - outer_wall_thickness,
                outer_wall_thickness+servo_thickness/2-outer_wall_thickness/2])
            translate([-outer_wall_thickness/2, 0, 0])
            cube([outer_wall_thickness, servo_wings_thickness, outer_wall_thickness]);
        }
    }
}

module lid()
{
    difference()
    {
        translate([-lid_body_x/2, 0, -lid_thickness])
            cube([lid_body_x, lid_body_y, lid_body_z]);
        
        translate([-lid_body_hollow_x/2, lid_thickness,lid_thickness])
            cube([lid_body_hollow_x, lid_body_hollow_y, lid_body_hollow_z]);
        
        // Cam bridge slit
        translate([-(box_size_x+lid_box_tolerance*2)/2, 0, lid_thickness])
            cube([box_size_x+lid_box_tolerance*2, lid_thickness, lid_thickness+2*lid_box_tolerance]);
        
        // Slit for cam
        translate([-(box_size_x+lid_box_tolerance*2)/2, lid_thickness, 0])
            cube([box_size_x+lid_box_tolerance*2, cam_height+bridging_tolerance, lid_thickness+2*lid_box_tolerance]);
        
        // Slits for servo wings
        translate([-(box_size_x+lid_thickness*2)/2,
            lid_thickness+(servo_height-servo_wings_offset)-servo_wings_thickness,
            lid_thickness+lid_box_tolerance+outer_wall_thickness])
            cube([box_size_x+lid_thickness*2, lid_height-lid_thickness-(servo_height-servo_wings_offset)+servo_wings_thickness, servo_thickness+2*lid_box_tolerance]);

        translate([0, layer_height, 8])
            rotate([90,0,0])
            versiontext();
    }
}
