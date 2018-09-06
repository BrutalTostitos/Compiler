require "set"


grammarRegex = Hash.new
$grammarNormal = Hash.new
normalMode = false

File.open(ARGV[0]).each do |line|
    if line.length == 1
        normalMode = true
    end
    if normalMode
        if line.include? "->"
            split = line.split("->")
            $grammarNormal[split[0].strip!] = split[1].strip!
        end


    else
        if line.include? "->"
            split = line.split("->")
            grammarRegex[split[0].strip!] = split[1].strip!
        end
    end
    
end

$grammarList = Array.new

def recursiveFindStuff(x)
    if $grammarList.include?(x)
        return
    end
    if !$grammarNormal.has_key?(x)
        return
    end
    $grammarList << x
    $grammarNormal[x].split("|").each do |y|
        y.split(" ").each do |z|
            recursiveFindStuff(z)
        end
    end
end

recursiveFindStuff("S")


$grammarNormal.each do |x|
    if !$grammarList.include?(x[0])
        printf("%s is nullable!\n", x[0])
    end
end
