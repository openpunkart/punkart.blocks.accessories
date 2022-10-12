####
#  to run use:
#   $   ruby sandbox/prepare.rb


require 'punks'


def slugify( str )
  str.downcase.strip.gsub( /[ ]/, '_' )
end


WHITE = Color.parse( '#ffffff')


def add_punks( composite, color )

  base_m = Punk::Sheet.find_by( name: 'Male 4' )
  base_f = Punk::Sheet.find_by( name: 'Female 4' )

    hsl  = Color.to_hsl( color )
    pp hsl

    h, s, l = hsl
    h = h % 360   # make always positive (might be -50 or such)
    pp [h,s,l]

    darker   = Color.from_hsl(
      h,
      [0.0, s-0.05].max,
      [0.14, l-0.1].max)

    ## sub one degree on hue on color wheel (plus +10% on lightness??)
    darkest = Color.from_hsl(
                   (h-1) % 360,
                   s,
                   [0.05, l-0.1].max)


    lighter = Color.from_hsl(
                    (h+1) % 360,
                    s,
                    [1.0, l+0.1].min)

    color_map = {
       '#ead9d9'  =>   color,
       '#ffffff'  =>   lighter,
       '#a58d8d'  =>   darkest,
       '#c9b2b2'  =>   darker
    }

    punk = base_m.change_colors( color_map )
    punk[10,12] = WHITE     # left eye dark-ish pixel to white
    punk[15,12] = WHITE     # right eye ---

    composite << punk
    ## for female - change lips to all black (like in male for now) - why? why not?
    color_map[ '#711010' ] = '#000000'
    punk = base_f.change_colors( color_map )
    punk[10,13] = WHITE     # left eye dark-ish pixel to white
    punk[15,13] = WHITE     # right eye ---

    composite << punk
end



palettes = [
  'ye_olde_punks',
  'dr_ellis_monk',
  'punks_not_dead',
]


buf = String.new('')

palettes.each do |palette|

  path = "./#{palette}.csv"

  puts "==> reading #{path}..."
  recs = read_csv( path )
  puts "  #{recs.size} record(s)"


  cols = 10
  rows = (recs.size*2) / cols
  rows += 1   if (recs.size*2) % cols != 0


  puts "  cols=#{cols},rows=#{rows} | #{cols*rows} punks"
  composite = ImageComposite.new( cols, rows )


  buf << "## #{palette} (#{recs.size} skin tones)\n\n"

  buf << "![](i/#{palette}@2x.png)"
  buf << "\n\n"


  buf << "Names | Color  | HEX, RGB, HSL, HSV\n"
  buf << "------|--------|---------\n"

  recs.each do |rec|
    hex        = rec['color']
    names       = rec['names'].split( '|' )

    ## normalize spaces in more names
    names = names.map {|str| str.strip.gsub(/[ ]{2,}/, ' ' )}
    slug  = slugify( names[0] )

    id  = "#{palette}-#{slug}"
    bar = Image.new( 128, 64, hex )
    bar.save( "./tmp/#{id}.png" )

    color = Color.parse( hex )

    buf << names.join( ' • ' )
    buf << " | "
    buf << "![](i/#{id}.png)"
    buf << " | "
    buf << Color.format( color )
    buf << "\n"

    add_punks( composite, color )
  end
  buf << "\n\n"

  composite.save( "./tmp/#{palette}.png" )
  composite.zoom(2).save( "./tmp/#{palette}@2x.png" )
end




write_text( "./tmp/page.md",  buf )


puts "bye"