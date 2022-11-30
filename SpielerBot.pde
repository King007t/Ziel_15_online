public class BotSpieler extends Spieler {
  
  // --- Konstruktoren ---

  public BotSpieler(String name) {
    super(name);
  }

  // Algorithmus, um effizient in der Nähe von 15, oder auf 15 zu landen.
  public int pruefe() {
    meldeDialog("Der Computer hat eine " + aktWurf + " gewuerfelt.");
    int diff = 15 - aktStand;
    int med = round(diff/ (6 - anzGewertet));
    if (anzGewertet == 5 && aktWurf == med) {
      meldeDialog("gewertet");
      return 1;
    } else if (aktWurf <= med && anzGewertet != 5) {
      meldeDialog("gewertet");
      return 1;
    } else {
      meldeDialog("nicht gewertet");
      return 2;
    }
  }
}
