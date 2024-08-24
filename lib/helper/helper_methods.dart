bool isWhite(index){
     int x = index ~/ 8;// this give us the integer division ie row
     int y = index % 8;// this give us the integer division  ie column

     bool isWhite = ( x + y ) % 2 == 0;    

     return isWhite; 
}

bool isInBoard(int row , int col){
  return row >= 0 && row < 8 && col >= 0 && col < 8 ;
}