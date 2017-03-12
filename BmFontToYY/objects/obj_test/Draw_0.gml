draw_set_font(fnt_test);
var s = "The quick brown fox jumps over a lazy dog";
draw_text_ext(4, 4, string_upper(s) + @"
" + string_lower(s), -1, room_width - 8);