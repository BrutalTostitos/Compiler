
grammar = Hash.new
grammarRegx = Hash.new
wedoneyet = false

File.open(ARGV[0]) do |f|
  f.each_line do |line|
    #testing to see if we hit a newline. splits grammar from stuff
    if line.length == 1
      wedoneyet = true
      next
    end
    if wedoneyet
      split = line.split("->")
      grammar[split[0].strip] = split[1].strip


    else
      split = line.split("->")
      grammarRegx[split[0].strip] = split[1].strip

    end

  end
end

#printing everything in our hashes
puts "normal"
grammar.each do |thing|
  puts thing
end
puts "regex stuff"
grammarRegx.each do |thing|
  puts thing
end



inputFile = ""
File.open(ARGV[1]) do |f|
  f.each_line do |line|
    inputFile += line
  end
end
puts "\n"






lineCounter = 1

#incoming bad variable names
while inputFile.length != 0
  validCheck = false
  grammarRegx.each do |thing|
    r = Regexp.new(thing[1])
    idx  = (r=~ inputFile)
    if idx != 0
      next
    end
    validCheck = true
    m = r.match(inputFile, 0)

    printf("LINE [%d] [%s] [%s]\n", lineCounter, thing[0], m)


    #calculating line number and stripping white space
    tmp = inputFile.count "\n"
    inputFile.slice!(0, m.end(0))
    inputFile.lstrip!
    tmp2 = inputFile.count "\n"
    tmp -= tmp2
    lineCounter += tmp

    break
  end

  if validCheck == false
    printf("Error on line %i, on symbol '%s'.", lineCounter, inputFile[0])
    break
  end
end


