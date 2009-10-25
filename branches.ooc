import cairo/Cairo
import structs/ArrayList
use math
include time

time: extern func (Pointer) -> Int

Branch: cover {   
   x,y: Int
   radius, oradius: Double
   direction: Double

   new: static func(.x, .y, .direction, sradius: Double) -> This {
      b : Branch
      b x = x
      b y = y
      b direction = direction
      b radius = sradius
      b oradius = sradius
      return b
   }
}


TreeField: class {

   // cairo 
   surface: Surface
   cx: Context
   width: Int
   height: Int
   filename: String
   frame: Int

   // drawing settings
   startradius       := 20.0
   straighten_factor := 0.95
   curviness         := 0.1
   color_speed       := 0.03
   new_branch_frames := 250
   branch_shrink     := 0.95
   branch_opacity    := 0.7

   // constants
   pi                = 3.1415926 : const Double

   init: func(=filename, =width, =height) {
      surface = ImageSurface new(0, width, height)
      cx = Context new(surface)

      frame = 0

      // initialize random number generator
      srand(time(null));

      cx setSourceRGB(1.0, 1.0, 1.0)
      cx paint()
   }

   addTree: func(x,y :Int) {
      branches := ArrayList<Branch> new(20)
    
      // create the branches
      b1 := Branch new(x, y, 0.0, startradius)
      b2 := Branch new(x, y, pi * 2.0 / 3.0, startradius)
      b3 := Branch new(x, y, pi * 4.0 / 3.0, startradius)
      branches .add(b1) .add(b2) .add(b3)

      direction_offset := 0.0

      while (branches size() != 0) {
         // color
         r :=  sin(frame * color_speed) + 0.5        
         g := sin((frame * color_speed) + (pi * 2.0 / 3.0) ) + 0.5         
         b := sin((frame * color_speed) + (pi * 4.0 / 3.0) ) + 0.5         
         cx setSourceRGBa(r, g, b, branch_opacity)

         frame += 1

         // direction
         direction_offset += ((rand() % 10000) / 10000.0) * curviness - curviness / 2
         direction_offset *= straighten_factor

         for (j: Int in 0..branches size()) {
            i := branches size() - j -1
            this_branch := branches get(i)

            cx setLineWidth(this_branch radius)
            cx moveTo(this_branch x , this_branch y)

            this_branch radius *= branch_shrink
            this_branch direction += direction_offset
            this_branch x += cos(this_branch direction) * this_branch radius
            this_branch y += sin(this_branch direction) * this_branch radius
            cx lineTo(this_branch x, this_branch y)
            cx stroke() 

            if (this_branch radius < (this_branch oradius / 2.0)) {
               branches removeAt(i)  
               new_radius := this_branch oradius / 2.0
               if (new_radius > 2) {
                  bn1 := Branch new(this_branch x, this_branch y, this_branch direction, new_radius)
                  bn2 := Branch new(this_branch x, this_branch y, this_branch direction + 1, new_radius)
                  branches .add(bn1) .add(bn2)
               }
            }
            else {
               branches set(i, this_branch)
            }
         }
      }
   }

  addRandomTrees: func(count: Int) {
    for (i in 0..count) {
      addTree(rand() % width, rand() % height)
    }   
  }

  finalize: func {
      surface writeToPng(filename)
   }
}

main: func {
    w := 1200
    h := 1200
    filename := "bracnhes.png"

    t := TreeField new(filename, w, h) /* 0 = CAIRO_FORMAT_ARGB32 */
    t addRandomTrees(25)
    t finalize()
}
