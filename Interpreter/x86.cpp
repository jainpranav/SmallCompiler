char* paramRegs[] = {"%rdi", "%rsi", "%rdx", "%rcx", "%r8", "%r9"};
char strings[2048] = {0};

char* GetVal(struct symbol* s) {
	static char v[256];
	static int strId = 0;
	

	if (s->sType == int_const) {
		sprintf(v, "$%s", s->name);
	} else if (s->sType == bool_const) {
		if (strcmp(s->name, "true") == 0) sprintf(v, "$1");
		else sprintf(v, "$0");
	} else if (s->sType == char_const) {
		sprintf(v, "%d", s->name[1]);
	} else if (s->sType == str_const)
	{
		//add to a list of strings to be emitted later
		strId ++;
		char str[256];
		sprintf(str, "format%d: .asciz %s\n", strId, s->name);
		strcat(strings, str);
		sprintf(v, "$format%d", strId);
	} else if (s->sType == globalvar) {
		sprintf(v, "%s", s->name);
	}
	else if (s->sType == vartmp) {
		sprintf(v, "-%d(%%rbp)", s->offset);
	} else if (s->sType == labelvar) {
		sprintf(v, "%s_1", s->name);
	}
	return v;
}//GetVal



void EmitGlobals() {

	printf(".globl main\n.data\n");

	//find the symbols in the bottom-most symbol table of the symtab stack
	struct symtab* s = symStack;
	while (s->next != NULL) {
		s = s->next;
	}

	//go over all symbols and print
	struct symbol* sy = s->symbols;
	while(sy != NULL) {
		if (sy->sType == globalvar) {

			printf("%s: .quad", sy->name);
			
			//check if this variable has been initialized	
			struct quadtab* q = quads;
			while((q!=NULL) && (strcmp(q->opcode, "function") != 0)) {
				if ((strcmp(q->opcode, "=") == 0) && (q->dst == sy)) printf(" %s", GetVal(q->src1));
				q = q->next;
			}

		} //process global var

		
		sy = sy->next;
	}//go over all symbols and print

	printf(".text\n");
}//EmitGlobalVars


void EmitFunction (struct quadtab* q) {
	int counter = 0;

	printf("%s:\n", q->dst->name);
	printf("L%d_%d: push %%rbp\n", q->idx, ++counter);
	printf("L%d_%d: mov %%rsp, %%rbp\n", q->idx, ++counter); 

	//make space for local vars and temporaries
	//the offset required is stored in src1 field
	//and is 16B aligned
	printf("L%d_%d: subq $%d, %%rsp\n", q->idx, ++counter, q->dst->isArray);

	//copy the parameters and place them in the space reserved on stack
	int argCnt = q->dst->nElem;
	if (argCnt >= 1) { printf("L%d_%d: mov %%rdi, -8(%%rbp)\n", q->idx, ++counter); }
	if (argCnt >= 2) { printf("L%d_%d: mov %%rsi, -16(%%rbp)\n", q->idx, ++counter); }
	if (argCnt >= 3) { printf("L%d_%d: mov %%rdx, -24(%%rbp)\n", q->idx, ++counter); }
	if (argCnt >= 4) { printf("L%d_%d: mov %%rcx, -32(%%rbp)\n", q->idx, ++counter); }
	if (argCnt >= 5) { printf("L%d_%d: mov %%r8, -40(%%rbp)\n", q->idx, ++counter); }
	if (argCnt >= 6) { printf("L%d_%d: mov %%r9, -48(%%rbp)\n", q->idx, ++counter); }
	if (argCnt >= 7) {  assert(0); }

		
	
}//EmitFunction

void EmitRet(struct quadtab* q, struct quadtab* fq) {
	int counter = 0;

	//store return value in rax, if there is one
	if (q->dst) 
	{
		if ((q->dst->sType == globalvar) || (q->dst->sType == vartmp)) printf("L%d_%d: mov %s, %%rax\n", q->idx, ++counter, GetVal(q->dst));
		else printf("L%d_%d: movq %s, %%rax\n", q->idx, ++counter, GetVal(q->dst)); 
	}

	//reclaim storage space for local vars and temporaries
	printf("L%d_%d: addq $%d, %%rsp\n", q->idx, ++counter, fq->dst->isArray);

	//restore rbp and return
	printf("L%d_%d: pop %%rbp\n", q->idx, ++counter);
	printf("L%d_%d: ret\n", q->idx, ++counter);
	
}//EmitRet

void HandleParams (struct quadtab** q) {
	int counter = 0;
	struct quadtab* qt = *q;

	int np = 0;
	while (strcmp(qt->opcode, "param") == 0) {
		
		if (np > 5) assert (0);
		if ((qt->dst->sType == globalvar) || (qt->dst->sType == vartmp)) printf("L%d_%d: mov %s, %s\n", qt->idx, ++counter, GetVal(qt->dst), paramRegs[np]);
		else printf("L%d_%d: movq %s, %s\n", qt->idx, ++counter, GetVal(qt->dst), paramRegs[np]);
		np ++;
		*q = qt;
		qt = qt->next;
	}

	


}//Handle Params

void EmitCall(struct quadtab* q) {
	int counter = 0;
	
	if (q->src1->name[0] == '"') {
		q->src1->name[strlen(q->src1->name) - 1] = 0;
		printf("L%d_%d: call %s\n", q->idx, ++counter, &(q->src1->name[1]));
		q->src1->name[strlen(q->src1->name) - 1] = '"';
	} else {
		printf("L%d_%d: call %s\n", q->idx, ++counter, q->src1->name);
	}
	if (q->dst) { printf("L%d_%d: mov %%rax, %s\n", q->idx, ++counter, GetVal(q->dst)); }
}//EmitCall

void EmitAssign(struct quadtab* q) {
	int counter = 0;
	if ((q->src1->sType == globalvar) || (q->src1->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	} else {
		printf("L%d_%d: movq %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	}
	printf("L%d_%d: mov %%rax, %s\n", q->idx, ++counter, GetVal(q->dst));
		
}//EmitAssign

void EmitAdd (struct quadtab* q) {
	int counter = 0;
	if ((q->src1->sType == globalvar) || (q->src1->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	} else {
		printf("L%d_%d: movq %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	}
	if ((q->src2->sType == globalvar) || (q->src2->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rbx\n", q->idx, ++counter, GetVal(q->src2));
	} else {
		printf("L%d_%d: movq %s, %%rbx\n", q->idx, ++counter, GetVal(q->src2));
	}
	printf("L%d_%d: add %%rbx, %%rax\n", q->idx, ++counter);
	printf("L%d_%d: mov %%rax, %s\n", q->idx, ++counter, GetVal(q->dst));
	
}//EmitAdd

void EmitSub (struct quadtab* q) {
	int counter = 0;
	if ((q->src1->sType == globalvar) || (q->src1->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	} else {
		printf("L%d_%d: movq %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	}
	if ((q->src2->sType == globalvar) || (q->src2->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rbx\n", q->idx, ++counter, GetVal(q->src2));
	} else {
		printf("L%d_%d: movq %s, %%rbx\n", q->idx, ++counter, GetVal(q->src2));
	}
	printf("L%d_%d: sub %%rbx, %%rax\n", q->idx, ++counter);
	printf("L%d_%d: mov %%rax, %s\n", q->idx, ++counter, GetVal(q->dst));
	
}//EmitSub

void EmitMul (struct quadtab* q) {
	int counter = 0;
	if ((q->src1->sType == globalvar) || (q->src1->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	} else {
		printf("L%d_%d: movq %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	}
	if ((q->src2->sType == globalvar) || (q->src2->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rbx\n", q->idx, ++counter, GetVal(q->src2));
	} else {
		printf("L%d_%d: movq %s, %%rbx\n", q->idx, ++counter, GetVal(q->src2));
	}
	printf("L%d_%d: mulq %%rbx\n", q->idx, ++counter);
	printf("L%d_%d: mov %%rax, %s\n", q->idx, ++counter, GetVal(q->dst));
	
}//EmitMul

void EmitDiv (struct quadtab* q) {
	int counter = 0;
	if ((q->src1->sType == globalvar) || (q->src1->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rbx\n", q->idx, ++counter, GetVal(q->src1));
	} else {
		printf("L%d_%d: movq %s, %%rbx\n", q->idx, ++counter, GetVal(q->src1));
	}
	if ((q->src2->sType == globalvar) || (q->src2->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rax\n", q->idx, ++counter, GetVal(q->src2));
	} else {
		printf("L%d_%d: movq %s, %%rax\n", q->idx, ++counter, GetVal(q->src2));
	}
	printf("L%d_%d: idiv %%rbx\n", q->idx, ++counter);
	printf("L%d_%d: mov %%rax, %s\n", q->idx, ++counter, GetVal(q->dst));
	
}//EmitDiv

void EmitDeref (struct quadtab* q) {
	int counter = 0;
	if ((q->src1->sType == globalvar) || (q->src1->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	} else {
		printf("L%d_%d: movq %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	}
	
	printf("L%d_%d: mov (%%rax), %s\n", q->idx, ++counter, GetVal(q->dst));
	
}//EmitDeref

void EmitLT (struct quadtab* q) {
	int counter = 0;
	if ((q->src1->sType == globalvar) || (q->src1->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	} else {
		printf("L%d_%d: movq %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	}
	if ((q->src2->sType == globalvar) || (q->src2->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rbx\n", q->idx, ++counter, GetVal(q->src2));
	} else {
		printf("L%d_%d: movq %s, %%rbx\n", q->idx, ++counter, GetVal(q->src2));
	}

	printf("L%d_%d: cmp %%rbx, %%rax\n", q->idx, ++counter);
	printf("L%d_%d: jl L%d_%d\n", q->idx, ++counter, q->idx, counter + 4);
	printf("L%d_%d: movq $0, %%rax\n", q->idx, ++counter);
	printf("L%d_%d: jmp L%d_%d\n", q->idx, ++counter, q->idx, counter + 3);
	printf("L%d_%d: movq $1, %%rax\n", q->idx, ++counter);
	
	printf("L%d_%d: mov %%rax, %s\n", q->idx, ++counter, GetVal(q->dst));
	
}//EmitLT

void EmitGT (struct quadtab* q) {
	int counter = 0;
	if ((q->src1->sType == globalvar) || (q->src1->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	} else {
		printf("L%d_%d: movq %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	}
	if ((q->src2->sType == globalvar) || (q->src2->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rbx\n", q->idx, ++counter, GetVal(q->src2));
	} else {
		printf("L%d_%d: movq %s, %%rbx\n", q->idx, ++counter, GetVal(q->src2));
	}

	printf("L%d_%d: cmp %%rbx, %%rax\n", q->idx, ++counter);
	printf("L%d_%d: jg L%d_%d\n", q->idx, ++counter, q->idx, counter + 4);
	printf("L%d_%d: movq $0, %%rax\n", q->idx, ++counter);
	printf("L%d_%d: jmp L%d_%d\n", q->idx, ++counter, q->idx, counter + 3);
	printf("L%d_%d: movq $1, %%rax\n", q->idx, ++counter);
	
	printf("L%d_%d: mov %%rax, %s\n", q->idx, ++counter, GetVal(q->dst));
	
}//EmitGT

void EmitLE (struct quadtab* q) {
	int counter = 0;
	if ((q->src1->sType == globalvar) || (q->src1->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	} else {
		printf("L%d_%d: movq %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	}
	if ((q->src2->sType == globalvar) || (q->src2->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rbx\n", q->idx, ++counter, GetVal(q->src2));
	} else {
		printf("L%d_%d: movq %s, %%rbx\n", q->idx, ++counter, GetVal(q->src2));
	}

	printf("L%d_%d: cmp %%rbx, %%rax\n", q->idx, ++counter);
	printf("L%d_%d: jle L%d_%d\n", q->idx, ++counter, q->idx, counter + 4);
	printf("L%d_%d: movq $0, %%rax\n", q->idx, ++counter);
	printf("L%d_%d: jmp L%d_%d\n", q->idx, ++counter, q->idx, counter + 3);
	printf("L%d_%d: movq $1, %%rax\n", q->idx, ++counter);
	
	printf("L%d_%d: mov %%rax, %s\n", q->idx, ++counter, GetVal(q->dst));
	
}//EmitLE

void EmitGE (struct quadtab* q) {
	int counter = 0;
	if ((q->src1->sType == globalvar) || (q->src1->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	} else {
		printf("L%d_%d: movq %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	}
	if ((q->src2->sType == globalvar) || (q->src2->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rbx\n", q->idx, ++counter, GetVal(q->src2));
	} else {
		printf("L%d_%d: movq %s, %%rbx\n", q->idx, ++counter, GetVal(q->src2));
	}

	printf("L%d_%d: cmp %%rbx, %%rax\n", q->idx, ++counter);
	printf("L%d_%d: jge L%d_%d\n", q->idx, ++counter, q->idx, counter + 4);
	printf("L%d_%d: movq $0, %%rax\n", q->idx, ++counter);
	printf("L%d_%d: jmp L%d_%d\n", q->idx, ++counter, q->idx, counter + 3);
	printf("L%d_%d: movq $1, %%rax\n", q->idx, ++counter);
	
	printf("L%d_%d: mov %%rax, %s\n", q->idx, ++counter, GetVal(q->dst));
	
}//EmitGE

void EmitEQ (struct quadtab* q) {
	int counter = 0;
	if ((q->src1->sType == globalvar) || (q->src1->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	} else {
		printf("L%d_%d: movq %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	}
	if ((q->src2->sType == globalvar) || (q->src2->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rbx\n", q->idx, ++counter, GetVal(q->src2));
	} else {
		printf("L%d_%d: movq %s, %%rbx\n", q->idx, ++counter, GetVal(q->src2));
	}

	printf("L%d_%d: cmp %%rbx, %%rax\n", q->idx, ++counter);
	printf("L%d_%d: je L%d_%d\n", q->idx, ++counter, q->idx, counter + 4);
	printf("L%d_%d: movq $0, %%rax\n", q->idx, ++counter);
	printf("L%d_%d: jmp L%d_%d\n", q->idx, ++counter, q->idx, counter + 3);
	printf("L%d_%d: movq $1, %%rax\n", q->idx, ++counter);
	
	printf("L%d_%d: mov %%rax, %s\n", q->idx, ++counter, GetVal(q->dst));
	
}//EmitEQ

void EmitNE (struct quadtab* q) {
	int counter = 0;
	if ((q->src1->sType == globalvar) || (q->src1->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	} else {
		printf("L%d_%d: movq %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	}
	if ((q->src2->sType == globalvar) || (q->src2->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rbx\n", q->idx, ++counter, GetVal(q->src2));
	} else {
		printf("L%d_%d: movq %s, %%rbx\n", q->idx, ++counter, GetVal(q->src2));
	}

	printf("L%d_%d: cmp %%rbx, %%rax\n", q->idx, ++counter);
	printf("L%d_%d: jne L%d_%d\n", q->idx, ++counter, q->idx, counter + 4);
	printf("L%d_%d: movq $0, %%rax\n", q->idx, ++counter);
	printf("L%d_%d: jmp L%d_%d\n", q->idx, ++counter, q->idx, counter + 3);
	printf("L%d_%d: movq $1, %%rax\n", q->idx, ++counter);
	
	printf("L%d_%d: mov %%rax, %s\n", q->idx, ++counter, GetVal(q->dst));
	
}//EmitNE



void EmitIf (struct quadtab* q) {
	int counter = 0;
	if ((q->src1->sType == globalvar) || (q->src1->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	} else {
		printf("L%d_%d: movq %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	}
	

	printf("L%d_%d: cmp $0, %%rax\n", q->idx, ++counter);
	printf("L%d_%d: jne %s\n", q->idx, ++counter, GetVal(q->dst));
	
	
	
	
}//EmitIf

void EmitIfFalse (struct quadtab* q) {
	int counter = 0;
	if ((q->src1->sType == globalvar) || (q->src1->sType == vartmp)) {
		printf("L%d_%d: mov %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	} else {
		printf("L%d_%d: movq %s, %%rax\n", q->idx, ++counter, GetVal(q->src1));
	}
	

	printf("L%d_%d: cmp $0, %%rax\n", q->idx, ++counter);
	printf("L%d_%d: je %s\n", q->idx, ++counter, GetVal(q->dst));
	
	
	
	
}//EmitIfFalse

void EmitGoto (struct quadtab* q) {
	int counter = 0;
	printf("L%d_%d: jmp %s\n", q->idx, ++counter, GetVal(q->dst));
}//EmitJmp

void EmitX86Code () {

	EmitGlobals();

	//skip quads until first function
	struct quadtab* fq = NULL; //remembers which function is being processed
	struct quadtab* q = quads; //iterates over quadruples
	while((q!=NULL) && (strcmp(q->opcode, "function") != 0)) q = q->next;
	
	
	
	while (q != NULL)
	{
		printf("\n#");
		PrintQuad(q);
		printf("\n");
		if (strcmp(q->opcode, "function") == 0) { fq = q; EmitFunction(q); }
		else if (strcmp(q->opcode, "ret") == 0) { EmitRet(q, fq); }
		else if (strcmp(q->opcode, "param") == 0) { HandleParams(&q); }
		else if (strcmp(q->opcode, "call") == 0) { EmitCall(q); }
		else if (strcmp(q->opcode, "=") == 0) { EmitAssign(q); }
		else if (strcmp(q->opcode, "+") == 0) { EmitAdd(q); }
		else if (strcmp(q->opcode, "-") == 0) { EmitSub(q); }
		else if (strcmp(q->opcode, "*") == 0) { EmitMul(q); }
		else if (strcmp(q->opcode, "/") == 0) { EmitDiv(q); }
		else if (strcmp(q->opcode, "[]") == 0) { EmitDeref(q); }
		else if (strcmp(q->opcode, "<") == 0) { EmitLT(q); }
		else if (strcmp(q->opcode, ">") == 0) { EmitGT(q); }
		else if (strcmp(q->opcode, "<=") == 0) { EmitLE(q); }
		else if (strcmp(q->opcode, ">=") == 0) { EmitGE(q); }
		else if (strcmp(q->opcode, "==") == 0) { EmitEQ(q); }
		else if (strcmp(q->opcode, "!=") == 0) { EmitNE(q); }
		else if (strcmp(q->opcode, "if") == 0) { EmitIf(q); }
		else if (strcmp(q->opcode, "ifFalse") == 0) { EmitIfFalse(q); }
		else if (strcmp(q->opcode, "goto") == 0) { EmitGoto(q); }

		q = q->next;
	}

	printf("%s\n", strings);
}//EmitX86Code


