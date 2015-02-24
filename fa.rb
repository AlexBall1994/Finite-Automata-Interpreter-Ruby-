#!/usr/bin/ruby -w

class FiniteAutomaton
    @@nextID = 0	# shared across all states
    attr_reader:state, :start, :final, :alphabet, :transition

    #---------------------------------------------------------------
    # Constructor for the FA
    def initialize
        @start = nil 		# start state 
        @state = { } 		# all states
        @final = { } 		# final states
        @transition = { }	# transitions
        @alphabet = [ ] 	# symbols on transitions
    end

    #---------------------------------------------------------------
    # Return number of states
    def num_states
        @state.size
    end

    #---------------------------------------------------------------
    # Creates a new state 
    def new_state
        newID = @@nextID
        @@nextID += 1
        @state[newID] = true
        @transition[newID] = {}
        newID 
    end

    #---------------------------------------------------------------
    # Creates a new state
    def add_state(v)
        unless has_state?(v)
            @state[v] = true
            @transition[v] = {}
        end
    end

    #---------------------------------------------------------------
    # Returns true if the state exists
    def has_state?(v)
        @state[v]
    end

    #---------------------------------------------------------------
    # Set (or reset) the start state
    def set_start(v)
        add_state(v)
        @start = v
    end

    #---------------------------------------------------------------
    # Set (or reset) a final state
    def set_final(v, final = true)
        add_state(v)
        if final
            @final[v] = true
        else
            @final.delete(v)
        end
    end

    #---------------------------------------------------------------
    # Returns true if the state is final
    def is_final?(v)
        @final[v]
    end

    #---------------------------------------------------------------
    # Creates a new transition from v1 to v2 with symbol x
    # Any previous transition from v1 with symbol x is removed
    def add_transition(v1, v2, x)
      add_state(v1)
      add_state(v2)

      if !@transition[v1][x]

        @transition[v1][x] = [v2]
      else
        @transition[v1][x].push(v2)

      end
    end

    #---------------------------------------------------------------
    # Get the destination state from v1 with symbol x
    # Returns nil if non-existent
    def get_transition(v1,x)
        if has_state?(v1)
            @transition[v1][x]
        else
            nil
        end
    end

    #---------------------------------------------------------------
    # Returns true if the dfa accepts the given string
    def accept?(s, temp2ent = @start)
        if s == ""
            is_final?(temp2ent)
        else
            dest = get_transition(temp2ent,s[0,1])
            if dest == nil || dest.size > 1
                false
            else
                accept?(s[1..-1], dest[0])
            end
        end
    end

    #---------------------------------------------------------------
    # Prints FA 
    def pretty_print
        print "% Start "
	puts @start


        # Final states in sorted order
	print "% Final {"
	@final.keys.sort.each { |x| print " #{x}" }
	puts " }" 

        # States in sorted order
	print "% States {"
	@state.keys.sort.each { |x| print " #{x}" }
	puts " }" 

        # Alphabet in alphabetical order
        print "% Alphabet {"
	@alphabet.sort.each { |x| print " #{x}" }
	puts " }" 

        # Transitions in lexicographic order
        puts "% Transitions {"
	@transition.keys.sort.each { |v1| 
            @transition[v1].keys.sort.each { |x| 
                v2 = get_transition(v1,x)
                i = 0
                while i < v2.size
                  puts "% (#{v1} #{x} #{v2[i]})"
                  i = i + 1
                end
            }
        }
	puts "% }" 
    end
        
    #---------------------------------------------------------------
    # Prints FA statistics
    def print_stats
         temp = 0
         statesfound = []
        puts "FiniteAutomaton"
        puts "  #{state.size} states"
        puts "  #{final.size} final states" 
        
        transition.keys.sort.each{ |v1|
        
          if !transition[v1].any?
            if !statesfound[0]
              statesfound[0] = 1
            else
              statesfound[0] += 1
            end
          end
          blah = 0
          transition[v1].keys.sort.each { |x|
            v2 = get_transition(v1,x)
            blah += v2.size

            if v2.size > 0 
              temp += v2.size
            end
                   
            
          }
          if blah > 0
            if !statesfound[blah]
              statesfound[blah] = 1
              
            else
              statesfound[blah] +=1
              
            end
          end
              
          
        }
          

        i = 0
        puts "  #{temp} transitions"
        while i < statesfound.size
          if statesfound[i]
            puts "    #{statesfound[i]} states with #{i} transitions" 
          end         
          i += 1
          
        end

    end

    #---------------------------------------------------------------
    # accepts just symbol ("" = epsilon)
    def symbol! sym
        initialize
        s0 = new_state
        s1 = new_state
        set_start(s0)
        set_final(s1, true)
        add_transition(s0, s1, sym)
        if (sym != "") && (!@alphabet.include? sym)
            @alphabet.push sym
        end
        
    end

 
    #---------------------------------------------------------------
    # accept strings accepted by self, followed by strings accepted by newFA
    def concat! newFA

      iterate = 0

      
      while iterate < @final.keys.size
        add_transition(@final.keys[iterate], newFA.start,"")
        set_final(@final.keys[iterate], false)
        iterate += 1
      end

      @final = newFA.final
      
      newFA.alphabet.each { |x|
        if !@alphabet.include?(x)
          @alphabet.push(x)
        end
      }
      newFA.transition.keys.sort.each { |v1|
        newFA.transition[v1].keys.sort.each { |x|
          v2 = newFA.get_transition(v1,x)
      
          v2.each { |c|
           
            add_transition(v1,c,x)
          }    
        }
      }



    end

    #---------------------------------------------------------------
    # accept strings accepted by either self or newFA
    def union! newFA
    s0 = new_state
    add_transition(s0,@start,"")
    add_transition(s0,newFA.start,"")
    set_start(s0)
    s0 = new_state

     @final.keys.sort.each {|x| set_final(x,false)
     add_transition(x,s0,"")}

     newFA.final.keys.each{|x| add_transition(x,s0,"")}

     set_final(s0)
      newFA.alphabet.each { |x|
        if !@alphabet.include?(x)
          @alphabet.push(x)
        end
      }

      newFA.transition.keys.sort.each { |v1|
        newFA.transition[v1].keys.sort.each { |x|
          v2 = newFA.get_transition(v1,x)
          v2.each { |c|
            add_transition(v1,c,x)
          }    
        }
      }


    end

    #---------------------------------------------------------------
    # accept any sequence of 0 or more strings accepted by self
    def closure! 
s0 = new_state
add_transition(s0,@start,"")
@start = s0
s0 = new_state

@final.keys.each{|t|
add_transition(t,s0,"")
set_final(t,false)
}

add_transition(@start, s0, "")
add_transition(s0,@start,"")
set_final(s0,true)

    end

    #---------------------------------------------------------------
    # returns DFA that accepts only strings accepted by self \
    def to_dfa
    newFA = FiniteAutomaton.new
    processed = {}
    notprocessed = []
    movesLetter = []

    #creating my start node
    temp = epsilonClosures(@start)
    

    #notprocessed nodes
    notprocessed.push(temp)
    s0 = new_state
    newFA.set_start(s0)
    processed[temp] = s0

    
    while notprocessed.any?
      temp2 = notprocessed.pop

      @alphabet.each{ |a|
        temp = []
        movesLetter = move(temp2,a)

        movesLetter.flatten!

        if movesLetter != nil && movesLetter.any?
          movesLetter.each{ |x| movesLetter = movesLetter | epsilonClosures(x)}
          
        

        if processed[movesLetter] == nil && movesLetter.size != 0
          notprocessed.push(movesLetter)
          n = new_state
          processed[movesLetter] = n
        end
        newFA.add_transition(processed[temp2],processed[movesLetter],a)

        end

      }
      
       
    end


  
   processed.keys.each{|x|
     @final.keys.each{|y| if x.include?(y) then newFA.set_final(processed[x], true) end}
   }
 
   
    @alphabet.each{ |x|
      newFA.alphabet.push(x)}

      
 
  newFA

    end


def move(arr,letter)
  transitioner = []
  
if arr
  arr.each{|x|
    if get_transition(x,letter)
      transitioner.push(get_transition(x,letter))
    end

  }
end
  transitioner
  


end

    def epsilonClosures(start1)
     visited = Array.new
     discovered = [start1]
     while discovered != []
      n = discovered.pop
       if !(visited.include?(n))
         visited.push(n)
         successor = get_transition(n, "")
        if successor 
         successor.each{|x|
          if !(visited.include?(x))
            discovered.push(x)
          end
        }
        end
       end
     end
    visited
    end

     def epsilonClosuresStart(start1)
     visited = Array.new
     discovered = [start1]
     epsilons = 0
     while discovered != []
      n = discovered.pop
       if !(visited.include?(n))
         visited.push(n)
         successor = get_transition(n, "")
        if successor 
          epsilons += 1
         successor.each{|x|
          if !(visited.include?(x))
            discovered.push(x)
          end
        }
        end
       end
     end
     if epsilons > 0
      visited.delete(@start)
     end
     visited
     end
    #---------------------------------------------------------------
    # returns a DFA that accepts only strings not accepted by self, 
    # and rejects all strings previously accepted by self
    def complement!
        # create a new one, or modify the temp2ent one in place,
        # and return it
        #FiniteAutomaton.new   
        add_explicit = false
        
        #if every state includes every part of the alphabet, then there is no need for a dead state
        transition.keys.sort.each{ |v1|
          @alphabet.each{ |y|
              if !transition[v1].include?(y)
                
                add_explicit = true
              end
              }
        }


        if add_explicit
          sfinal = new_state
          transition.keys.sort.each { |v1|
            @alphabet.each{ |y|
              if !transition[v1].include?(y)
                add_transition(v1,sfinal,y)
              end
            }
          }


        end

        #setting all non-final states to final states
        state.keys.each {|x|
          if @final[x]
            set_final(x,false)
          else
            set_final(x)
          end
        }

        self


    end

    #---------------------------------------------------------------
    # return all strings accepted by FA with length <= strLen
    def gen_str strLen
	sortedAlphabet = @alphabet.sort
        resultStrs = [ ] 
        testStrings = [ ]
        testStrings[0] = [] 
        testStrings[0].push ""
        1.upto(strLen.to_i) { |x|
            testStrings[x] = []
            testStrings[x-1].each { |s|
                sortedAlphabet.each { |c|
                    testStrings[x].push s+c
                }
            }
        }
        testStrings.flatten.each { |s|
            resultStrs.push s if accept? s
        }
        result = ""
        resultStrs.each { |x| result.concat '"'+x+'" ' }
        result
    end

end

#---------------------------------------------------------------
# read standard input and interpret as a stack machine

def interpreter file
   dfaStack = [ ] 
   loop do
       line = file.gets
       if line == nil then break end
       words = line.scan(/\S+/)
       words.each{ |word|
           case word
               when /DONE/
                   return
               when /SIZE/
                   f = dfaStack.last
                   puts f.num_states
               when /PRINT/
                   f = dfaStack.last
                   f.pretty_print
               when /STAT/
                   f = dfaStack.last
                   f.print_stats
               when /DFA/
                   f = dfaStack.pop
                   f2 = f.to_dfa
                   dfaStack.push f2
               when /COMPLEMENT/
                   f = dfaStack.pop
                   f2 = f.complement!
                   dfaStack.push f2
               when /GENSTR([0-9]+)/
                   f = dfaStack.last
                   puts f.gen_str($1)
               when /"([a-z]*)"/
                   f = dfaStack.last
                   
                   str = $1
                   if f.accept?(str)
                       puts "Accept #{str}"
                   else
                       puts "Reject #{str}"
                   end
               when /([a-zE])/
                   puts "Illegal syntax for: #{word}" if word.length != 1
                   f = FiniteAutomaton.new
                   sym = $1
                   sym="" if $1=="E"
                   f.symbol!(sym)
                   dfaStack.push f
               when /\*/
                   puts "Illegal syntax for: #{word}" if word.length != 1
                   f = dfaStack.pop
                   f.closure!
                   dfaStack.push f
               when /\|/
                   puts "Illegal syntax for: #{word}" if word.length != 1
                   f1 = dfaStack.pop
                   f2 = dfaStack.pop
                   f2.union!(f1)
                   dfaStack.push f2
               when /\./
                   puts "Illegal syntax for: #{word}" if word.length != 1
                   f1 = dfaStack.pop
                   f2 = dfaStack.pop
                   f2.concat!(f1)
                   dfaStack.push f2
               else
                   puts "Ignoring #{word}"
           end
        }
   end
end


#---------------------------------------------------------------
# main( )

if false			# just debugging messages
    f = FiniteAutomaton.new
    f.set_start(1)
    f.set_final(2)
    f.set_final(3)
    f.add_transition(1,2,"a")   # need to keep this for NFA
    f.add_transition(1,3,"a")  
    f.prettyPrint
end

if ARGV.length > 0 then
  file = open(ARGV[0])
else
  file = STDIN
end

interpreter file  # type "DONE" to exit

