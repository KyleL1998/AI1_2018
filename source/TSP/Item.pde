class Item{
 
  final int SIZE = 35;
  PVector locale;
  int id;
  boolean searching = false;
  

  Item(int name, float x, float y){
    locale = new PVector(x,y);
    this.id = name;
  }
  
  void activate(){
    searching = true;
  }
  void deactivate(){
    searching = false;
  }
  
  //Item clone(){
  //  return new Item(this.id, this.locale.x, this.locale.y);
  //}
  
  void display(){
    if(!searching)
      fill(185);
    else
      fill(0,255,0);
    ellipse(locale.x, locale.y, SIZE, SIZE);
    fill(0);
    textSize(12);
    if(id >= 0)
      text(id, locale.x -6, locale.y +6);
    else
      text("me", locale.x -8, locale.y +6);
    
  }
  
}
