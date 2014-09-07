// Define units

in = 1/12;
ft = 12 * in;

// Define sizes of lumber

two_four_w = 1.5 * in;
two_four_h = 3.5 * in;

two_six_w = 1.5 * in;
two_six_h = 5.5 * in;

four_four_w = 3.5 * in;
four_four_h = 3.5 * in;

six_six_w = 5.5 * in;
six_six_h = 5.5 * in;

// Associate individual pieces with their size

a_post_size = 6;

a_post_x = a_post_size == 4 ? four_four_w : six_six_w;
a_post_y = a_post_size == 4 ? four_four_h : six_six_h;

a_post_l = 8 * ft;

b_beam_w = two_six_w;
b_beam_h = two_six_h;
b_beam_l = 10 * ft;

c_beam_w = two_six_w;
c_beam_h = two_six_h;
c_beam_l = 20 * ft;

e_beam_w = four_four_w;
e_beam_h = four_four_h;

f_slat_w = two_four_w;
f_slat_h = two_four_h;
f_slat_l = 10 * ft;

// Define counts of slats and beams

f_slat_count = 10;
a_post_pair_count = 3;
c_beam_pair_count = 5;

// Define offsets and depths

b_beam_overhang = 8 * in;
c_beam_overhang = 8 * in;
f_slat_overhang = 8 * in;

layers = 3;

c_beam_lower_notch_depth = layers == 3 ? 2 * in : b_beam_h / 2 * in;
c_beam_upper_notch_depth = layers == 3 ? 0 : f_slat_h / 2 * in;

f_slat_lower_notch_depth = layers == 3 ? 1.5 * in : f_slat_h / 2 * in;
b_beam_upper_notch_depth = layers == 3 ? 0 : c_beam_h / 2 * in;

// Define curves

b_beam_overhang_radius = 3.5 * in;
c_beam_overhang_radius = 3.5 * in;
f_slat_overhang_radius = 2 * in;

cyl_detail = 10;

e1_beam_inner_hypotenuse = 2.4 * ft;
e2_beam_inner_hypotenuse = e1_beam_inner_hypotenuse - 0.4 * ft;

// Angles are measured from the bottom of the triangle.
e1_beam_angle = 45;
e2_beam_angle = 45;

// Precompute measurements

c_beam_z = a_post_l - c_beam_h;
b_beam_z = c_beam_z - b_beam_h + c_beam_lower_notch_depth + c_beam_upper_notch_depth;
f_slat_z = c_beam_z + c_beam_h - b_beam_upper_notch_depth - f_slat_lower_notch_depth;

a_post_y_inner_spacing = b_beam_l - (b_beam_overhang + a_post_x + c_beam_w) * 2;
a_post_x_inner_spacing = 
  // the available inner spacing...
  (c_beam_l - (c_beam_overhang + a_post_y + b_beam_w) * 2 - a_post_y)
  // divided by the number of inner posts
  / (a_post_pair_count - 1);

c_beam_pair_width = a_post_y + c_beam_w * 2;
c_beam_pair_y_inner_spacing = 
  // the available empty distance...
  (
    // the total distance between the two posts...
    a_post_y_inner_spacing
    // minus the c_beam's on both sides, up against the posts...
    - c_beam_w * 2
    // minus the width of the c_beam pair times the number of inner beam pairs...
    - c_beam_pair_width * (c_beam_pair_count - 2)
  )
  // divided by the number of beam pair gaps
  / (c_beam_pair_count - 1);

f_slat_x_cl_spacing = c_beam_l / (f_slat_count + 1);

e1_beam_inner_adjacent = e1_beam_inner_hypotenuse * cos(e1_beam_angle);
e1_beam_inner_cross_opposite = e1_beam_inner_adjacent * sin(e1_beam_angle);
e1_beam_outer_adjacent = (e_beam_h + e1_beam_inner_cross_opposite) / sin(e1_beam_angle);
e1_beam_outer_hypotenuse = e1_beam_outer_adjacent / cos(e1_beam_angle);

e2_beam_inner_adjacent = e2_beam_inner_hypotenuse * cos(e2_beam_angle);
e2_beam_inner_cross_opposite = e2_beam_inner_adjacent * sin(e2_beam_angle);
e2_beam_outer_adjacent = (e_beam_h + e2_beam_inner_cross_opposite) / sin(e2_beam_angle);
e2_beam_outer_hypotenuse = e2_beam_outer_adjacent / cos(e2_beam_angle);

// Construct the model

//e1_beam();

//lighting();


translate([-(a_post_x_inner_spacing + a_post_x * 1.5),-(a_post_y_inner_spacing/2 + a_post_y),0])
translate([0,0,-a_post_l])
pergola();


pipe_od = 0.625 * in;
pipe_radius = pipe_od/2;

light_tube_count_x = 20;
light_tube_count_y = 10;
light_y_stub_dist = 2 * in;
tee_connector_radius = pipe_radius * 1.1;
tee_connector_length = 1.75 * in;
tee_connector_height = 1.25 * in;
// When the pipe is in a tee or bend connector, the connector overlaps the pipe by 1/2".
connector_overlap = 0.5 * in;
//tee_connector_y_offset = (tee_connector_length - (connector_overlap * 2))/2;
tee_connector_y_offset = 0.1 * in;
tee_connector_z_offset = (tee_connector_height - connector_overlap) - tee_connector_radius;

light_tube_offset_x = pipe_radius * 2;
light_tube_offset_y = pipe_radius * 2;
light_tube_dist_x = (c_beam_l - (c_beam_overhang + a_post_y + b_beam_w * 2) * 2 - light_tube_offset_x * 2) / (light_tube_count_x-1);
light_tube_dist_y = (b_beam_l - (b_beam_overhang + a_post_x + c_beam_w * 2) * 2 - light_tube_offset_y * 2) / (light_tube_count_y-1);

echo(str("Distance between each Z-connector on the Y-axis: ",light_tube_dist_y/in," in"));

light_tube_height = f_slat_z - c_beam_z + f_slat_h - tee_connector_z_offset;
light_x_segment_length = light_tube_dist_x - pipe_radius*2 - tee_connector_y_offset*2;
light_y_segment_length = light_tube_dist_y - pipe_radius*2 - tee_connector_y_offset*2;
light_y_stub_length = light_y_stub_dist - tee_connector_y_offset*2;
light_y_short_segment_length = light_y_segment_length - light_y_stub_length - pipe_radius * 2 - tee_connector_y_offset*2;

light_tube_total_dist_y = (light_tube_count_y-1) * light_tube_dist_y;

module tee_connector() {
	translate([0, 0, tee_connector_height-tee_connector_radius])
	%union() {
		translate([0, -(tee_connector_length / 2), 0]) rotate([-90, 0, 0])
			cylinder(h = tee_connector_length, r = tee_connector_radius, $fn = cyl_detail);
		translate([0, 0, -(tee_connector_height-tee_connector_radius)])
			cylinder(h = tee_connector_height-tee_connector_radius, r = tee_connector_radius, $fn = cyl_detail);
	}
}

module light_tube() {
	color("Blue") cylinder(h = light_tube_height, r = pipe_radius, $fn = cyl_detail);
	translate([0, 0, light_tube_height - connector_overlap]) tee_connector();
}

module light_y_segment() {
	color("Orange") translate([0,tee_connector_y_offset,0]) rotate([-90, 0, 0]) cylinder(h = light_y_segment_length, r = pipe_radius, $fn = cyl_detail);
}

module light_y_short_segment() {
	color("Orange") translate([0,tee_connector_y_offset,0]) rotate([-90, 0, 0]) cylinder(h = light_y_short_segment_length, r = pipe_radius, $fn = cyl_detail);
}

module light_x_segment() {
	color("Green") translate([tee_connector_y_offset,0,0]) rotate([0, 90, 0]) cylinder(h = light_x_segment_length, r = pipe_radius, $fn = cyl_detail);
}

module light_x_brace() {
	light_x_segment();
	translate([tee_connector_z_offset+connector_overlap-pipe_radius,0,0]) rotate([0, -90, 0]) tee_connector();
	translate([light_tube_dist_x - (pipe_radius*2) - tee_connector_height + tee_connector_radius + pipe_radius,0,0])  rotate([0,90,0]) tee_connector();
}

module light_y_stub() {
	color("Red") translate([0, tee_connector_y_offset, 0]) rotate([-90, 0, 0]) cylinder(h = light_y_stub_length, r = pipe_radius, $fn = cyl_detail);
}

module stub_and_short_segment() {
	light_y_stub();
	translate([0, light_y_stub_dist + pipe_radius*2, 0])
	light_y_short_segment();
}

module lighting() {
	echo("Cut list:");
	
	x_connectors = light_tube_count_x * 2;
	x_connector_length = light_x_segment_length;
	echo(str("  ",x_connectors,"x X-connector: ",x_connector_length/in," in"));

	// There are four y_stubs per value of x except three on the first and last.
	y_stubs = light_tube_count_x*4 - 2;
	y_stub_length = light_y_stub_length;
	echo(str("  ",y_stubs,"x Y-stub: ",y_stub_length/in," in"));

	// There are light_tube_count_y-2 y_connectors per value of x except light_tube_count_y-1
	// on the first and last.
	y_connectors = light_tube_count_x*(light_tube_count_y-2) + 2;
	y_connector_length = light_y_segment_length;
	echo(str("  ",y_connectors,"x Y-connector: ",y_connector_length/in," in"));

	// The first and last x have only 1 y_short_connector
	y_short_connectors = light_tube_count_x * 2 - 2;
	y_short_connector_length = light_y_short_segment_length;
	echo(str("  ",y_short_connectors,"x Y-connector (short): ",y_short_connector_length/in," in"));

	z_connectors = light_tube_count_x*light_tube_count_y;
	z_connector_length = light_tube_height;
	echo(str("  ",z_connectors,"x Z-connector: ",z_connector_length/in," in"));

	total_pipe_length = x_connectors * x_connector_length + y_connectors * y_connector_length
		+ y_short_connectors * y_short_connector_length + z_connectors * z_connector_length
		+ y_stubs * y_stub_length;
	std_pipe_length = 10 * ft;
	echo(str("Total pipe needed: ",total_pipe_length/ft," ft"));
	echo(str("Total ",std_pipe_length/ft," ft lengths needed: ",ceil((total_pipe_length/std_pipe_length)/ft)));

	// Tees are used for each Z-connector and for cross braces (2 per x except first and last have 1).
	total_tee_connectors = z_connectors + light_tube_count_x * 2 - 2;
	// 90 degree connectors are found twice per x except first and last have 1.
	total_bend_connectors = light_tube_count_x * 2 - 2;
	echo(str("Tee connectors: ",total_tee_connectors,"; 90 degree connectors: ",total_bend_connectors));

	for (x = [0 : light_tube_count_x - 1]) {
		for (y = [0 : light_tube_count_y - 1]) {
			translate([x * light_tube_dist_x, y * light_tube_dist_y, 0])
			light_tube();
		}
	}

	translate([0, pipe_radius, light_tube_height + tee_connector_z_offset])
	for (x = [0 : light_tube_count_x - 1]) {
		for (y = [0 : light_tube_count_y - 2]) {
			if (
				(y == 0 || y == light_tube_count_y - 2) &&
				!((x == 0 && y == 0) || (x == light_tube_count_x-1 && y == 0))
			) {
				if (y == 0) {
					translate([x * light_tube_dist_x, y * light_tube_dist_y, 0])
					stub_and_short_segment();
				} else {
					translate([x * light_tube_dist_x, y * light_tube_dist_y, 0])
				 	translate([0, light_tube_dist_y - pipe_radius*2, 0]) rotate([180,0,0])
					stub_and_short_segment();
				}
			} else {
				translate([x * light_tube_dist_x, y * light_tube_dist_y, 0])
				light_y_segment();
			}
		}
	}

	translate([0, 0, light_tube_height + tee_connector_z_offset])
	for (x = [0 : light_tube_count_x - 1]) {
			
			// Stub on near end.
			translate([x * light_tube_dist_x, -(light_y_stub_dist + pipe_radius), 0])
			light_y_stub();

			// Stub on far end.
			translate([x * light_tube_dist_x, light_tube_total_dist_y + pipe_radius, 0])
			light_y_stub();

			translate([x * light_tube_dist_x + pipe_radius, 0, 0])
			if (x < light_tube_count_x - 1) {
				if (x % 2 == 0) {
					// Near end wire connector.
					translate([0, -(light_y_stub_length + pipe_radius * 2 + tee_connector_y_offset*2), 0])
						light_x_segment();
					// Far end structural connector.
					translate([0, light_tube_total_dist_y - pipe_radius*2 - light_y_stub_dist, 0])
						light_x_brace();
				} else {
					// Far end wire connector.
					translate([0, light_tube_total_dist_y + pipe_radius*2 + light_y_stub_length + tee_connector_y_offset*2, 0])
						light_x_segment();
					// Near end structural connector.
					translate([0, light_y_stub_dist + pipe_radius*2, 0])
						light_x_brace();
				}
			}
	}

}

module pergola() {
	translate([0,0,pipe_radius])
	//color("Orange")
	translate([a_post_x + b_beam_w + light_tube_offset_x, a_post_y + c_beam_w + light_tube_offset_y, c_beam_z]) 	lighting();

  for (i = [0 : a_post_pair_count - 1]) {
    translate([i * (a_post_x_inner_spacing + a_post_x),0,0]) {
      a_post();
      translate([0, a_post_y_inner_spacing + a_post_x, 0]) a_post();
      translate([0,0,b_beam_z]) b_beam_pair();
	  if (i == 0) {
		e2_beams();
	  } else if (i == a_post_pair_count - 1) {
		translate([-a_post_x + e_beam_w,0,0]) e2_beams();
	  } else {
		translate([-(a_post_x/2 - e_beam_w/2),0,0]) e2_beams();
//		translate([-a_post_x + e_beam_w,0,0]) e2_beams();
	  }
    }
  }

  for (i = [0 : c_beam_pair_count - 1]) {
    translate([0,i * (c_beam_pair_y_inner_spacing + c_beam_pair_width),c_beam_z])
    c_beam_pair();
  }
  e1_beams();


  translate([-(c_beam_overhang + b_beam_w + f_slat_w / 2),0,f_slat_z])
  for (i = [0 : f_slat_count - 1]) {
    translate([(i + 1) * f_slat_x_cl_spacing,0,0]) f_slat();
  }
}

module a_post() {
  translate([0,0,-(sin($t * 180) * 2 * ft)])
  color("DarkOliveGreen") cube([a_post_x, a_post_y, a_post_l]);
}

module b_beam_pair() {
  translate([-b_beam_w,0,0]) {
    b_beam();
    translate([a_post_x + b_beam_w,0,0]) b_beam();
  }
}


module b_beam_overhang_cutout() {
  excess = .1 * in;
  rotate([0,90,0]) rotate([0,0,-90])
  translate([b_beam_overhang_radius + 2 * in,0,-excess])
  union() {
    cylinder(h = b_beam_w + excess * 2, r = b_beam_overhang_radius, $fn = cyl_detail);
    translate([0, -b_beam_overhang_radius, 0]) cube([b_beam_overhang, b_beam_overhang_radius * 2, b_beam_w + excess * 2]);
  }
}

module b_beam() {
  color("DarkKhaki") difference() {
    translate([0,-(b_beam_overhang + c_beam_w),0])
      cube([b_beam_w, b_beam_l, b_beam_h]);

      b_beam_overhang_cutout();
      translate([0, b_beam_l - (b_beam_overhang * 2) - b_beam_overhang_radius, 0])
        rotate([180,0,0])
        b_beam_overhang_cutout();
  }
}

module c_beam_overhang_cutout() {
  excess = .1 * in;
  translate([-(c_beam_overhang_radius + b_beam_w + 2 * in),0,0])
  rotate([-90,0,0])
  translate([0,0,-excess])
  union() {
    cylinder(h = c_beam_w + excess * 2, r = c_beam_overhang_radius, $fn = cyl_detail);
    translate([-c_beam_overhang, -c_beam_overhang_radius, 0])
      cube([c_beam_overhang, c_beam_overhang_radius * 2, c_beam_w + excess * 2]);
  }
}

module c_beam_pair() {
  translate([0,-c_beam_w,0]) {
    c_beam();
    translate([0,a_post_y + c_beam_w,0]) c_beam();
  }
}

module c_beam() {
  difference() {
    translate([-(c_beam_overhang + b_beam_w),0,0])
      cube([c_beam_l, c_beam_w, c_beam_h]);
    c_beam_overhang_cutout();
    translate([c_beam_l - (c_beam_overhang * 2) - c_beam_overhang_radius,0, 0])
        rotate([0,180,0])
        c_beam_overhang_cutout();
  }
}

module f_slat_overhang_cutout() {
  excess = .1 * in;
  rotate([0,90,0]) rotate([0,0,-90])
  translate([f_slat_overhang_radius + 5 * in,0,-excess])
  union() {
    cylinder(h = f_slat_w + excess * 2, r = f_slat_overhang_radius, $fn = cyl_detail);
    translate([0, -f_slat_overhang_radius, 0]) cube([f_slat_overhang, f_slat_overhang_radius * 2, f_slat_w + excess * 2]);
  }
}

module f_slat() {
  color("Khaki") difference() {
    translate([0, -(f_slat_overhang + c_beam_w),0])
      cube([f_slat_w, f_slat_l, f_slat_h]);
    f_slat_overhang_cutout();
    translate([0, f_slat_l - (f_slat_overhang * 2) - f_slat_overhang_radius - 1 *in, 0])
      rotate([180,0,0])
      f_slat_overhang_cutout();
  }
}

module e1_beams() {
	e1_beams_side();
	translate([a_post_x + (a_post_pair_count - 1) * (a_post_x_inner_spacing + a_post_x),0,0])
		mirror([1,0,0])
		e1_beams_side();
}

module e1_beams_side() {
	for (i = [0 : a_post_pair_count - 2]) {
		translate([i * (a_post_x_inner_spacing + a_post_x), 0, 0]) {
			translate([a_post_x, a_post_y - e_beam_w, a_post_l - e1_beam_outer_adjacent])
				e1_beam();
			translate([a_post_x, a_post_y_inner_spacing + a_post_y, a_post_l - e1_beam_outer_adjacent])
				e1_beam();
		}
	}
}

module e1_beam() {
	sub_size = e_beam_h * 1.5;
	difference() {
		color("red") rotate([0,-(90-e1_beam_angle),0]) cube([e1_beam_outer_hypotenuse, e_beam_w, e_beam_h]);
		translate([0,e_beam_w/2,0]) {
			translate([-sub_size,-(sub_size/2),0]) cube([sub_size, sub_size, e1_beam_outer_hypotenuse]);
			translate([0,-(sub_size/2),e1_beam_outer_adjacent]) cube([e1_beam_outer_hypotenuse, sub_size, sub_size]);
		}
	}
}

module e2_beam() {
	sub_size = e_beam_h * 1.5;
	difference() {
		color("red") rotate([90-e2_beam_angle,0,0]) cube([e_beam_w, e2_beam_outer_hypotenuse, e_beam_h]);
		translate([-(sub_size/2) + e_beam_w/2,0,0]) {
			translate([0,-sub_size,0]) cube([sub_size, sub_size, e2_beam_outer_hypotenuse]);
			translate([0,0,e2_beam_outer_adjacent]) cube([sub_size, e2_beam_outer_hypotenuse, sub_size]);
		}
	}
}

module e2_beams() {
	translate([a_post_x - e_beam_w,a_post_y,b_beam_z + b_beam_h - e2_beam_outer_adjacent]) {
		e2_beam();
		translate([0,a_post_y_inner_spacing,0]) mirror([0,1,0]) e2_beam();
	}
}
