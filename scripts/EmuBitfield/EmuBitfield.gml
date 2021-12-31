// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu
function EmuBitfield(x, y, w, h, value, callback) : EmuCallback(x, y, w, h, value, callback) constructor {
    enum E_BitfieldOrientations { HORIZONTAL, VERTICAL };
    
    self.fixed_spacing = -1;
    self.orientation = E_BitfieldOrientations.HORIZONTAL;
    
    static SetOrientation = function(orientation) {
        orientation = orientation;
        ArrangeElements();
        return self;
    };
    
    static SetFixedSpacing = function(spacing) {
        fixed_spacing = spacing;
        ArrangeElements();
        return self;
    };
    
    static SetAutoSpacing = function() {
        fixed_spacing = -1;
        ArrangeElements();
        return self;
    };
    
    static AddOptions = function(elements) {
        if (!is_array(elements)) {
            elements = [elements];
        }
        
        for (var i = 0; i < array_length(elements); i++) {
            if (!is_struct(elements[i])) {
                elements[i] = new EmuBitfieldOption(string(elements[i]), 1 << (array_length(self.contents) + i),
                function() {
                    root.value ^= value;
                    root.callback();
                },
                function() {
                    return (root.value & value) == value;
                });
            }
        }
        
        AddContent(elements);
        ArrangeElements();
        return self;
    };
    
    static ArrangeElements = function() {
        if (orientation == E_BitfieldOrientations.HORIZONTAL) {
            for (var i = 0, n = array_length(contents); i < n; i++) {
                var option = contents[i];
                option.width = (fixed_spacing == -1) ? floor(width / n) : fixed_spacing;
                option.height = height;
                option.x = option.width * i;
                option.y = 0;
            }
        } else {
            for (var i = 0, n = array_length(contents); i < n; i++) {
                var option = contents[i];
                option.width = width;
                option.height = (fixed_spacing == -1) ? floor(height / n) : fixed_spacing;
                option.x = 0;
                option.y = option.height * i;
            }
        }
        return self;
    };
    
    static GetHeight = function() {
        var first = self.contents[0];
        var last = self.contents[array_length(self.contents) - 1];
        return (first == undefined) ? self.height : (last.y + last.height - first.y);
    };
    
    static Render = function(base_x, base_y) {
        self.gc.Clean();
        processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        renderContents(x1, y1);
    };
}

function EmuBitfieldOption(text, value, callback, eval) : EmuCallback(0, 0, 0, 0, value, callback) constructor {
    static SetEval = function(eval) {
        evaluate = method(self, eval);
    };
    
    self.text = text;
    SetEval(eval);
    
    self.color_hover = function() { return EMU_COLOR_HOVER };
    self.color_disabled = function() { return EMU_COLOR_DISABLED };
    self.color_active = function() { return EMU_COLOR_SELECTED };
    self.color_inactive = function() { return EMU_COLOR_BACK };
    
    static Render = function(base_x, base_y) {
        self.gc.Clean();
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        var back_color = evaluate() ? self.color_active() : self.color_inactive();
        
        if (root.GetInteractive()) {
            back_color = merge_colour(back_color, getMouseHover(x1, y1, x2, y2) ? self.color_hover() : back_color, 0.5);
        } else {
            back_color = merge_colour(back_color, self.color_disabled(), 0.5);
        }
        
        draw_sprite_stretched_ext(sprite_nineslice, 1, x1, y1, x2 - x1, y2 - y1, back_color, 1);
        draw_sprite_stretched_ext(sprite_nineslice, 0, x1, y1, x2 - x1, y2 - y1, self.color(), 1);
        
        scribble(self.text)
            .align(fa_center, fa_middle)
            .draw(floor(mean(x1, x2)), floor(mean(y1, y2)));
        
        if (getMouseHover(x1, y1, x2, y2)) {
            ShowTooltip();
        }
        
        if (getMousePressed(x1, y1, x2, y2)) {
            callback();
        }
    };
    
    static GetInteractive = function() {
        return enabled && interactive && root.interactive && root.isActiveDialog();
    };
}

// You may find yourself using these particularly often
function emu_bitfield_option_exact_callback() {
    root.value = value;
    root.callback();
}

function emu_bitfield_option_exact_eval() {
    return root.value == value;
};