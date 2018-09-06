require "set"


$grammarRegex = Hash.new
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
            $grammarRegex[split[0].strip!] = split[1].strip!
        end
    end
    
end


$grammarList = Array.new

$grammarNormal.each do |x|
    x[1].split("|").each do |y|
        y.split(" ").each do |z|
            if ($grammarNormal.include?(z) == false)
                if ($grammarRegex.has_key?(z) == false)
                    $grammarList << x[0]
                end
            end
        end
    end
end

def isLambda(x)
    if ($grammarNormal.include?(x) == false)
        if ($grammarRegex.has_key?(x) == false)
            return true
        end
    end
    return false
end

$FirstHash = Hash.new

def firstRecursive(x)
    #$FirstHash[x] = Array.new
    tempArray = Array.new
    $grammarNormal[x].split("|").each do |y|
        y.split(" ").each do |z|
            if ($grammarRegex.include?(z))
                tempArray << z
                break
            end
            if (isLambda(z))
                tempArray << "$"
                break
            end
            if (z == x)
                break
            end
            temp = firstRecursive(z)
            if (temp.length > 0)
                temp.each do |w|
                    if (!tempArray.include?(w))
                        tempArray << w
                    end
                end
                break
            end
        end
    end
    return tempArray
end


$grammarNormal.each_key do |x|
   $FirstHash[x] = firstRecursive(x) 
end

$grammarList.each do |x|
    printf("%s is nullable.\n", x)
end

puts "FIRST"

$FirstHash.each_key do |x|
    printf("[%s] {", x)
    $FirstHash[x].each do |y|
        printf("%s,", y)
    end
    printf("}\n")
end
