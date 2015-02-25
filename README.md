Finite-Automata-Interpreter-Ruby

My Code: fa.rb

TO RUN

Ruby fa.rb < Input File Name



This is a school project I did last semester (Fall 2014). The code is use to build up NFAs based on user given commands and then convert the NFAs to DFAs. Below is an explanation for the entire project. This displays my understand of Ruby's object oriented fundamentals.




he interpreter will accept the following commands:
symbol where symbol is a lowercase letter or the uppercase E. In the former case this command creates finite automaton that accepts just that letter, and in the latter case it creates an automaton that accepts just the empty string. The new automaton is pushed onto the stack. . pops off top 2 finite automata on the stack and creates a new NFA representing their concatenation, pushing this new NFA on to the stack | pops off top 2 finite automaton on stack, creates a new NFA representing their union, pushing this new NFA on to the stack * pops off top finite automaton on stack, creates a new NFA representing its closure, pushing this new NFA on to the stack SIZE prints # of states in the finite automaton at the top of the stack (without popping it off) PRINT prints the finite automaton at the top of the stack (without popping it off). All output from this command is preceded by %, so it is just for documentation & debugging STAT prints some statistics about the finite automaton at the top of the stack (without popping it off) DFA converts finite automaton (DFA or NFA) at the top of the stack to a DFA "str" using finite automaton (must be a DFA) at the top of the stack, decide whether to accept or reject string str GENSTR# prints all strings accepted by finite automaton (must be a DFA) at the top of the stack of length # or less COMPLEMENT converts finite automaton (must be DFA) on top of stack to a DFA that is its complement (i.e., rejects strings accepted by the previous DFA, and accepts strings rejected by the previous DFA) DONE interpreter exits  
Example Here is an example session with the interpreter:
a b . PRINT SIZE c | * DONE
The first line creates an FA that accepts exactly the string a, and pushes it on the stack. The second line creates an FA that accepts exactly the string b, and pushes it on the stack. The third line pops these two automata off of the stack, and constructs a new automaton that accepts the concatenation of strings accepted by the two, i.e., ab. This new automaton is pushed back on the stack, and is now the only automaton on the stack.
The next command prints out this automaton (leaving it on the stack), producing output like the following:
% Start 0 % Final { 3 } % States { 0 1 2 3 } % Alphabet { a b } % Transitions { % (0 a 1) % (1 2) % (2 b 3) % }
The next command prints the number of states in the topmost automaton (leaving it on the stack), in this case 4. The next command constructs an automaton that accepts the string c and pushes it on-stack. The subsequent command pops off this automaton and combines with the the ab automaton also on-stack to produce the automaton implementing ab|c, pushing it on-stack. The next command creates a new automaton from this one, implementing (ab|c)*. The final command terminates the session.
Examples of how to use: ruby fa.rb < "test (1).in" tests the first text file input test case Example input: a b . PRINT SIZE c | * DONE The a creates an FA that accepts exactly the string a, and pushes it on the stack. The b creates an FA that accepts exactly the string b, and pushes it on the stack. The . pops these two automata off of the stack, and constructs a new automaton that accepts the concatenation of strings accepted by the two, i.e., ab. This new automaton is pushed back on the stack, and is now the only automaton on the stack.
