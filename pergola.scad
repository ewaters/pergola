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

e_beam_w = two_six_w;
e_beam_h = two_six_h;

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

cyl_detail = 10;

e1_beam_inner_hypotenuse = 2 * ft;
e2_beam_inner_hypotenuse = 2 * ft;

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
e1_beam_outer_adjacent = (e_beam_w + e1_beam_inner_cross_opposite) / sin(e1_beam_angle);
e1_beam_outer_hypotenuse = e1_beam_outer_adjacent / cos(e1_beam_angle);

e2_beam_inner_adjacent = e2_beam_inner_hypotenuse * cos(e2_beam_angle);
e2_beam_inner_cross_opposite = e2_beam_inner_adjacent * sin(e2_beam_angle);
e2_beam_outer_adjacent = (e_beam_w + e2_beam_inner_cross_opposite) / sin(e2_beam_angle);
e2_beam_outer_hypotenuse = e2_beam_outer_adjacent / cos(e2_beam_angle);

// Construct the model

translate([-(a_post_x_inner_spacing + a_post_x * 1.5),-(a_post_y_inner_spacing/2 + a_post_y),0])
pergola();

module pergola() {
  for (i = [0 : a_post_pair_count - 1]) {
    translate([i * (a_post_x_inner_spacing + a_post_x),0,0]) {
      a_post();
      translate([0, a_post_y_inner_spacing + a_post_x, 0]) a_post();
      translate([0,0,b_beam_z]) b_beam_pair();
	  if (i == a_post_pair_count - 1) {
		translate([-a_post_x + e_beam_w,0,0]) e2_beams();
	  } else {
		e2_beams();
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
  //translate([0,0,-(sin($t * 180) * 2 * ft)])
  color("DarkOliveGreen") cube([a_post_x, a_post_y, a_post_l]);
}

module b_beam_pair() {
  translate([-b_beam_w,0,0]) {
    b_beam();
    translate([a_post_x + b_beam_w,0,0]) b_beam();
  }
}

b_beam_overhang_radius = 3.5 * in;

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

c_beam_overhang_radius = 3.5 * in;

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

f_slat_overhang_radius = 2 * in;

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
	difference() {
		color("Tan") rotate([0,-e1_beam_angle,0]) cube([e1_beam_outer_hypotenuse, e_beam_w, e_beam_h]);
		translate([0,e_beam_w/2,0]) {
			translate([-e_beam_h,-(e_beam_h/2),0]) cube([e_beam_h, e_beam_h, e1_beam_outer_hypotenuse]);
			translate([0,-(e_beam_h/2),e1_beam_outer_adjacent]) cube([e1_beam_outer_hypotenuse, e_beam_h, e_beam_h]);
		}
	}
}

module e2_beam() {
	difference() {
		color("Tan") rotate([e2_beam_angle,0,0]) cube([e_beam_w, e2_beam_outer_hypotenuse, e_beam_h]);
		translate([-(e_beam_h/2) + e_beam_w/2,0,0]) {
			translate([0,-e_beam_h,0]) cube([e_beam_h, e_beam_h, e2_beam_outer_hypotenuse]);
			translate([0,0,e2_beam_outer_adjacent]) cube([e_beam_h, e2_beam_outer_hypotenuse, e_beam_h]);
		}
	}
}

module e2_beams() {
	translate([a_post_x - e_beam_w,a_post_y,b_beam_z + b_beam_h - e2_beam_outer_adjacent]) {
		e2_beam();
		translate([0,a_post_y_inner_spacing,0]) mirror([0,1,0]) e2_beam();
	}
}
