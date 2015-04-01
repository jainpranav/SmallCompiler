# What this Code does ?

- It generates 3-address code for programs defined by the CFG defined 
- +, -, *, /, =, [], if, ifFalse, goto, !, <, >, <=, >=, ==, !=, param, call and ret are the allowed operators

# How to Use The Code  ?

```bash
$ sudo apt-get install flex
$ lex lex.l 
$ yacc yacc.y
$ gcc y.tab.c -ll -ly
$ ./a.out < (input_file_name)
```
