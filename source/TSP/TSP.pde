// Kyle Lamoureux 7814562
// A Genetic Algorith to solve TSP:
// Story:
// Santa don did fucked up and missed some houses and hes runnning outa time, as the sun is about to rise
// Santa wants to know what would be a optimal path to get between the missed houses as fast as possible.
// Luckily for him he happens to have this alright genetic algorithm lieing around and he uses to it find the
// optimal path pretty quickly!


import java.util.*;

boolean runCases = true; //if this is true change testCase just below to the case you wanna test
//Change these variables to make there be a large effect on the way the algorithim runs
final int NUM_ITEMS = 20; // make santa have missed more houses
final float mutRate = .01; 
final float crossoverRate = .95;
final float keepBest = .25; //keep the best 10% of individuals in the population
int capGen = 300; //300 generations without change will stop the current run
final int POP_SIZE = 500; // must be a number where x%5 == 0 
        //30 items 2000
        //25 items 1000
        //20 items 500
  
float scaleMutationRate = .0001; //really small increased chance for mutation
float mutationRate = mutRate; // for reseting

//30 3500
//.01 for 40,30 with 5k pop
//pop = 1k for 25, 500 for 20

int[] testCase4 = {2,3,7,103,86,25,101,68,16,122,124,77,52,46,50,74,100,31,34,64,97,40,13,55,89,61,19,26,83,43};//30
int[] testCase1 = {2,7,8,14,56,81,41,43,47,5,54,22,24,72,80,90,33,69,26,29,88,92,104,119,64};// 25
int[] testCase2 = {2,3,7,103,86,25,101,68,16,122,124,77,52,46,50,74,100,31,34,64};// 20
int[] testCase3 = {2,7,8,14,56,81,41};// 7
//MAKE SURE YOU CHANGE NUM_ITEMS JUST ABOVE TO MATCH CASE SIZE
int[] testCase = testCase2;


// Variables for running the algorithm
int manyRuns = 5; // 5 runs b4 loop back 
boolean done = false; // check for loop back so we can stop code

//All house related variables
ArrayList<Item> inventory; // inventory of every house in the neighbourhood
int count = 0;
final int SPACING = 5;
float[][] distBtw; //distance between every single house in the inventory will be procomputed


Item[] list; // holds the items(Houses) we're trying to find
DNA bestPath; // just holds index's 0-list.length of the item list
float cheapestPath = 10000000;
DNA currBest; // currBest holds the populations best individual do this so you see some sort of progression

// Population list and list of best paths
ArrayList<DNA> population;
ArrayList<DNA> bestOf;

//some extra variables to keep track of misc things
final int POP_MOD = POP_SIZE/5;
int generation = 1;
int noChange = 0; // gens without change
int best = round(POP_SIZE*keepBest); // number of individuals that will be kept


void setup(){
  size(650, 850);
  
  inventory = new ArrayList<Item>();
  list = new Item[NUM_ITEMS];
  population = new ArrayList<DNA>(POP_SIZE);
  bestOf = new ArrayList<DNA>();
  
  initialize(); // move all the messy initialization below to make this top part cleaner
  normalizeFitness(); // normalize all the fitness's of the population for proboablistic selection below
  Collections.sort(population); // sort by fitness
  checkForImprovement(population); // check for improvements in path
  currBest = population.get(0); // set the currBest for display
  displayAll(currBest);
}


//*****************************************************************************************
// Most Definitely could have been split up into a couple different methods but just left it
// all in one. But it just runs the algorithm
//*****************************************************************************************
void draw(){
    
  if(noChange < capGen){ // if there hasn't been change for a while alter the algorithm
    if(generation% 50 == 0) // a scaling mutationRate so it doesn't get stuck in later generations
      mutationRate = Math.min(.025, mutationRate+=scaleMutationRate);
    newGeneration(population); // create a new pop
    normalizeFitness(); // normalize all the fitness's of the population
    Collections.sort(population); // sort it
    currBest = population.get(0); // set the curr best path of the population

    generation++;
    noChange++;
    checkForImprovement(population);
    displayAll(currBest);
  }
  else{// Hasn't been change for a while so algorithim has found its potential path so switch it up by reseting 
    bestOf.add(new DNA(bestPath.order, bestPath.fitness, bestPath.cost, bestPath.genNum)); // store the current best individual of the pop
    manyRuns--; // run the algorithim manyRuns on this problem set
    mutationRate = mutRate; // reset mutation rate
    if(manyRuns <= 0){// if you still have runs to go, go softreset()
      checkForImprovement(bestOf);
      displayAll(bestPath);
      if(done){ // if this is true means we've run the course of the algorithm
        println(bestOf.get(0).cost);
        stop();
      }
      else{ // IF the GA has run 5 times then set up its final run with a bunch of the best candidates from those runs
        for(DNA d : bestOf)//print off the best costs for knowledge/statistics
          println(d.cost);
        done = true;
        population.clear();
        //mutationRate = .01;
        // fill pop with the best candidates from the previous 5 runs so it can do 1 super run
        for(int i = 0; i < POP_MOD; i++){
          population.add(new DNA(bestOf.get(0).order, bestOf.get(0).fitness, bestOf.get(0).cost, 1));
          population.add(new DNA(bestOf.get(1).order, bestOf.get(1).fitness, bestOf.get(1).cost, 1));
          population.add(new DNA(bestOf.get(2).order, bestOf.get(2).fitness, bestOf.get(2).cost, 1));
          population.add(new DNA(bestOf.get(3).order, bestOf.get(3).fitness, bestOf.get(3).cost, 1));
          population.add(new DNA(bestOf.get(4).order, bestOf.get(4).fitness, bestOf.get(4).cost, 1));
        }
        //reset a bunch of variables
        bestOf.clear();
        normalizeFitness();
        Collections.sort(population);
        generation = 1;
        noChange = 0;
      }
    }
    else{
      softReset();
    }
    displayAll(bestPath);
  }
}



//*****************************************************************************************
// Search through the given ArrayList and see if there is an individual who has a better 
// pathcost then the current best pathCost if it does then reset the noChange count
//*****************************************************************************************
void checkForImprovement(ArrayList<DNA> useThis){//changes the bestPath
  for(DNA d : useThis){
     if(d.cost < bestPath.cost){
       bestPath = new DNA(d.order, d.fitness, d.cost, d.genNum);
       cheapestPath = d.cost;
       noChange = 0;
       //mutationRate = mutRate;
     }
  }
}


//*****************************************************************************************
// Normalize function sums up all the fitness's of the individuals in the population then
// it divides each of there fitness by the sum to normalize it to a percentage from 0-100(0.0 - 1.0)
//*****************************************************************************************
void normalizeFitness(){ // go read about
    double sum = 0;
    for(int i = 0; i < population.size(); i++){
      sum += population.get(i).getFitness();
    }
    for(int i = 0; i < population.size(); i++){
      population.get(i).normalizeFitness(sum);
    }
}


//*****************************************************************************************
// creating a new generation of individuals send down the old population to the selection 
// process. Then initialize the population then mutate those new individuals.
//*****************************************************************************************
void newGeneration(ArrayList<DNA> input){
  ArrayList<DNA> temp = selectionProbabilistic(input);
  population.clear();
  for(DNA d : temp)
    population.add(d);
  mutate();
}


//*****************************************************************************************
// Crossover part of the Gentic algorithm: it compares 2 DNA's ordering and keeps all the
// matching pieces it then puts te non matching pieces in a bag which is shuffled then
// thrown back into the array with the matcing pieces and that is the new order
//*****************************************************************************************
DNA crossoverMatch(DNA d1, DNA d2){
  int[] crossed = new int[d1.order.length];
  Stack<Integer> bag = new Stack<Integer>();
  for(int i = 0; i < crossed.length; i++){
    crossed[i] = -1; // initialize for later bag insertion
  }
  
  for(int i = 0; i < crossed.length; i++){ //check for matching index's
    if(d1.getIndex(i) == d2.getIndex(i)){//shit matches add it 2 the new array
      crossed[i] = d1.getIndex(i);
    }
    else{ // else add the numbers to the bag if they're not already in it
      if(!bag.contains(d1.getIndex(i)))
        bag.push(d1.getIndex(i));
      if(!bag.contains(d2.getIndex(i)))
        bag.push(d2.getIndex(i));
    }
  }
  //go through and fill in all the -1's with the shuffled bag of numbers
  Collections.shuffle(bag);
  for(int i = 0; i < crossed.length; i++)
    if(crossed[i] == -1)
      crossed[i] = bag.pop();
  
  return new DNA(crossed, pathCost(crossed), pathCost(crossed), generation); 
}


//*****************************************************************************************
// Mutation part all it does it go through each index of order and random's a number if that
// number is less than the mutation rate then it randoms a second index for that current index 
// to be swapped with
//*****************************************************************************************
void mutate(){
  for(DNA d : population){ // for each DNA in population
    for(int i = 0; i < d.order.length; i++){
      if(Math.random() < mutationRate){
        d.swapSpots(i);
        float x = pathCost(d.order); // calculate the new data of the DNA
        d.cost = x;
        d.calcFitness(x);
      }
    }
  }
}


//*****************************************************************************************
// Selection part of the Genetic algorithim. I combined a both proboablistic and elitism
// into a single method. This also calls the crossover function.
//*****************************************************************************************
ArrayList<DNA> selectionProbabilistic(ArrayList<DNA> nxt){
  ArrayList<DNA> newPop = new ArrayList<DNA>(nxt.size()); // put a size cap on the ArrayList
  for(int i = 0; i < best; i++)// Make sure the best number of individuals of the population will survive to spread genes
    newPop.add(nxt.get(i));
  for(int i = 0; i < nxt.size() - best; i++){
    DNA s1 = selectedByProb(nxt); // select 2 individals from the pop
    DNA s2 = selectedByProb(nxt);
    if(Math.random() < crossoverRate) // if the randomed number is < crossoverRate then do a crossover
      newPop.add(crossoverMatch(s1,s2)); // add the newly crossed over DNA
    else{
      if(s1.getFitness() < s2.getFitness()) // else you don't crossover add the highest fitness DNA to the population
        newPop.add(new DNA(s2.order, s2.fitness, s2.cost, s2.genNum));
      else
        newPop.add(new DNA(s1.order, s1.fitness, s1.cost, s1.genNum));
    }
  }
  return newPop;
}


//*****************************************************************************************
// Will randomize a number and keep suming up the normalized proboablities 
// until its bigger than the sum then it will return that a new DNA with that indexs data
//*****************************************************************************************
DNA selectedByProb(ArrayList<DNA> nxt){
  int index = 0;
  double randNum = Math.random();
  double sum = nxt.get(index).getFitnessN();// initial starting point
  while(sum <= randNum){ // loop till the sum proboablity is over the random'd amount
    index++;
    sum+= nxt.get(index).getFitnessN();
  }
  return new DNA(nxt.get(index).order, nxt.get(index).fitness, nxt.get(index).cost, nxt.get(index).genNum);
}






//*****************************************************************************************
// Usefull shortcuts to speed up output
// S: Stop the program early
// MouseClicked: randomize the list again with new individuals or a new starting spot with a test case
//*****************************************************************************************
void keyPressed(){
 if(key == 's')
   noChange = capGen;
   manyRuns = -1;
   done = true;
}
void mouseClicked(){
  for(Item i : list)
    i.deactivate();
  randomizeList();
  cheapestPath = 1000000;
  for(Item i : list)
    i.activate();   
  population.clear();
  generation = 1;
  noChange = 0;
  setupPop();
  normalizeFitness();
  bestOf = new ArrayList<DNA>();
}


//*****************************************************************************************
// Soft reset the world so you keep lots of the data but reset the algorithim part for repetition
//*****************************************************************************************
void softReset(){
  cheapestPath = 1000000;
  population.clear();
  bestPath = null;
  generation = 1;
  noChange = 0;
  setupPop();
  normalizeFitness();
}


//*****************************************************************************************
// Display thew world. All the houses, and paths between houses
//*****************************************************************************************
void displayAll(DNA curr){
  background(255);
  strokeWeight(1);
  for(Item i : inventory){
    i.display();
  }
  
  strokeWeight(2);
  for(int j = 0; j < curr.order.length - 1; j++){
      drawArrow(list[curr.getIndex(j + 0)].locale.x, list[curr.getIndex(j + 0)].locale.y, 
           list[curr.getIndex(j + 1)].locale.x, list[curr.getIndex(j + 1)].locale.y);
  }
  // Display useful information. curr.cost rounded because extra decimals don't matter for display purposes
  textSize(32);
  text("Cheapest Path: " + (int)curr.cost + " Gen:" + generation, 0  , height - 5);
  
}




//*****************************************************************************************
// depending on if you're running a test case or not the list will be changed accordingly
//*****************************************************************************************
void randomizeList(){
  if(!runCases){
    ArrayList<Item> temp = new ArrayList<Item>(); // use this for the contains function
    list = new Item[NUM_ITEMS];
    for(int i = 0; i < list.length; i++){
      Item rdm = inventory.get((int)random(inventory.size())); // randomly select an item from inventory
      if(!temp.contains(rdm)){ // make sure its not a dupe if it is try randoming again
        temp.add(rdm);
        list[i] = rdm;
      }
      else{
        i--;
      }
    }
  }
  else{
    for(int i = 0; i < testCase.length; i++){
      list[i] = inventory.get(testCase[i]); // Currrent test case change able above just resets the list
    }
  }
} 


//*****************************************************************************************
// Sums up the total path cost of a given integer array
//*****************************************************************************************
float pathCost(int[] input){
  float pathDist = 0;
  for(int i = 0; i < input.length - 1; i++){
     int id1 = list[input[i + 0]].id; // gets the id from list
     int id2 = list[input[i + 1]].id;
     pathDist+= distBtw[id1][id2]; // goes to that array index for summing 
  }
  return pathDist;
}


//*****************************************************************************************
// Given an Integer array it will shuffle the order pretty inefficently but gets the job done
// Makes use of the collections shuffle function
//*****************************************************************************************
int[] shuffleArray(int[] a){
  int[] result = new int[a.length];
  ArrayList<Integer> list = new ArrayList<Integer>();
  // Transfer order array to a list so we can use the Collections.shuffle function
  for(int i : a){ 
    list.add(i);
  }
  Collections.shuffle(list);
  for(int i = 0; i < list.size(); i++) // transfer it all back
    result[i] = list.get(i);
  return result;
}


//*****************************************************************************************
// Initializes the state of the algorithm and all its pieces
//*****************************************************************************************
void initialize(){
  // set up inventory
  // add a bunch of houses that can be traveled to
  for(int i = 0; i < height/43; i++){
    inventory.add(new Item(count++, 36, 36 + 36*i + SPACING*i));
  }
  for(int i = 0; i < height/43; i++){
    inventory.add(new Item(count++, width-36, 36 + 36*i + SPACING*i));
  }
  for(int i = 0; i < width/50; i++){
    inventory.add(new Item(count++, 72 + 36*i + SPACING*(i+1), 36));
  }
  for(int i = 0; i < height/54; i++){
    for(int j = 0; j < width/130; j++){
      inventory.add(new Item(count++, 36 + 72 + (36*j) +(72*j), 108 + 36*i + SPACING*i));
    }
  }
  
  //fill distance calcualtions
  distBtw = new float[inventory.size()][inventory.size()];
  for(int i = 0; i < distBtw.length; i++){
    for(int j = 0; j < distBtw[0].length; j++){
      PVector t1 = inventory.get(i).locale;
      PVector t2 = inventory.get(j).locale;
      // Euclidean distance bit slow to run but whatever still goes pretty fast
      distBtw[i][j] =  (float)Math.sqrt(Math.pow((t1.x - t2.x),2) + Math.pow((t1.y - t2.y),2));    
    }
  }
  
  //initialize List and pop
  randomizeList();
  setupPop();
  //activate all the selected houses so you can see the targets
  for(Item i : list)
    i.activate();
}



//*****************************************************************************************
// Initializes the population
//*****************************************************************************************
void setupPop(){
  float pthCost = 0;
  int[] tmpArray = new int[list.length];
  
  for(int i = 0; i < NUM_ITEMS; i++)//initialize the array with the index's of the item array not the actual ID's
    tmpArray[i] = i;
  for(int i = 0; i < POP_SIZE; i++){
    tmpArray = shuffleArray(tmpArray); // shuffle the ordering of the array
    pthCost = pathCost(tmpArray); // calculate the path's cost
    population.add(new DNA(tmpArray, pthCost, pthCost, generation)); // add it to the population
    if(pthCost < cheapestPath){ // check if it's the current best path 
      bestPath = new DNA(population.get(i).order, population.get(i).fitness, population.get(i).cost, population.get(i).genNum);
      cheapestPath = pthCost;
    }
  }
}


//*****************************************************************************************
// Draws an arrow instead of a line so you can see the direction its drawn
// https://gist.github.com/ketakahashi/81b7f22b4ecee1fa5d84393ab670ef99
//*****************************************************************************************
void drawArrow(float x1, float y1, float x2, float y2) {
  float a = dist(x1, y1, x2, y2) / 50;
  pushMatrix();
  translate(x2, y2);
  rotate(atan2(y2 - y1, x2 - x1));
  triangle(- a * 2 , - a, 0, 0, - a * 2, a);
  popMatrix();
  line(x1, y1, x2, y2);  
}
















//going to take the best 50% of the population and just double them to populate the new population
/*ArrayList<DNA> selection1Elitism(ArrayList<DNA> nxt){
  ArrayList<DNA> newPop = new ArrayList<DNA>(nxt.size()); // put a size cap on the ArrayList
  for(int i = 0; i < nxt.size()/2; i++){
    newPop.add(new DNA(nxt.get(i).order, nxt.get(i).fitness, nxt.get(i).cost, nxt.get(i).genNum));
    newPop.add(new DNA(nxt.get(i).order, nxt.get(i).fitness, nxt.get(i).cost, nxt.get(i).genNum));
  }
  return newPop;
}*/
