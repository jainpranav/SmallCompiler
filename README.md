# :pager: Small Top-Down Compiler written in C

![alt tag](http://i.imgur.com/oMO6omg.png)


##About this Project 

This project progressively builds up a small compiler for the below given CFG tools using the following technologies :

- `C`
- `LEX`
- `YACC `

##Context - Free Grammar

- `[program] ==> class Program { [field_decl]* [method_decl]* }`
- `[field_decl] ==> [type] (id | id [ int_literal ] ) ( , id | id [ int-literal ] )* ;`
- `[field_decl] ==> [type] [id] = [constant] ; `
- `[method_decl] ==> { [type] | void } [id] (( ([type] [id]) ( , [type] [id])*)? ) [block]`
- `[block] ==> { [var_decl]* [statement]* } `
- `[var_decl] ==> [type] [id] ( , [id])* ; `
- `[type] ==> int | boolean `
- `[statement] ==> [location] [assign_op] [expr] ; `
- `[statement] ==> [method_call] ;`
- `[statement] ==> if ( [expr] ) [block] ( else [block] )? `
- `[statement] ==> for [id] = [expr] , [expr] [block] `
- `[statement] ==> return ( [expr] )? ; `
- `[statement] ==> break ; `
- `[statement] ==> continue ; `
- `[statement] ==> [block] `
- `[assign_op] ==> = `
- `[assign_op] ==> += `
- `[assign_op] ==> -= `
- `[method_call] ==> [method_name] ( ([expr] ( , [expr] )*)? ) `
- `[method_call] ==> callout ( [string_literal] ( , [callout_arg] )* ) `
- `[method_name] ==> [id] `
- `[location] ==> [id]`
- `[location] ==> id [ expr ] `
- `[expr] ==> [location] `
- `[expr] ==> [method_call] `
- `[expr] ==> [literal] `
- `[expr] ==> '[expr] [bin_op] [expr] `
- `[expr] ==> - [expr] `
- `[expr] ==> ! [expr] `
- `[expr] ==> ( [expr] ) `
- `[callout_arg] ==> [expr] | [string_literal] `
- `[bin_op] ==> [arith_op] | [rel_op] | [eq_op] | [cond_op] `
- `[arith_op] ==> + | - | * | / | % `
- `[rel_op] ==> < | > | <= | >= `
- `[eq_op] ==> == | != `
- `[cond_op] -> && | || `
- `[literal] ==> [int_literal] | [char_literal] | [bool_literal]`
- `[id] ==> [alpha] [alpha_num]* `
- `[alpha] ==> [a-zA-Z_] `
- `[alpha_num] ==> [alpha] | [digit] `
- `[digit] ==> [0-9]`
- `[hex_digit] ==> [digit] | [a-fA-F] `
- `[int_literal] ==> [decimal_literal] | [hex_literal] `
- `[decimal_literal] ==> [digit] [digit]* `
- `[hex_literal] ==> 0x [hex_digit] [hex_digit]* `
- `[bool_literal] ==> true | false `
- `[char_literal] ==> ‘[char]’ `
- `[string_literal] ==> “[char]*”`


##Features :

 - Written in vanilla C
 - Code is highly `Modularized`
 - Abstraction Maintained
 - Readability due to `inline comments`


## How to Use The Code From source ?
```bash
$ git clone --recursive git@github.com:jainpranav/SmallCompiler.git
$ cd src/
```

## Contributing

#### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/jainpranav/SmallCompiler/issues) to report any bugs or file feature requests
