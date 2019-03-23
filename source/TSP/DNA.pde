import java.util.Comparator;

class DNA implements Comparable<DNA>{
  
  int[] order;
  double fitnessN;
  double fitness;
  float cost;
  int genNum;
 
  DNA(int[] o, double f, float cost, int gen){
   order = new int[o.length];
   for(int i =0; i < o.length; i++)
     order[i] = o[i];
   fitness = calcFitness(f);
   this.cost = cost;
   genNum = gen;
  }
  
  // invert the cost of the path to make small numbers big and big numbers small
  double calcFitness(double f){return 1/(f+1);}
  
  // we're doing this because we want the the sum of all fitness's to add up to 100%
  // used for picking them becuase we dont want an arbitry value but we want a probability
  void normalizeFitness(double sum){fitnessN = (this.fitness)/(sum);}
  
  int getIndex(int i){return order[i];}
  double getFitness(){return fitness;}
  double getFitnessN(){return fitnessN;}
  void swapSpots(int i){
    int j = (int)random(order.length);
    int temp = order[i];
    order[i] = order[j]; 
    order[j] = temp;
  }
  
  DNA cpy(){
    return new DNA(this.order, this.fitness, this.cost, this.genNum); 
  }
  public int compareTo(DNA compDNA){
    return (int)this.cost - (int)compDNA.cost;
  }

  
    //@Override
    //int compareTo(DNA comparestu) {
    //    float compareage=((DNA)comparestu).rF();
        /* For Ascending order*/
   //     return 0;//this.rF()-compareage;

        /* For Descending order do like this */
        //return compareage-this.studentage;
   // }
    

 
}
