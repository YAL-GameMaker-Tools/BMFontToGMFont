# BmFontToGMX #

This small program converts [BMFont](http://www.angelcode.com/products/bmfont/)'s "text format" `.fnt` font atlas files to GameMaker compatible (`.font.gmx` for GM:S, `.yy` for GMS2+) font atlas files.

This allows to make use of BMFont's numerous settings while having fonts that work as fast as those produced by GameMaker itself.

### Setting up ###

With GameMaker expecting fonts to be in a certain format, you'll need to do a bit of setup in BMFont' "export options" to produce compliant files:

* Check "force offsets to zero". GameMaker does not support vertical offsets in font glyphs, meaning that it cannot correctly interpret "clipped" format exported by default.
* Set "bit depth" to 32.
* Set channels (ARGB) to "glyph", "one", "one", "one" accordingly to produce white glyphs on transparent background.
* Set "font descriptor" to "Text".
* Set "textures" to "PNG".
* Set "texture width" and "texture height" to power-of-two (128, 256, 512, ...) values that are sufficient for your font to fit onto a single "page". Use "Visualize" option from main menu to check.

If you do not have an existing font configuration, you can also use the included `fnt_test.bmfc` as a starting point.

### Use ###

Once your font is configured accordingly, export a bitmap font to a `.fnt` file (also creates a `.png` atlas alongside of it), and drag the `.fnt` file onto BmFontToGMX' executable.

A same-named `.font.gmx` file will appear along with an accordingly named copy of the atlas.

You can then import the file onto GameMaker: Studio exactly as you would do with a GMS-created `.font.gmx`. As long as you do not tinker with the generated resource via GMS itself, it will remain unchanged though compilations.

For additional convenience, consider placing `.bmfc` and `.fnt` in the `fonts` subdirectory of the project, so that newly generated `.font.gmx` overwrites the previous version of the font file used by the project.
