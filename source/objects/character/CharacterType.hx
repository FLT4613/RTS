package objects.character;

enum CharacterType{
  Friend;
  Enemy(name:String);
  Neutral(name:String);
}