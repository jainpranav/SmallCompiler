# What this Code does ?

- For a given program written using the CFG specified , outputs the tokens in the program
- Outputs the lexemes where necessary

# How to Use The Code  ?

```bash
$ sudo apt-get install flex
$ lex lex.l 
$ gcc -lfl lex.yy.cc
$ ./a.out < (input_file_name)
```
