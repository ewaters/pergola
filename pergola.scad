// Define units

in = 1;
ft = 12 * in;

// Define sizes of lumber

two_four_w = 1.5 * in;
two_four_h = 3.5 * in;

two_six_w = 1.5 * in;
two_six_h = 5.5 * in;

four_four_w = 3.5 * in;
four_four_h = 3.5 * in;

// Associate individual pieces with their size

a_post_x = four_four_w;
a_post_y = four_four_h;
a_post_l = 10 * ft;

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

b_beam_upper_notch_depth = 0;

c_beam_lower_notch_depth = 2 * in;
c_beam_upper_notch_depth = 0;

f_slat_lower_notch_depth = 1.5 * in;

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

// Construct the model

b_beam();

module pergola() {
  for (i = [0 : a_post_pair_count - 1]) {
    translate([i * (a_post_x_inner_spacing + a_post_x),0,0]) {
      a_post();
      translate([0, a_post_y_inner_spacing + a_post_x, 0]) a_post();
      translate([0,0,b_beam_z]) b_beam_pair();
    }
  }

  for (i = [0 : c_beam_pair_count - 1]) {
    translate([0,i * (c_beam_pair_y_inner_spacing + c_beam_pair_width),c_beam_z])
    c_beam_pair();
  }

  translate([-(c_beam_overhang + b_beam_w + f_slat_w / 2),0,f_slat_z])
  for (i = [0 : f_slat_count - 1]) {
    translate([(i + 1) * f_slat_x_cl_spacing,0,0]) f_slat();
  }
}

module a_post() {
  cube([a_post_x, a_post_y, a_post_l]);
}

module b_beam_pair() {
  translate([-b_beam_w,0,0]) {
    b_beam();
    translate([a_post_x + b_beam_w,0,0]) b_beam();
  }
}

module b_beam_overhang_cutout() {
  cyn_radius = 3.5 * in;
  excess = .1 * in;
  rotate([0,90,0]) rotate([0,0,-90])
  translate([cyn_radius + 2 * in,0,-excess])
  union() {
    cylinder(h = b_beam_w + excess * 2, r = cyn_radius, $fn = 20);
    translate([0, -cyn_radius, 0]) cube([b_beam_overhang, cyn_radius * 2, b_beam_w + excess * 2]);
  }
}

module b_beam() {
  difference() {
    translate([0,-(b_beam_overhang + c_beam_w),0])
      cube([b_beam_w, b_beam_l, b_beam_h]);

      %b_beam_overhang_cutout();
      % translate([0, b_beam_l - (b_beam_overhang * 2), 0])
        rotate([180,0,0])
        b_beam_overhang_cutout();
  }
}

module c_beam_pair() {
  translate([0,-c_beam_w,0]) {
    c_beam();
    translate([0,a_post_y + c_beam_w,0]) c_beam();
  }
}

module c_beam() {
  translate([-(c_beam_overhang + b_beam_w),0,0])
  cube([c_beam_l, c_beam_w, c_beam_h]);
}

module f_slat() {
  translate([0, -(f_slat_overhang + c_beam_w),0])
  cube([f_slat_w, f_slat_l, f_slat_h]);
}
