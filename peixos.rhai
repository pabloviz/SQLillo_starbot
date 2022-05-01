
let play_dumb=0;


if play_dumb==1{
for w in 0..8 {
    let r = (rand() % 4).abs();
    switch r {
        0 => worker(w).move_up(),
        1 => worker(w).move_down(),
        2 => worker(w).move_right(),
        3 => worker(w).move_left(),
    }
    
    info(`worker ${w} finished`);
}

}else{



let chaos=450;
let tiles=40;
let extra=1;


if "first" in memory == false{
	memory.ticks = 0;
	memory.first = 1;
	memory.start_x=worker(0).x;
	memory.start_y=worker(0).y;
	memory.group=[0, 1, 0, 1, 0, 1, 0, 1];
	memory.previous_x = [-1, -2, -3, -4, -5, -6, -7, -8];
	memory.previous_y = [-1, -2, -3, -4, -5, -6, -7, -8];

	if memory.start_x > 25 && memory.start_y > 25 {
		memory.even_limits=[tiles/2-extra, tiles, tiles/2, tiles];
		memory.odd_limits=[tiles/2-extra, tiles, 0, tiles/2];
		memory.quadrant=0;
	}else if memory.start_x > 25 && memory.start_y < 25 {
		memory.even_limits=[tiles/2-extra, tiles, tiles/2, tiles];
		memory.odd_limits=[tiles/2-extra, tiles, 0, tiles/2];
		memory.quadrant=1;
	}else if memory.start_x < 25 && memory.start_y > 25 {
		memory.even_limits=[0, tiles/2+extra, tiles/2, tiles];
		memory.odd_limits=[0, tiles/2+extra, 0, tiles/2];
		memory.quadrant=2;
	}else{
		memory.even_limits=[0, tiles/2+extra, tiles/2, tiles];
		memory.odd_limits=[0, tiles/2+extra, 0, tiles/2];
		memory.quadrant=3;
	}	
	memory.slash_y=[0,0,0,0,0,0,0,0];
	memory.slash_x=[0,0,0,0,0,0,0,0];

	info(`even ${memory.even_limits[0]} ${memory.even_limits[1]} ${memory.even_limits[2]} ${memory.even_limits[3]}`); 
	info(`odd ${memory.odd_limits[0]} ${memory.odd_limits[1]} ${memory.odd_limits[2]} ${memory.odd_limits[3]}`); 
}



let next_x = [-1, -2, -3, -4, -5, -6, -7, -8];
let next_y = [-1, -2, -3, -4, -5, -6, -7, -8];

let objectives_x = [-1, -2, -3, -4, -5, -6 , -7, -8];
let objectives_y = [-1, -2, -3, -4, -5, -6 , -7, -8];

//score surround
memory.ticks += 1;
if memory.ticks % 500 == 0{
	for i in 1..8{
		if memory.group[i]==0 {memory.group[i]=1;}
		else {memory.group[i]=0;}
	}
}

for w in 0..8 {
	let w_x = worker(w).x;
	let w_y = worker(w).y;
		

	let decision = (rand() % 4).abs();	
	if memory.previous_x[w] != w_x || memory.previous_y[w] != w_y{ //is not stuck

	memory.previous_x[w] = w_x;
	memory.previous_y[w] = w_y;
	let color = worker(w).color;
	
	//study surroundings, get an objective
	if memory.ticks == chaos && w != 0{
		if w/4==0 { //horizontal slasher 0 1 2 3
			let position = (w%4)+1; // 1 2 3 4
			memory.slash_y[w]=(tiles/5)*(position);
			if (tiles-w_x).abs() > (0-w_x).abs(){ //go right
				memory.slash_x[w] = tiles-1;
			}else{ 					//go left
				memory.slash_x[w] = 0; 
			}
		}else{ //vertical slasher: 4 5 6 7
			let position = (w-4)/2 + 1; //0 0 1 1
			memory.slash_x[w]=(tiles/3)*position;
			if (tiles-w_y).abs() > (0-w_y).abs(){ //go up
				memory.slash_y[w] = tiles-1;
			}else{ 					//go down
				memory.slash_y[w] = 0; 
			}
		}
	}
	if memory.ticks >= chaos && w != 0{
		//info(`${w} ${memory.slash_x[w]} ${memory.slash_y[w]}`);
		//up down right left
		if memory.slash_y[w] == w_y && memory.slash_x[w] == w_x{ //if arrived
			if w_x==0{
				memory.slash_x[w]=tiles-1;
			}else if w_x==tiles-1{
				memory.slash_x[w]=0;
			}else if w_y==0{
				memory.slash_y[w]=tiles-1;
			}else if w_y==tiles-1{
				memory.slash_y[w]=0;
			}
		}

		let hor=0;
		if memory.slash_y[w] == w_y{
			hor=1;
		}else if memory.slash_x[w] == w_x{
			hor=0;
		}else{
			hor = rand()%2;
		}
		if hor==1{
			if memory.slash_x[w] > w_x {decision=2;}
			else {decision=3;}
		}else{
			if memory.slash_y[w] > w_y {decision=0;}
			else {decision=1;}
		}
	}else{

	let objective_score = -1000;
	let depth = 20;
	let lim=[w_x-depth, w_x+depth, w_y-depth, w_y+depth];

	if w == 0{ //frontier reforcer
		if lim[0] < memory.even_limits[0] {lim[0] = memory.even_limits[0];}
		if lim[1] > memory.even_limits[1] {lim[1] = memory.even_limits[1];}
		if lim[2] < 17 {lim[2] = 17;}
		if lim[3] > 23 {lim[3] = 23;}		
	}else{
		if memory.group[w] == 0{
			if lim[0] < memory.even_limits[0] {lim[0] = memory.even_limits[0];}
			if lim[1] > memory.even_limits[1] {lim[1] = memory.even_limits[1];}
			if lim[2] < memory.even_limits[2] {lim[2] = memory.even_limits[2];}
			if lim[3] > memory.even_limits[3] {lim[3] = memory.even_limits[3];}
		}else{
			if lim[0] < memory.odd_limits[0] {lim[0] = memory.odd_limits[0];}
			if lim[1] > memory.odd_limits[1] {lim[1] = memory.odd_limits[1];}
			if lim[2] < memory.odd_limits[2] {lim[2] = memory.odd_limits[2];}
			if lim[3] > memory.odd_limits[3] {lim[3] = memory.odd_limits[3];}
		}
	}

	let out_of_zone = 1;
	let out_of_options = 1;
	for x in lim[0]..lim[1]{
		for y in lim[2]..lim[3]{ 
			if x!=w_x || y!=w_y{
			out_of_zone = 0;
			let temptative_score = 0;
			if map[x][y] == Tile::EMPTY{
				temptative_score = 30;
				out_of_options = 0;
			}else if map[x][y] != color{
				let isworker=0;
				for worker in map.workers{
					if worker.x == x && worker.y == y{
						isworker=1;
					}
				}
				if isworker==0 {
				temptative_score = 30;
				}
				out_of_options = 0;
/*
			}else{
				//distance to closest friendly neighbor
				let min_dist=100;
				for i in 0..8{
					let dist_x = (worker(i).x - x).abs();
					let dist_y = (worker(i).y - y).abs();
					//let totdist = (dist_x*dist_x + dist_y*dist_y);
					let totdist = (dist_x + dist_y);
					if totdist < min_dist{
						min_dist = totdist; 
					}
				}
				temptative_score += min_dist;
*/
			}

			let distance_x = (x - w_x).abs();
			let distance_y = (y - w_y).abs();
			//let totdist = (distance_x*distance_x + distance_y*distance_y);
			let totdist = (distance_x + distance_y);
			temptative_score -= (totdist*3)/2; //far away points are worse...but maybe not so much?

			//dont repeat objectives!!!!
			for i in 0..w{
				if objectives_x[i] == x && objectives_y[i] == y {temptative_score-=15;}
			}


			//if we have land next to objective, add points
			let cool_neigh=0;
			if map[x][y] != color{
			for x2 in x-1..x+2{
				for y2 in y-1..y+2{
					if x2 >= lim[0] && x2 < lim[1] && y2 >= lim[2] && y2 < lim[3] && (rand()%3)==0{
						if map[x2][y2] == color{
							cool_neigh+=1;
						}
					}
				}
			}
			temptative_score+=cool_neigh*1;
			}


			if temptative_score > objective_score{
				objective_score = temptative_score;
				objectives_x[w] = x;
				objectives_y[w] = y;
			}
			}
		}
	}
	if out_of_zone == 1{
		objectives_x[w] = w_x;
		if w==0{
			objectives_y[w] = tiles/2;
		}else if memory.group[w] == 0 { //even
			objectives_y[w] = tiles;
		}else{
			objectives_y[w] = 0;
		} 
/*
	}else if out_of_options == 1{
		objectives_x[w] = tiles/2; //w_x;
		objectives_y[w] = w_y;
*/
	}

	//if all objective are ours

	//try moving towards objective

	let temptative_x = [w_x  , w_x  , w_x+1, w_x-1];
	let temptative_y = [w_y+1, w_y-1, w_y  , w_y  ];
	let scores = [0,0,0,0];
	let dir = [0,1,2,3];
	
	//assign scores
	for i in 0..4{
		let candidate_x = temptative_x[i];
		let candidate_y = temptative_y[i];
		if candidate_x < tiles & candidate_y < tiles & candidate_x >= 0 & candidate_y >= 0{
			if map[candidate_x][candidate_y] == Tile::EMPTY{
				scores[i] = 1;
			}else if map[candidate_x][candidate_y] != color{
				scores[i] = 2;
			}

			//avoid collision with your team
			for index in 0..w{
				if next_x[index] == candidate_x && next_y[index] == candidate_y {scores[i]=-1000;}
				//if you go to a location dir you have a worker and he goes to you, bad option, you are older so bad luck
				if memory.previous_x[index] == candidate_x && memory.previous_y[index] == candidate_y && 
					next_x[index] == w_x && next_y[index] == w_y {scores[i]=-1000;}
			}
			//avoid collision with enemies
			for worker in map.workers{
				if worker.color != color{
					if worker.x == candidate_x && worker.y == candidate_y {
						scores[i]=-1000;
//						info(` w ${w} avoiding collision on ${w_x} ${w_y} going ${candidate_x} ${candidate_y}`);
					}
				}
			}

			let distance_x = (candidate_x - objectives_x[w]).abs();
			let distance_y = (candidate_y - objectives_y[w]).abs();
			//let totdist = (distance_x*distance_x + distance_y*distance_y);
			let totdist = (distance_x + distance_y);
			scores[i] -= totdist;
/*
			if w > 0{
				let distance_x = (candidate_x - next_x[0]).abs();
				let distance_y = (candidate_y - next_y[0]).abs();
				if distance_x+distance_y > 10{
					scores[i] -= (distance_x+distance_y);
				}
			}
*/


		}else{
			scores[i]=-1000;
			//info (`${w} scores ${i} = ${scores[i]}, dir=${dir[i]} NULL`);
		}
	}

	let start=(rand() % 4).abs();	
	let max = -1000;
	for i in 0..4{
		let score=scores[start];
		if score > max {
			max = score;
			decision = dir[start];
		}
		start = (start+1)%4;
	}
//	info(`${w} decision = ${decision} score=${max}`);

	}
	}else{
		info(`stuck`);
	}
	if decision == 0{
	   worker(w).move_up();
	   next_x[w]=w_x;
	   next_y[w]=w_y+1;
	}else if decision == 1{
	   worker(w).move_down();
	   next_x[w]=w_x;
	   next_y[w]=w_y-1;
	}else if decision == 2{
	   worker(w).move_right();
	   next_x[w]=w_x+1;
	   next_y[w]=w_y;
	}else if decision == 3{
	   worker(w).move_left();
	   next_x[w]=w_x-1;
	   next_y[w]=w_y;
	}

}
}
