---------------------------------------------------------------------------
--- Module dedicated to gather common shape painters.
--
-- It add the concept of "shape" to Awesome. A shape can be applied to a
-- background, a margin, a mask or a drawable shape bounding.
--
-- The functions exposed by this module always take a context as first
-- parameter followed by the widget and height and additional parameters.
--
-- The functions provided by this module only create a path in the content.
-- to actually draw the content, use `cr:fill()`, `cr:mask()`, `cr:clip()` or
-- `cr:stroke()`
--
-- In many case, it is necessary to apply the shape using a transformation
-- such as a rotation. The preferred way to do this is to wrap the function
-- in another function calling `cr:rotate()` (or any other transformation
-- matrix)
--
-- @author Emmanuel Lepage Vallee
-- @copyright 2011-2016 Emmanuel Lepage Vallee
-- @release @AWESOME_VERSION@
-- @module gears.shape
---------------------------------------------------------------------------
local g_matrix = require( "gears.matrix" )

local module = {}

--- Add a rounded rectangle to the current path.
-- Note: If the radius is bigger than either half side, it will be reduced.
--
-- @DOC_gears_shape_rounded_rect_EXAMPLE@
--
-- @param cr A cairo content
-- @tparam number width The rectangle width
-- @tparam number height The rectangle height
-- @tparam number radius the corner radius
function module.rounded_rect(cr, width, height, radius)
    radius = radius or 10

    if width / 2 < radius then
        radius = width / 2
    end

    if height / 2 < radius then
        radius = height / 2
    end

    cr:arc( radius      , radius       , radius,    math.pi   , 3*(math.pi/2) )
    cr:arc( width-radius, radius       , radius, 3*(math.pi/2),    math.pi*2  )
    cr:arc( width-radius, height-radius, radius,    math.pi*2 ,    math.pi/2  )
    cr:arc( radius      , height-radius, radius,    math.pi/2 ,    math.pi    )

    cr:close_path()
end

--- Add a rectangle delimited by 2 180 degree arcs to the path.
--
-- @DOC_gears_shape_rounded_bar_EXAMPLE@
--
-- @param cr A cairo content
-- @param width The rectangle width
-- @param height The rectangle height
function module.rounded_bar(cr, width, height)
    module.rounded_rect(cr, width, height, height / 2)
end

--- A rounded rect with only some of the corners rounded.
--
-- @DOC_gears_shape_partially_rounded_rect_EXAMPLE@
--
-- @param cr A cairo context
-- @tparam number width The shape width
-- @tparam number height The shape height
-- @tparam boolean tl If the top left corner is rounded
-- @tparam boolean tr If the top right corner is rounded
-- @tparam boolean br If the bottom right corner is rounded
-- @tparam boolean bl If the bottom left corner is rounded
-- @tparam number rad The corner radius
function module.partially_rounded_rect(cr, width, height, tl, tr, br, bl, rad)
    rad = rad or 10
    if width / 2 < rad then
        rad = width / 2
    end

    if height / 2 < rad then
        rad = height / 2
    end

    -- Top left
    if tl then
        cr:arc( rad, rad, rad, math.pi, 3*(math.pi/2))
    else
        cr:move_to(0,0)
    end

    -- Top right
    if tr then
        cr:arc( width-rad, rad, rad, 3*(math.pi/2), math.pi*2)
    else
        cr:line_to(width, 0)
    end

    -- Bottom right
    if br then
        cr:arc( width-rad, height-rad, rad, math.pi*2 , math.pi/2)
    else
        cr:line_to(width, height)
    end

    -- Bottom left
    if bl then
        cr:arc( rad, height-rad, rad, math.pi/2, math.pi)
    else
        cr:line_to(0, height)
    end

    cr:close_path()
end

--- A rounded rectangle with a triangle at the top.
--
-- @DOC_gears_shape_infobubble_EXAMPLE@
--
-- @param cr A cairo context
-- @tparam number width The shape width
-- @tparam number height The shape height
-- @tparam[opt=5] number corner_radius The corner radius
-- @tparam[opt=10] number arrow_size The width and height of the arrow
-- @tparam[opt=width/2 - arrow_size/2] number arrow_position The position of the arrow
function module.infobubble(cr, width, height, corner_radius, arrow_size, arrow_position)
    arrow_size     = arrow_size     or 10
    corner_radius  = math.min((height-arrow_size)/2, corner_radius or 5)
    arrow_position = arrow_position or width/2 - arrow_size/2


    cr:move_to(0 ,corner_radius+arrow_size)

    -- Top left corner
    cr:arc(corner_radius, corner_radius+arrow_size, (corner_radius), math.pi, 3*(math.pi/2))

    -- The arrow triangle (still at the top)
    cr:line_to(arrow_position                , arrow_size )
    cr:line_to(arrow_position + arrow_size   , 0          )
    cr:line_to(arrow_position + 2*arrow_size , arrow_size )

    -- Complete the rounded rounded rectangle
    cr:arc(width-corner_radius, corner_radius+arrow_size  , (corner_radius) , 3*(math.pi/2) , math.pi*2 )
    cr:arc(width-corner_radius, height-(corner_radius)    , (corner_radius) , math.pi*2     , math.pi/2 )
    cr:arc(corner_radius      , height-(corner_radius)    , (corner_radius) , math.pi/2     , math.pi   )

    -- Close path
    cr:close_path()
end

--- A rectangle terminated by an arrow.
--
-- @DOC_gears_shape_rectangular_tag_EXAMPLE@
--
-- @param cr A cairo context
-- @tparam number width The shape width
-- @tparam number height The shape height
-- @tparam[opt=height/2] number arrow_length The length of the arrow part
function module.rectangular_tag(cr, width, height, arrow_length)
    arrow_length = arrow_length or height/2
    if arrow_length > 0 then
        cr:move_to(0            , height/2 )
        cr:line_to(arrow_length , 0        )
        cr:line_to(width        , 0        )
        cr:line_to(width        , height   )
        cr:line_to(arrow_length , height   )
    else
        cr:move_to(0            , 0        )
        cr:line_to(-arrow_length, height/2 )
        cr:line_to(0            , height   )
        cr:line_to(width        , height   )
        cr:line_to(width        , 0        )
    end

    cr:close_path()
end

--- A simple arrow shape.
--
-- @DOC_gears_shape_arrow_EXAMPLE@
--
-- @param cr A cairo context
-- @tparam number width The shape width
-- @tparam number height The shape height
-- @tparam[opt=head_width] number head_width The width of the head (/\) of the arrow
-- @tparam[opt=width /2] number shaft_width The width of the shaft of the arrow
-- @tparam[opt=height/2] number shaft_length The head_length of the shaft (the rest is the head)
function module.arrow(cr, width, height, head_width, shaft_width, shaft_length)
    shaft_length = shaft_length or height / 2
    shaft_width  = shaft_width  or width  / 2
    head_width   = head_width   or width
    local head_length  = height - shaft_length

    cr:move_to    ( width/2                     , 0            )
    cr:rel_line_to( head_width/2                , head_length  )
    cr:rel_line_to( -(head_width-shaft_width)/2 , 0            )
    cr:rel_line_to( 0                           , shaft_length )
    cr:rel_line_to( -shaft_width                , 0            )
    cr:rel_line_to( 0           , -shaft_length                )
    cr:rel_line_to( -(head_width-shaft_width)/2 , 0            )

    cr:close_path()
end

--- A squeezed hexagon filling the rectangle.
--
-- @DOC_gears_shape_hexagon_EXAMPLE@
--
-- @param cr A cairo context
-- @tparam number width The shape width
-- @tparam number height The shape height
function module.hexagon(cr, width, height)
    cr:move_to(height/2,0)
    cr:line_to(width-height/2,0)
    cr:line_to(width,height/2)
    cr:line_to(width-height/2,height)
    cr:line_to(height/2,height)
    cr:line_to(0,height/2)
    cr:line_to(height/2,0)
    cr:close_path()
end

--- Double arrow popularized by the vim-powerline module.
--
-- @DOC_gears_shape_powerline_EXAMPLE@
--
-- @param cr A cairo context
-- @tparam number width The shape width
-- @tparam number height The shape height
-- @tparam[opt=height/2] number arrow_depth The width of the arrow part of the shape
function module.powerline(cr, width, height, arrow_depth)
    arrow_depth = arrow_depth or height/2
    local offset = 0

    -- Avoid going out of the (potential) clip area
    if arrow_depth < 0 then
        width  =  width + 2*arrow_depth
        offset = -arrow_depth
    end

    cr:move_to(offset                       , 0        )
    cr:line_to(offset + width - arrow_depth , 0        )
    cr:line_to(offset + width               , height/2 )
    cr:line_to(offset + width - arrow_depth , height   )
    cr:line_to(offset                       , height   )
    cr:line_to(offset + arrow_depth         , height/2 )

    cr:close_path()
end

--- An isosceles triangle.
--
-- @DOC_gears_shape_isosceles_triangle_EXAMPLE@
--
-- @param cr A cairo context
-- @tparam number width The shape width
-- @tparam number height The shape height
function module.isosceles_triangle(cr, width, height)
    cr:move_to( width/2, 0      )
    cr:line_to( width  , height )
    cr:line_to( 0      , height )
    cr:close_path()
end

--- A cross (**+**) symbol.
--
-- @DOC_gears_shape_cross_EXAMPLE@
--
-- @param cr A cairo context
-- @tparam number width The shape width
-- @tparam number height The shape height
-- @tparam[opt=width/3] number thickness The cross section thickness
function module.cross(cr, width, height, thickness)
    thickness = thickness or width/3
    local xpadding   = (width  - thickness) / 2
    local ypadding   = (height - thickness) / 2
    cr:move_to(xpadding, 0)
    cr:line_to(width - xpadding, 0)
    cr:line_to(width - xpadding, ypadding)
    cr:line_to(width           , ypadding)
    cr:line_to(width           , height-ypadding)
    cr:line_to(width - xpadding, height-ypadding)
    cr:line_to(width - xpadding, height         )
    cr:line_to(xpadding        , height         )
    cr:line_to(xpadding        , height-ypadding)
    cr:line_to(0               , height-ypadding)
    cr:line_to(0               , ypadding       )
    cr:line_to(xpadding        , ypadding       )
    cr:close_path()
end

--- A similar shape to the `rounded_rect`, but with sharp corners.
--
-- @DOC_gears_shape_octogon_EXAMPLE@
--
-- @param cr A cairo context
-- @tparam number width The shape width
-- @tparam number height The shape height
-- @tparam number corner_radius 
function module.octogon(cr, width, height, corner_radius)
    corner_radius = corner_radius or math.min(10, math.min(width, height)/4)
    local offset = math.sqrt( (corner_radius*corner_radius) / 2 )

    cr:move_to(offset, 0)
    cr:line_to(width-offset, 0)
    cr:line_to(width, offset)
    cr:line_to(width, height-offset)
    cr:line_to(width-offset, height)
    cr:line_to(offset, height)
    cr:line_to(0, height-offset)
    cr:line_to(0, offset)
    cr:close_path()
end

--- A circle shape.
--
-- @DOC_gears_shape_circle_EXAMPLE@
--
-- @param cr A cairo context
-- @tparam number width The shape width
-- @tparam number height The shape height
function module.circle(cr, width, height)
    local size = math.min(width, height) / 2
    cr:arc(width / 2, height / 2, size, 0, 2*math.pi)
    cr:close_path()
end

--- A simple rectangle.
--
-- @DOC_gears_shape_rectangle_EXAMPLE@
--
-- @param cr A cairo context
-- @tparam number width The shape width
-- @tparam number height The shape height
function module.rectangle(cr, width, height)
    cr:rectangle(0, 0, width, height)
end

--- A diagonal parallelogram with the bottom left corner at x=0 and top right
-- at x=width.
--
-- @DOC_gears_shape_parallelogram_EXAMPLE@
--
-- @param cr A cairo context
-- @tparam number width The shape width
-- @tparam number height The shape height
-- @tparam[opt=width/3] number base_width The parallelogram base width
function module.parallelogram(cr, width, height, base_width)
    base_width = base_width or width/3
    cr:move_to(width-base_width, 0      )
    cr:line_to(width           , 0      )
    cr:line_to(base_width      , height )
    cr:line_to(0               , height )
    cr:close_path()
end

--- A losange.
--
-- @DOC_gears_shape_losange_EXAMPLE@
--
-- @param cr A cairo context
-- @tparam number width The shape width
-- @tparam number height The shape height
function module.losange(cr, width, height)
    cr:move_to(width/2 , 0        )
    cr:line_to(width   , height/2 )
    cr:line_to(width/2 , height   )
    cr:line_to(0       , height/2 )
    cr:close_path()
end

--- A partial rounded bar. How much of the rounded bar is visible depends on
-- the given percentage value.
--
-- Note that this shape is not closed and thus filling it doesn't make much
-- sense.
--
-- @DOC_gears_shape_radial_progress_EXAMPLE@
--
-- @param cr A cairo context
-- @tparam number w The shape width
-- @tparam number h The shape height
-- @tparam number percent The progressbar percent
-- @tparam boolean hide_left Do not draw the left side of the shape
function module.radial_progress(cr, w, h, percent, hide_left)
    percent = percent or 1
    local total_length = (2*(w-h))+2*((h/2)*math.pi)
    local bar_percent  = (w-h)/total_length
    local arc_percent  = ((h/2)*math.pi)/total_length

    -- Bottom line
    if percent > bar_percent then
        cr:move_to(h/2,h)
        cr:line_to((h/2) + (w-h),h)
        cr:stroke()
    elseif percent < bar_percent then
        cr:move_to(h/2,h)
        cr:line_to(h/2+(total_length*percent),h)
        cr:stroke()
    end

    -- Right arc
    if percent >= bar_percent+arc_percent then
        cr:arc(w-h/2 , h/2, h/2,3*(math.pi/2),math.pi/2)
        cr:stroke()
    elseif percent > bar_percent and percent < bar_percent+(arc_percent/2) then
        cr:arc(w-h/2 , h/2, h/2,(math.pi/2)-((math.pi/2)*((percent-bar_percent)/(arc_percent/2))),math.pi/2)
        cr:stroke()
    elseif percent >= bar_percent+arc_percent/2 and percent < bar_percent+arc_percent then
        cr:arc(w-h/2 , h/2, h/2,0,math.pi/2)
        cr:stroke()
        local add = (math.pi/2)*((percent-bar_percent-arc_percent/2)/(arc_percent/2))
        cr:arc(w-h/2 , h/2, h/2,2*math.pi-add,0)
        cr:stroke()
    end

    -- Top line
    if percent > 2*bar_percent+arc_percent then
        cr:move_to((h/2) + (w-h),0)
        cr:line_to(h/2,0)
        cr:stroke()
    elseif percent > bar_percent+arc_percent and percent < 2*bar_percent+arc_percent then
        cr:move_to((h/2) + (w-h),0)
        cr:line_to(((h/2) + (w-h))-total_length*(percent-bar_percent-arc_percent),0)
        cr:stroke()
    end

    -- Left arc
    if not hide_left then
        if percent > 0.985 then
            cr:arc(h/2, h/2, h/2,math.pi/2,3*(math.pi/2))
            cr:stroke()
        elseif percent  > 2*bar_percent+arc_percent then
            local relpercent = (percent - 2*bar_percent - arc_percent)/arc_percent
            cr:arc(h/2, h/2, h/2,3*(math.pi/2)-(math.pi)*relpercent,3*(math.pi/2))
            cr:stroke()
        end
    end
end

--- Adjust the shape using a transformation object
--
-- Apply various transformations to the shape
--
-- @usage gears.shape.transform(gears.shape.rounded_bar)
--    : rotate(math.pi/2)
--       : translate(10, 10)
--
-- @param shape A shape function
-- @return A transformation handle, also act as a shape function
function module.transform(shape)

    -- Apply the transformation matrix and apply the shape, then restore
    local function apply(self, cr, width, height, ...)
        cr:save()
        cr:transform(self.matrix:to_cairo_matrix())
        shape(cr, width, height, ...)
        cr:restore()
    end
    -- Redirect function calls like :rotate() to the underlying matrix
    local function index(_, key)
        return function(self, ...)
            self.matrix = self.matrix[key](self.matrix, ...)
            return self
        end
    end

    local result = setmetatable({
        matrix = g_matrix.identity
    }, {
        __call = apply,
        __index = index
    })

    return result
end

return module

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
