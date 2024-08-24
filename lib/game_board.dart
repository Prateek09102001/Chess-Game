import 'package:chess/components/dead_piece.dart';
import 'package:chess/components/piece.dart';
import 'package:chess/components/square.dart';
import 'package:chess/helper/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'values/colors.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => initialized();
}

class initialized extends State<GameBoard> {

  //2-D  list represent a chess board
  //with each position possibly contains the chess board
  late List<List<ChessPiece?>> board;

  // The currently selected piece on the chess board
  // with each position contains of a chess board
  ChessPiece ? selectedPiece;

  //The row index of the selected piece
  //DefaultValue -1 indicated no piece is currently selected 
  int selectedRow = -1;

  //The col index of the selected piece
  //DefaultValue -1 indicated no piece is currently selected 
  int selectedCol = -1;

  //A list of valid move for the currently selected piece
  //each move as a list represent as a list with 2 element :  row and col
  List<List<int>> validMove = [] ; 

  //A list of white piece that have been taken by black player
  List<ChessPiece> whitePieceTaken = []; 

  //A list of black piece that have been taken by white player
  List<ChessPiece> blackPieceTaken = []; 

  // A boolean is indite whose turn in it
  bool isWhiteTurn = true;

  //initial position of king
  List<int> whiteKingPosition = [7,4];
  List<int> blackKingPosition = [0,4];
  bool checkStatus = false ;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  //INITIALIZE BOARD
  void _initializeBoard() {
    //initialize the board with nulls, it means no pieces in those position

    List<List<ChessPiece?>> newBoard = 
    List.generate(
      8, (index) => List.generate(
        8, (index) => null)
    );
    
    //place pawn
    for(int i=0 ; i < 8 ; i++){
      newBoard[1][i] = ChessPiece(
       type: ChessPieceType.pawn,
       isWhite: false,
       imagePath: 'lib/images/pawn.png');

      newBoard[6][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: true, 
        imagePath: 'lib/images/pawn.png') ;
    }

    //place rook
      newBoard[0][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false, 
        imagePath: 'lib/images/rook.png'
      );
      newBoard[0][7] = ChessPiece(
        type: ChessPieceType.rook, 
        isWhite: false, 
        imagePath: 'lib/images/rook.png'
      );
      newBoard[7][0] = ChessPiece(
        type: ChessPieceType.rook, 
        isWhite: true, 
        imagePath: 'lib/images/rook.png'
      );
      newBoard[7][7] = ChessPiece(
        type: ChessPieceType.rook, 
        isWhite: true, 
        imagePath: 'lib/images/rook.png'
      );

    //place knight
    newBoard[0][1] = ChessPiece(
      type: ChessPieceType.knight, 
      isWhite: false, 
      imagePath: 'lib/images/knight.png'
    );
    newBoard[0][6] = ChessPiece(
      type: ChessPieceType.knight, 
      isWhite: false, 
      imagePath: 'lib/images/knight.png'
    );
    newBoard[7][1] = ChessPiece(
      type: ChessPieceType.knight, 
      isWhite: true, 
      imagePath: 'lib/images/knight.png'
    );
    newBoard[7][6] = ChessPiece(
      type: ChessPieceType.knight, 
      isWhite: true, 
      imagePath: 'lib/images/knight.png'
    );

    //place bishop
    newBoard[0][2] = ChessPiece(
      type: ChessPieceType.bishop, 
      isWhite: false, 
      imagePath: 'lib/images/bishop.png'
    );
    newBoard[0][5] = ChessPiece(
      type: ChessPieceType.bishop, 
      isWhite: false, 
      imagePath: 'lib/images/bishop.png'
    );
    newBoard[7][2] = ChessPiece(
      type: ChessPieceType.bishop, 
      isWhite: true, 
      imagePath: 'lib/images/bishop.png'
    );
    newBoard[7][5] = ChessPiece(
      type: ChessPieceType.bishop, 
      isWhite: true, 
      imagePath: 'lib/images/bishop.png'
    );

    //place queen
    newBoard[0][3] = ChessPiece(
      type: ChessPieceType.queen, 
      isWhite: false, 
      imagePath: 'lib/images/queen.png'
    );
    newBoard[7][3] = ChessPiece(
      type: ChessPieceType.queen, 
      isWhite: true, 
      imagePath: 'lib/images/queen.png'
    );


    //place king 
    newBoard[0][4] = ChessPiece(
      type: ChessPieceType.king, 
      isWhite: false, 
      imagePath: 'lib/images/king.png'
    );
    newBoard[7][4] = ChessPiece(
      type: ChessPieceType.king, 
      isWhite: true, 
      imagePath: 'lib/images/king.png'
    );

    board = newBoard;
  }

  //USER Selected a piece
  void pieceSelect(int row , int col){
    setState(() {
      //No piece selected yet , this is the first piece
      if(selectedPiece == null && board[row][col] != null){
        if(board[row][col]!.isWhite == isWhiteTurn){
          selectedPiece = board[row][col] ;
          selectedRow = row ;
          selectedCol = col ;
        }
        
      }
      //There is a piece already selected , but user can selected another one of their piece .
      else if(board[row][col] != null &&
       board[row][col]!.isWhite == selectedPiece!.isWhite ){
          selectedPiece = board[row][col] ;
          selectedRow = row ;
          selectedCol = col ;
       }
      //if there is a piece selected and user taps on a square that is a valid move , move there
      else if(selectedPiece != null 
      && validMove.any((element) => element[0] == row && element[1] == col)){
        movePiece(row, col);
      }
      //if a piece is selected so calculate a valid Move
      validMove = calculateRealValidMove( selectedRow , selectedCol , selectedPiece ,true );
    });
  }

  //calculate Row Valid move
  List<List<int>>? calculateRowValidMove(int row , int col , ChessPiece? piece){
    List<List<int>> candidateMove = [];

    if(piece == null) {
      return [] ;
    }
    //different directions based on their colors
    int directions = piece.isWhite ? -1 : 1 ;

    switch (piece.type) {
      case ChessPieceType.pawn:
        //pawn can move forward if the square is not occupied
        if(isInBoard(row+directions, col) &&
        board[row+directions][col] == null){
          candidateMove.add([row+directions , col]);
        }
        //pawn can be 2 move square forward if they are at their initial position
        if((row==1 && !piece.isWhite) || (row==6 && piece.isWhite)){
          if(isInBoard(row + 2*directions, col) && 
            board[row + 2*directions][col]==null &&
            board[row + directions][col] == null){
              candidateMove.add([row + 2*directions , col]);
          }
        }
        
        //pawn can kill diagonally
        if(isInBoard(row + directions , col - 1) && 
        board[row + directions][col-1] != null  &&
        board[row + directions][col - 1]!.isWhite != piece.isWhite){
          candidateMove.add([row + directions , col -1]);
        }
        if(isInBoard(row + directions , col + 1) && 
        board[row + directions][col+1] != null  &&
        board[row + directions][col + 1]!.isWhite != piece.isWhite){
          candidateMove.add([row + directions , col + 1]);
        }
        break;

      case ChessPieceType.rook:
        //horizontal and vertical directions
        var directions = [
          [-1,0],//up
          [1,0],//down
          [0,-1],//left
          [0,1]//right
        ];

        for(var direction in directions){
          var i = 1;
          while(true){
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if(!isInBoard(newRow, newCol)){
              break ;
            }
            if(board[newRow][newCol] != null){
              if(board[newRow][newCol]!.isWhite != piece.isWhite){
                candidateMove.add([newRow , newCol]); // kill
              }
              break;//blocked
            }
            candidateMove.add([newRow , newCol]);
            i++;
          }
        }
        break;  

      case ChessPieceType.knight:
        //all 8 possible L shape the knight can be move
        var knightMove = [
          [-2,-1], //up 2 left 1
          [-2,1], //up 2 right 1
          [-1,-2], // up 1 left 2
          [-1,2], // up 1 right 2
          [1,-2], //down 1 left 2
          [1,2], // down 1 right 2
          [2,-1], //down 2 left 1
          [2,1] //down 2 right 1
          ];

          for(var move in knightMove){
            var newRow = row + move[0] ;
            var newCol = col + move[1];

            if(!isInBoard(newRow , newCol)){
              continue ;
            }

            if(board[newRow][newCol] != null){
              if(board[newRow][newCol]!.isWhite != piece.isWhite){
                candidateMove.add([newRow , newCol]); // kill
              }
              continue ; //blocked
            }
            candidateMove.add([newRow , newCol]);
          }
        break;

      case ChessPieceType.bishop:
         var directions = [
          [-1,-1], //up left
          [-1,1], //up right
          [1,-1], //down left 
          [1,1]  //down right
        ];

        for(var direction in directions){
          var i = 1;
          while(true){
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if(!isInBoard(newRow, newCol)){
              break ;
            }
            if(board[newRow][newCol] != null){
              if(board[newRow][newCol]!.isWhite != piece.isWhite){
                candidateMove.add([newRow , newCol]); // kill
              }
              break;//blocked
            }
            candidateMove.add([newRow , newCol]);//valid move
            i++;
          }
        }
        break;

      case ChessPieceType.queen:
        //all 8 direction up , down , left , right and 4 diagonal
        var directions = [
          [-1,0], //up
          [1,0], //down
          [0,-1], //left
          [0,1], //right
          [-1,-1], //up left
          [-1,1], //up right
          [1,-1], //down left 
          [1,1]  //down right
        ];

        for(var direction in directions){
          
          var i = 1;
          while(true){
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if(!isInBoard(newRow, newCol)){
              break ;
            }
            if(board[newRow][newCol] != null){
              if(board[newRow][newCol]!.isWhite != piece.isWhite){
                candidateMove.add([newRow , newCol]); // kill
              }
              break;//blocked
            }
            candidateMove.add([newRow , newCol]);
            i++;
          }
        }
        break;

      case ChessPieceType.king:
      //all 8 direction up , down , left , right and 4 diagonal
        var directions = [
          [-1,0], //up
          [1,0], //down
          [0,-1], //left
          [0,1], //right
          [-1,-1], //up left
          [-1,1], //up right
          [1,-1], //down left 
          [1,1]  //down right
        ];

        for(var direction in directions){
            var newRow = row + direction[0];
            var newCol = col + direction[1];
            if(!isInBoard(newRow, newCol)){
              continue ;
            }
            if(board[newRow][newCol] != null){
              if(board[newRow][newCol]!.isWhite != piece.isWhite){
                candidateMove.add([newRow , newCol]); // kill
              }
              continue ;//blocked
            }
            candidateMove.add([newRow , newCol]);
        }
        break;        
      default:
    }
    return candidateMove;
  }

  //Calculate Real valid move
  List<List<int>> calculateRealValidMove (int row, int col, ChessPiece? piece, bool checkSimulation){
    List<List<int>> realValidMove = [];
    List<List<int>>? candidateMove = calculateRowValidMove(row, col, piece);

    //after generating all candidate move , filter out any that would result is any check
    if(checkSimulation){
      for(var move in candidateMove!){
        int endRow = move[0];
        int endCol = move[1];
        //this will simulate the future move to see if it's safe 
        if(SimulatedMoveIsSafe(piece!, row , col , endRow , endCol)){
          realValidMove.add(move);
        }
      }
      
    }else{
      realValidMove = candidateMove!;
    }

    return realValidMove ;
  }
  
  //MOVE PIECE
  void movePiece(int newRow , int newCol){
    //If the new spot has an enemy piece
    if(board[newRow][newCol] != null){
      //add the capture piece to appropriate list
      var capturePiece = board[newRow][newCol] ;
      if(capturePiece!.isWhite){
        whitePieceTaken.add(capturePiece);
      }else{
        blackPieceTaken.add(capturePiece);
      }
    }
    //check if the piece being moved in a king
    if(selectedPiece!.type == ChessPieceType.king){
      //update the appropriate king value
      if(selectedPiece!.isWhite){
         whiteKingPosition = [newRow, newCol];
      }else{
        blackKingPosition = [newRow, newCol];
      }
    }
    //move the piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    //if any king are under attack
    if(isKingInCheck(!isWhiteTurn)){
      checkStatus = true;
    }else{
      checkStatus = false;
    }

    //clear selection
    setState(() {
      selectedPiece = null ;
      selectedRow = -1 ;
      selectedCol = -1;
      validMove = [] ;
    });

    //show if it's check mate 
    if (isCheckMate(!isWhiteTurn)) {
       showDialog(
       context: context,
       builder: (context) => AlertDialog(
          title: const Text("Check Mate!"),
          actions: [
          TextButton(
            onPressed: resetGame,
          child: const Text("Play Again"),
        ),
      ],
    ),
  );
}

    //change turn
    isWhiteTurn = !isWhiteTurn;
  }

  //IS King in check
  bool isKingInCheck(bool isWhiteKing){
    //get the position of king
    List<int> kingPosition =
           isWhiteKing ? whiteKingPosition : blackKingPosition ;
           
    //check if any enemy piece attack the king
    for(int i = 0 ; i < 8 ;i++){
      for(int j = 0 ;j < 8 ; j++){
        //skip empty squares and piece of the same colors as the king.
        if(board[i][j] == null || board[i][j]!.isWhite == isWhiteKing){
          continue ;
        } 

        List<List<int>>? pieceValidMoves = calculateRealValidMove(i, j, board[i][j],false);

        //check if the king position's is in this piece is valid move
        if(pieceValidMoves.any((move) => move[0] == kingPosition[0] && move[1] == kingPosition[1])){
          return true;
        }
      }
    } 

    return false;     
  }
  
  //simulate a future move to see if it is safe (Dose not put your Own king under attack!)
  bool SimulatedMoveIsSafe(ChessPiece piece, int startRow, int startCol, int endRow, int endCol){
    //save the current board state
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    //if the piece is king , save is current position and update to the new one
    List<int>? originalKingPosition ;
    if(piece.type == ChessPieceType.king){
      originalKingPosition = piece.isWhite ? whiteKingPosition : blackKingPosition ;

      //update king position 
      if(!piece.isWhite){
        whiteKingPosition = [endRow , endCol];
      }else{
        blackKingPosition = [endRow , endCol];
      }
    } 
    //simulate the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    //check if our own king is under attack
    bool kingIsInCheck = isKingInCheck(piece.isWhite);

    //restore board is original state
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    //if the piece is king restore it original position
    if (piece.type == ChessPieceType.king && originalKingPosition != null) {
    if (piece.isWhite) {
      whiteKingPosition = originalKingPosition;
    } else {
      blackKingPosition = originalKingPosition;
    }
  }

  //if is king in check = true means it is not a safe move = false
  return !kingIsInCheck;
  }

  //Is It check Mate?
  bool isCheckMate(bool isWhiteKing){
    //if the king is not in check , so it is not Check Mate
    if(!isKingInCheck(isWhiteKing)) {
      return false;
    }

    //if there is at least one legal move any of player piece's then not checkmate
    for(int i = 0 ; i < 8 ; i++){
      for(int j = 0 ; j < 8 ; j++){
        //skip empty square and piece of the other color
        if(board[i][j] == null || board[i][j]!.isWhite != isWhiteKing ){
          continue ;
        }

        List<List<int>> pieceValidMove = calculateRealValidMove(i, j, board[i][j] , true);

        //in this piece has any valid moves ,  then it's not check Mate
        if(pieceValidMove.isNotEmpty){
          return false;
        }
      }
    }
    //if none of above condition is met , them there are no legal moves left to move
    //it's check mate
    return true;
  }

  //Reset To new game
  void resetGame() {
      Navigator.pop(context);
      _initializeBoard();
      checkStatus = false;
      whitePieceTaken.clear();
      blackPieceTaken.clear();
      whiteKingPosition = [7, 4];
      blackKingPosition = [0, 4];
      isWhiteTurn = true;
      setState(() {
        // Any additional state changes if necessary
      });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        
        children: [
            // A dead white piece taken
            Expanded(
              child: GridView.builder(
                itemCount: whitePieceTaken.length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
                 itemBuilder: (context , index) => DeadPiece(
                  imagePath: whitePieceTaken[index].imagePath,
                  isWhite: true,))),

              //Game status
              Text(
                checkStatus ? "Check!":"",
              ),

        //Chess Board
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 8*8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context,index) {
                
                //get the row and column of these square 
                int row = index ~/ 8 ;
                int col = index % 8 ;
            
                //check if this square is selected or not
                bool isSelect = selectedRow==row && selectedCol ==col ;
            
                //if check the square is a valid move
                bool isValidMove = false;
                for(var position in validMove){
            
                  //check valid row and col
                  if(position[0] == row && position[1] == col){
                    isValidMove = true;
                  }
                }
                return Square(isWhite: isWhite(index),
                piece: board[row][col], 
                isSelect: isSelect, 
                isValidMove: isValidMove,
                onTap: () => pieceSelect(row,col),);
              }),
          ),
          // A dead Black piece taken
            Expanded(
              child: GridView.builder(
                itemCount: blackPieceTaken.length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
                 itemBuilder: (context , index) => DeadPiece(
                  imagePath: blackPieceTaken[index].imagePath,
                  isWhite: false,))),
        ],
      ),
    );
  }
}