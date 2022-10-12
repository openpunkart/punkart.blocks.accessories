####
#  to run use:
#   $   ruby sandbox/prepare.rb


require 'pixelart'

def slugify( str )
  str.downcase.strip.gsub( /[ ]/, '_' )
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

  buf << "## #{palette} (#{recs.size} skin tones)\n\n"

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
  end
  buf << "\n\n"
end


# puts buf

write_text( "./tmp/page.md",  buf )


puts "bye"