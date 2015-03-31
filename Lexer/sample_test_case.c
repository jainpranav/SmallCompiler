int life_universe_and_everything(int n){
	if(n<43){
		ans = n;
	}
	else{
		ans = life_universe_and_everything(n-1);
	}
}
