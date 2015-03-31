# :pager: Small Top-Down Compiler written in C

![alt tag](http://i.imgur.com/oMO6omg.png)


##About this Project 

This project progressively builds up a small compiler for the below given CFG tools using the following technologies :

- C
- LEX
- YACC 

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
- <assign_op> -> = 
- <assign_op> -> += 
- <assign_op> -> -= 
- <method_call> -> <method_name> ( (<expr> ( , <expr> )*)? ) 
- <method_call> -> callout ( <string_literal> ( , <callout_arg> )* ) 
- <method_name> -> <id> 
- <location> -> <id>



##Features :

 - Written in uncomplicated Java
 - Uses Design Patterns ( namely [`MVC Pattern`] (http://programmers.stackexchange.com/questions/127624/what-is-mvc-really) )
 - Code is highly `Modularized`
 - Abstraction Maintained
 - Readability due to `inline comments`

## How to Play ?

Download the [Pre-Release Version] (https://github.com/jainpranav/Minesweeper/releases/tag/1.0)

## How to Use The Code From source ?
```bash
$ git clone --recursive git@github.com:jainpranav/Minesweeper.git
$ cd src/
```

## Contributing

#### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/jainpranav/Minesweeper/issues) to report any bugs or file feature requests
