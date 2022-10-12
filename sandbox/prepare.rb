####
#  to run use:
#   $   ruby sandbox/prepare.rb


require 'pixelart'


palettes = [
  'ye_olde_punks',
  'dr_ellis_monk'
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
    name       = rec['name']
    more_names =  (rec['more_names'] || '').split( '|' )

    ## normalize spaces in more names
    names = [name] + more_names
    names = names.map {|str| str.strip.gsub(/[ ]{2,}/, ' ' )}

    id  = "#{palette}-#{name}"
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


puts buf

write_text( "./tmp/page.md",  buf )


puts "bye"