# What this Code does ?

- Lists all the conflicts in the Yacc program and tells how these conflicts will be resolved
- Outputs the preorder traversal of the Abstract Syntax Tree (AST) of the program
- Each line outputs one node
- Leaves four spaces for each level of the AST
- For example, if a node is at the top level, there will not be any spaces before it
- If a node is on the second level, four spaces will precede the print info about the node

# How to Use The Code  ?

```bash
$ sudo apt-get install flex
$ lex lex.l 
$ yacc yacc.y
$ gcc y.tab.c -ll -ly
$ ./a.out < (input_file_name)
```
