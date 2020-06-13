function EmuText(_x, _y, _w, _h, _text) : EmuCore(_x, _y, _w, _h) constructor {
    text = _text;
    
    Render = function(base_x, base_y) {
        processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        var tx = getTextX(x1);
        var ty = getTextY(y1);
        
        if (GetMouseHover(x1, y1, x2, y2)) {
            ShowTooltip();
            if (GetMouseReleased(x1, y1, x2, y2)) {
                Activate();
            }
        }
        
        scribble_set_wrap(width, height);
        scribble_set_box_align(alignment, valignment);
        scribble_draw(tx, ty, text);
    }
}