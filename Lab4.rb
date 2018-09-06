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

$FollowHash = Hash.new

def follow(x)
    tempArray = Array.new
    $grammarNormal.each_value do |y|
        y.split("|").each do |z|
            tempArray << z
        end
    end

    finalArray = Array.new

    #puts " "
    #puts x
    #puts "________"
    initialExclude = [x]
    tempArray.each do |y|
        expandNonTerminal(y, initialExclude).each do |z|
            finalArray << z
            #z.each do |w|
            #    finalArray << w
            #end
            #puts z
        end
    end

    follows = Array.new
    finalArray.each do |y|
        quickTempArray = y.split(" ")
        #puts y
        #puts quickTempArray.length
        for i in 0...quickTempArray.length
            if (quickTempArray[i] == x)
                if ((i + 1) == quickTempArray.length)
                    
                    follows << "$"
                else
                    if ($grammarNormal.has_key?(quickTempArray[i + 1]))
                        puts quickTempArray[i + 1]
                        $FirstHash[quickTempArray[i + 1]].each do |z|
                            follows << z
                        end
                    else
                        follows << quickTempArray[i + 1]
                    end
                end
            end
        end
    end

    follows = follows.uniq

    return follows
end

def expandNonTerminal(x, exclude)
    tempString = Array.new
    tempString << ""
    newTempString = Array.new
    hasSplit = false
    excludeGroup = exclude
    hasExpanded = false
    x.split(" ").each do |y|
        #puts tempString[0]
        if (hasSplit)
            for i in 0...tempString.length
                if (tempString[i] == "")
                    tempString[i] += y
                else
                    tempString[i] += " " + y
                end
            end
        else
            if (exclude.include?(y))
                for i in 0...tempString.length
                    if (tempString[i] == "")
                        tempString[i] += y
                    else
                        tempString[i] += " " + y
                    end
                end
                next
            else
                if ($grammarNormal.include?(y))
                    if ($grammarNormal[y].include?("|"))
                        hasSplit = true
                        $grammarNormal[y].split("|").each do |z|
                            if (tempString[0] == "")
                                newTempString << tempString[0] + z
                            else
                                newTempString << tempString[0] + " " + z
                            end
                        end
                        excludeGroup << y
                        tempString = newTempString
                    else
                        for i in 0...tempString.length
                            if (tempString[i] == "")
                                tempString[i] += $grammarNormal[y]
                            else
                                tempString[i] += " " + $grammarNormal[y]
                            end
                        end
                    end
                    hasExpanded = true
                else
                    for i in 0...tempString.length
                        if (tempString[i] == "")
                            tempString[i] += y
                        else
                            tempString[i] += " " + y
                        end
                    end
                end
            end
        end
    end

    if (hasExpanded == false)
        return tempString
    end

    resultStrings = Array.new
    tempString.each do |y|
        expandNonTerminal(y, excludeGroup).each do |z|
            resultStrings << z
        end
    end
    return resultStrings
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

puts "FOLLOW"


$grammarNormal.each_key do |x|
    puts "Follow for "
    puts x
    follow(x).each do |y|
        puts y
    end
end